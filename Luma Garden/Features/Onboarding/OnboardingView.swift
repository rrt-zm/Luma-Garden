import SwiftUI

struct OnboardingView: View {
    @Environment(GameStore.self) private var store
    @Environment(\.luma) private var luma
    @State private var step = 0
    @State private var session: PuzzleSession

    init() {
        let layout = PuzzleLayout(
            id: "tutorial",
            name: "First Light",
            zoneId: "seed_field",
            rewardSpeciesId: "glimmercap",
            difficulty: 1,
            columns: 1,
            rows: 3,
            nodes: [
                PuzzleNode(id: 0, kind: .source, position: GridPoint(col: 0, row: 0)),
                PuzzleNode(id: 1, kind: .conductor, position: GridPoint(col: 0, row: 1)),
                PuzzleNode(id: 2, kind: .sink, position: GridPoint(col: 0, row: 2))
            ],
            optimalLinks: 2
        )
        let solver = FlowSolver()
        _session = State(initialValue: PuzzleSession(layout: layout) { l, links in
            solver.solve(layout: l, links: links)
        })
    }

    private let titles = ["Luma Garden", "Wire the Light", "Watch It Bloom", "Light Flows On", "Try It"]
    private let bodies = [
        "Grow a quiet garden from threads of light. Connect glowing nodes, and life will follow.",
        "Draw a link between two nodes to carry light. Source nodes emit; sinks wait to bloom.",
        "When light reaches a sink, a luminous plant unfurls — sprout, bloom, and mature.",
        "Mature plants give off light even while you are away. Spend it to grow your garden.",
        "Connect the source to the seed below. Drag between the two glowing nodes, or tap one then the other."
    ]

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Spacer(minLength: 20)
                ZStack {
                    switch step {
                    case 0: WelcomeArt()
                    case 1: WireArt()
                    case 2: BloomArt()
                    case 3: IdleArt()
                    default:
                        PuzzleBoardView(session: session, quality: store.state.settings.quality) {
                            store.playWire()
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, 30)

                VStack(spacing: 12) {
                    Text(titles[step])
                        .font(LumaFont.display(30))
                        .foregroundStyle(luma.text)
                    Text(bodies[step])
                        .font(LumaFont.body(16))
                        .foregroundStyle(luma.textSoft)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 320)
                        .frame(minHeight: 90, alignment: .top)
                }
                .padding(.horizontal, 24)

                HStack(spacing: 8) {
                    ForEach(0..<5, id: \.self) { index in
                        Capsule()
                            .fill(index == step ? luma.primary : luma.textFaint)
                            .frame(width: index == step ? 22 : 7, height: 7)
                            .animation(.spring(response: 0.3), value: step)
                    }
                }
                .padding(.vertical, 20)

                Group {
                    if step < 4 {
                        LumaButton(title: "Continue", icon: nil) {
                            store.playTap()
                            withAnimation(.easeInOut) { step += 1 }
                        }
                    } else {
                        LumaButton(title: session.isSolved ? "Enter the Garden" : "Connect the light", icon: session.isSolved ? .check : nil, enabled: session.isSolved) {
                            store.completeOnboarding()
                        }
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 16)

                Button("Skip") {
                    store.completeOnboarding()
                }
                .font(LumaFont.body(14))
                .foregroundStyle(luma.textFaint)
                .padding(.bottom, 20)
            }
        }
    }
}

private struct WelcomeArt: View {
    @Environment(\.luma) private var luma
    var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            Canvas { context, size in
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                let pulse = 0.5 + 0.5 * sin(t * 1.2)
                for ring in 0..<3 {
                    let r = 40.0 + Double(ring) * 30 + pulse * 12
                    let rect = CGRect(x: center.x - r, y: center.y - r, width: r * 2, height: r * 2)
                    context.stroke(Circle().path(in: rect), with: .color(luma.glow.opacity(0.3 - Double(ring) * 0.08)), lineWidth: 2)
                }
                let core = 26.0 + pulse * 6
                let coreRect = CGRect(x: center.x - core, y: center.y - core, width: core * 2, height: core * 2)
                context.fill(Circle().path(in: coreRect), with: .radialGradient(Gradient(colors: [luma.glow, luma.accent.opacity(0.2)]), center: center, startRadius: 0, endRadius: core))
            }
        }
    }
}

private struct WireArt: View {
    @Environment(\.luma) private var luma
    var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            Canvas { context, size in
                let a = CGPoint(x: size.width * 0.3, y: size.height * 0.5)
                let b = CGPoint(x: size.width * 0.7, y: size.height * 0.5)
                var line = Path(); line.move(to: a); line.addLine(to: b)
                context.stroke(line, with: .color(luma.glow.opacity(0.7)), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                let frac = (t * 0.5).truncatingRemainder(dividingBy: 1)
                let p = CGPoint(x: a.x + (b.x - a.x) * frac, y: a.y)
                context.fill(Circle().path(in: CGRect(x: p.x - 5, y: p.y - 5, width: 10, height: 10)), with: .color(luma.accentGlow))
                for (point, color) in [(a, luma.accent), (b, luma.primary)] {
                    context.fill(Circle().path(in: CGRect(x: point.x - 18, y: point.y - 18, width: 36, height: 36)), with: .color(color.opacity(0.25)))
                    context.stroke(Circle().path(in: CGRect(x: point.x - 18, y: point.y - 18, width: 36, height: 36)), with: .color(color), lineWidth: 2)
                }
            }
        }
    }
}

private struct BloomArt: View {
    @State private var progress: Double = 0.1
    var body: some View {
        PlantGlyph(species: ContentCatalog.species("starwort")!, progress: progress, swaySeed: 0.4)
            .onAppear {
                withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                    progress = 1
                }
            }
    }
}

private struct IdleArt: View {
    @Environment(\.luma) private var luma
    @State private var value: Double = 0
    var body: some View {
        VStack(spacing: 8) {
            GlyphView(glyph: .spark, size: 48, color: luma.accent, filled: true)
                .lumaGlow(luma.glow, radius: 16, intensity: 0.5)
            RollingValue(value: value, font: LumaFont.display(44))
            RollingValue(value: 12.5, font: LumaFont.mono(16), asRate: true)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 2.4).repeatForever(autoreverses: false)) {
                value = 9999
            }
        }
    }
}
