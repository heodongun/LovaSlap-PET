import AppKit
import Foundation

struct Palette {
    static let windowBackground = NSColor(hex: 0x201D1D)
    static let wall = NSColor(hex: 0x2D2933)
    static let wallAccent = NSColor(hex: 0x393342)
    static let floor = NSColor(hex: 0x5B4D5F)
    static let accentPink = NSColor(hex: 0xFF7CA9)
    static let accentRose = NSColor(hex: 0xFFB1C8)
    static let accentSky = NSColor(hex: 0x8CCBFF)
    static let hair = NSColor(hex: 0x412739)
    static let skin = NSColor(hex: 0xFFDEB8)
    static let blush = NSColor(hex: 0xFF95B6)
    static let eye = NSColor(hex: 0x221A22)
    static let dress = NSColor(hex: 0x73B4FF)
    static let dressShadow = NSColor(hex: 0x4B78B0)
    static let ribbon = NSColor(hex: 0xFF5C91)
    static let impact = NSColor(hex: 0xFFE58F)
    static let impactOutline = NSColor(hex: 0xFFB45E)
    static let line = NSColor(hex: 0xFDFCFC, alpha: 0.14)
}

let iconArt = [
    "................",
    ".....PP.PP......",
    "....PPPPPPP.....",
    "...HHHHHHHH.....",
    "..HHHSSSSHHH....",
    "..HHSSSSSSHH..O.",
    "..HHSESSSEHH.OYO",
    "..HHSSMMSSHH..O.",
    "..HHSBBBBSHH....",
    "..HHSSSSSSHH....",
    ".HHHSSSSSSHHH...",
    ".HDDDDPPDDDDH...",
    ".DDDDDDDDDDDD...",
    "..QDDDDDDDDQ....",
    "...QQ....QQ.....",
    "................"
]

let rootURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let assetsURL = rootURL.appendingPathComponent("Assets/AppIcon", isDirectory: true)
let iconsetURL = assetsURL.appendingPathComponent("MiyeonSlap.iconset", isDirectory: true)
let icnsURL = assetsURL.appendingPathComponent("MiyeonSlap.icns")
let masterURL = assetsURL.appendingPathComponent("MiyeonSlap-master.png")

let outputs: [(name: String, size: CGFloat)] = [
    ("icon_16x16.png", 16),
    ("icon_16x16@2x.png", 32),
    ("icon_32x32.png", 32),
    ("icon_32x32@2x.png", 64),
    ("icon_128x128.png", 128),
    ("icon_128x128@2x.png", 256),
    ("icon_256x256.png", 256),
    ("icon_256x256@2x.png", 512),
    ("icon_512x512.png", 512),
    ("icon_512x512@2x.png", 1024)
]

try FileManager.default.createDirectory(at: iconsetURL, withIntermediateDirectories: true)

let masterImage = renderIcon(size: 1024)
try writePNG(image: masterImage, to: masterURL)

for output in outputs {
    let image = renderIcon(size: output.size)
    try writePNG(image: image, to: iconsetURL.appendingPathComponent(output.name))
}

try runIconutil(iconsetURL: iconsetURL, icnsURL: icnsURL)

print("Generated app icon assets in \(assetsURL.path)")

func renderIcon(size: CGFloat) -> NSImage {
    let image = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()

    guard let context = NSGraphicsContext.current?.cgContext else {
        fatalError("Unable to acquire graphics context")
    }

    context.interpolationQuality = .none
    context.setShouldAntialias(true)

    let canvas = NSRect(x: 0, y: 0, width: size, height: size)
    NSColor.clear.setFill()
    canvas.fill()

    let badge = canvas.insetBy(dx: size * 0.08, dy: size * 0.08)
    drawBadge(in: badge)
    drawSprite(in: badge, size: size)

    image.unlockFocus()
    return image
}

