import AppKit

@MainActor
final class GameSceneView: NSView {
    private let asset: PetAsset
    private let metrics: PetLayoutMetrics
    private let state: GameState

    private let pixelCharacterView: PixelCharacterView?
    private let pngSequenceCharacterView: PNGSequenceCharacterView?
    private var animationTask: Task<Void, Never>?

    init(frame frameRect: NSRect, asset: PetAsset, metrics: PetLayoutMetrics) {
        self.asset = asset
        self.metrics = metrics
        state = GameState(activePreset: asset.scenePreset)

        switch asset {
        case .builtIn:
            pixelCharacterView = PixelCharacterView()
            pngSequenceCharacterView = nil
        case let .pngSequence(sequence):
            pixelCharacterView = nil
            pngSequenceCharacterView = PNGSequenceCharacterView(sequence: sequence)
        }

        super.init(frame: frameRect)
        translatesAutoresizingMaskIntoConstraints = false
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
        buildViewHierarchy()
        startAnimationLoop()
        refreshScene()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    deinit {
        animationTask?.cancel()
    }

    private func buildViewHierarchy() {
        let characterView: NSView
        if let pixelCharacterView {
            characterView = pixelCharacterView
            pixelCharacterView.onSlap = { [weak self] in
                self?.triggerSharedSlap()
            }
        } else if let pngSequenceCharacterView {
            characterView = pngSequenceCharacterView
            pngSequenceCharacterView.onSlap = { [weak self] in
                self?.triggerSharedSlap()
            }
        } else {
            return
        }

        addSubview(characterView)
        characterView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            characterView.centerXAnchor.constraint(equalTo: centerXAnchor),
            characterView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -metrics.bottomPadding),
            characterView.widthAnchor.constraint(equalToConstant: metrics.canvasSize.width),
            characterView.heightAnchor.constraint(equalToConstant: metrics.canvasSize.height)
        ])
    }

    private func startAnimationLoop() {
        animationTask = Task { [weak self] in
            while !Task.isCancelled {
                self?.refreshScene()
                let sleepDuration = UInt64(GameState.refreshInterval * 1_000_000_000)
                try? await Task.sleep(nanoseconds: sleepDuration)
            }
        }
    }

    func triggerPhysicalSlap() {
        triggerSharedSlap()
    }

    private func triggerSharedSlap() {
        state.triggerSlap(at: ProcessInfo.processInfo.systemUptime)
        refreshScene()
    }

    private func refreshScene() {
        let now = ProcessInfo.processInfo.systemUptime
        let reaction = state.reactionVisual(
            at: now,
            mood: .calm
        )

        switch asset {
        case let .builtIn(preset):
            pixelCharacterView?.update(preset: preset, reaction: reaction)
        case .pngSequence:
            pngSequenceCharacterView?.update(reaction: reaction, time: now)
        }
    }
}

@MainActor
final class PNGSequenceCharacterView: NSView {
    var onSlap: (() -> Void)?

    private let sequence: PNGSequencePetAsset
    private var currentFrame: NSImage?
    private var reaction = ReactionVisual(
        spriteOffset: .zero,
        leftArmOffset: .zero,
        rightArmOffset: .zero,
        bangsOffsetY: 0,
        eyeStyle: .open,
        mouthStyle: .smile,
        showImpactBurst: false
    )

    init(sequence: PNGSequencePetAsset) {
        self.sequence = sequence
        currentFrame = sequence.frames.first
        super.init(frame: .zero)
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        true
    }

    override func mouseDown(with event: NSEvent) {
        onSlap?()
    }

    func update(reaction: ReactionVisual, time: TimeInterval) {
        self.reaction = reaction

        let frameIndex = Int(floor(time / GameState.idleFrameDuration))
            .quotientAndRemainder(dividingBy: sequence.frames.count)
            .remainder
        currentFrame = sequence.frames[frameIndex]
        needsDisplay = true
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        guard let frame = currentFrame else {
            return
        }

        let maxFrameSize = sequence.maxFrameSize
        let scale = min(bounds.width / maxFrameSize.width, bounds.height / maxFrameSize.height, 1)
        let drawSize = NSSize(
            width: floor(frame.size.width * scale),
            height: floor(frame.size.height * scale)
        )
        let drawRect = NSRect(
            x: floor((bounds.width - drawSize.width) / 2 + reaction.spriteOffset.x),
            y: floor((bounds.height - drawSize.height) / 2 + reaction.spriteOffset.y),
            width: drawSize.width,
            height: drawSize.height
        )

        frame.draw(in: drawRect)

        if reaction.showImpactBurst {
            drawImpactBurst(anchorRect: drawRect)
        }
    }

