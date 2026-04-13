import AppKit
import Foundation

enum SelfCheckRunner {
    static func runIfRequested() -> Bool {
        guard CommandLine.arguments.contains("--self-check") else {
            return false
        }

        do {
            try runAll()
            print("[self-check] pass")
            return true
        } catch {
            fputs("[self-check] fail: \(error)\n", stderr)
            Foundation.exit(EXIT_FAILURE)
        }
    }

    private static func runAll() throws {
        try verifyDialogueStopsAtLastLine()
        try verifyPresetCatalog()
        try verifyPresetSelection()
        try verifyHitRecovery()
        try verifyRepeatedHitExtendsRecovery()
        try verifyPetPlacementStaysInsideVisibleFrame()
        try verifyPetsStoreTracksMultiplePets()
        try verifyPNGSequenceSorting()
    }

    private static func verifyDialogueStopsAtLastLine() throws {
        let script = DialogueScript()
        for _ in 0..<(script.count + 2) {
            _ = script.advance()
        }

        try expect(script.currentLine.mood == .dizzy, "dialogue should stop on the last mood")
        try expect(script.currentLine.speaker == "Miyeon", "dialogue speaker should remain Miyeon")
    }

    private static func verifyPresetCatalog() throws {
        let names = PixelPetPreset.builtIns.map(\.name)
        try expect(Set(names).count == PixelPetPreset.builtIns.count, "preset names must be unique")
        try expect(PixelPetPreset.builtIns.allSatisfy { !$0.idleFrames.isEmpty }, "presets must define idle frames")
    }

    private static func verifyPresetSelection() throws {
        try expect(PixelPetPreset.launchPreset(seed: 0).name == PixelPetPreset.builtIns[0].name, "seed 0 should pick the first preset")
        try expect(PixelPetPreset.launchPreset(seed: 1).name == PixelPetPreset.builtIns[1].name, "seed 1 should pick the second preset")
        try expect(PixelPetPreset.launchPreset(seed: 2).name == PixelPetPreset.builtIns[2].name, "seed 2 should pick the third preset")
    }

    private static func verifyHitRecovery() throws {
        let state = GameState(activePreset: .sunsetPeach)
        state.triggerSlap(at: 10.0)

        let hitVisual = state.reactionVisual(at: 10.1, mood: .startled)
        try expect(hitVisual.showImpactBurst, "hit visual should show an impact burst")
        try expect(recoveryTime(of: state.reactionPhase, isApproximately: 10.42), "hit state should persist until recovery time")

        let settledVisual = state.reactionVisual(at: 10.6, mood: .startled)
        try expect(!settledVisual.showImpactBurst, "settled visual should hide the impact burst")
        try expect(state.reactionPhase == .idle, "state should return to idle after recovery")
    }

    private static func verifyRepeatedHitExtendsRecovery() throws {
        let state = GameState(activePreset: .miyeonClassic)
        state.triggerSlap(at: 1.0)
        state.triggerSlap(at: 1.2)

        _ = state.reactionVisual(at: 1.5, mood: .pout)
        try expect(recoveryTime(of: state.reactionPhase, isApproximately: 1.62), "second hit should extend recovery")

        _ = state.reactionVisual(at: 1.7, mood: .pout)
        try expect(state.reactionPhase == .idle, "extended recovery should still return to idle")
    }

    private static func verifyPetPlacementStaysInsideVisibleFrame() throws {
        let visibleFrame = NSRect(x: 0, y: 0, width: 1280, height: 720)
        let firstOrigin = PetPlacementPlanner.origin(
            for: 0,
            windowSize: SceneMetrics.petWindowSize,
            visibleFrame: visibleFrame
        )
        let secondOrigin = PetPlacementPlanner.origin(
            for: 1,
            windowSize: SceneMetrics.petWindowSize,
            visibleFrame: visibleFrame
        )

        try expect(firstOrigin.x >= visibleFrame.minX, "first pet origin should stay inside the visible frame")
        try expect(firstOrigin.y >= visibleFrame.minY, "first pet should sit above the screen bottom")
        try expect(secondOrigin != firstOrigin, "subsequent pets should not reuse the same origin")
    }

    private static func verifyPetsStoreTracksMultiplePets() throws {
        let visibleFrame = NSRect(x: 0, y: 0, width: 1280, height: 720)
        let store = PetsStore()

        let first = store.add(asset: .builtIn(.miyeonClassic), visibleFrame: visibleFrame)
        _ = store.add(asset: .builtIn(.sunsetPeach), visibleFrame: visibleFrame)

        try expect(store.count == 2, "pets store should hold multiple visible pets")

        _ = store.remove(id: first.id)
        try expect(store.count == 1, "pets store should support removing individual pets")

        let removed = store.removeAll()
        try expect(removed.count == 1, "removeAll should return remaining pets")
        try expect(store.count == 0, "removeAll should empty the store")
    }

    private static func verifyPNGSequenceSorting() throws {
        let urls = [
            URL(fileURLWithPath: "/tmp/frame-10.png"),
            URL(fileURLWithPath: "/tmp/frame-2.png"),
            URL(fileURLWithPath: "/tmp/frame-1.PNG"),
            URL(fileURLWithPath: "/tmp/readme.txt")
        ]
        let sortedNames = PNGSequenceFolderLoader.sortFrameURLs(urls).map(\.lastPathComponent)

        try expect(
            sortedNames == ["frame-1.PNG", "frame-2.png", "frame-10.png"],
            "PNG frame sorting should keep numeric animation order and ignore non-PNG files"
        )
    }

    private static func recoveryTime(of phase: ReactionPhase, isApproximately expected: TimeInterval) -> Bool {
        guard case let .hit(recoverAt) = phase else {
            return false
        }

        return abs(recoverAt - expected) < 0.000_1
    }

    private static func expect(_ condition: @autoclosure () -> Bool, _ message: String) throws {
        if !condition() {
            throw SelfCheckError(message: message)
        }
    }
}

struct SelfCheckError: LocalizedError {
    let message: String

    var errorDescription: String? {
        message
    }
}

if SelfCheckRunner.runIfRequested() {
    exit(EXIT_SUCCESS)
}

let app = NSApplication.shared
let delegate = AppDelegate()

app.setActivationPolicy(.accessory)
app.delegate = delegate
app.run()
