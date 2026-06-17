import SwiftUI

extension View {
    func lumaGlow(_ color: Color, radius: CGFloat = 12, intensity: Double = 0.8) -> some View {
        self
            .shadow(color: color.opacity(intensity * 0.6), radius: radius * 0.5)
            .shadow(color: color.opacity(intensity * 0.35), radius: radius)
    }
}

struct PressableStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .opacity(configuration.isPressed ? 0.85 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct GlowPanel<Content: View>: View {
    @Environment(\.luma) private var luma
    var strong: Bool = false
    @ViewBuilder var content: Content

    var body: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: LumaMetric.cornerMedium, style: .continuous)
                    .fill(strong ? luma.panelStrong : luma.panel)
                    .overlay(
                        RoundedRectangle(cornerRadius: LumaMetric.cornerMedium, style: .continuous)
                            .stroke(luma.panelStroke, lineWidth: 1)
                    )
            )
    }
}

struct LumaButton: View {
    @Environment(\.luma) private var luma
    var title: String
    var icon: LumaGlyph?
    var prominent: Bool = true
    var enabled: Bool = true
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if let icon {
                    GlyphView(glyph: icon, size: 18, color: prominent ? luma.backgroundBottom : luma.primary)
                }
                Text(title)
                    .font(LumaFont.title(16))
                    .kerning(0.5)
            }
            .foregroundStyle(prominent ? luma.backgroundBottom : luma.primary)
            .padding(.horizontal, 22)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(
                ZStack {
                    if prominent {
                        RoundedRectangle(cornerRadius: LumaMetric.cornerMedium, style: .continuous)
                            .fill(LinearGradient(colors: [luma.primary, luma.accent], startPoint: .topLeading, endPoint: .bottomTrailing))
                    } else {
                        RoundedRectangle(cornerRadius: LumaMetric.cornerMedium, style: .continuous)
                            .stroke(luma.primary.opacity(0.6), lineWidth: 1.4)
                    }
                }
            )
            .lumaGlow(prominent ? luma.glow : .clear, radius: prominent ? 16 : 0, intensity: enabled ? 0.7 : 0)
            .opacity(enabled ? 1 : 0.4)
        }
        .buttonStyle(PressableStyle())
        .disabled(!enabled)
    }
}

struct CurrencyChip: View {
    @Environment(\.luma) private var luma
    var icon: LumaGlyph
    var value: Double
    var tint: Color?
    var asRate: Bool = false

    var body: some View {
        HStack(spacing: 7) {
            GlyphView(glyph: icon, size: 15, color: tint ?? luma.accent, filled: icon == .spark)
            Text(asRate ? EnergyFormatter.rate(value) : EnergyFormatter.string(value))
                .font(LumaFont.mono(15))
                .foregroundStyle(luma.text)
                .contentTransition(.numericText(value: value))
                .animation(.easeOut(duration: 0.4), value: value)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(
            Capsule(style: .continuous)
                .fill(luma.panel)
                .overlay(Capsule().stroke(luma.panelStroke, lineWidth: 1))
        )
    }
}

struct RollingValue: View {
    @Environment(\.luma) private var luma
    var value: Double
    var font: Font
    var asRate: Bool = false

    var body: some View {
        Text(asRate ? EnergyFormatter.rate(value) : EnergyFormatter.string(value))
            .font(font)
            .foregroundStyle(luma.text)
            .contentTransition(.numericText(value: value))
            .animation(.easeOut(duration: 0.5), value: value)
    }
}

struct SectionHeader: View {
    @Environment(\.luma) private var luma
    var title: String
    var subtitle: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(LumaFont.display(22))
                .foregroundStyle(luma.text)
            if let subtitle {
                Text(subtitle)
                    .font(LumaFont.body(13))
                    .foregroundStyle(luma.textSoft)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct LumaProgressBar: View {
    @Environment(\.luma) private var luma
    var progress: Double
    var tint: Color?

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(luma.panelStroke)
                Capsule()
                    .fill(LinearGradient(colors: [(tint ?? luma.primary), (tint ?? luma.accent)], startPoint: .leading, endPoint: .trailing))
                    .frame(width: max(0, min(1, progress)) * geo.size.width)
                    .lumaGlow(tint ?? luma.glow, radius: 8, intensity: 0.6)
                    .animation(.easeOut(duration: 0.4), value: progress)
            }
        }
        .frame(height: 8)
    }
}

struct LumaLoader: View {
    @Environment(\.luma) private var luma
    @State private var spin = false

    var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            Canvas { context, size in
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                for i in 0..<6 {
                    let a = Double(i) / 6 * 2 * .pi + t * 1.6
                    let r = size.width * 0.32
                    let pulse = 0.4 + 0.6 * (0.5 + 0.5 * sin(t * 2 + Double(i)))
                    let pt = CGPoint(x: center.x + cos(a) * r, y: center.y + sin(a) * r)
                    let dot = CGRect(x: pt.x - 4, y: pt.y - 4, width: 8, height: 8)
                    context.fill(Circle().path(in: dot), with: .color(luma.glow.opacity(pulse)))
                }
            }
        }
        .frame(width: 56, height: 56)
    }
}

struct EmptyStateView: View {
    @Environment(\.luma) private var luma
    var glyph: LumaGlyph
    var title: String
    var message: String

    var body: some View {
        VStack(spacing: 14) {
            GlyphView(glyph: glyph, size: 52, color: luma.primary.opacity(0.7))
                .lumaGlow(luma.glow, radius: 14, intensity: 0.4)
            Text(title)
                .font(LumaFont.title(18))
                .foregroundStyle(luma.text)
            Text(message)
                .font(LumaFont.body(14))
                .foregroundStyle(luma.textSoft)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 280)
        }
        .padding(40)
    }
}

struct LumaToast: View {
    @Environment(\.luma) private var luma
    var text: String
    var glyph: LumaGlyph

    var body: some View {
        HStack(spacing: 10) {
            GlyphView(glyph: glyph, size: 18, color: luma.accent)
            Text(text)
                .font(LumaFont.title(15))
                .foregroundStyle(luma.text)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(
            Capsule(style: .continuous)
                .fill(luma.panelStrong)
                .overlay(Capsule().stroke(luma.panelStroke, lineWidth: 1))
        )
        .lumaGlow(luma.glow, radius: 14, intensity: 0.4)
    }
}

struct StatPill: View {
    @Environment(\.luma) private var luma
    var label: String
    var value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(LumaFont.display(20))
                .foregroundStyle(luma.primary)
            Text(label)
                .font(LumaFont.body(11))
                .foregroundStyle(luma.textSoft)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: LumaMetric.cornerSmall, style: .continuous)
                .fill(luma.panel)
                .overlay(RoundedRectangle(cornerRadius: LumaMetric.cornerSmall).stroke(luma.panelStroke, lineWidth: 1))
        )
    }
}
