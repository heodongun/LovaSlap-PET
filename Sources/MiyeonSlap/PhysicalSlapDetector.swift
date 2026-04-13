import Foundation
import IOKit
import IOKit.hid

protocol PhysicalSlapDetecting: AnyObject {
    var onHit: (() -> Void)? { get set }
    func start()
    func stop()
}

final class PrivateSPUSlapDetector: NSObject, PhysicalSlapDetecting {
    var onHit: (() -> Void)?

    private enum Constants {
        static let pageVendor: Int64 = 0xFF00
        static let pageSensor: Int64 = 0x0020
        static let usageAccelerometer: Int64 = 3
        static let usageGyroscope: Int64 = 9
        static let usageAmbientLight: Int64 = 4
        static let usageLid: Int64 = 138

        static let imuReportLength = 22
        static let imuDataOffset = 6
        static let reportBufferSize = 4096
        static let reportIntervalMicros: Int32 = 1000
        static let accelScale = 65536.0
        static let decimation = 2
        static let impulseThreshold = 0.12
        static let quietPeriod: TimeInterval = 0.22
        static let baselineSmoothing = 0.08
        static let warmupSamples = 24
    }

    private var devices: [IOHIDDevice] = []
    private var reportBuffers: [UnsafeMutablePointer<UInt8>] = []
    private var callbackContext: UnsafeMutableRawPointer?
    private var decimationCounter = 0
    private var lastTriggerAt: TimeInterval = 0
    private var baselineMagnitude: Double?
    private var warmupSampleCount = 0
    private var started = false

    deinit {
        stop()
    }

    func start() {
        guard !started else { return }
        started = true

        callbackContext = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())

        wakeSPUDrivers()
        registerDevices()

