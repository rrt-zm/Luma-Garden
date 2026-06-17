import SwiftUI

struct SettingsView: View {
    @Environment(GameStore.self) private var store
    @Environment(\.luma) private var luma
    @State private var confirmingReset = false
    @State private var didResetTutorial = false

    private var settings: GameSettings { store.state.settings }

    var body: some View {
        LumaScreen(title: "Settings", subtitle: "Tune the mood to your liking.") {
            ScrollView {
                VStack(spacing: 18) {
                    GlowPanel {
                        VStack(spacing: 4) {
                            toggleRow("Sound Effects", isOn: settings.soundEnabled) { update { $0.soundEnabled = !$0.soundEnabled } }
                            divider
                            toggleRow("Ambient Music", isOn: settings.musicEnabled) { update { $0.musicEnabled = !$0.musicEnabled } }
                            divider
                            toggleRow("Ambience Layer", isOn: settings.ambienceEnabled) { update { $0.ambienceEnabled = !$0.ambienceEnabled } }
                            divider
                            toggleRow("Haptics", isOn: settings.hapticsEnabled) { update { $0.hapticsEnabled = !$0.hapticsEnabled } }
                        }.padding(8)
                    }

                    pickerCard(title: "Theme") {
                        ForEach(ThemePreference.allCases, id: \.self) { option in
                            segment(option.label, selected: settings.theme == option) {
                                update { $0.theme = option }
                            }
                        }
                    }

                    pickerCard(title: "Visual Quality") {
                        ForEach(QualityPreference.allCases, id: \.self) { option in
                            segment(option.label, selected: settings.quality == option) {
                                update { $0.quality = option }
                            }
                        }
                    }

                    GlowPanel {
                        VStack(spacing: 12) {
                            actionRow("Replay Tutorial", detail: didResetTutorial ? "Will show on next launch" : "Walk through the basics again") {
                                store.resetTutorial(); didResetTutorial = true
                            }
                            divider
                            actionRow("Reset Progress", detail: "Erase everything and start fresh", destructive: true) {
                                confirmingReset = true
                            }
                        }.padding(14)
                    }

                    aboutCard
                }
                .padding(.horizontal, 18)
                .padding(.bottom, LumaMetric.tabBarInset)
            }
        }
        .alert("Reset all progress?", isPresented: $confirmingReset) {
            Button("Cancel", role: .cancel) {}
            Button("Reset Everything", role: .destructive) { store.resetProgress() }
        } message: {
            Text("This permanently erases your garden, light, unlocks, and collection. This cannot be undone.")
        }
    }

    private func update(_ change: (inout GameSettings) -> Void) {
        var copy = store.state.settings
        change(&copy)
        store.updateSettings(copy)
        store.playTap()
    }

    private var divider: some View { Rectangle().fill(luma.panelStroke).frame(height: 1).padding(.horizontal, 8) }

    private func toggleRow(_ title: String, isOn: Bool, toggle: @escaping () -> Void) -> some View {
        Button(action: toggle) {
            HStack {
                Text(title).font(LumaFont.body(15)).foregroundStyle(luma.text)
                Spacer()
                ZStack {
                    Capsule().fill(isOn ? AnyShapeStyle(LinearGradient(colors: [luma.primary, luma.accent], startPoint: .leading, endPoint: .trailing)) : AnyShapeStyle(luma.panelStroke))
                        .frame(width: 46, height: 28)
                    Circle().fill(.white).frame(width: 22, height: 22)
                        .offset(x: isOn ? 9 : -9)
                        .lumaGlow(isOn ? luma.glow : .clear, radius: 6, intensity: 0.5)
                }
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isOn)
            }
            .padding(.horizontal, 10).padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableStyle())
    }

    private func pickerCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        GlowPanel {
            VStack(alignment: .leading, spacing: 10) {
                Text(title).font(LumaFont.title(15)).foregroundStyle(luma.text)
                HStack(spacing: 8) { content() }
            }.padding(14)
        }
    }

    private func segment(_ label: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(LumaFont.body(13))
                .foregroundStyle(selected ? luma.backgroundBottom : luma.textSoft)
                .frame(maxWidth: .infinity).padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: LumaMetric.cornerSmall, style: .continuous)
                        .fill(selected ? AnyShapeStyle(LinearGradient(colors: [luma.primary, luma.accent], startPoint: .leading, endPoint: .trailing)) : AnyShapeStyle(luma.panel))
                )
        }
        .buttonStyle(PressableStyle())
    }

    private func actionRow(_ title: String, detail: String, destructive: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: { store.playTap(); action() }) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(title).font(LumaFont.title(15)).foregroundStyle(destructive ? luma.warning : luma.text)
                    Text(detail).font(LumaFont.body(12)).foregroundStyle(luma.textSoft)
                }
                Spacer()
                GlyphView(glyph: .quests, size: 16, color: luma.textFaint)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableStyle())
    }

    private var aboutCard: some View {
        GlowPanel {
            VStack(spacing: 8) {
                Text("Luma Garden").font(LumaFont.display(20)).foregroundStyle(luma.text)
                Text("A meditative garden grown from light. Connect, bloom, and let it glow — entirely offline, at your own pace.")
                    .font(LumaFont.body(13)).foregroundStyle(luma.textSoft)
                    .multilineTextAlignment(.center)
                Text("Version 1.0").font(LumaFont.mono(11)).foregroundStyle(luma.textFaint)
            }
            .frame(maxWidth: .infinity)
            .padding(18)
        }
    }
}
