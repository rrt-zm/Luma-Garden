import SwiftUI

struct AchievementsView: View {
    @Environment(GameStore.self) private var store
    @Environment(\.luma) private var luma

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        LumaScreen(title: "Achievements", subtitle: "\(store.state.unlockedAchievementIds.count) of \(ContentCatalog.achievements.count) earned") {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(ContentCatalog.achievements) { achievement in
                        card(achievement)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.bottom, LumaMetric.tabBarInset)
            }
        }
    }

    private func card(_ achievement: Achievement) -> some View {
        let unlocked = store.isAchievementUnlocked(achievement)
        let progress = min(1, store.achievementProgress(achievement) / achievement.target)
        return VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(unlocked ? luma.accent.opacity(0.2) : luma.panel)
                    .frame(width: 60, height: 60)
                GlyphView(glyph: unlocked ? .prestige : .lock, size: 30, color: unlocked ? luma.accent : luma.textFaint)
                    .lumaGlow(unlocked && store.state.settings.quality.glowEnabled ? luma.glow : .clear, radius: 12, intensity: 0.6)
            }
            .scaleEffect(unlocked ? 1 : 0.92)
            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: unlocked)

            Text(achievement.title).font(LumaFont.title(14)).foregroundStyle(luma.text).multilineTextAlignment(.center)
            Text(achievement.detail).font(LumaFont.body(11)).foregroundStyle(luma.textSoft).multilineTextAlignment(.center)
            if !unlocked {
                LumaProgressBar(progress: progress)
                    .padding(.horizontal, 4)
            } else {
                Text("Earned").font(LumaFont.body(11)).foregroundStyle(luma.success)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .frame(minHeight: 190)
        .background(
            RoundedRectangle(cornerRadius: LumaMetric.cornerMedium, style: .continuous)
                .fill(luma.panel)
                .overlay(RoundedRectangle(cornerRadius: LumaMetric.cornerMedium).stroke(unlocked ? luma.accent.opacity(0.4) : luma.panelStroke, lineWidth: 1))
        )
    }
}
