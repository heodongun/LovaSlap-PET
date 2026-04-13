import AppKit

enum ScenePalette {
    static let windowBackground = NSColor(hex: 0x201D1D)
    static let wall = NSColor(hex: 0x2D2933)
    static let wallAccent = NSColor(hex: 0x393342)
    static let floor = NSColor(hex: 0x5B4D5F)
    static let floorStripe = NSColor(hex: 0x6C5B70)
    static let dialogueBackground = NSColor(hex: 0x161316)
    static let dialogueBorder = NSColor(hex: 0xFDFCFC, alpha: 0.14)
    static let textPrimary = NSColor(hex: 0xFDFCFC)
    static let textSecondary = NSColor(hex: 0xD4CDD1)
    static let accentPink = NSColor(hex: 0xFF7CA9)
    static let accentRose = NSColor(hex: 0xFFB1C8)
    static let accentSky = NSColor(hex: 0x8CCBFF)
    static let accentMint = NSColor(hex: 0x9DF4D1)
    static let moon = NSColor(hex: 0xFFF3BA)
    static let shadow = NSColor(hex: 0x000000, alpha: 0.22)
    static let hair = NSColor(hex: 0x412739)
    static let hairShadow = NSColor(hex: 0x291925)
    static let skin = NSColor(hex: 0xFFDEB8)
    static let blush = NSColor(hex: 0xFF95B6)
    static let eye = NSColor(hex: 0x221A22)
    static let dress = NSColor(hex: 0x73B4FF)
    static let dressShadow = NSColor(hex: 0x4B78B0)
    static let ribbon = NSColor(hex: 0xFF5C91)
    static let impact = NSColor(hex: 0xFFE58F)
    static let impactOutline = NSColor(hex: 0xFFB45E)
}

enum SceneMetrics {
    static let pixel: CGFloat = 8
    static let petWindowSize = NSSize(width: 280, height: 320)
    static let petCanvasSize = NSSize(width: 220, height: 286)
    static let petBottomPadding: CGFloat = 12
}

enum SceneTypography {
    @MainActor static var speaker: NSFont {
        NSFont(name: "Menlo-Bold", size: 16)
            ?? NSFont.monospacedSystemFont(ofSize: 16, weight: .bold)
    }

    @MainActor static var dialogue: NSFont {
        NSFont(name: "Menlo", size: 15)
            ?? NSFont.monospacedSystemFont(ofSize: 15, weight: .medium)
    }

    @MainActor static var detail: NSFont {
        NSFont(name: "Menlo", size: 12)
            ?? NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
    }
}

extension NSColor {
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let red = CGFloat((hex >> 16) & 0xFF) / 255.0
        let green = CGFloat((hex >> 8) & 0xFF) / 255.0
        let blue = CGFloat(hex & 0xFF) / 255.0
        self.init(calibratedRed: red, green: green, blue: blue, alpha: alpha)
    }
}
