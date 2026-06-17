import SwiftUI

struct AwaySummaryView: View {
    @Environment(\.luma) private var luma
    let summary: OfflineSummary
    var onCollect: () -> Void
    @State private var appeared = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.55).ignoresSafeArea()
            VStack(spacing: 18) {
                ZStack {
                    ForEach(0..<8) { i in
                        Circle()
                            .fill(luma.glow.opacity(0.5))
                            .frame(width: 6, height: 6)
                            .offset(y: appeared ? -54 : 0)
                            .rotationEffect(.degrees(Double(i) / 8 * 360))
                            .opacity(appeared ? 0.8 : 0)
                    }
                    GlyphView(glyph: .garden, size: 52, color: luma.primary)
                        .lumaGlow(luma.glow, radius: 18, intensity: 0.6)
                }
                .frame(height: 120)

                Text("While You Were Away")
                    .font(LumaFont.display(24)).foregroundStyle(luma.text)
                Text("Your garden kept glowing for \(timeString(summary.elapsedSeconds)).")
                    .font(LumaFont.body(14)).foregroundStyle(luma.textSoft)
                    .multilineTextAlignment(.center)

                VStack(spacing: 12) {
                    metric(glyph: .spark, label: "Light gathered", value: EnergyFormatter.string(summary.energyEarned))
                    if summary.plantsMatured > 0 {
                        metric(glyph: .garden, label: "Plants matured", value: "\(summary.plantsMatured)")
                    }
                }
                .padding(.vertical, 4)

                if summary.wasCapped {
                    Text("Your reserves were full — upgrade storage to hold more.")
                        .font(LumaFont.body(11)).foregroundStyle(luma.textFaint)
                        .multilineTextAlignment(.center).frame(maxWidth: 260)
                }

                LumaButton(title: "Collect", icon: .check) { onCollect() }
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
        .onAppear { withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) { appeared = true } }
    }

    private func metric(glyph: LumaGlyph, label: String, value: String) -> some View {
        HStack(spacing: 12) {
            GlyphView(glyph: glyph, size: 22, color: luma.accent)
            Text(label).font(LumaFont.body(14)).foregroundStyle(luma.textSoft)
            Spacer()
            Text(value).font(LumaFont.mono(16)).foregroundStyle(luma.primary)
        }
        .padding(.horizontal, 18).padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(Capsule().fill(luma.panel))
    }

    private func timeString(_ seconds: Double) -> String {
        let total = Int(seconds)
        let h = total / 3600
        let m = (total % 3600) / 60
        if h > 0 { return "\(h)h \(m)m" }
        if m > 0 { return "\(m)m" }
        return "\(total)s"
    }
}
