import SwiftUI

struct StatsView: View {
    @Environment(GameStore.self) private var store
    @Environment(\.luma) private var luma

    private var stats: LifetimeStats { store.state.lifetime }

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        LumaScreen(title: "Statistics", subtitle: "Your lifetime of light.") {
            ScrollView {
                VStack(spacing: 20) {
                    LazyVGrid(columns: columns, spacing: 12) {
                        StatPill(label: "Puzzles", value: "\(stats.puzzlesSolved)")
                        StatPill(label: "Plants", value: "\(stats.plantsGrown)")
                        StatPill(label: "Chains", value: "\(stats.chainsTriggered)")
                        StatPill(label: "Species", value: "\(stats.speciesDiscovered)")
                        StatPill(label: "Zones", value: "\(store.state.unlockedZoneIds.count)")
                        StatPill(label: "Reseeds", value: "\(stats.prestigeCount)")
                    }

                    chartCard(title: "Light Output by Zone", subtitle: "Current energy per second") {
                        ZoneRateChart(values: rateByZone())
                    }

                    chartCard(title: "Species Found by Zone", subtitle: "Discovery progress") {
                        DiscoveryChart(values: discoveryByZone())
                    }

                    GlowPanel {
                        VStack(spacing: 14) {
                            statRow("Total Light Generated", EnergyFormatter.string(stats.energyGenerated))
                            divider
                            statRow("Best Chain Bonus", "+\(Int(stats.bestChainBonus * 100))%")
                            divider
                            statRow("Time in the Garden", timeString(stats.secondsPlayed))
                            divider
                            statRow("Spores Held", EnergyFormatter.string(store.state.spores))
                        }
                        .padding(18)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.bottom, LumaMetric.tabBarInset)
            }
        }
    }

    private var divider: some View { Rectangle().fill(luma.panelStroke).frame(height: 1) }

    private func statRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).font(LumaFont.body(14)).foregroundStyle(luma.textSoft)
            Spacer()
            Text(value).font(LumaFont.mono(15)).foregroundStyle(luma.text)
        }
    }

    private func chartCard<Content: View>(title: String, subtitle: String, @ViewBuilder content: () -> Content) -> some View {
        GlowPanel {
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(LumaFont.title(16)).foregroundStyle(luma.text)
                    Text(subtitle).font(LumaFont.body(11)).foregroundStyle(luma.textSoft)
                }
                content().frame(height: 140)
            }
            .padding(16)
        }
    }

    private func rateByZone() -> [(String, Double, Double)] {
        ContentCatalog.zones.filter { store.state.unlockedZoneIds.contains($0.id) }.map { zone in
            let rate = store.state.plants(inZone: zone.id).reduce(0.0) { sum, plant in
                guard let species = ContentCatalog.species(plant.speciesId) else { return sum }
                return sum + species.baseRate * plant.yieldFactor * store.yieldMultiplier
            }
            return (zone.name, rate, zone.moodHue)
        }
    }

    private func discoveryByZone() -> [(String, Double, Double)] {
        ContentCatalog.zones.map { zone in
            let all = ContentCatalog.species(inZone: zone.id)
            let found = all.filter { store.state.discoveredSpeciesIds.contains($0.id) }.count
            let fraction = all.isEmpty ? 0 : Double(found) / Double(all.count)
            return (zone.name, fraction, zone.moodHue)
        }
    }

    private func timeString(_ seconds: Double) -> String {
        let total = Int(seconds)
        let h = total / 3600
        let m = (total % 3600) / 60
        if h > 0 { return "\(h)h \(m)m" }
        return "\(m)m"
    }
}

struct ZoneRateChart: View {
    @Environment(\.luma) private var luma
    var values: [(String, Double, Double)]

    var body: some View {
        let maxValue = max(values.map { $0.1 }.max() ?? 1, 0.0001)
        HStack(alignment: .bottom, spacing: 10) {
            ForEach(Array(values.enumerated()), id: \.offset) { _, item in
                VStack(spacing: 6) {
                    GeometryReader { geo in
                        VStack {
                            Spacer(minLength: 0)
                            RoundedRectangle(cornerRadius: 6)
                                .fill(LinearGradient(colors: [Color(hue: item.2, saturation: 0.5, brightness: 1), Color(hue: item.2, saturation: 0.6, brightness: 0.7)], startPoint: .top, endPoint: .bottom))
                                .frame(height: max(4, CGFloat(item.1 / maxValue) * geo.size.height))
                                .lumaGlow(Color(hue: item.2, saturation: 0.5, brightness: 1), radius: 8, intensity: 0.4)
                        }
                    }
                    Text(item.0).font(LumaFont.body(9)).foregroundStyle(luma.textSoft).lineLimit(1)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

struct DiscoveryChart: View {
    @Environment(\.luma) private var luma
    var values: [(String, Double, Double)]

    var body: some View {
        VStack(spacing: 10) {
            ForEach(Array(values.enumerated()), id: \.offset) { _, item in
                HStack(spacing: 10) {
                    Text(item.0).font(LumaFont.body(11)).foregroundStyle(luma.textSoft)
                        .frame(width: 92, alignment: .leading)
                    LumaProgressBar(progress: item.1, tint: Color(hue: item.2, saturation: 0.5, brightness: 1))
                    Text("\(Int(item.1 * 100))%").font(LumaFont.mono(11)).foregroundStyle(luma.text)
                        .frame(width: 40, alignment: .trailing)
                }
            }
        }
    }
}
