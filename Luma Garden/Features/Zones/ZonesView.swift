import SwiftUI

struct ZonesView: View {
    @Environment(GameStore.self) private var store
    @Environment(\.luma) private var luma

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                SectionHeader(title: "Garden Zones", subtitle: "Each biome carries its own light and life.")
                    .padding(.top, 8)
                ForEach(ContentCatalog.zones) { zone in
                    zoneCard(zone)
                }
            }
            .padding(.horizontal, 18)
            .padding(.bottom, LumaMetric.tabBarInset)
        }
    }

    private func zoneCard(_ zone: Zone) -> some View {
        let unlocked = store.state.unlockedZoneIds.contains(zone.id)
        let current = store.state.currentZoneId == zone.id
        let canUnlock = store.canUnlockZone(zone)
        let blocked = !unlocked && !store.previousZoneUnlocked(zone)
        let speciesCount = ContentCatalog.species(inZone: zone.id).count
        let discovered = ContentCatalog.species(inZone: zone.id).filter { store.state.discoveredSpeciesIds.contains($0.id) }.count

        return VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(zone.name).font(LumaFont.display(22)).foregroundStyle(.white)
                    Text(zone.tagline).font(LumaFont.body(13)).foregroundStyle(.white.opacity(0.7))
                }
                Spacer()
                if current {
                    Text("Here")
                        .font(LumaFont.body(11)).foregroundStyle(.white)
                        .padding(.horizontal, 10).padding(.vertical, 5)
                        .background(Capsule().stroke(.white.opacity(0.6), lineWidth: 1))
                } else if !unlocked {
                    GlyphView(glyph: blocked ? .lock : .spark, size: 20, color: .white.opacity(0.8))
                }
            }

            HStack(spacing: 8) {
                pill("\(zone.capacity) plots")
                pill("\(speciesCount) species")
                if unlocked { pill("\(discovered)/\(speciesCount) found") }
            }

            if unlocked {
                LumaButton(title: current ? "Currently Tending" : "Enter Zone", icon: current ? .check : .garden, enabled: !current) {
                    store.playTap(); store.selectZone(zone.id)
                }
            } else if blocked {
                Text("Unlock the previous zone first.")
                    .font(LumaFont.body(13)).foregroundStyle(.white.opacity(0.7))
                    .frame(maxWidth: .infinity).padding(.vertical, 12)
            } else {
                Button {
                    store.playTap(); store.unlockZone(zone)
                } label: {
                    HStack(spacing: 8) {
                        GlyphView(glyph: .spark, size: 16, color: .white)
                        Text("Unlock for \(EnergyFormatter.string(zone.unlockCost))")
                            .font(LumaFont.title(15))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: LumaMetric.cornerMedium, style: .continuous)
                            .fill(.white.opacity(canUnlock ? 0.22 : 0.08))
                            .overlay(RoundedRectangle(cornerRadius: LumaMetric.cornerMedium).stroke(.white.opacity(0.4), lineWidth: 1))
                    )
                    .opacity(canUnlock ? 1 : 0.55)
                }
                .buttonStyle(PressableStyle())
                .disabled(!canUnlock)
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: LumaMetric.cornerLarge, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: zone.backgroundTop), Color(hue: zone.moodHue, saturation: 0.5, brightness: 0.32)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: LumaMetric.cornerLarge)
                        .stroke(Color(hue: zone.moodHue, saturation: 0.4, brightness: 0.9).opacity(0.4), lineWidth: 1)
                )
        )
        .overlay(alignment: .topTrailing) {
            ZoneOrb(hue: zone.moodHue, accentHue: zone.accentHue, dimmed: !unlocked)
                .frame(width: 70, height: 70)
                .padding(12)
                .allowsHitTesting(false)
        }
        .lumaGlow(unlocked ? Color(hue: zone.moodHue, saturation: 0.5, brightness: 1) : .clear, radius: 14, intensity: 0.3)
    }

    private func pill(_ text: String) -> some View {
        Text(text)
            .font(LumaFont.body(11)).foregroundStyle(.white.opacity(0.85))
            .padding(.horizontal, 10).padding(.vertical, 5)
            .background(Capsule().fill(.white.opacity(0.14)))
    }
}

struct ZoneOrb: View {
    var hue: Double
    var accentHue: Double
    var dimmed: Bool

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 24.0)) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            Canvas { context, size in
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                let pulse = 0.5 + 0.5 * sin(t * 1.1)
                for i in 0..<5 {
                    let a = Double(i) / 5 * 2 * .pi + t * 0.4
                    let r = size.width * 0.32
                    let p = CGPoint(x: center.x + cos(a) * r, y: center.y + sin(a) * r)
                    let dot = CGRect(x: p.x - 4, y: p.y - 4, width: 8, height: 8)
                    context.fill(Circle().path(in: dot), with: .color(Color(hue: accentHue, saturation: 0.5, brightness: 1).opacity(dimmed ? 0.2 : 0.7)))
                }
                let core = size.width * (0.16 + pulse * 0.05)
                let rect = CGRect(x: center.x - core, y: center.y - core, width: core * 2, height: core * 2)
                context.fill(Circle().path(in: rect), with: .color(Color(hue: hue, saturation: 0.5, brightness: 1).opacity(dimmed ? 0.25 : 0.9)))
            }
        }
    }
}