        if devices.isEmpty {
            print("[PhysicalSlapDetector] No AppleSPUHIDDevice accelerometer device available.")
        } else {
            print("[PhysicalSlapDetector] Registered \(devices.count) SPU HID device(s).")
        }
    }

    func stop() {
        guard started else { return }
        started = false

        devices.removeAll()
        reportBuffers.forEach { $0.deallocate() }
        reportBuffers.removeAll()
        callbackContext = nil
        baselineMagnitude = nil
        warmupSampleCount = 0
        decimationCounter = 0
        lastTriggerAt = 0
    }

    private func wakeSPUDrivers() {
        guard let matching = IOServiceMatching("AppleSPUHIDDriver") else { return }

        var iterator: io_iterator_t = 0
        let status = IOServiceGetMatchingServices(kIOMainPortDefault, matching, &iterator)
        guard status == KERN_SUCCESS else {
            print("[PhysicalSlapDetector] Failed to enumerate AppleSPUHIDDriver: \(status)")
            return
        }
        defer { IOObjectRelease(iterator) }

        while true {
            let service = IOIteratorNext(iterator)
            if service == 0 { break }
            defer { IOObjectRelease(service) }

            set(service: service, key: "SensorPropertyReportingState", value: 1)
            set(service: service, key: "SensorPropertyPowerState", value: 1)
            set(service: service, key: "ReportInterval", value: Constants.reportIntervalMicros)
        }
    }

    private func registerDevices() {
        guard let matching = IOServiceMatching("AppleSPUHIDDevice") else { return }

        var iterator: io_iterator_t = 0
        let status = IOServiceGetMatchingServices(kIOMainPortDefault, matching, &iterator)
        guard status == KERN_SUCCESS else {
            print("[PhysicalSlapDetector] Failed to enumerate AppleSPUHIDDevice: \(status)")
            return
        }
        defer { IOObjectRelease(iterator) }

        while true {
            let service = IOIteratorNext(iterator)
            if service == 0 { break }
            defer { IOObjectRelease(service) }

            let usagePage = integerProperty(for: service, key: "PrimaryUsagePage") ?? -1
            let usage = integerProperty(for: service, key: "PrimaryUsage") ?? -1

            guard usagePage == Constants.pageVendor, usage == Constants.usageAccelerometer else {
                continue
            }

            guard let hidDevice = IOHIDDeviceCreate(kCFAllocatorDefault, service) else {
                continue
            }

            let openStatus = IOHIDDeviceOpen(hidDevice, IOOptionBits(kIOHIDOptionsTypeNone))
            guard openStatus == kIOReturnSuccess else {
                print("[PhysicalSlapDetector] IOHIDDeviceOpen failed: \(openStatus)")
                continue
            }

            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: Constants.reportBufferSize)
            buffer.initialize(repeating: 0, count: Constants.reportBufferSize)
            reportBuffers.append(buffer)
            devices.append(hidDevice)

            IOHIDDeviceRegisterInputReportCallback(
                hidDevice,
                buffer,
                Constants.reportBufferSize,
                reportCallback,
                callbackContext
            )
            IOHIDDeviceScheduleWithRunLoop(hidDevice, CFRunLoopGetMain(), CFRunLoopMode.defaultMode.rawValue)
        }
    }

    private func set(service: io_registry_entry_t, key: String, value: Int32) {
        let cfKey = key as CFString
        var mutableValue = value
        guard let cfNumber = CFNumberCreate(kCFAllocatorDefault, .sInt32Type, &mutableValue) else {
            return
        }

        let status = IORegistryEntrySetCFProperty(service, cfKey, cfNumber)
        if status != KERN_SUCCESS {
            print("[PhysicalSlapDetector] Failed setting \(key): \(status)")
        }
    }

    private func integerProperty(for service: io_registry_entry_t, key: String) -> Int64? {
        guard let property = IORegistryEntryCreateCFProperty(service, key as CFString, kCFAllocatorDefault, 0)?.takeRetainedValue() else {
            return nil
        }

        if let number = property as? NSNumber {
            return number.int64Value
        }

        return nil
    }

    fileprivate func handleReport(_ report: UnsafeMutablePointer<UInt8>?, length: CFIndex) {
        guard started, let report, length == Constants.imuReportLength else { return }

        decimationCounter += 1
        guard decimationCounter >= Constants.decimation else { return }
        decimationCounter = 0

        let buffer = UnsafeBufferPointer(start: report, count: length)
        guard buffer.count >= Constants.imuDataOffset + 12 else { return }

        let base = Constants.imuDataOffset
        let xRaw = int32LE(buffer, offset: base)
        let yRaw = int32LE(buffer, offset: base + 4)
        let zRaw = int32LE(buffer, offset: base + 8)

        let x = Double(xRaw) / Constants.accelScale
        let y = Double(yRaw) / Constants.accelScale
        let z = Double(zRaw) / Constants.accelScale
        let magnitude = sqrt((x * x) + (y * y) + (z * z))

        if let existingBaseline = baselineMagnitude {
            baselineMagnitude = existingBaseline + ((magnitude - existingBaseline) * Constants.baselineSmoothing)
        } else {
            baselineMagnitude = magnitude
        }

        warmupSampleCount += 1
        guard warmupSampleCount > Constants.warmupSamples, let baselineMagnitude else {
            return
        }

        let impulse = abs(magnitude - baselineMagnitude)

        let now = ProcessInfo.processInfo.systemUptime
        guard impulse >= Constants.impulseThreshold else { return }
        guard now - lastTriggerAt >= Constants.quietPeriod else { return }

        lastTriggerAt = now
        print("[PhysicalSlapDetector] Physical hit detected with impulse=\(String(format: "%.3f", impulse))")

        onHit?()
    }

    private func int32LE(_ buffer: UnsafeBufferPointer<UInt8>, offset: Int) -> Int32 {
        let b0 = UInt32(buffer[offset])
        let b1 = UInt32(buffer[offset + 1]) << 8
        let b2 = UInt32(buffer[offset + 2]) << 16
        let b3 = UInt32(buffer[offset + 3]) << 24
        return Int32(bitPattern: b0 | b1 | b2 | b3)
    }
}

private let reportCallback: IOHIDReportCallback = {
    context,
    result,
    sender,
    type,
    reportID,
    report,
    reportLength in

    guard result == kIOReturnSuccess,
          let context
    else {
        return
    }

    let detector = Unmanaged<PrivateSPUSlapDetector>.fromOpaque(context).takeUnretainedValue()
    detector.handleReport(report, length: reportLength)
}
