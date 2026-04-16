import AppKit
import Foundation

struct PetLayoutMetrics {
    let windowSize: NSSize
    let canvasSize: NSSize
    let bottomPadding: CGFloat

    static let builtIn = PetLayoutMetrics(
        windowSize: SceneMetrics.petWindowSize,
        canvasSize: SceneMetrics.petCanvasSize,
        bottomPadding: SceneMetrics.petBottomPadding
    )

    static func pngSequence(maxFrameSize: NSSize) -> PetLayoutMetrics {
        let fittedSize = maxFrameSize.aspectFit(within: SceneMetrics.customPetMaxCanvasSize)
        let canvasSize = NSSize(
            width: max(fittedSize.width, 96),
            height: max(fittedSize.height, 96)
        )
        let windowSize = NSSize(
            width: canvasSize.width + 48,
            height: canvasSize.height + 34
        )

        return PetLayoutMetrics(
            windowSize: windowSize,
            canvasSize: canvasSize,
            bottomPadding: SceneMetrics.petBottomPadding
        )
    }
}

struct PNGSequencePetAsset {
    let name: String
    let folderURL: URL
    let frameURLs: [URL]
    let frames: [NSImage]
    let maxFrameSize: NSSize
}

enum PetAsset {
    case builtIn(PixelPetPreset)
    case pngSequence(PNGSequencePetAsset)

    var displayName: String {
        switch self {
        case let .builtIn(preset):
            return preset.name
        case let .pngSequence(sequence):
            return sequence.name
        }
    }

    var layoutMetrics: PetLayoutMetrics {
        switch self {
        case .builtIn:
            return .builtIn
        case let .pngSequence(sequence):
            return .pngSequence(maxFrameSize: sequence.maxFrameSize)
        }
    }

    var scenePreset: PixelPetPreset {
        switch self {
        case let .builtIn(preset):
            return preset
        case .pngSequence:
            return .defaultPreset
        }
    }
}

struct PetInstance {
    let id: UUID
    let asset: PetAsset
    let origin: NSPoint
}

struct PetPlacementPlanner {
    private static let horizontalInset: CGFloat = 36
    private static let verticalInset: CGFloat = 24
    private static let horizontalSpacing: CGFloat = 28
    private static let verticalSpacing: CGFloat = 20

    static func origin(for index: Int, windowSize: NSSize, visibleFrame: NSRect) -> NSPoint {
        let usableWidth = max(visibleFrame.width - (horizontalInset * 2), windowSize.width)
        let columns = max(1, Int((usableWidth + horizontalSpacing) / (windowSize.width + horizontalSpacing)))
        let column = index % columns
        let row = index / columns

        let x = visibleFrame.maxX - horizontalInset - windowSize.width - (CGFloat(column) * (windowSize.width + horizontalSpacing))
        let unclampedY = visibleFrame.minY + verticalInset + (CGFloat(row) * (windowSize.height + verticalSpacing))
        let y = min(unclampedY, visibleFrame.maxY - windowSize.height - verticalInset)

        return NSPoint(x: max(x, visibleFrame.minX + horizontalInset), y: max(y, visibleFrame.minY + verticalInset))
    }
}

final class PetsStore {
    private(set) var pets: [PetInstance] = []

    var count: Int {
        pets.count
    }

    func add(asset: PetAsset, visibleFrame: NSRect) -> PetInstance {
        let windowSize = asset.layoutMetrics.windowSize
        let origin = PetPlacementPlanner.origin(
            for: pets.count,
            windowSize: windowSize,
            visibleFrame: visibleFrame
        )
        let pet = PetInstance(id: UUID(), asset: asset, origin: origin)
        pets.append(pet)
        return pet
    }

    @discardableResult
    func remove(id: UUID) -> PetInstance? {
        guard let index = pets.firstIndex(where: { $0.id == id }) else {
            return nil
        }

        return pets.remove(at: index)
    }

    @discardableResult
    func removeLast() -> PetInstance? {
        pets.popLast()
    }

    func removeAll() -> [PetInstance] {
        let removed = pets
        pets.removeAll()
        return removed
    }
}

enum PNGSequenceFolderLoaderError: LocalizedError {
    case inaccessibleFolder
    case missingPNGFrames
    case unreadablePNGFrame(String)

    var errorDescription: String? {
        switch self {
        case .inaccessibleFolder:
            return "선택한 PNG 시퀀스 폴더를 읽을 수 없습니다."
        case .missingPNGFrames:
            return "선택한 폴더에 PNG 프레임이 없습니다."
        case let .unreadablePNGFrame(fileName):
            return "PNG 프레임 \(fileName)을 불러올 수 없습니다."
        }
    }
}

enum PNGSequenceFolderLoader {
    static func load(from folderURL: URL) throws -> PNGSequencePetAsset {
        let frameURLs = try sortedPNGFrameURLs(in: folderURL)
        guard !frameURLs.isEmpty else {
            throw PNGSequenceFolderLoaderError.missingPNGFrames
        }

        let frames = try frameURLs.map { frameURL in
            guard let image = NSImage(contentsOf: frameURL) else {
                throw PNGSequenceFolderLoaderError.unreadablePNGFrame(frameURL.lastPathComponent)
            }
            return image
        }

        let maxFrameSize = frames.reduce(into: NSSize(width: 1, height: 1)) { currentMax, image in
            currentMax.width = max(currentMax.width, image.size.width)
            currentMax.height = max(currentMax.height, image.size.height)
        }

        return PNGSequencePetAsset(
            name: folderURL.lastPathComponent,
            folderURL: folderURL,
            frameURLs: frameURLs,
            frames: frames,
            maxFrameSize: maxFrameSize
        )
    }

    static func sortedPNGFrameURLs(in folderURL: URL) throws -> [URL] {
        let fileManager = FileManager.default
        guard let urls = try? fileManager.contentsOfDirectory(
            at: folderURL,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        ) else {
            throw PNGSequenceFolderLoaderError.inaccessibleFolder
        }

        return sortFrameURLs(urls)
    }

    static func sortFrameURLs(_ urls: [URL]) -> [URL] {
        urls
            .filter { $0.pathExtension.lowercased() == "png" }
            .sorted {
                $0.lastPathComponent.localizedStandardCompare($1.lastPathComponent) == .orderedAscending
            }
    }
}
