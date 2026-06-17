import SwiftUI

struct UpgradesView: View {
    @Environment(GameStore.self) private var store
    @Environment(\.luma) private var luma
    @State private var category: UpgradeCategory = .yield

    var body: some View {
        VStack(spacing: 0) {
            SectionHeader(title: "Upgrades", subtitle: "Shape how your garden gathers light.")
                .padding(.horizontal, 18).padding(.top, 8)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(UpgradeCategory.allCases, id: \.self) { cat in
                        Button {
                            store.playTap(); withAnimation(.spring(response: 0.3)) { category = cat }
                        } label: {
                            Text(cat.title)
                                .font(LumaFont.title(14))
                                .foregroundStyle(category == cat ? luma.backgroundBottom : luma.textSoft)
                                .padding(.horizontal, 16).padding(.vertical, 9)
                                .background(
                                    Capsule().fill(category == cat ? AnyShapeStyle(LinearGradient(colors: [luma.primary, luma.accent], startPoint: .leading, endPoint: .trailing)) : AnyShapeStyle(luma.panel))
                                )
                        }
                        .buttonStyle(PressableStyle())
                    }
                }
                .padding(.horizontal, 18).padding(.vertical, 12)
            }

            ScrollView {
                VStack(spacing: 12) {
                    Text(category.blurb)
                        .font(LumaFont.body(13)).foregroundStyle(luma.textSoft)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 4)
                    ForEach(ContentCatalog.upgrades.filter { $0.category == category }) { upgrade in
                        upgradeCard(upgrade)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.bottom, LumaMetric.tabBarInset)
            }
        }
    }

    private func upgradeCard(_ upgrade: Upgrade) -> some View {
        let level = store.state.upgradeLevel(upgrade.id)
        let maxed = level >= upgrade.maxLevel
        let cost = store.upgradeCost(upgrade)
        let canBuy = store.canBuyUpgrade(upgrade)
        let isAutomation = upgrade.category == .automation
        return GlowPanel {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(upgrade.name).font(LumaFont.title(16)).foregroundStyle(luma.text)
                        Text(upgrade.description).font(LumaFont.body(12)).foregroundStyle(luma.textSoft)
                    }
                    Spacer()
                    if isAutomation {
                        Text(level > 0 ? "Active" : "Locked")
                            .font(LumaFont.body(11))
                            .foregroundStyle(level > 0 ? luma.success : luma.textFaint)
                    } else {
                        Text("Lv \(level)/\(upgrade.maxLevel)")
                            .font(LumaFont.mono(13)).foregroundStyle(luma.accent)
                    }
                }
                if !isAutomation {
                    LumaProgressBar(progress: Double(level) / Double(upgrade.maxLevel))
                }
                HStack {
                    Text(effectText(upgrade, level: level))
                        .font(LumaFont.body(12)).foregroundStyle(luma.primary)
                    Spacer()
                    if maxed {
                        Text("Maxed").font(LumaFont.title(13)).foregroundStyle(luma.success)
                    } else {
                        Button {
                            store.playTap(); store.buyUpgrade(upgrade)
                        } label: {
                            HStack(spacing: 6) {
                                GlyphView(glyph: .spark, size: 13, color: canBuy ? luma.backgroundBottom : luma.textFaint)
                                Text(EnergyFormatter.string(cost)).font(LumaFont.mono(13))
                            }
                            .foregroundStyle(canBuy ? luma.backgroundBottom : luma.textFaint)
                            .padding(.horizontal, 16).padding(.vertical, 9)
                            .background(
                                Capsule().fill(canBuy ? AnyShapeStyle(LinearGradient(colors: [luma.primary, luma.accent], startPoint: .leading, endPoint: .trailing)) : AnyShapeStyle(luma.panel))
                            )
                        }
                        .buttonStyle(PressableStyle())
                        .disabled(!canBuy)
                    }
                }
            }
            .padding(16)
        }
    }

    private func effectText(_ upgrade: Upgrade, level: Int) -> String {
        switch upgrade.effect {
        case .yieldMultiplier: return "+\(Int(upgrade.value(atLevel: level) * 100))% light yield"
        case .growthSpeed: return "+\(Int(upgrade.value(atLevel: level) * 100))% growth speed"
        case .chainBonus: return "+\(Int(upgrade.value(atLevel: level) * 100))% chain bonus"
        case .offlineCap: return "+\(Int(upgrade.value(atLevel: level) / 3600))h offline light"
        case .startingLinks: return "+\(Int(upgrade.value(atLevel: level))) link capacity"
        case .autoHarvest: return level > 0 ? "Full offline light collected" : "Collects all offline light"
        case .autoPulse: return level > 0 ? "Mature plants pulse on their own" : "Plants pulse automatically"
        }
    }
}
