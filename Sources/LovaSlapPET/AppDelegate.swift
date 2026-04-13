import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let petsCoordinator: PetsCoordinator

    override init() {
        petsCoordinator = PetsCoordinator()
        super.init()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        petsCoordinator.start()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    func applicationWillTerminate(_ notification: Notification) {
        petsCoordinator.stop()
    }
}
