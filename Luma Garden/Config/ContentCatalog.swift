import Foundation

enum ContentCatalog {
    static let zones: [Zone] = [
        Zone(id: "seed_field", name: "Seed Field", tagline: "Where the first sparks take root.", unlockCost: 0, order: 0, capacity: 6, moodHue: 0.46, accentHue: 0.40, backgroundTop: "0B1418", backgroundBottom: "06090C"),
        Zone(id: "deep_bloom", name: "Deep Bloom", tagline: "Violet light pooling in the quiet dark.", unlockCost: 4_000, order: 1, capacity: 8, moodHue: 0.78, accentHue: 0.84, backgroundTop: "120B1C", backgroundBottom: "07060F"),
        Zone(id: "lumen_grove", name: "Lumen Grove", tagline: "Amber canopies humming with warmth.", unlockCost: 180_000, order: 2, capacity: 10, moodHue: 0.10, accentHue: 0.07, backgroundTop: "1A1206", backgroundBottom: "0C0803"),
        Zone(id: "prism_hollow", name: "Prism Hollow", tagline: "A hollow that splits light into song.", unlockCost: 6_000_000, order: 3, capacity: 12, moodHue: 0.54, accentHue: 0.92, backgroundTop: "06141A", backgroundBottom: "030A0E"),
        Zone(id: "aurora_canopy", name: "Aurora Canopy", tagline: "The sky itself blooms overhead.", unlockCost: 320_000_000, order: 4, capacity: 14, moodHue: 0.58, accentHue: 0.34, backgroundTop: "07101A", backgroundBottom: "020509")
    ]

