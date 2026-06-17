import SwiftUI

struct PuzzlePlayView: View {
    @Environment(GameStore.self) private var store
    @Environment(\.luma) private var luma
    @Environment(\.dismiss) private var dismiss
    let layout: PuzzleLayout
    @State private var session: PuzzleSession
    @State private var bloomFlash = false

    init(layout: PuzzleLayout, store: GameStore) {
        self.layout = layout
        _session = State(initialValue: PuzzleSession(layout: layout) { l, links in
            store.liveSolution(layout: l, links: links)
        })
    }

    private var litSinks: Int {
        let total = layout.nodes.filter { $0.kind == .sink }.count
        return total - session.solution.unpoweredSinks.count
    }

    private var totalSinks: Int { layout.nodes.filter { $0.kind == .sink }.count }

    var body: some View {
        ZStack {
            LumaBackground(theme: luma, quality: store.state.settings.quality)
            VStack(spacing: 14) {
                header
                statusBar
                PuzzleBoardView(session: session, quality: store.state.settings.quality) {
                    store.playWire()
                }
                .background(
                    RoundedRectangle(cornerRadius: LumaMetric.cornerLarge, style: .continuous)
                        .fill(luma.panel)
                        .overlay(RoundedRectangle(cornerRadius: LumaMetric.cornerLarge).stroke(luma.panelStroke, lineWidth: 1))
                )
                controls
            }
            .padding(18)

            if bloomFlash {
                Circle()
                    .fill(RadialGradient(colors: [luma.glow.opacity(0.5), .clear], center: .center, startRadius: 0, endRadius: 400))
                    .scaleEffect(bloomFlash ? 2.4 : 0.1)
                    .opacity(bloomFlash ? 0 : 0.8)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(layout.name)
                    .font(LumaFont.display(24))
                    .foregroundStyle(luma.text)
                Text("Light \(totalSinks) seed\(totalSinks == 1 ? "" : "s") to bloom \(ContentCatalog.species(layout.rewardSpeciesId)?.name ?? "")")
                    .font(LumaFont.body(13))
                    .foregroundStyle(luma.textSoft)
            }
            Spacer()
            Button {
                store.playTap(); dismiss()
            } label: {
                GlyphView(glyph: .close, size: 22, color: luma.textSoft)
                    .padding(10)
                    .background(Circle().fill(luma.panel))
            }
            .buttonStyle(PressableStyle())
        }
    }

    private var statusBar: some View {
        HStack(spacing: 10) {
            statusPill(label: "Seeds lit", value: "\(litSinks)/\(totalSinks)", tint: litSinks == totalSinks ? luma.success : luma.primary)
            statusPill(label: "Links", value: "\(session.links.count)", tint: luma.primary)
            statusPill(label: "Elegance", value: "\(Int(session.solution.efficiency * 100))%", tint: luma.accent)
        }
    }

    private func statusPill(label: String, value: String, tint: Color) -> some View {
        VStack(spacing: 2) {
            Text(value).font(LumaFont.mono(16)).foregroundStyle(tint)
            Text(label).font(LumaFont.body(10)).foregroundStyle(luma.textSoft)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Capsule().fill(luma.panel))
    }

    private var controls: some View {
        HStack(spacing: 12) {
            LumaButton(title: "Clear", icon: .close, prominent: false) {
                store.playTap(); session.clear()
            }
            LumaButton(title: session.isSolved ? "Bloom" : "Connect all seeds", icon: session.isSolved ? .spark : nil, enabled: session.isSolved) {
                triggerBloom()
            }
        }
    }

    private func triggerBloom() {
        withAnimation(.easeOut(duration: 0.8)) { bloomFlash = true }
        store.solve(layout: layout, links: session.links)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            dismiss()
        }
    }
}
