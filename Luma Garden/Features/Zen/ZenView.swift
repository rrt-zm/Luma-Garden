import SwiftUI

struct ZenView: View {
    @Environment(GameStore.self) private var store
    @Environment(\.luma) private var luma
    @State private var variant = 0
    @State private var session: PuzzleSession

    init() {
        let solver = FlowSolver()
        let layout = PuzzleFactory.zen(zoneId: "seed_field", variant: 0)
        _session = State(initialValue: PuzzleSession(layout: layout) { l, links in
            solver.solve(layout: l, links: links)
        })
    }

    var body: some View {
        LumaScreen(title: "Zen Mode", subtitle: "Wire freely. Watch the light. No goals here.") {
            VStack(spacing: 16) {
                PuzzleBoardView(session: session, quality: store.state.settings.quality) {
                    store.playWire()
                }
                .background(
                    RoundedRectangle(cornerRadius: LumaMetric.cornerLarge, style: .continuous)
                        .fill(luma.panel)
                        .overlay(RoundedRectangle(cornerRadius: LumaMetric.cornerLarge).stroke(luma.panelStroke, lineWidth: 1))
                )
                .overlay {
                    if session.isSolved {
                        Text("In harmony")
                            .font(LumaFont.title(15)).foregroundStyle(luma.success)
                            .padding(.horizontal, 16).padding(.vertical, 8)
                            .background(Capsule().fill(luma.panelStrong))
                            .offset(y: 8)
                            .transition(.opacity)
                    }
                }
                .padding(.horizontal, 18)

                HStack(spacing: 12) {
                    LumaButton(title: "Clear", icon: .close, prominent: false) {
                        store.playTap(); session.clear()
                    }
                    LumaButton(title: "New Pattern", icon: .zen) {
                        newPattern()
                    }
                }
                .padding(.horizontal, 18)
                .padding(.bottom, LumaMetric.tabBarInset)
            }
        }
        .animation(.easeInOut, value: session.isSolved)
    }

    private func newPattern() {
        store.playTap()
        variant += 1
        let solver = FlowSolver()
        let zoneId = store.state.currentZoneId
        let layout = PuzzleFactory.zen(zoneId: zoneId, variant: variant)
        session = PuzzleSession(layout: layout) { l, links in
            solver.solve(layout: l, links: links)
        }
    }
}
