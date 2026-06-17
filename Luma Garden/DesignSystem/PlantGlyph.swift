import SwiftUI

struct PlantGlyph: View {
    var species: Species
    var progress: Double
    var swaySeed: Double
    var animated: Bool = true
    var glowEnabled: Bool = true

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: !animated)) { timeline in
            let t = animated ? timeline.date.timeIntervalSinceReferenceDate : 0
            Canvas { context, size in
                draw(context: &context, size: size, time: t)
            }
        }
    }

    private func draw(context: inout GraphicsContext, size: CGSize, time: Double) {
        let base = CGPoint(x: size.width / 2, y: size.height * 0.96)
        let stemHeight = size.height * 0.6 * max(0.12, progress)
        let sway = sin(time * 0.9 + swaySeed * 6.28) * size.width * 0.04 * progress
        let top = CGPoint(x: base.x + sway, y: base.y - stemHeight)

        let primary = Color(hue: species.huePrimary, saturation: 0.6, brightness: 1)
        let secondary = Color(hue: species.hueSecondary, saturation: 0.65, brightness: 1)

        var stem = Path()
        stem.move(to: base)
        stem.addQuadCurve(to: top, control: CGPoint(x: base.x + sway * 0.4, y: base.y - stemHeight * 0.5))
        context.stroke(stem, with: .color(primary.opacity(0.7)), style: StrokeStyle(lineWidth: max(1.6, size.width * 0.03), lineCap: .round))

        let bloom = max(0, (progress - 0.4) / 0.6)
        let flowerRadius = size.width * 0.16 * (0.4 + bloom)
        let pulse = 0.85 + 0.15 * sin(time * 1.6 + swaySeed * 3)

        if glowEnabled && bloom > 0 {
            let glowRect = CGRect(x: top.x - flowerRadius * 2, y: top.y - flowerRadius * 2, width: flowerRadius * 4, height: flowerRadius * 4)
            context.fill(Circle().path(in: glowRect), with: .radialGradient(
                Gradient(colors: [secondary.opacity(0.35 * bloom * pulse), .clear]),
                center: top, startRadius: 0, endRadius: flowerRadius * 2))
        }

        if progress < 0.4 {
            let budRadius = size.width * 0.06 * (0.6 + progress)
            let budRect = CGRect(x: top.x - budRadius, y: top.y - budRadius, width: budRadius * 2, height: budRadius * 2)
            context.fill(Circle().path(in: budRect), with: .color(primary.opacity(0.85)))
        } else {
            let petals = species.petals
            for i in 0..<petals {
                let angle = Double(i) / Double(petals) * 2 * .pi + time * 0.1
                var petal = Path()
                let tip = CGPoint(x: top.x + cos(angle) * flowerRadius, y: top.y + sin(angle) * flowerRadius)
                let left = CGPoint(x: top.x + cos(angle - 0.4) * flowerRadius * 0.5, y: top.y + sin(angle - 0.4) * flowerRadius * 0.5)
                let right = CGPoint(x: top.x + cos(angle + 0.4) * flowerRadius * 0.5, y: top.y + sin(angle + 0.4) * flowerRadius * 0.5)
                petal.move(to: top)
                petal.addQuadCurve(to: tip, control: left)
                petal.addQuadCurve(to: top, control: right)
                context.fill(petal, with: .linearGradient(
                    Gradient(colors: [primary.opacity(0.9), secondary.opacity(0.85)]),
                    startPoint: top, endPoint: tip))
            }
            let coreRadius = flowerRadius * 0.4 * pulse
            let coreRect = CGRect(x: top.x - coreRadius, y: top.y - coreRadius, width: coreRadius * 2, height: coreRadius * 2)
            context.fill(Circle().path(in: coreRect), with: .color(Color.white.opacity(0.9)))
        }
    }
}