    private func drawImpactBurst(anchorRect: NSRect) {
        let burstCenter = NSPoint(x: anchorRect.maxX - 8, y: anchorRect.midY + 18)
        let outerRect = NSRect(x: burstCenter.x - 10, y: burstCenter.y - 10, width: 20, height: 20)
        let innerRect = NSRect(x: burstCenter.x - 5, y: burstCenter.y - 5, width: 10, height: 10)

        ScenePalette.accentPink.setFill()
        NSBezierPath(ovalIn: outerRect).fill()
        ScenePalette.moon.setFill()
        NSBezierPath(ovalIn: innerRect).fill()
    }
}

@MainActor
final class PixelCharacterView: NSView {
    var onSlap: (() -> Void)?

    private var preset: PixelPetPreset = .defaultPreset
    private var reaction = ReactionVisual(
        spriteOffset: .zero,
        leftArmOffset: .zero,
        rightArmOffset: .zero,
        bangsOffsetY: 0,
        eyeStyle: .open,
        mouthStyle: .smile,
        showImpactBurst: false
    )

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        true
    }

    override func mouseDown(with event: NSEvent) {
        onSlap?()
    }

    func update(preset: PixelPetPreset, reaction: ReactionVisual) {
        self.preset = preset
        self.reaction = reaction
        needsDisplay = true
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        let palette = preset.palette

        let pixel = floor(min(bounds.width / 20, bounds.height / 26))
        let spriteWidth = pixel * 20
        let spriteHeight = pixel * 26
        let originX = floor((bounds.width - spriteWidth) / 2 + reaction.spriteOffset.x)
        let originY = floor((bounds.height - spriteHeight) / 2 + reaction.spriteOffset.y)

        drawPixelRect(x: 4, y: 1, w: 12, h: 1, color: palette.shadow, pixel: pixel, originX: originX, originY: originY)

        drawPixelRect(x: 8, y: 1, w: 1, h: 4, color: palette.skin, pixel: pixel, originX: originX, originY: originY)
        drawPixelRect(x: 11, y: 1, w: 1, h: 4, color: palette.skin, pixel: pixel, originX: originX, originY: originY)
        drawPixelRect(x: 7, y: 5, w: 6, h: 1, color: palette.outfitShadow, pixel: pixel, originX: originX, originY: originY)
        drawPixelRect(x: 6, y: 6, w: 8, h: 6, color: palette.outfit, pixel: pixel, originX: originX, originY: originY)
        drawPixelRect(
            x: 5 + reaction.leftArmOffset.x,
            y: 8 + reaction.leftArmOffset.y,
            w: 1,
            h: 3,
            color: palette.skin,
            pixel: pixel,
            originX: originX,
            originY: originY
        )
        drawPixelRect(
            x: 14 + reaction.rightArmOffset.x,
            y: 8 + reaction.rightArmOffset.y,
            w: 1,
            h: 3,
            color: palette.skin,
            pixel: pixel,
            originX: originX,
            originY: originY
        )
        drawPixelRect(x: 6, y: 12, w: 8, h: 1, color: palette.ribbon, pixel: pixel, originX: originX, originY: originY)

        drawPixelRect(x: 5, y: 12, w: 10, h: 9, color: palette.hairShadow, pixel: pixel, originX: originX, originY: originY)
        drawPixelRect(x: 6, y: 13, w: 8, h: 7, color: palette.skin, pixel: pixel, originX: originX, originY: originY)
        drawPixelRect(x: 4, y: 13, w: 2, h: 7, color: palette.hair, pixel: pixel, originX: originX, originY: originY)
        drawPixelRect(x: 14, y: 13, w: 2, h: 7, color: palette.hair, pixel: pixel, originX: originX, originY: originY)
        drawPixelRect(x: 5, y: 20, w: 10, h: 3, color: palette.hair, pixel: pixel, originX: originX, originY: originY)
        drawPixelRect(x: 8, y: 20 + reaction.bangsOffsetY, w: 4, h: 1, color: palette.hair, pixel: pixel, originX: originX, originY: originY)
        drawPixelRect(x: 6, y: 23, w: 8, h: 1, color: palette.ribbon, pixel: pixel, originX: originX, originY: originY)
        drawPixelRect(x: 4, y: 22, w: 2, h: 2, color: palette.ribbon, pixel: pixel, originX: originX, originY: originY)
        drawPixelRect(x: 14, y: 22, w: 2, h: 2, color: palette.ribbon, pixel: pixel, originX: originX, originY: originY)
        drawPixelRect(x: 7, y: 15, w: 1, h: 1, color: palette.blush, pixel: pixel, originX: originX, originY: originY)
        drawPixelRect(x: 12, y: 15, w: 1, h: 1, color: palette.blush, pixel: pixel, originX: originX, originY: originY)

        drawFace(pixel: pixel, originX: originX, originY: originY, palette: palette)

        if reaction.showImpactBurst {
            drawImpactBurst(pixel: pixel, originX: originX, originY: originY, palette: palette)
        }
    }

    private func drawFace(pixel: CGFloat, originX: CGFloat, originY: CGFloat, palette: PixelPetPalette) {
        switch reaction.eyeStyle {
        case .open:
            drawPixelRect(x: 8, y: 17, w: 1, h: 1, color: palette.eye, pixel: pixel, originX: originX, originY: originY)
            drawPixelRect(x: 11, y: 17, w: 1, h: 1, color: palette.eye, pixel: pixel, originX: originX, originY: originY)
        case .blink:
            drawPixelRect(x: 8, y: 17, w: 1, h: 1, color: palette.hairShadow, pixel: pixel, originX: originX, originY: originY)
            drawPixelRect(x: 11, y: 17, w: 1, h: 1, color: palette.hairShadow, pixel: pixel, originX: originX, originY: originY)
        case .pout:
            drawPixelRect(x: 7, y: 18, w: 2, h: 1, color: palette.eye, pixel: pixel, originX: originX, originY: originY)
            drawPixelRect(x: 11, y: 18, w: 2, h: 1, color: palette.eye, pixel: pixel, originX: originX, originY: originY)
        case .dizzy:
            drawPixelRect(x: 7, y: 16, w: 2, h: 1, color: palette.eye, pixel: pixel, originX: originX, originY: originY)
            drawPixelRect(x: 8, y: 17, w: 1, h: 2, color: palette.eye, pixel: pixel, originX: originX, originY: originY)
            drawPixelRect(x: 11, y: 16, w: 2, h: 1, color: palette.eye, pixel: pixel, originX: originX, originY: originY)
            drawPixelRect(x: 11, y: 17, w: 1, h: 2, color: palette.eye, pixel: pixel, originX: originX, originY: originY)
        case .shock:
            drawPixelRect(x: 8, y: 16, w: 1, h: 2, color: palette.eye, pixel: pixel, originX: originX, originY: originY)
            drawPixelRect(x: 11, y: 16, w: 1, h: 2, color: palette.eye, pixel: pixel, originX: originX, originY: originY)
        }

        switch reaction.mouthStyle {
        case .smile:
            drawPixelRect(x: 9, y: 14, w: 2, h: 1, color: palette.ribbon, pixel: pixel, originX: originX, originY: originY)
        case .neutral:
            drawPixelRect(x: 9, y: 14, w: 2, h: 1, color: palette.eye, pixel: pixel, originX: originX, originY: originY)
        case .pout:
            drawPixelRect(x: 9, y: 14, w: 2, h: 1, color: palette.blush, pixel: pixel, originX: originX, originY: originY)
        case .open:
            drawPixelRect(x: 9, y: 13, w: 2, h: 2, color: palette.ribbon, pixel: pixel, originX: originX, originY: originY)
        }
    }

    private func drawImpactBurst(pixel: CGFloat, originX: CGFloat, originY: CGFloat, palette: PixelPetPalette) {
        drawPixelRect(x: 15, y: 16, w: 2, h: 1, color: palette.impactOutline, pixel: pixel, originX: originX, originY: originY)
        drawPixelRect(x: 16, y: 15, w: 1, h: 3, color: palette.impact, pixel: pixel, originX: originX, originY: originY)
        drawPixelRect(x: 17, y: 16, w: 1, h: 1, color: palette.impactOutline, pixel: pixel, originX: originX, originY: originY)
        drawPixelRect(x: 15, y: 18, w: 1, h: 1, color: palette.impact, pixel: pixel, originX: originX, originY: originY)
    }

    private func drawPixelRect(
        x: CGFloat,
        y: CGFloat,
        w: CGFloat,
        h: CGFloat,
        color: NSColor,
        pixel: CGFloat,
        originX: CGFloat,
        originY: CGFloat
    ) {
        color.setFill()
        NSRect(
            x: originX + (x * pixel),
            y: originY + (y * pixel),
            width: w * pixel,
            height: h * pixel
        ).fill()
    }
}
