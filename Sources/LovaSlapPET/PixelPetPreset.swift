import AppKit

struct PixelPetIdleFrame: Equatable {
    let spriteOffset: CGPoint
    let leftArmOffset: CGPoint
    let rightArmOffset: CGPoint
    let bangsOffsetY: CGFloat
    let blink: Bool
}

struct PixelPetPalette {
    let shadow: NSColor
    let hair: NSColor
    let hairShadow: NSColor
    let skin: NSColor
    let blush: NSColor
    let eye: NSColor
    let outfit: NSColor
    let outfitShadow: NSColor
    let ribbon: NSColor
    let impact: NSColor
    let impactOutline: NSColor
}

struct PixelPetPreset {
    let name: String
    let palette: PixelPetPalette
    let idleFrames: [PixelPetIdleFrame]
}

extension PixelPetPreset {
    static let defaultPreset = miyeonClassic

    static let builtIns: [PixelPetPreset] = [
        .miyeonClassic,
        .midnightMint,
        .sunsetPeach
    ]

    static func launchPreset(seed: UInt64) -> PixelPetPreset {
        builtIns[Int(seed % UInt64(builtIns.count))]
    }

    static func launchPreset() -> PixelPetPreset {
        launchPreset(seed: UInt64(ProcessInfo.processInfo.systemUptime.bitPattern))
    }

    static let miyeonClassic = PixelPetPreset(
        name: "Miyeon Classic",
        palette: PixelPetPalette(
            shadow: NSColor(hex: 0x000000, alpha: 0.22),
            hair: NSColor(hex: 0x412739),
            hairShadow: NSColor(hex: 0x291925),
            skin: NSColor(hex: 0xFFDEB8),
            blush: NSColor(hex: 0xFF95B6),
            eye: NSColor(hex: 0x221A22),
            outfit: NSColor(hex: 0x73B4FF),
            outfitShadow: NSColor(hex: 0x4B78B0),
            ribbon: NSColor(hex: 0xFF5C91),
            impact: NSColor(hex: 0xFFE58F),
            impactOutline: NSColor(hex: 0xFFB45E)
        ),
        idleFrames: [
            PixelPetIdleFrame(spriteOffset: CGPoint(x: 0, y: 0), leftArmOffset: .zero, rightArmOffset: CGPoint(x: 0, y: 1), bangsOffsetY: 0, blink: false),
            PixelPetIdleFrame(spriteOffset: CGPoint(x: 0, y: 2), leftArmOffset: CGPoint(x: 0, y: 1), rightArmOffset: .zero, bangsOffsetY: 1, blink: false),
            PixelPetIdleFrame(spriteOffset: CGPoint(x: 0, y: 1), leftArmOffset: .zero, rightArmOffset: .zero, bangsOffsetY: 0, blink: true),
            PixelPetIdleFrame(spriteOffset: CGPoint(x: 0, y: 2), leftArmOffset: CGPoint(x: 0, y: 1), rightArmOffset: CGPoint(x: 0, y: 1), bangsOffsetY: 1, blink: false)
        ]
    )

    static let midnightMint = PixelPetPreset(
        name: "Midnight Mint",
        palette: PixelPetPalette(
            shadow: NSColor(hex: 0x000000, alpha: 0.22),
            hair: NSColor(hex: 0x24374A),
            hairShadow: NSColor(hex: 0x16212D),
            skin: NSColor(hex: 0xFFD9BF),
            blush: NSColor(hex: 0xF49FC2),
            eye: NSColor(hex: 0x112030),
            outfit: NSColor(hex: 0x8CE7D1),
            outfitShadow: NSColor(hex: 0x56A08D),
            ribbon: NSColor(hex: 0x7BE0FF),
            impact: NSColor(hex: 0xFFF2A5),
            impactOutline: NSColor(hex: 0xFFC267)
        ),
        idleFrames: [
            PixelPetIdleFrame(spriteOffset: CGPoint(x: -1, y: 0), leftArmOffset: CGPoint(x: 0, y: 1), rightArmOffset: CGPoint(x: 0, y: 1), bangsOffsetY: 0, blink: false),
            PixelPetIdleFrame(spriteOffset: CGPoint(x: 1, y: 1), leftArmOffset: CGPoint(x: -1, y: 0), rightArmOffset: CGPoint(x: 1, y: 0), bangsOffsetY: 1, blink: false),
            PixelPetIdleFrame(spriteOffset: CGPoint(x: 0, y: 2), leftArmOffset: CGPoint(x: 0, y: 1), rightArmOffset: .zero, bangsOffsetY: 1, blink: true),
            PixelPetIdleFrame(spriteOffset: CGPoint(x: 1, y: 1), leftArmOffset: CGPoint(x: -1, y: 0), rightArmOffset: CGPoint(x: 1, y: 1), bangsOffsetY: 0, blink: false)
        ]
    )

    static let sunsetPeach = PixelPetPreset(
        name: "Sunset Peach",
        palette: PixelPetPalette(
            shadow: NSColor(hex: 0x000000, alpha: 0.22),
            hair: NSColor(hex: 0x5A3240),
            hairShadow: NSColor(hex: 0x351D28),
            skin: NSColor(hex: 0xFFE2C6),
            blush: NSColor(hex: 0xFF9DA4),
            eye: NSColor(hex: 0x2A1D26),
            outfit: NSColor(hex: 0xFFBE8B),
            outfitShadow: NSColor(hex: 0xBF7C52),
            ribbon: NSColor(hex: 0xFF7B7B),
            impact: NSColor(hex: 0xFFE59A),
            impactOutline: NSColor(hex: 0xFFAE61)
        ),
        idleFrames: [
            PixelPetIdleFrame(spriteOffset: CGPoint(x: 0, y: 0), leftArmOffset: CGPoint(x: 0, y: 1), rightArmOffset: CGPoint(x: 0, y: 1), bangsOffsetY: 0, blink: false),
            PixelPetIdleFrame(spriteOffset: CGPoint(x: 0, y: 3), leftArmOffset: CGPoint(x: 0, y: 2), rightArmOffset: CGPoint(x: 0, y: 2), bangsOffsetY: 1, blink: false),
            PixelPetIdleFrame(spriteOffset: CGPoint(x: 0, y: 1), leftArmOffset: CGPoint(x: 0, y: 1), rightArmOffset: CGPoint(x: 0, y: 1), bangsOffsetY: 0, blink: true),
            PixelPetIdleFrame(spriteOffset: CGPoint(x: 0, y: 2), leftArmOffset: CGPoint(x: 0, y: 1), rightArmOffset: CGPoint(x: 0, y: 2), bangsOffsetY: 1, blink: false)
        ]
    )
}
