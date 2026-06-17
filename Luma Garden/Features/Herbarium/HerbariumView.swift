import SwiftUI

struct HerbariumView: View {
    @Environment(GameStore.self) private var store
    @Environment(\.luma) private var luma
    @State private var inspected: Species?

    private let columns = [GridItem(.adaptive(minimum: 104), spacing: 12)]

    var body: some View {
        LumaScreen(title: "Herbarium", subtitle: "\(store.state.discoveredSpeciesIds.count) of \(ContentCatalog.speciesCount) species found") {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(ContentCatalog.zones) { zone in
                        let speciesList = ContentCatalog.species(inZone: zone.id)
                        if store.state.unlockedZoneIds.contains(zone.id) || store.state.discoveredSpeciesIds.contains(where: { id in speciesList.contains { $0.id == id } }) {
                            VStack(alignment: .leading, spacing: 10) {
                                Text(zone.name).font(LumaFont.title(17)).foregroundStyle(luma.text)
                                LazyVGrid(columns: columns, spacing: 12) {
                                    ForEach(speciesList) { species in
                                        cell(species)
                                    }
                                }
                            }
                        }
                    }

                    nodeTypesSection
                }
                .padding(.horizontal, 18)
                .padding(.bottom, LumaMetric.tabBarInset)
            }
        }
        .sheet(item: $inspected) { species in
            SpeciesDetailSheet(species: species).environment(store).environment(\.luma, luma)
                .presentationDetents([.medium]).presentationBackground(luma.backgroundBottom)
        }
    }

    private func cell(_ species: Species) -> some View {
        let found = store.state.discoveredSpeciesIds.contains(species.id)
        return Button {
            if found { store.playTap(); inspected = species }
        } label: {
            VStack(spacing: 6) {
                if found {
                    PlantGlyph(species: species, progress: 1, swaySeed: species.huePrimary, glowEnabled: store.state.settings.quality.glowEnabled)
                        .frame(height: 74)
                    Text(species.name).font(LumaFont.body(11)).foregroundStyle(luma.text).lineLimit(1)
                    Text(species.rarity.label).font(LumaFont.body(9)).foregroundStyle(luma.rarity(species.rarity))
                } else {
                    GlyphView(glyph: .lock, size: 28, color: luma.textFaint)
                        .frame(height: 74)
                    Text("Undiscovered").font(LumaFont.body(10)).foregroundStyle(luma.textFaint)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: LumaMetric.cornerMedium, style: .continuous)
                    .fill(luma.panel)
                    .overlay(RoundedRectangle(cornerRadius: LumaMetric.cornerMedium).stroke(found ? luma.rarity(species.rarity).opacity(0.4) : luma.panelStroke, lineWidth: 1))
            )
        }
        .buttonStyle(PressableStyle())
    }

    private var nodeTypesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Node Types").font(LumaFont.title(17)).foregroundStyle(luma.text)
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(NodeKind.allCases, id: \.self) { kind in
                    let known = store.state.unlockedNodeKinds.contains(kind.rawValue)
                    VStack(spacing: 6) {
                        if known {
                            NodeGlyph(kind: kind, size: 40, color: luma.node(kind)).frame(height: 56)
                            Text(kind.displayName).font(LumaFont.body(11)).foregroundStyle(luma.text)
                        } else {
                            GlyphView(glyph: .lock, size: 24, color: luma.textFaint).frame(height: 56)
                            Text("Locked").font(LumaFont.body(10)).foregroundStyle(luma.textFaint)
                        }
                    }
                    .frame(maxWidth: .infinity).padding(.vertical, 10)
                    .background(RoundedRectangle(cornerRadius: LumaMetric.cornerMedium).fill(luma.panel).overlay(RoundedRectangle(cornerRadius: LumaMetric.cornerMedium).stroke(luma.panelStroke, lineWidth: 1)))
                }
            }
        }
    }
}

struct SpeciesDetailSheet: View {
    @Environment(GameStore.self) private var store
    @Environment(\.luma) private var luma
    let species: Species

    var body: some View {
        VStack(spacing: 14) {
            PlantGlyph(species: species, progress: 1, swaySeed: species.huePrimary, glowEnabled: store.state.settings.quality.glowEnabled)
                .frame(height: 150).padding(.top, 20)
            Text(species.name).font(LumaFont.display(24)).foregroundStyle(luma.text)
            Text(species.rarity.label).font(LumaFont.title(14)).foregroundStyle(luma.rarity(species.rarity))
            Text(species.description).font(LumaFont.body(14)).foregroundStyle(luma.textSoft)
                .multilineTextAlignment(.center).frame(maxWidth: 300)
            HStack(spacing: 12) {
                StatPill(label: "Base Output", value: EnergyFormatter.rate(species.baseRate))
                StatPill(label: "Growth", value: "\(Int(species.growthSeconds))s")
                StatPill(label: "Zone", value: ContentCatalog.zone(species.zoneId)?.name ?? "")
            }.padding(.horizontal, 18)
            Spacer()
        }.padding(.bottom, 20)
    }
}
