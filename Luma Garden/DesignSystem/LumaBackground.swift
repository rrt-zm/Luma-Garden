import SwiftUI

struct Mote {
    var x: Double
    var y: Double
    var radius: Double
    var speed: Double
    var phase: Double
    var brightness: Double
}

struct LumaBackground: View {
    var theme: LumaTheme
    var quality: QualityPreference
    var animated: Bool = true

    private let motes: [Mote]

    init(theme: LumaTheme, quality: QualityPreference, animated: Bool = true) {
        self.theme = theme
        self.quality = quality
        self.animated = animated
        var rng = SeededGenerator(seed: 0x10F2A)
        self.motes = (0..<quality.moteCount).map { _ in
            Mote(
                x: Double.random(in: 0...1, using: &rng),
                y: Double.random(in: 0...1, using: &rng),
                radius: Double.random(in: 0.8...2.8, using: &rng),
                speed: Double.random(in: 0.005...0.03, using: &rng),
                phase: Double.random(in: 0...6.28, using: &rng),
                brightness: Double.random(in: 0.2...0.7, using: &rng)
            )
        }
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [theme.backgroundTop, theme.backgroundBottom],
                startPoint: .top,
                endPoint: .bottom
            )
            RadialGradient(
                colors: [theme.glow.opacity(theme.isDark ? 0.16 : 0.10), .clear],
                center: .init(x: 0.5, y: 0.32),
                startRadius: 8,
                endRadius: 460
            )
            if quality != .calm {
                TimelineView(.animation(minimumInterval: animated ? 1.0 / 30.0 : 1, paused: !animated)) { timeline in
                    Canvas { context, size in
                        let t = timeline.date.timeIntervalSinceReferenceDate
                        for mote in motes {
                            let drift = animated ? (t * mote.speed).truncatingRemainder(dividingBy: 1) : 0
                            let y = (mote.y - drift + 1).truncatingRemainder(dividingBy: 1)
                            let twinkle = 0.5 + 0.5 * sin(t * 0.8 + mote.phase)
                            let point = CGPoint(x: mote.x * size.width, y: y * size.height)
                            let r = mote.radius * (0.7 + 0.5 * twinkle)
                            let rect = CGRect(x: point.x - r, y: point.y - r, width: r * 2, height: r * 2)
                            context.fill(Circle().path(in: rect), with: .color(theme.glow.opacity(mote.brightness * twinkle * 0.5)))
                        }
                    }
                }
                .blendMode(theme.isDark ? .screen : .plusDarker)
            }
        }
        .ignoresSafeArea()
    }
}
