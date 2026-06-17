import SwiftUI

struct PrestigeView: View {
    @Environment(GameStore.self) private var store
    @Environment(\.luma) private var luma
    @State private var confirming = false
    @State private var reseeding = false

    var body: some View {
        LumaScreen(title: "Reseed the Garden", subtitle: "Begin again, brighter than before.") {
            ScrollView {
                VStack(spacing: 22) {
                    ReseedOrb(active: reseeding)
                        .frame(height: 180)
                        .padding(.top, 10)

                    Text("Reseeding returns your garden to the Seed Field, releasing all light, plants, zones, and upgrades. In their place you gather Spores — permanent motes that brighten every future bloom.")
                        .font(LumaFont.body(14)).foregroundStyle(luma.textSoft)
                        .multilineTextAlignment(.center).frame(maxWidth: 340)

                    GlowPanel {
                        VStack(spacing: 14) {
                            row("Spores held", EnergyFormatter.string(store.state.spores))
                            divider
                            row("Spores from this garden", "+\(EnergyFormatter.string(store.prestigeGain()))")
                            divider
                            row("Current light bonus", "+\(currentBonusPercent)%")
                            divider
                            row("Bonus after reseed", "+\(futureBonusPercent)%")
                        }.padding(18)
                    }

                    if store.canPrestige() {
                        LumaButton(title: "Reseed Now", icon: .prestige) {
                            store.playTap(); confirming = true
                        }
                    } else {
                        VStack(spacing: 6) {
                            Text("Not yet ready").font(LumaFont.title(15)).foregroundStyle(luma.textSoft)
                            Text("Generate more lifetime light to gather your first spores.")
                                .font(LumaFont.body(12)).foregroundStyle(luma.textFaint)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.vertical, 8)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.bottom, LumaMetric.tabBarInset)
            }
        }
        .alert("Reseed the Garden?", isPresented: $confirming) {
            Button("Cancel", role: .cancel) {}
            Button("Reseed", role: .destructive) { performReseed() }
        } message: {
            Text("You will gain \(EnergyFormatter.string(store.prestigeGain())) spores. Your current garden will be released.")
        }
    }

    private var currentBonusPercent: Int {
        Int((store.state.prestigeMultiplier - 1) * 100)
    }

    private var futureBonusPercent: Int {
        let futureSpores = store.state.spores + store.prestigeGain()
        let multiplier = 1 + futureSpores * 0.02
        return Int((multiplier - 1) * 100)
    }

    private var divider: some View { Rectangle().fill(luma.panelStroke).frame(height: 1) }

    private func row(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).font(LumaFont.body(14)).foregroundStyle(luma.textSoft)
            Spacer()
            Text(value).font(LumaFont.mono(15)).foregroundStyle(luma.primary)
        }
    }

    private func performReseed() {
        withAnimation(.easeInOut(duration: 1.2)) { reseeding = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            store.prestige()
            reseeding = false
        }
    }
}

struct ReseedOrb: View {
    @Environment(\.luma) private var luma
    var active: Bool

    var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            Canvas { context, size in
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                let speed = active ? 3.0 : 0.6
                for i in 0..<12 {
                    let a = Double(i) / 12 * 2 * .pi + t * speed
                    let r = size.width * (active ? 0.1 + (t * 0.5).truncatingRemainder(dividingBy: 1) * 0.3 : 0.22)
                    let p = CGPoint(x: center.x + cos(a) * r, y: center.y + sin(a) * r)
                    context.fill(Circle().path(in: CGRect(x: p.x - 4, y: p.y - 4, width: 8, height: 8)), with: .color(luma.accentGlow.opacity(0.7)))
                }
                let core = size.width * (active ? 0.16 : 0.1) * (1 + 0.1 * sin(t * 2))
                context.fill(Circle().path(in: CGRect(x: center.x - core, y: center.y - core, width: core * 2, height: core * 2)), with: .radialGradient(Gradient(colors: [luma.glow, luma.accent.opacity(0.1)]), center: center, startRadius: 0, endRadius: core))
            }
        }
    }
}