    static let species: [Species] = [
        Species(id: "glimmercap", name: "Glimmercap", zoneId: "seed_field", rarity: .common, baseRate: 1.2, growthSeconds: 25, unlockCost: 0, petals: 5, huePrimary: 0.45, hueSecondary: 0.50, description: "A modest bulb that hums a soft teal when fed."),
        Species(id: "dewlace", name: "Dewlace", zoneId: "seed_field", rarity: .common, baseRate: 2.6, growthSeconds: 40, unlockCost: 0, petals: 6, huePrimary: 0.48, hueSecondary: 0.40, description: "Threads of light gather dew that glows at dusk."),
        Species(id: "emberfern", name: "Emberfern", zoneId: "seed_field", rarity: .uncommon, baseRate: 5.5, growthSeconds: 60, unlockCost: 0, petals: 7, huePrimary: 0.38, hueSecondary: 0.13, description: "Fronds curl with a warm undertone beneath the teal."),
        Species(id: "lullabud", name: "Lullabud", zoneId: "seed_field", rarity: .uncommon, baseRate: 9, growthSeconds: 80, unlockCost: 0, petals: 5, huePrimary: 0.52, hueSecondary: 0.58, description: "Opens slowly, as if waking from a gentle dream."),
        Species(id: "starwort", name: "Starwort", zoneId: "seed_field", rarity: .rare, baseRate: 16, growthSeconds: 110, unlockCost: 0, petals: 8, huePrimary: 0.55, hueSecondary: 0.62, description: "Petals arranged like a small constellation."),

        Species(id: "violadusk", name: "Violadusk", zoneId: "deep_bloom", rarity: .common, baseRate: 26, growthSeconds: 50, unlockCost: 0, petals: 6, huePrimary: 0.78, hueSecondary: 0.72, description: "A violet cup that drinks the dark and gives back glow."),
        Species(id: "nightsilk", name: "Nightsilk", zoneId: "deep_bloom", rarity: .uncommon, baseRate: 48, growthSeconds: 75, unlockCost: 0, petals: 7, huePrimary: 0.80, hueSecondary: 0.86, description: "Smooth petals that ripple like quiet water."),
        Species(id: "amethorn", name: "Amethorn", zoneId: "deep_bloom", rarity: .uncommon, baseRate: 78, growthSeconds: 95, unlockCost: 0, petals: 8, huePrimary: 0.83, hueSecondary: 0.90, description: "Crystalline thorns catch and scatter the light."),
        Species(id: "duskbell", name: "Duskbell", zoneId: "deep_bloom", rarity: .rare, baseRate: 130, growthSeconds: 120, unlockCost: 0, petals: 6, huePrimary: 0.76, hueSecondary: 0.66, description: "Rings without sound, only a pulse of soft violet."),
        Species(id: "wraithlily", name: "Wraithlily", zoneId: "deep_bloom", rarity: .radiant, baseRate: 230, growthSeconds: 160, unlockCost: 0, petals: 9, huePrimary: 0.85, hueSecondary: 0.95, description: "Barely there, a luminous ghost of a flower."),

        Species(id: "honeyglow", name: "Honeyglow", zoneId: "lumen_grove", rarity: .common, baseRate: 360, growthSeconds: 60, unlockCost: 0, petals: 6, huePrimary: 0.11, hueSecondary: 0.08, description: "Warm amber sap that lights from within."),
        Species(id: "sunmoss", name: "Sunmoss", zoneId: "lumen_grove", rarity: .uncommon, baseRate: 620, growthSeconds: 90, unlockCost: 0, petals: 7, huePrimary: 0.13, hueSecondary: 0.06, description: "A low carpet that holds the day's warmth."),
        Species(id: "goldspire", name: "Goldspire", zoneId: "lumen_grove", rarity: .uncommon, baseRate: 1_050, growthSeconds: 115, unlockCost: 0, petals: 8, huePrimary: 0.09, hueSecondary: 0.14, description: "Reaches upward in a single bright column."),
        Species(id: "candlevine", name: "Candlevine", zoneId: "lumen_grove", rarity: .rare, baseRate: 1_800, growthSeconds: 150, unlockCost: 0, petals: 7, huePrimary: 0.07, hueSecondary: 0.12, description: "Tiny flames bud along its winding length."),
        Species(id: "phoenixpetal", name: "Phoenixpetal", zoneId: "lumen_grove", rarity: .radiant, baseRate: 3_200, growthSeconds: 200, unlockCost: 0, petals: 9, huePrimary: 0.05, hueSecondary: 0.10, description: "Each bloom feels like a small, warm sunrise."),

        Species(id: "prismdrop", name: "Prismdrop", zoneId: "prism_hollow", rarity: .uncommon, baseRate: 5_400, growthSeconds: 80, unlockCost: 0, petals: 7, huePrimary: 0.54, hueSecondary: 0.92, description: "A single droplet that fans into every color."),
        Species(id: "spectraleaf", name: "Spectraleaf", zoneId: "prism_hollow", rarity: .uncommon, baseRate: 9_200, growthSeconds: 110, unlockCost: 0, petals: 8, huePrimary: 0.50, hueSecondary: 0.00, description: "Leaves shift hue with the slightest motion."),
        Species(id: "echobloom", name: "Echobloom", zoneId: "prism_hollow", rarity: .rare, baseRate: 16_000, growthSeconds: 150, unlockCost: 0, petals: 9, huePrimary: 0.58, hueSecondary: 0.85, description: "Light bounces inside it long after the pulse."),
        Species(id: "halospore", name: "Halospore", zoneId: "prism_hollow", rarity: .radiant, baseRate: 28_000, growthSeconds: 195, unlockCost: 0, petals: 10, huePrimary: 0.52, hueSecondary: 0.95, description: "Wears a faint ring of refracted light."),
        Species(id: "chromavine", name: "Chromavine", zoneId: "prism_hollow", rarity: .mythic, baseRate: 50_000, growthSeconds: 260, unlockCost: 0, petals: 11, huePrimary: 0.56, hueSecondary: 0.30, description: "A vine that writes slow rainbows in the air."),

        Species(id: "auroracup", name: "Auroracup", zoneId: "aurora_canopy", rarity: .rare, baseRate: 82_000, growthSeconds: 120, unlockCost: 0, petals: 9, huePrimary: 0.58, hueSecondary: 0.34, description: "Holds a sip of the northern lights."),
        Species(id: "veilflower", name: "Veilflower", zoneId: "aurora_canopy", rarity: .radiant, baseRate: 150_000, growthSeconds: 170, unlockCost: 0, petals: 10, huePrimary: 0.60, hueSecondary: 0.45, description: "Drapes the canopy in slow, shifting curtains."),
        Species(id: "skylantern", name: "Skylantern", zoneId: "aurora_canopy", rarity: .radiant, baseRate: 260_000, growthSeconds: 215, unlockCost: 0, petals: 8, huePrimary: 0.55, hueSecondary: 0.16, description: "Rises a little each night, tethered by light."),
        Species(id: "celestbloom", name: "Celestbloom", zoneId: "aurora_canopy", rarity: .mythic, baseRate: 480_000, growthSeconds: 280, unlockCost: 0, petals: 12, huePrimary: 0.62, hueSecondary: 0.40, description: "The garden's crown, woven from sky and seed."),
        Species(id: "everdawn", name: "Everdawn", zoneId: "aurora_canopy", rarity: .mythic, baseRate: 820_000, growthSeconds: 340, unlockCost: 0, petals: 13, huePrimary: 0.59, hueSecondary: 0.20, description: "A bloom that never fully closes, holding the dawn.")
    ]

