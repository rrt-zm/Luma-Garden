import SwiftUI

struct RootView: View {
    @Environment(GameStore.self) private var store
    @Environment(\.colorScheme) private var systemScheme

    private var theme: LumaTheme {
        LumaTheme.make(zone: store.currentZone(), preference: store.state.settings.theme, systemDark: systemScheme == .dark)
    }

    var body: some View {
        ZStack {
            LumaBackground(theme: theme, quality: store.state.settings.quality)
                .animation(.easeInOut(duration: 0.6), value: store.state.currentZoneId)

            if store.state.onboardingComplete {
                MainShell()
                    .transition(.opacity)
            } else {
                OnboardingView()
                    .transition(.opacity)
            }

            if let summary = store.pendingOfflineSummary {
                AwaySummaryView(summary: summary) {
                    withAnimation(.easeInOut) { store.pendingOfflineSummary = nil }
                }
                .transition(.opacity)
                .zIndex(10)
            }

            if let outcome = store.lastSolveOutcome {
                SolveOutcomeOverlay(outcome: outcome) {
                    withAnimation(.spring()) { store.lastSolveOutcome = nil }
                }
                .transition(.opacity)
                .zIndex(11)
            }

            if let name = store.recentUnlockName {
                VStack {
                    LumaToast(text: "Unlocked \(name)", glyph: .check)
                        .padding(.top, 60)
                    Spacer()
                }
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(12)
                .task(id: name) {
                    try? await Task.sleep(nanoseconds: 2_200_000_000)
                    withAnimation(.easeInOut) { store.recentUnlockName = nil }
                }
            }
        }
        .environment(\.luma, theme)
        .animation(.easeInOut(duration: 0.4), value: store.state.onboardingComplete)
    }
}
