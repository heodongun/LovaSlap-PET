import AppKit

@MainActor
final class PetsCoordinator: NSObject {
    private let petsStore = PetsStore()
    private let physicalSlapDetector: PhysicalSlapDetecting
    private var windowControllers: [UUID: MainWindowController] = [:]
    private lazy var statusItemController = StatusItemController(target: self)

    init(physicalSlapDetector: PhysicalSlapDetecting = PrivateSPUSlapDetector()) {
        self.physicalSlapDetector = physicalSlapDetector
    }

    func start() {
        statusItemController.attach(activePetCount: petsStore.count)
        physicalSlapDetector.onHit = { [weak self] in
            self?.triggerPhysicalSlapOnAllPets()
        }
        physicalSlapDetector.start()
        addBuiltInPet(.launchPreset())
    }

    func stop() {
        physicalSlapDetector.stop()
        removeAllPets(nil)
    }

    @objc func addBuiltInPetFromMenu(_ sender: NSMenuItem) {
        guard let presetIndex = sender.representedObject as? Int,
              PixelPetPreset.builtIns.indices.contains(presetIndex)
        else {
            return
        }

        addBuiltInPet(PixelPetPreset.builtIns[presetIndex])
    }

    @objc func addPNGSequencePet(_ sender: Any?) {
        NSApp.activate(ignoringOtherApps: true)

        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.allowsMultipleSelection = false
        openPanel.prompt = "Add Pet"
        openPanel.message = "Choose a folder that contains an ordered PNG sequence."

        guard openPanel.runModal() == .OK, let folderURL = openPanel.url else {
            return
        }

        do {
            let sequence = try PNGSequenceFolderLoader.load(from: folderURL)
            addPet(asset: .pngSequence(sequence))
        } catch {
            let alert = NSAlert(error: error)
            alert.runModal()
        }
    }

    @objc func removeLastPet(_ sender: Any?) {
        guard let removedPet = petsStore.removeLast() else {
            return
        }

        windowControllers.removeValue(forKey: removedPet.id)?.close()
        statusItemController.rebuildMenu(activePetCount: petsStore.count)
    }

    @objc func removeAllPets(_ sender: Any?) {
        let removedPets = petsStore.removeAll()
        for pet in removedPets {
            windowControllers.removeValue(forKey: pet.id)?.close()
        }
        statusItemController.rebuildMenu(activePetCount: petsStore.count)
    }

    @objc func quitApplication(_ sender: Any?) {
        NSApp.terminate(nil)
    }

    private func addBuiltInPet(_ preset: PixelPetPreset) {
        addPet(asset: .builtIn(preset))
    }

    private func addPet(asset: PetAsset) {
        let pet = petsStore.add(asset: asset, visibleFrame: activeVisibleFrame())
        let windowController = MainWindowController(pet: pet)
        windowControllers[pet.id] = windowController
        windowController.showWindow(nil)
        statusItemController.rebuildMenu(activePetCount: petsStore.count)
    }

    private func triggerPhysicalSlapOnAllPets() {
        for windowController in windowControllers.values {
            windowController.triggerPhysicalSlap()
        }
    }

    private func activeVisibleFrame() -> NSRect {
        let mouseLocation = NSEvent.mouseLocation

        if let screenUnderMouse = NSScreen.screens.first(where: { NSMouseInRect(mouseLocation, $0.frame, false) }) {
            return screenUnderMouse.visibleFrame
        }

        if let mainScreen = NSScreen.main {
            return mainScreen.visibleFrame
        }

        if let firstScreen = NSScreen.screens.first {
            return firstScreen.visibleFrame
        }

        return NSRect(x: 0, y: 0, width: 1440, height: 900)
    }
}

@MainActor
final class StatusItemController {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private unowned let target: PetsCoordinator

    init(target: PetsCoordinator) {
        self.target = target
    }

    func attach(activePetCount: Int) {
        if let button = statusItem.button {
            button.title = "🐾"
            button.toolTip = "LovaSlap-PET"
        }

        rebuildMenu(activePetCount: activePetCount)
    }

    func rebuildMenu(activePetCount: Int) {
        let menu = NSMenu()

        let titleItem = NSMenuItem(title: "LovaSlap-PET (\(activePetCount))", action: nil, keyEquivalent: "")
        titleItem.isEnabled = false
        menu.addItem(titleItem)
        menu.addItem(.separator())

        let builtInItem = NSMenuItem(title: "Add Built-in Pet", action: nil, keyEquivalent: "")
        let builtInMenu = NSMenu()
        for (index, preset) in PixelPetPreset.builtIns.enumerated() {
            let item = NSMenuItem(title: preset.name, action: #selector(PetsCoordinator.addBuiltInPetFromMenu(_:)), keyEquivalent: "")
            item.target = target
            item.representedObject = index
            builtInMenu.addItem(item)
        }
        menu.addItem(builtInItem)
        menu.setSubmenu(builtInMenu, for: builtInItem)

        let addSequenceItem = NSMenuItem(title: "Add PNG Sequence Folder…", action: #selector(PetsCoordinator.addPNGSequencePet(_:)), keyEquivalent: "")
        addSequenceItem.target = target
        menu.addItem(addSequenceItem)
        menu.addItem(.separator())

        let removeLastItem = NSMenuItem(title: "Remove Last Pet", action: #selector(PetsCoordinator.removeLastPet(_:)), keyEquivalent: "")
        removeLastItem.target = target
        removeLastItem.isEnabled = activePetCount > 0
        menu.addItem(removeLastItem)

        let removeAllItem = NSMenuItem(title: "Remove All Pets", action: #selector(PetsCoordinator.removeAllPets(_:)), keyEquivalent: "")
        removeAllItem.target = target
        removeAllItem.isEnabled = activePetCount > 0
        menu.addItem(removeAllItem)
        menu.addItem(.separator())

        let quitItem = NSMenuItem(title: "Quit LovaSlap-PET", action: #selector(PetsCoordinator.quitApplication(_:)), keyEquivalent: "q")
        quitItem.target = target
        menu.addItem(quitItem)

        statusItem.menu = menu
        statusItem.button?.toolTip = "LovaSlap-PET - \(activePetCount) pet(s)"
    }
}
