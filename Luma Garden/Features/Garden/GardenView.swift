import SwiftUI

struct GrowView: View {
    var body: some View {
        PuzzlePickerView()
    }
}

struct GardenView: View {
    @Environment(GameStore.self) private var store
    @Environment(\.luma) private var luma
    @State private var cultivating = false
    @State private var growing = false
    @State private var inspected: Plant?

    private var zone: Zone { store.currentZone() }
    private var plants: [Plant] { store.state.plants(inZone: zone.id) }
    private var capacity: Int { store.state.capacity(forZone: zone) }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                SectionHeader(title: zone.name, subtitle: zone.tagline)
                    .padding(.top, 8)

                if plants.isEmpty {
                    EmptyStateView(glyph: .garden, title: "A Quiet Bed of Soil", message: "Solve a light network to bloom your first plant, or cultivate a discovered seed.")
                        .frame(maxWidth: .infinity)
                }

                plotGrid

                HStack(spacing: 12) {
                    LumaButton(title: "Grow a Bloom", icon: .puzzle) {
                        store.playTap(); growing = true
                    }
                    LumaButton(title: "Cultivate", icon: .garden, prominent: false) {
                        store.playTap(); cultivating = true
                    }
                }

                expandRow
            }
            .padding(.horizontal, 18)
            .padding(.bottom, LumaMetric.tabBarInset)
        }
        .fullScreenCover(isPresented: $growing) {
            PuzzlePickerView(showsClose: true) { growing = false }
                .environment(store)
                .environment(\.luma, luma)
        }
        .sheet(isPresented: $cultivating) {
            CultivateSheet().environment(store).environment(\.luma, luma)
                .presentationDetents([.medium, .large])
                .presentationBackground(luma.backgroundBottom)
        }
        .sheet(item: $inspected) { plant in
            PlantDetailSheet(plant: plant).environment(store).environment(\.luma, luma)
                .presentationDetents([.medium])
                .presentationBackground(luma.backgroundBottom)
        }
    }

    private var plotGrid: some View {
        let columns = [GridItem(.adaptive(minimum: 92), spacing: 12)]
        return LazyVGrid(columns: columns, spacing: 12) {
            ForEach(0..<capacity, id: \.self) { slot in
                if let plant = plants.first(where: { $0.slot == slot }) {
                    plantCell(plant)
                } else {
                    emptyCell
                }
            }
        }
    }

    private func plantCell(_ plant: Plant) -> some View {
        let species = ContentCatalog.species(plant.speciesId)
        return Button {
            store.playTap(); inspected = plant
        } label: {
            VStack(spacing: 6) {
                PlantGlyph(species: species ?? ContentCatalog.species[0], progress: plant.progress, swaySeed: plant.swaySeed, glowEnabled: store.state.settings.quality.glowEnabled)
                    .frame(height: 86)
                Text(species?.name ?? "")
                    .font(LumaFont.body(11))
                    .foregroundStyle(luma.textSoft)
                    .lineLimit(1)
                LumaProgressBar(progress: plant.progress, tint: luma.rarity(species?.rarity ?? .common))
                    .padding(.horizontal, 8)
            }
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: LumaMetric.cornerMedium, style: .continuous)
                    .fill(luma.panel)
                    .overlay(RoundedRectangle(cornerRadius: LumaMetric.cornerMedium).stroke(luma.panelStroke, lineWidth: 1))
            )
        }
        .buttonStyle(PressableStyle())
    }

    private var emptyCell: some View {
        Button {
            store.playTap(); cultivating = true
        } label: {
            VStack(spacing: 8) {
                GlyphView(glyph: .garden, size: 28, color: luma.textFaint)
                Text("Empty plot").font(LumaFont.body(10)).foregroundStyle(luma.textFaint)
            }
            .frame(maxWidth: .infinity, minHeight: 132)
            .background(
                RoundedRectangle(cornerRadius: LumaMetric.cornerMedium, style: .continuous)
                    .stroke(style: StrokeStyle(lineWidth: 1.4, dash: [6, 6]))
                    .foregroundStyle(luma.panelStroke)
            )
        }
        .buttonStyle(PressableStyle())
    }

    private var expandRow: some View {
        let cost = store.expandCost(zoneId: zone.id)
        return GlowPanel {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Expand the bed").font(LumaFont.title(15)).foregroundStyle(luma.text)
                    Text("\(plants.count)/\(capacity) plots used").font(LumaFont.body(12)).foregroundStyle(luma.textSoft)
                }
                Spacer()
                Button {
                    if store.expandPlot(zoneId: zone.id) { store.playTap() }
                } label: {
                    HStack(spacing: 6) {
                        GlyphView(glyph: .spark, size: 13, color: luma.accent)
                        Text(EnergyFormatter.string(cost)).font(LumaFont.mono(13))
                    }
                    .foregroundStyle(store.state.energy.canSpend(cost) ? luma.text : luma.textFaint)
                    .padding(.horizontal, 14).padding(.vertical, 9)
                    .background(Capsule().stroke(luma.primary.opacity(store.state.energy.canSpend(cost) ? 0.6 : 0.2), lineWidth: 1.4))
                }
                .buttonStyle(PressableStyle())
                .disabled(!store.state.energy.canSpend(cost))
            }
            .padding(14)
        }
    }
}
