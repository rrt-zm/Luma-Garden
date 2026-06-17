import SwiftUI

struct SolveOutcomeOverlay: View {
    @Environment(\.luma) private var luma
    let outcome: SolveOutcome
    var onDismiss: () -> Void
    @State private var appeared = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.5).ignoresSafeArea()
                .onTapGesture { onDismiss() }
            VStack(spacing: 18) {
                ZStack {
                    ForEach(0..<3) { ring in
                        Circle()
                            .stroke(luma.glow.opacity(0.3 - Double(ring) * 0.08), lineWidth: 2)
                            .frame(width: 90 + CGFloat(ring) * 28, height: 90 + CGFloat(ring) * 28)
                            .scaleEffect(appeared ? 1 : 0.4)
                            .opacity(appeared ? 1 : 0)
                    }
                    GlyphView(glyph: .spark, size: 56, color: luma.accent, filled: true)
                        .lumaGlow(luma.glow, radius: 20, intensity: 0.7)
                        .scaleEffect(appeared ? 1 : 0.2)
                }
                .frame(height: 150)

                Text(outcome.firstDiscovery ? "New Species Discovered" : "Network Solved")
                    .font(LumaFont.display(24))
                    .foregroundStyle(luma.text)
                Text(outcome.speciesName)
                    .font(LumaFont.title(18))
                    .foregroundStyle(luma.rarity(.radiant))

                HStack(spacing: 14) {
                    rewardPill(label: "Light", value: EnergyFormatter.string(outcome.energyReward))
                    rewardPill(label: "Elegance", value: "\(Int(outcome.efficiency * 100))%")
                    if outcome.bloomed {
                        rewardPill(label: "Bloom", value: "+1")
                    }
                }

                LumaButton(title: "Lovely", icon: .check) { onDismiss() }
                    .frame(maxWidth: 220)
            }
            .padding(28)
            .background(
                RoundedRectangle(cornerRadius: LumaMetric.cornerLarge, style: .continuous)
                    .fill(luma.backgroundBottom.opacity(0.96))
                    .overlay(RoundedRectangle(cornerRadius: LumaMetric.cornerLarge).stroke(luma.panelStroke, lineWidth: 1))
            )
            .padding(36)
            .scaleEffect(appeared ? 1 : 0.85)
            .opacity(appeared ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) { appeared = true }
        }
    }

    private func rewardPill(label: String, value: String) -> some View {
        VStack(spacing: 3) {
            Text(value).font(LumaFont.mono(16)).foregroundStyle(luma.primary)
            Text(label).font(LumaFont.body(11)).foregroundStyle(luma.textSoft)
        }
        .padding(.horizontal, 14).padding(.vertical, 10)
        .background(Capsule().fill(luma.panel))
    }
}
