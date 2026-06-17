import Foundation

enum GrowthStage: Int, Codable, CaseIterable, Comparable {
    case seed
    case sprout
    case blooming
    case mature

    static func < (lhs: GrowthStage, rhs: GrowthStage) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    var label: String {
        switch self {
        case .seed: return "Seed"
        case .sprout: return "Sprout"
        case .blooming: return "Blooming"
        case .mature: return "Mature"
        }
    }
}

enum Rarity: String, Codable, CaseIterable {
    case common
    case uncommon
    case rare
    case radiant
    case mythic

    var label: String {
        switch self {
        case .common: return "Common"
        case .uncommon: return "Uncommon"
        case .rare: return "Rare"
        case .radiant: return "Radiant"
        case .mythic: return "Mythic"
        }
    }

    var order: Int {
        Rarity.allCases.firstIndex(of: self) ?? 0
    }
}

struct Species: Codable, Identifiable {
    var id: String
    var name: String
    var zoneId: String
    var rarity: Rarity
    var baseRate: Double
    var growthSeconds: Double
    var unlockCost: Double
    var petals: Int
    var huePrimary: Double
    var hueSecondary: Double
    var description: String
}

struct Plant: Codable, Identifiable {
    var id: UUID
    var speciesId: String
    var zoneId: String
    var slot: Int
    var plantedElapsed: Double
    var growthSeconds: Double
    var swaySeed: Double

    init(id: UUID = UUID(), speciesId: String, zoneId: String, slot: Int, growthSeconds: Double, swaySeed: Double) {
        self.id = id
        self.speciesId = speciesId
        self.zoneId = zoneId
        self.slot = slot
        self.plantedElapsed = 0
        self.growthSeconds = growthSeconds
        self.swaySeed = swaySeed
    }

    var progress: Double {
        guard growthSeconds > 0 else { return 1 }
        return min(1, plantedElapsed / growthSeconds)
    }

    var stage: GrowthStage {
        switch progress {
        case ..<0.05: return .seed
        case ..<0.45: return .sprout
        case ..<1.0: return .blooming
        default: return .mature
        }
    }

    var yieldFactor: Double {
        switch stage {
        case .seed: return 0
        case .sprout: return 0.15
        case .blooming: return 0.5
        case .mature: return 1.0
        }
    }
}

struct Zone: Codable, Identifiable {
    var id: String
    var name: String
    var tagline: String
    var unlockCost: Double
    var order: Int
    var capacity: Int
    var moodHue: Double
    var accentHue: Double
    var backgroundTop: String
    var backgroundBottom: String
}
