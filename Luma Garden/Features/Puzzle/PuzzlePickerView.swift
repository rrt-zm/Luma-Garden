import SwiftUI

struct PuzzlePickerView: View {
    @Environment(GameStore.self) private var store
    @Environment(\.luma) private var luma
    var showsClose: Bool = false
    var onClose: (() -> Void)? = nil

    @State private var selectedZoneId: String = ""
    @State private var playing: PuzzleLayout?

    private var zones: [Zone] { store.unlockedZones() }
    private var activeZoneId: String { selectedZoneId.isEmpty ? store.state.currentZoneId : selectedZoneId }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                SectionHeader(title: "Grow", subtitle: "Solve light networks to bloom new species.")
                if showsClose {
                    Button { onClose?() } label: {
                        GlyphView(glyph: .close, size: 20, color: luma.textSoft).padding(8).background(Circle().fill(luma.panel))
                    }.buttonStyle(PressableStyle())
                }
            }
            .padding(.horizontal, 18)
            .padding(.top, showsClose ? 24 : 12)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(zones) { zone in
                        zoneChip(zone)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
            }

            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(Array(store.availablePuzzles(zoneId: activeZoneId).enumerated()), id: \.element.id) { index, puzzle in
                        puzzleCard(puzzle, index: index)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.bottom, showsClose ? 30 : LumaMetric.tabBarInset)
            }
        }
        .fullScreenCover(item: $playing) { puzzle in
            PuzzlePlayView(layout: puzzle, store: store)
                .environment(\.luma, luma)
                .environment(store)
        }
        .onAppear { if selectedZoneId.isEmpty { selectedZoneId = store.state.currentZoneId } }
    }

    private func zoneChip(_ zone: Zone) -> some View {
        Button {
            store.playTap(); selectedZoneId = zone.id
        } label: {
            Text(zone.name)
                .font(LumaFont.title(14))
                .foregroundStyle(activeZoneId == zone.id ? luma.backgroundBottom : luma.textSoft)
                .padding(.horizontal, 16).padding(.vertical, 9)
                .background(
                    Capsule().fill(activeZoneId == zone.id ? AnyShapeStyle(LinearGradient(colors: [luma.primary, luma.accent], startPoint: .leading, endPoint: .trailing)) : AnyShapeStyle(luma.panel))
                )
        }
        .buttonStyle(PressableStyle())
    }

    private func puzzleCard(_ puzzle: PuzzleLayout, index: Int) -> some View {
        let solved = store.state.solvedPuzzleIds.contains(puzzle.id)
        let species = ContentCatalog.species(puzzle.rewardSpeciesId)
        return Button {
            store.playTap(); playing = puzzle
        } label: {
            GlowPanel {
                HStack(spacing: 14) {
                    ZStack {
                        Circle().fill(luma.node(.sink).opacity(0.18)).frame(width: 52, height: 52)
                        NodeGlyph(kind: .sink, size: 30, color: luma.rarity(species?.rarity ?? .common))
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text(puzzle.name).font(LumaFont.title(16)).foregroundStyle(luma.text)
                        HStack(spacing: 6) {
                            Text(species?.name ?? "").font(LumaFont.body(12)).foregroundStyle(luma.rarity(species?.rarity ?? .common))
                            Text("·").foregroundStyle(luma.textFaint)
                            Text("\(puzzle.nodes.count) nodes").font(LumaFont.body(12)).foregroundStyle(luma.textSoft)
                        }
                        difficultyDots(puzzle.difficulty)
                    }
                    Spacer()
                    if solved {
                        GlyphView(glyph: .check, size: 22, color: luma.success).lumaGlow(luma.success, radius: 8, intensity: 0.5)
                    } else {
                        GlyphView(glyph: .spark, size: 20, color: luma.accent)
                    }
                }
                .padding(14)
            }
        }
        .buttonStyle(PressableStyle())
    }

    private func difficultyDots(_ difficulty: Int) -> some View {
        let pips = min(5, 1 + difficulty / 8)
        return HStack(spacing: 3) {
            ForEach(0..<5, id: \.self) { i in
                Circle().fill(i < pips ? luma.accent : luma.textFaint).frame(width: 5, height: 5)
            }
        }
    }
}