    static let upgrades: [Upgrade] = [
        Upgrade(id: "yield_1", name: "Photosynthate", category: .yield, effect: .yieldMultiplier, description: "Every plant produces more light.", maxLevel: 25, baseCost: 50, costGrowth: 1.55, valuePerLevel: 0.12),
        Upgrade(id: "yield_2", name: "Deep Roots", category: .yield, effect: .yieldMultiplier, description: "Roots draw light from deeper soil.", maxLevel: 25, baseCost: 5_000, costGrowth: 1.6, valuePerLevel: 0.25),
        Upgrade(id: "yield_3", name: "Radiant Bloom", category: .yield, effect: .yieldMultiplier, description: "Mature blooms shine far brighter.", maxLevel: 20, baseCost: 1_200_000, costGrowth: 1.7, valuePerLevel: 0.6),
        Upgrade(id: "growth_1", name: "Warm Current", category: .growth, effect: .growthSpeed, description: "Plants reach maturity faster.", maxLevel: 20, baseCost: 120, costGrowth: 1.6, valuePerLevel: 0.10),
        Upgrade(id: "growth_2", name: "Quicksprout", category: .growth, effect: .growthSpeed, description: "Seeds sprout almost eagerly.", maxLevel: 18, baseCost: 60_000, costGrowth: 1.7, valuePerLevel: 0.18),
        Upgrade(id: "eff_1", name: "Gentle Wiring", category: .efficiency, effect: .startingLinks, description: "Begin puzzles with extra link capacity to spare.", maxLevel: 8, baseCost: 400, costGrowth: 2.0, valuePerLevel: 1),
        Upgrade(id: "eff_2", name: "Stored Sunlight", category: .efficiency, effect: .offlineCap, description: "Hold more light while you are away.", maxLevel: 12, baseCost: 2_500, costGrowth: 1.8, valuePerLevel: 3_600),
        Upgrade(id: "chain_1", name: "Resonance", category: .chain, effect: .chainBonus, description: "Elegant solutions grant a larger chain bonus.", maxLevel: 15, baseCost: 1_500, costGrowth: 1.75, valuePerLevel: 0.15),
        Upgrade(id: "chain_2", name: "Harmonics", category: .chain, effect: .chainBonus, description: "Chains ripple wider through the network.", maxLevel: 12, baseCost: 350_000, costGrowth: 1.85, valuePerLevel: 0.3),
        Upgrade(id: "auto_harvest", name: "Living Soil", category: .automation, effect: .autoHarvest, description: "The soil quietly collects offline light for you.", maxLevel: 1, baseCost: 25_000, costGrowth: 2, valuePerLevel: 1),
        Upgrade(id: "auto_pulse", name: "Heartbeat", category: .automation, effect: .autoPulse, description: "Mature plants pulse on their own, glowing as they give.", maxLevel: 1, baseCost: 900_000, costGrowth: 2, valuePerLevel: 1)
    ]

    static let quests: [Quest] = [
        Quest(id: "q_first_bloom", title: "First Light", detail: "Solve your first light network.", goal: .solvePuzzles, target: 1, reward: Reward(kind: .energy, amount: 60, boostId: nil), order: 0),
        Quest(id: "q_grow_5", title: "A Little Garden", detail: "Grow 5 plants to maturity.", goal: .growPlants, target: 5, reward: Reward(kind: .energy, amount: 250, boostId: nil), order: 1),
        Quest(id: "q_solve_5", title: "Patterns Within", detail: "Solve 5 networks.", goal: .solvePuzzles, target: 5, reward: Reward(kind: .boost, amount: 0, boostId: "boost_photosynthesis"), order: 2),
        Quest(id: "q_chains_10", title: "Cascade", detail: "Trigger 10 chain reactions.", goal: .triggerChains, target: 10, reward: Reward(kind: .energy, amount: 4_000, boostId: nil), order: 3),
        Quest(id: "q_zone_2", title: "Deeper Still", detail: "Unlock a second garden zone.", goal: .unlockZones, target: 2, reward: Reward(kind: .energy, amount: 8_000, boostId: nil), order: 4),
        Quest(id: "q_species_8", title: "Collector", detail: "Discover 8 species.", goal: .discoverSpecies, target: 8, reward: Reward(kind: .boost, amount: 0, boostId: "boost_overgrowth"), order: 5),
        Quest(id: "q_energy_1m", title: "Field of Light", detail: "Generate 1M lifetime light.", goal: .generateEnergy, target: 1_000_000, reward: Reward(kind: .energy, amount: 120_000, boostId: nil), order: 6),
        Quest(id: "q_solve_25", title: "Quiet Mastery", detail: "Solve 25 networks.", goal: .solvePuzzles, target: 25, reward: Reward(kind: .boost, amount: 0, boostId: "boost_resonance"), order: 7),
        Quest(id: "q_prestige_1", title: "Reseed", detail: "Reseed the garden once.", goal: .prestige, target: 1, reward: Reward(kind: .spores, amount: 5, boostId: nil), order: 8),
        Quest(id: "q_species_18", title: "Herbarium", detail: "Discover 18 species.", goal: .discoverSpecies, target: 18, reward: Reward(kind: .energy, amount: 5_000_000, boostId: nil), order: 9)
    ]

