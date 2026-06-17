import SwiftUI

struct CultivateSheet: View {
    @Environment(GameStore.self) private var store
    @Environment(\.luma) private var luma
    @Environment(\.dismiss) private var dismiss

    private var discovered: [Species] {
        ContentCatalog.species.filter { store.state.discoveredSpeciesIds.contains($0.id) }
    }

    var body: some View {
        VStack(spacing: 0) {
            SectionHeader(title: "Cultivate", subtitle: "Plant a discovered seed into an empty plot.")
                .padding(18)
            if discovered.isEmpty {
                EmptyStateView(glyph: .codex, title: "No Seeds Yet", message: "Discover species by solving light networks, then cultivate them here.")
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(discovered) { species in
                            row(species)
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 30)
                }
            }
        }
    }

    private func row(_ species: Species) -> some View {
        let cost = store.cultivateCost(speciesId: species.id)
        let canAfford = store.state.energy.canSpend(cost)
        let hasRoom = store.canCultivate(speciesId: species.id)
        let zoneName = ContentCatalog.zone(species.zoneId)?.name ?? ""
        return GlowPanel {
            HStack(spacing: 12) {
                PlantGlyph(species: species, progress: 1, swaySeed: species.huePrimary, glowEnabled: store.state.settings.quality.glowEnabled)
                    .frame(width: 54, height: 54)
                VStack(alignment: .leading, spacing: 3) {
                    Text(species.name).font(LumaFont.title(15)).foregroundStyle(luma.text)
                    Text("\(species.rarity.label) · \(zoneName)").font(LumaFont.body(11)).foregroundStyle(luma.rarity(species.rarity))
                    Text(EnergyFormatter.rate(species.baseRate)).font(LumaFont.mono(11)).foregroundStyle(luma.textSoft)
                }
                Spacer()
                Button {
                    if store.cultivate(speciesId: species.id) { store.playTap() }
                } label: {
                    VStack(spacing: 2) {
                        Text(EnergyFormatter.string(cost)).font(LumaFont.mono(13))
                        Text(hasRoom ? "Plant" : "Full").font(LumaFont.body(10))
                    }
                    .foregroundStyle((canAfford && hasRoom) ? luma.backgroundBottom : luma.textFaint)
                    .padding(.horizontal, 14).padding(.vertical, 8)
                    .background(
                        Capsule().fill((canAfford && hasRoom) ? AnyShapeStyle(LinearGradient(colors: [luma.primary, luma.accent], startPoint: .leading, endPoint: .trailing)) : AnyShapeStyle(luma.panel))
                    )
                }
                .buttonStyle(PressableStyle())
                .disabled(!canAfford || !hasRoom)
            }
            .padding(12)
        }
    }
}

struct PlantDetailSheet: View {
    @Environment(GameStore.self) private var store
    @Environment(\.luma) private var luma
    let plant: Plant

    var body: some View {
        let species = ContentCatalog.species(plant.speciesId)
        VStack(spacing: 16) {
            PlantGlyph(species: species ?? ContentCatalog.species[0], progress: plant.progress, swaySeed: plant.swaySeed, glowEnabled: store.state.settings.quality.glowEnabled)
                .frame(height: 140)
                .padding(.top, 20)
            Text(species?.name ?? "")
                .font(LumaFont.display(24)).foregroundStyle(luma.text)
            Text(species?.description ?? "")
                .font(LumaFont.body(14)).foregroundStyle(luma.textSoft)
                .multilineTextAlignment(.center).frame(maxWidth: 300)
            HStack(spacing: 12) {
                StatPill(label: "Stage", value: plant.stage.label)
                StatPill(label: "Rarity", value: species?.rarity.label ?? "")
                StatPill(label: "Output", value: EnergyFormatter.rate(store.energyPerSecond > 0 ? (species?.baseRate ?? 0) * plant.yieldFactor * store.yieldMultiplier : 0))
            }
            .padding(.horizontal, 18)
            LumaProgressBar(progress: plant.progress, tint: luma.rarity(species?.rarity ?? .common))
                .padding(.horizontal, 24)
            Spacer()
        }
        .padding(.bottom, 20)
    }
}
