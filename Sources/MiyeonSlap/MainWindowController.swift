import AppKit

@MainActor
final class MainWindowController: NSWindowController {
    convenience init() {
        let windowSize = SceneMetrics.petWindowSize
        let window = OverlayPetWindow(
            contentRect: NSRect(origin: .zero, size: windowSize),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        window.backgroundColor = .clear
        window.isOpaque = false
        window.hasShadow = false
        window.level = .floating
        window.collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary]
        window.isReleasedWhenClosed = false
        window.contentViewController = SceneViewController()
        Self.position(window: window, size: windowSize)

        self.init(window: window)
    }

    private static func position(window: NSWindow, size: NSSize) {
        guard let screen = NSScreen.main else {
            window.setFrameOrigin(NSPoint(x: 80, y: 80))
            return
        }

        let visibleFrame = screen.visibleFrame
        let origin = NSPoint(
            x: visibleFrame.maxX - size.width - 36,
            y: visibleFrame.minY + 24
        )

        window.setFrameOrigin(origin)
    }
}

final class OverlayPetWindow: NSWindow {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
}

@MainActor
final class SceneViewController: NSViewController {
    private let sceneView = GameSceneView(frame: NSRect(origin: .zero, size: SceneMetrics.petWindowSize))
    private let physicalSlapDetector = PrivateSPUSlapDetector()

    override func loadView() {
        view = sceneView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        physicalSlapDetector.onHit = { [weak self] in
            self?.sceneView.triggerPhysicalSlap()
        }
        physicalSlapDetector.start()
    }
}
