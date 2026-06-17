import SwiftUI

enum LumaTab: Int, CaseIterable {
    case garden, grow, zones, upgrades, more

    var label: String {
        switch self {
        case .garden: return "Garden"
        case .grow: return "Grow"
        case .zones: return "Zones"
        case .upgrades: return "Upgrades"
        case .more: return "More"
        }
    }

    var glyph: LumaGlyph {
        switch self {
        case .garden: return .garden
        case .grow: return .puzzle
        case .zones: return .zones
        case .upgrades: return .upgrades
        case .more: return .settings
        }
    }
}

struct MainShell: View {
    @Environment(GameStore.self) private var store
    @Environment(\.luma) private var luma
    @State private var tab: LumaTab = .garden

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                TopHUD()
                    .padding(.horizontal, 18)
                    .padding(.top, 8)
                Group {
                    switch tab {
                    case .garden: GardenView()
                    case .grow: GrowView()
                    case .zones: ZonesView()
                    case .upgrades: UpgradesView()
                    case .more: MoreMenuView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            LumaTabBar(selection: $tab)
        }
    }
}

struct LumaTabBar: View {
    @Environment(GameStore.self) private var store
    @Environment(\.luma) private var luma
    @Binding var selection: LumaTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(LumaTab.allCases, id: \.self) { item in
                Button {
                    store.playTap()
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) { selection = item }
                } label: {
                    VStack(spacing: 5) {
                        GlyphView(glyph: item.glyph, size: 24, color: selection == item ? luma.primary : luma.textFaint)
                            .lumaGlow(selection == item ? luma.glow : .clear, radius: 10, intensity: 0.6)
                        Text(item.label)
                            .font(LumaFont.body(10))
                            .foregroundStyle(selection == item ? luma.primary : luma.textFaint)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .contentShape(Rectangle())
                }
                .buttonStyle(PressableStyle())
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 10)
        .padding(.bottom, 6)
        .background(
            UnevenRoundedRectangle(topLeadingRadius: LumaMetric.cornerLarge, topTrailingRadius: LumaMetric.cornerLarge, style: .continuous)
                .fill(luma.bar)
                .overlay(
                    UnevenRoundedRectangle(topLeadingRadius: LumaMetric.cornerLarge, topTrailingRadius: LumaMetric.cornerLarge, style: .continuous)
                        .stroke(luma.panelStroke, lineWidth: 1)
                )
                .lumaGlow(luma.isDark ? Color.black : .clear, radius: 18, intensity: 0.5)
                .ignoresSafeArea(edges: .bottom)
        )
    }
}

struct TopHUD: View {
    @Environment(GameStore.self) private var store
    @Environment(\.luma) private var luma

    var body: some View {
        VStack(spacing: 10) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 8) {
                        GlyphView(glyph: .spark, size: 22, color: luma.accent, filled: true)
                            .lumaGlow(luma.glow, radius: 10, intensity: 0.5)
                        RollingValue(value: store.state.energy, font: LumaFont.display(30))
                    }
                    RollingValue(value: store.energyPerSecond, font: LumaFont.mono(13), asRate: true)
                        .opacity(0.7)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 6) {
                    if store.state.spores > 0 {
                        CurrencyChip(icon: .prestige, value: store.state.spores, tint: luma.rarity(.radiant))
                    }
                    Text(store.currentZone().name)
                        .font(LumaFont.body(12))
                        .foregroundStyle(luma.textSoft)
                }
            }
            if !store.state.activeBoosts.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(store.state.activeBoosts) { active in
                            if let boost = ContentCatalog.boost(active.boostId) {
                                HStack(spacing: 6) {
                                    GlyphView(glyph: .boost, size: 13, color: luma.accent)
                                    Text(boost.name)
                                        .font(LumaFont.body(11))
                                        .foregroundStyle(luma.text)
                                    Text("\(Int(active.remaining))s")
                                        .font(LumaFont.mono(11))
                                        .foregroundStyle(luma.textSoft)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Capsule().fill(luma.panel).overlay(Capsule().stroke(luma.panelStroke, lineWidth: 1)))
                            }
                        }
                    }
                }
            }
        }
    }
}
