import AppKit

@MainActor
final class MainWindowController: NSWindowController {
    private let sceneViewController: SceneViewController

    init(pet: PetInstance) {
        let metrics = pet.asset.layoutMetrics
        sceneViewController = SceneViewController(asset: pet.asset, metrics: metrics)
        let window = OverlayPetWindow(
            contentRect: NSRect(origin: pet.origin, size: metrics.windowSize),
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
        window.contentViewController = sceneViewController

        super.init(window: window)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    func triggerPhysicalSlap() {
        sceneViewController.triggerPhysicalSlap()
    }
}

final class OverlayPetWindow: NSWindow {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
}

@MainActor
final class SceneViewController: NSViewController {
    private let sceneView: GameSceneView

    init(asset: PetAsset, metrics: PetLayoutMetrics) {
        sceneView = GameSceneView(
            frame: NSRect(origin: .zero, size: metrics.windowSize),
            asset: asset,
            metrics: metrics
        )
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func loadView() {
        view = sceneView
    }

    func triggerPhysicalSlap() {
        sceneView.triggerPhysicalSlap()
    }
}
