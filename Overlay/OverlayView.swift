import SwiftUI

/// Shared pink used for the pig sprite's glow and its side letters (matches the pig art).
let pigPink = Color(red: 0.910, green: 0.624, blue: 0.596)

struct OverlayView: View {
    @ObservedObject var state: OverlayState

    @State private var animationProgress: CGFloat = 0
    @State private var leftLetters: [Character] = randomLetterArray(4)
    @State private var rightLetters: [Character] = randomLetterArray(4)
    @State private var lastSide: String? = nil

    // Timer for animation
    @State private var displayLink: DisplayLinkTimer? = nil
    @State private var elapsedTime: Double = 0

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            if state.isActive {
                ZStack {
                    // Semi-transparent darkened overlay
                    Color.black.opacity(state.overlayOpacity)

                    // Side letters - left
                    if state.lettersEnabled {
                        VStack(spacing: 12) {
                            ForEach(0..<leftLetters.count, id: \.self) { i in
                                Text(String(leftLetters[i]))
                                    .font(.system(size: 44, weight: .bold, design: .monospaced))
                                    .foregroundColor(letterColor)
                                    .shadow(color: .white.opacity(0.2), radius: 6)
                            }
                        }
                        .position(x: 40, y: h / 2)
                    }

                    // Side letters - right
                    if state.lettersEnabled {
                        VStack(spacing: 12) {
                            ForEach(0..<rightLetters.count, id: \.self) { i in
                                Text(String(rightLetters[i]))
                                    .font(.system(size: 44, weight: .bold, design: .monospaced))
                                    .foregroundColor(letterColor)
                                    .shadow(color: .white.opacity(0.2), radius: 6)
                            }
                        }
                        .position(x: w - 40, y: h / 2)
                    }

                    // Moving object
                    let pos = figureEightPosition(t: animationProgress, width: w, height: h)

                    OverlayObjectView(shape: state.shape, color: state.objectColor, heading: objectHeading)
                        .position(pos)
                        .shadow(color: (state.shape == "pig" ? pigPink : Color.green).opacity(0.5), radius: 16)
                }
                .onAppear {
                    refreshLetters()
                    startAnimation()
                }
                .onDisappear {
                    stopAnimation()
                }
                .onChange(of: state.shape) { _ in
                    refreshLetters()
                }
                .onChange(of: state.isActive) { newValue in
                    if newValue {
                        startAnimation()
                    } else {
                        stopAnimation()
                    }
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
    }

    // MARK: - Figure-8 Path

    func figureEightPosition(t: CGFloat, width: CGFloat, height: CGFloat) -> CGPoint {
        let angle = t * .pi * 2
        let x = width / 2 + (width * 0.42) * sin(angle)
        let y = height / 2 + (height * 0.08) * sin(angle * 2)
        return CGPoint(x: x, y: y)
    }

    var objectHeading: Double {
        let angle = animationProgress * .pi * 2
        let vx = cos(angle) // derivative of sin
        return vx > 0 ? 0 : .pi
    }

    // MARK: - Animation

    func startAnimation() {
        guard displayLink == nil else { return }
        elapsedTime = 0
        displayLink = DisplayLinkTimer { dt in
            elapsedTime += dt * state.speed
            animationProgress = CGFloat(elapsedTime.truncatingRemainder(dividingBy: 1.0))

            // Check for letter bounce
            let normalizedX = 0.5 + 0.42 * sin(animationProgress * .pi * 2)
            let currentSide: String? = normalizedX < 0.1 ? "left" : (normalizedX > 0.9 ? "right" : nil)

            if let side = currentSide, side != lastSide {
                if side == "left" {
                    leftLetters = randomLetters(4)
                } else {
                    rightLetters = randomLetters(4)
                }
                lastSide = side
            } else if currentSide == nil {
                lastSide = nil
            }
        }
    }

    func stopAnimation() {
        displayLink?.stop()
        displayLink = nil
    }

    // MARK: - Letters

    /// Side letters are pink for the pig and white for every other shape.
    var letterColor: Color {
        state.shape == "pig" ? pigPink : .white.opacity(0.85)
    }

    /// Pig uses the themed pool P,I,G,S,F,L,Y; other shapes use the full alphabet.
    var letterPool: String {
        state.shape == "pig" ? "PIGSFLY" : "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    }

    func randomLetters(_ count: Int) -> [Character] {
        let pool = letterPool
        return (0..<count).map { _ in pool.randomElement()! }
    }

    func refreshLetters() {
        leftLetters = randomLetters(4)
        rightLetters = randomLetters(4)
    }

    // MARK: - Helpers

    static func randomLetterArray(_ count: Int) -> [Character] {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        return (0..<count).map { _ in letters.randomElement()! }
    }
}

private func randomLetterArray(_ count: Int) -> [Character] {
    OverlayView.randomLetterArray(count)
}

// MARK: - Overlay Object Shape

struct OverlayObjectView: View {
    let shape: String
    let color: Color
    let heading: Double

    var body: some View {
        if shape == "pig" {
            // Pixel pig: drawn facing left; mirror horizontally when moving right.
            // Uses its own pink palette and a soft pink glow instead of the green object color.
            PixelPig()
                .scaleEffect(x: heading == 0 ? -1 : 1, y: 1)
                .shadow(color: pigPink.opacity(0.6), radius: 12)
                .shadow(color: pigPink.opacity(0.3), radius: 24)
        } else {
            Group {
                switch shape {
                case "triangle":
                    Triangle()
                        .fill(color)
                        .frame(width: 32, height: 28)
                        .rotationEffect(.radians(heading))
                case "circle":
                    Circle()
                        .fill(color)
                        .frame(width: 28, height: 28)
                case "diamond":
                    Rectangle()
                        .fill(color)
                        .frame(width: 22, height: 22)
                        .rotationEffect(.degrees(45))
                default:
                    Circle()
                        .fill(color)
                        .frame(width: 28, height: 28)
                }
            }
            .shadow(color: color.opacity(0.7), radius: 12)
            .shadow(color: color.opacity(0.4), radius: 24)
        }
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Pixel Pig

/// A side-view pixel-art pig facing LEFT, drawn from the `pig` asset (pig.png).
/// The source PNG has a solid white background, so the white is masked out to transparent
/// once at load time and the result is cached. Mirrored (not rotated) to face right.
struct PixelPig: View {
    private static let image: Image = {
        if let masked = makeMaskedImage() {
            return Image(nsImage: masked)
        }
        // Fallback: raw asset (shows white box) if masking ever fails to load.
        return Image("pig")
    }()

    var body: some View {
        Self.image
            .interpolation(.none)        // keep the pixel edges crisp when scaled
            .resizable()
            .scaledToFit()
            .frame(width: 48, height: 48)
    }

    /// Draws the asset into an opaque RGB context (downscaled), then masks near-white
    /// pixels to transparent via `CGImage.copy(maskingColorComponents:)`.
    private static func makeMaskedImage() -> NSImage? {
        guard let source = NSImage(named: "pig") else { return nil }

        let side = 256
        var proposed = CGRect(x: 0, y: 0, width: side, height: side)
        guard let sourceCG = source.cgImage(forProposedRect: &proposed, context: nil, hints: nil),
              let context = CGContext(
                data: nil,
                width: side,
                height: side,
                bitsPerComponent: 8,
                bytesPerRow: 0,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
              ) else { return nil }

        context.interpolationQuality = .high
        context.draw(sourceCG, in: CGRect(x: 0, y: 0, width: side, height: side))

        // Mask near-white (R,G,B each within [235, 255]) to transparent.
        let whiteRange: [CGFloat] = [235, 255, 235, 255, 235, 255]
        guard let opaque = context.makeImage(),
              let masked = opaque.copy(maskingColorComponents: whiteRange) else { return nil }

        return NSImage(cgImage: masked, size: NSSize(width: side, height: side))
    }
}

// MARK: - Display Link Timer (smooth 60fps animation)

class DisplayLinkTimer {
    private var displayLink: CVDisplayLink?
    private var callback: (Double) -> Void
    private var lastTime: Double = 0

    init(callback: @escaping (Double) -> Void) {
        self.callback = callback

        CVDisplayLinkCreateWithActiveCGDisplays(&displayLink)

        guard let displayLink = displayLink else { return }

        CVDisplayLinkSetOutputCallback(displayLink, { (_, inNow, inOutputTime, _, _, context) -> CVReturn in
            let timer = Unmanaged<DisplayLinkTimer>.fromOpaque(context!).takeUnretainedValue()
            let now = Double(inNow.pointee.videoTime) / Double(inNow.pointee.videoTimeScale)

            if timer.lastTime == 0 {
                timer.lastTime = now
            }
            let dt = min(now - timer.lastTime, 0.05) // cap at 50ms
            timer.lastTime = now

            DispatchQueue.main.async {
                timer.callback(dt)
            }

            return kCVReturnSuccess
        }, Unmanaged.passUnretained(self).toOpaque())

        CVDisplayLinkStart(displayLink)
    }

    func stop() {
        if let displayLink = displayLink {
            CVDisplayLinkStop(displayLink)
        }
        displayLink = nil
    }
}
