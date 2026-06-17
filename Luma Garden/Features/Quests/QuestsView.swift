import SwiftUI

struct QuestsView: View {
    @Environment(GameStore.self) private var store
    @Environment(\.luma) private var luma

    private var sortedQuests: [Quest] {
        ContentCatalog.quests.sorted { lhs, rhs in
            let lc = store.isQuestClaimed(lhs)
            let rc = store.isQuestClaimed(rhs)
            if lc != rc { return !lc }
            return lhs.order < rhs.order
        }
    }

    var body: some View {
        LumaScreen(title: "Quests", subtitle: "Growth milestones, never time pressure.") {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(sortedQuests) { quest in
                        questCard(quest)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.bottom, LumaMetric.tabBarInset)
            }
        }
    }

    private func questCard(_ quest: Quest) -> some View {
        let progress = store.questProgress(quest)
        let complete = store.isQuestComplete(quest)
        let claimed = store.isQuestClaimed(quest)
        let fraction = min(1, progress / quest.target)
        return GlowPanel {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(quest.title).font(LumaFont.title(16)).foregroundStyle(luma.text)
                        Text(quest.detail).font(LumaFont.body(12)).foregroundStyle(luma.textSoft)
                    }
                    Spacer()
                    if claimed {
                        GlyphView(glyph: .check, size: 22, color: luma.success)
                    }
                }
                LumaProgressBar(progress: fraction, tint: complete ? luma.success : luma.primary)
                HStack {
                    Text("\(EnergyFormatter.string(min(progress, quest.target))) / \(EnergyFormatter.string(quest.target))")
                        .font(LumaFont.mono(12)).foregroundStyle(luma.textSoft)
                    Spacer()
                    Text(rewardText(quest.reward))
                        .font(LumaFont.body(12)).foregroundStyle(luma.accent)
                    if complete && !claimed {
                        Button {
                            store.playTap(); store.claimQuest(quest)
                        } label: {
                            Text("Claim").font(LumaFont.title(13)).foregroundStyle(luma.backgroundBottom)
                                .padding(.horizontal, 14).padding(.vertical, 7)
                                .background(Capsule().fill(LinearGradient(colors: [luma.primary, luma.accent], startPoint: .leading, endPoint: .trailing)))
                        }
                        .buttonStyle(PressableStyle())
                    }
                }
            }
            .padding(16)
            .opacity(claimed ? 0.6 : 1)
        }
    }

    private func rewardText(_ reward: Reward) -> String {
        switch reward.kind {
        case .energy: return "+\(EnergyFormatter.string(reward.amount)) light"
        case .spores: return "+\(Int(reward.amount)) spores"
        case .boost: return ContentCatalog.boost(reward.boostId ?? "")?.name ?? "Boost"
        }
    }
}