func drawBadge(in rect: NSRect) {
    let path = NSBezierPath(roundedRect: rect, xRadius: rect.width * 0.23, yRadius: rect.height * 0.23)

    NSGraphicsContext.saveGraphicsState()
    path.addClip()

    let gradient = NSGradient(colors: [Palette.wallAccent, Palette.floor])
    gradient?.draw(in: path, angle: -55)

    Palette.windowBackground.withAlphaComponent(0.42).setFill()
    NSBezierPath(rect: NSRect(x: rect.minX, y: rect.minY, width: rect.width, height: rect.height * 0.46)).fill()

    Palette.accentRose.withAlphaComponent(0.18).setFill()
    NSBezierPath(ovalIn: NSRect(x: rect.minX - rect.width * 0.08, y: rect.maxY - rect.height * 0.42, width: rect.width * 0.62, height: rect.height * 0.54)).fill()

    Palette.accentSky.withAlphaComponent(0.16).setFill()
    NSBezierPath(ovalIn: NSRect(x: rect.maxX - rect.width * 0.46, y: rect.minY - rect.height * 0.05, width: rect.width * 0.48, height: rect.height * 0.42)).fill()

    Palette.line.setStroke()
    path.lineWidth = max(2, rect.width * 0.012)
    path.stroke()

    let inner = rect.insetBy(dx: rect.width * 0.04, dy: rect.height * 0.04)
    let innerPath = NSBezierPath(roundedRect: inner, xRadius: inner.width * 0.18, yRadius: inner.height * 0.18)
    Palette.accentPink.withAlphaComponent(0.10).setStroke()
    innerPath.lineWidth = max(1.5, rect.width * 0.006)
    innerPath.stroke()

    NSGraphicsContext.restoreGraphicsState()
}

func drawSprite(in badge: NSRect, size: CGFloat) {
    let spriteRect = NSRect(
        x: badge.minX + badge.width * 0.18,
        y: badge.minY + badge.height * 0.16,
        width: badge.width * 0.62,
        height: badge.height * 0.62
    )

    let shadowRect = NSRect(
        x: spriteRect.minX + spriteRect.width * 0.16,
        y: badge.minY + badge.height * 0.12,
        width: spriteRect.width * 0.60,
        height: badge.height * 0.08
    )
    Palette.windowBackground.withAlphaComponent(0.38).setFill()
    NSBezierPath(roundedRect: shadowRect, xRadius: shadowRect.height / 2, yRadius: shadowRect.height / 2).fill()

    let gridSize = CGFloat(iconArt.count)
    let cell = min(spriteRect.width / gridSize, spriteRect.height / gridSize)
    let artWidth = cell * gridSize
    let artHeight = cell * gridSize
    let origin = NSPoint(
        x: spriteRect.midX - artWidth / 2 - cell * 0.95,
        y: spriteRect.midY - artHeight / 2 + cell * 0.20
    )

    for (rowIndex, row) in iconArt.enumerated() {
        for (columnIndex, symbol) in row.enumerated() {
            guard let color = color(for: symbol) else {
                continue
            }

            let y = origin.y + CGFloat(iconArt.count - 1 - rowIndex) * cell
            let x = origin.x + CGFloat(columnIndex) * cell
            color.setFill()
            NSBezierPath(rect: NSRect(x: x.rounded(.down), y: y.rounded(.down), width: ceil(cell), height: ceil(cell))).fill()
        }
    }

    drawImpactBurst(origin: origin, cell: cell)

}

