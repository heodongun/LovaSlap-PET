import CoreGraphics
import Foundation

enum ReactionPhase: Equatable {
    case idle
    case hit(recoverAt: TimeInterval)
}

enum EyeStyle: Equatable {
    case open
    case blink
    case pout
    case dizzy
    case shock
}

enum MouthStyle: Equatable {
    case smile
    case neutral
    case pout
    case open
}

struct ReactionVisual: Equatable {
    let spriteOffset: CGPoint
    let leftArmOffset: CGPoint
    let rightArmOffset: CGPoint
    let bangsOffsetY: CGFloat
    let eyeStyle: EyeStyle
    let mouthStyle: MouthStyle
    let showImpactBurst: Bool
}

final class GameState {
    static let idleFrameDuration: TimeInterval = 0.16
    static let hitDuration: TimeInterval = 0.42
    static let refreshInterval: TimeInterval = 1.0 / 12.0

    let activePreset: PixelPetPreset
    private(set) var slapCount = 0
    private(set) var reactionPhase: ReactionPhase = .idle

    init(activePreset: PixelPetPreset = .defaultPreset) {
        self.activePreset = activePreset
    }

    func triggerSlap(at time: TimeInterval) {
        slapCount += 1
        reactionPhase = .hit(recoverAt: time + Self.hitDuration)
    }

    func reactionVisual(at time: TimeInterval, mood: CharacterMood) -> ReactionVisual {
        settleIfNeeded(at: time)

        switch reactionPhase {
        case .idle:
            let frameIndex = Int(floor(time / Self.idleFrameDuration)).quotientAndRemainder(dividingBy: activePreset.idleFrames.count).remainder
            let frame = activePreset.idleFrames[frameIndex]
            return ReactionVisual(
                spriteOffset: frame.spriteOffset,
                leftArmOffset: frame.leftArmOffset,
                rightArmOffset: frame.rightArmOffset,
                bangsOffsetY: frame.bangsOffsetY,
                eyeStyle: idleEyeStyle(for: mood, blink: frame.blink),
                mouthStyle: idleMouthStyle(for: mood),
                showImpactBurst: false
            )
        case .hit:
            return ReactionVisual(
                spriteOffset: CGPoint(x: -14, y: 8),
                leftArmOffset: CGPoint(x: -1, y: 2),
                rightArmOffset: CGPoint(x: 1, y: 4),
                bangsOffsetY: -1,
                eyeStyle: hitEyeStyle(for: mood),
                mouthStyle: .open,
                showImpactBurst: true
            )
        }
    }

    private func settleIfNeeded(at time: TimeInterval) {
        guard case let .hit(recoverAt) = reactionPhase, time >= recoverAt else {
            return
        }

        reactionPhase = .idle
    }

    private func idleEyeStyle(for mood: CharacterMood, blink: Bool) -> EyeStyle {
        if blink {
            return .blink
        }

        switch mood {
        case .calm, .startled:
            return .open
        case .pout:
            return .pout
        case .dizzy:
            return .dizzy
        }
    }

    private func hitEyeStyle(for mood: CharacterMood) -> EyeStyle {
        switch mood {
        case .dizzy:
            return .dizzy
        case .calm, .startled, .pout:
            return .shock
        }
    }

    private func idleMouthStyle(for mood: CharacterMood) -> MouthStyle {
        switch mood {
        case .calm:
            return .smile
        case .startled:
            return .neutral
        case .pout, .dizzy:
            return .pout
        }
    }
}
