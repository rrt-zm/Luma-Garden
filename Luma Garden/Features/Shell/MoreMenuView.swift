import SwiftUI

enum MoreRoute: Hashable {
    case herbarium, quests, achievements, stats, zen, prestige, settings
}

struct MoreMenuView: View {
    @Environment(GameStore.self) private var store
    @Environment(\.luma) private var luma
    @State private var path: [MoreRoute] = []

    private struct Entry {
        var route: MoreRoute
        var glyph: LumaGlyph
        var title: String
        var subtitle: String
    }

    private var entries: [Entry] {
        [
            Entry(route: .herbarium, glyph: .codex, title: "Herbarium", subtitle: "\(store.state.discoveredSpeciesIds.count)/\(ContentCatalog.speciesCount) species discovered"),
            Entry(route: .quests, glyph: .quests, title: "Quests", subtitle: "Gentle goals and rewards"),
            Entry(route: .achievements, glyph: .check, title: "Achievements", subtitle: "\(store.state.unlockedAchievementIds.count)/\(ContentCatalog.achievements.count) unlocked"),
            Entry(route: .stats, glyph: .stats, title: "Statistics", subtitle: "Your lifetime of light"),
            Entry(route: .zen, glyph: .zen, title: "Zen Mode", subtitle: "Wire freely, no goals"),
            Entry(route: .prestige, glyph: .prestige, title: "Reseed the Garden", subtitle: store.canPrestige() ? "Ready to bloom anew" : "A long-term renewal"),
            Entry(route: .settings, glyph: .settings, title: "Settings", subtitle: "Sound, theme, and more")
        ]
    }

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(spacing: 12) {
                    SectionHeader(title: "More", subtitle: "Explore the deeper garden.")
                        .padding(.top, 8)
                    ForEach(entries, id: \.route) { entry in
                        Button {
                            store.playTap(); path.append(entry.route)
                        } label: {
                            GlowPanel {
                                HStack(spacing: 14) {
                                    ZStack {
                                        Circle().fill(luma.primary.opacity(0.16)).frame(width: 46, height: 46)
                                        GlyphView(glyph: entry.glyph, size: 24, color: luma.primary)
                                    }
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(entry.title).font(LumaFont.title(16)).foregroundStyle(luma.text)
                                        Text(entry.subtitle).font(LumaFont.body(12)).foregroundStyle(luma.textSoft)
                                    }
                                    Spacer()
                                    GlyphView(glyph: .quests, size: 16, color: luma.textFaint)
                                }
                                .padding(14)
                            }
                        }
                        .buttonStyle(PressableStyle())
                    }
                }
                .padding(.horizontal, 18)
                .padding(.bottom, LumaMetric.tabBarInset)
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            .navigationDestination(for: MoreRoute.self) { route in
                destination(route)
                    .environment(store)
                    .environment(\.luma, luma)
            }
        }
        .tint(luma.primary)
    }

    @ViewBuilder
    private func destination(_ route: MoreRoute) -> some View {
        switch route {
        case .herbarium: HerbariumView()
        case .quests: QuestsView()
        case .achievements: AchievementsView()
        case .stats: StatsView()
        case .zen: ZenView()
        case .prestige: PrestigeView()
        case .settings: SettingsView()
        }
    }
}