func drawImpactBurst(origin: NSPoint, cell: CGFloat) {
    let outlineBlocks: [(CGFloat, CGFloat)] = [
        (13.2, 11.0), (14.2, 11.0), (15.2, 11.0),
        (14.2, 12.0), (14.2, 10.0),
        (16.2, 12.0), (16.2, 10.0),
        (17.2, 11.0),
        (15.2, 13.0), (15.2, 9.0)
    ]

    let fillBlocks: [(CGFloat, CGFloat)] = [
        (14.2, 11.0), (15.2, 11.0),
        (15.2, 12.0), (15.2, 10.0)
    ]

    let motionBlocks: [(CGFloat, CGFloat)] = [
        (16.9, 12.5), (17.9, 12.9),
        (16.8, 9.7), (17.8, 9.3)
    ]

    let contactBlocks: [(CGFloat, CGFloat)] = [
        (12.3, 11.0), (12.6, 10.2)
    ]

    let handBlocks: [(CGFloat, CGFloat)] = [
        (18.2, 10.0), (18.2, 11.0), (18.2, 12.0),
        (19.2, 10.0), (19.2, 11.0), (19.2, 12.0), (19.2, 13.0),
        (20.2, 10.6), (20.2, 11.6), (20.2, 12.6),
        (21.2, 11.0), (21.2, 12.0)
    ]

    let handMotionBlocks: [(CGFloat, CGFloat)] = [
        (20.8, 14.2), (21.8, 14.6),
        (21.3, 8.4), (22.3, 8.0)
    ]

    Palette.ribbon.withAlphaComponent(0.55).setFill()
    for block in motionBlocks {
        fillPixel(x: block.0, y: block.1, cell: cell, origin: origin)
    }

    Palette.accentRose.withAlphaComponent(0.75).setFill()
    for block in handMotionBlocks {
        fillPixel(x: block.0, y: block.1, cell: cell, origin: origin)
    }

    Palette.skin.withAlphaComponent(0.96).setFill()
    for block in handBlocks {
        fillPixel(x: block.0, y: block.1, cell: cell, origin: origin)
    }

    Palette.accentRose.withAlphaComponent(0.9).setFill()
    for block in contactBlocks {
        fillPixel(x: block.0, y: block.1, cell: cell, origin: origin)
    }

    Palette.impactOutline.setFill()
    for block in outlineBlocks {
        fillPixel(x: block.0, y: block.1, cell: cell, origin: origin)
    }

    Palette.impact.setFill()
    for block in fillBlocks {
        fillPixel(x: block.0, y: block.1, cell: cell, origin: origin)
    }
}

func fillPixel(x: CGFloat, y: CGFloat, cell: CGFloat, origin: NSPoint) {
    NSBezierPath(
        rect: NSRect(
            x: (origin.x + x * cell).rounded(.down),
            y: (origin.y + y * cell).rounded(.down),
            width: ceil(cell),
            height: ceil(cell)
        )
    ).fill()
}

func color(for symbol: Character) -> NSColor? {
    switch symbol {
    case "H": return Palette.hair
    case "S": return Palette.skin
    case "P": return Palette.ribbon
    case "E": return Palette.eye
    case "B": return Palette.blush
    case "M": return Palette.accentPink
    case "D": return Palette.dress
    case "Q": return Palette.dressShadow
    case "Y": return Palette.impact
    case "O": return Palette.impactOutline
    default: return nil
    }
}

func writePNG(image: NSImage, to url: URL) throws {
    guard
        let tiffData = image.tiffRepresentation,
        let bitmap = NSBitmapImageRep(data: tiffData),
        let pngData = bitmap.representation(using: .png, properties: [:])
    else {
        throw NSError(domain: "MiyeonSlapIcon", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to encode PNG"]) 
    }

    try pngData.write(to: url)
}

func runIconutil(iconsetURL: URL, icnsURL: URL) throws {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
    process.arguments = ["-c", "icns", iconsetURL.path, "-o", icnsURL.path]
    try process.run()
    process.waitUntilExit()

    guard process.terminationStatus == 0 else {
        throw NSError(
            domain: "MiyeonSlapIcon",
            code: Int(process.terminationStatus),
            userInfo: [NSLocalizedDescriptionKey: "iconutil failed with status \(process.terminationStatus)"]
        )
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