    static let achievements: [Achievement] = [
        Achievement(id: "a_solve_1", title: "Spark", detail: "Solve a network.", goal: .solvePuzzles, target: 1),
        Achievement(id: "a_solve_10", title: "Wireworker", detail: "Solve 10 networks.", goal: .solvePuzzles, target: 10),
        Achievement(id: "a_solve_50", title: "Lattice Mind", detail: "Solve 50 networks.", goal: .solvePuzzles, target: 50),
        Achievement(id: "a_grow_10", title: "Gardener", detail: "Grow 10 plants.", goal: .growPlants, target: 10),
        Achievement(id: "a_grow_100", title: "Caretaker", detail: "Grow 100 plants.", goal: .growPlants, target: 100),
        Achievement(id: "a_chain_25", title: "Ripple", detail: "Trigger 25 chains.", goal: .triggerChains, target: 25),
        Achievement(id: "a_chain_200", title: "Resonant", detail: "Trigger 200 chains.", goal: .triggerChains, target: 200),
        Achievement(id: "a_species_10", title: "Curious", detail: "Discover 10 species.", goal: .discoverSpecies, target: 10),
        Achievement(id: "a_species_all", title: "Complete Herbarium", detail: "Discover every species.", goal: .discoverSpecies, target: 25),
        Achievement(id: "a_zone_all", title: "Worldgarden", detail: "Unlock every zone.", goal: .unlockZones, target: 5),
        Achievement(id: "a_energy_1b", title: "Sea of Light", detail: "Generate 1B lifetime light.", goal: .generateEnergy, target: 1_000_000_000),
        Achievement(id: "a_prestige_3", title: "Eternal Spring", detail: "Reseed 3 times.", goal: .prestige, target: 3)
    ]

    static let boosts: [Boost] = [
        Boost(id: "boost_photosynthesis", name: "Photosynthesis", detail: "x2 light for 60s", multiplier: 2, duration: 60, affects: .energy),
        Boost(id: "boost_overgrowth", name: "Overgrowth", detail: "x3 growth for 45s", multiplier: 3, duration: 45, affects: .growth),
        Boost(id: "boost_resonance", name: "Resonance Wave", detail: "x2.5 light for 90s", multiplier: 2.5, duration: 90, affects: .energy),
        Boost(id: "boost_solve", name: "Afterglow", detail: "x2 light for 30s", multiplier: 2, duration: 30, affects: .energy)
    ]

    static func zone(_ id: String) -> Zone? { zones.first { $0.id == id } }
    static func species(_ id: String) -> Species? { species.first { $0.id == id } }
    static func upgrade(_ id: String) -> Upgrade? { upgrades.first { $0.id == id } }
    static func boost(_ id: String) -> Boost? { boosts.first { $0.id == id } }
    static func quest(_ id: String) -> Quest? { quests.first { $0.id == id } }

    static func species(inZone zoneId: String) -> [Species] {
        species.filter { $0.zoneId == zoneId }
    }

    static func nodeKinds(forZone zoneId: String) -> [NodeKind] {
        switch zoneId {
        case "seed_field": return [.source, .conductor, .sink, .splitter]
        case "deep_bloom": return [.mirror]
        case "lumen_grove": return [.gate]
        default: return []
        }
    }

    static let cultivateBaseCost: Double = 40
    static let plotExpandBaseCost: Double = 200
    static let offlineBaseCapSeconds: Double = 6 * 3600
    static let speciesCount = 25
}
