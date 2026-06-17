import Foundation

enum UpgradeCategory: String, Codable, CaseIterable {
    case yield
    case growth
    case efficiency
    case chain
    case automation

    var title: String {
        switch self {
        case .yield: return "Yield"
        case .growth: return "Growth"
        case .efficiency: return "Efficiency"
        case .chain: return "Chains"
        case .automation: return "Automation"
        }
    }

    var blurb: String {
        switch self {
        case .yield: return "Increase the light every plant produces."
        case .growth: return "Help blooms reach maturity faster."
        case .efficiency: return "Make networks easier and more forgiving."
        case .chain: return "Amplify the bonus from elegant solutions."
        case .automation: return "Let the garden tend itself."
        }
    }
}

enum UpgradeEffect: String, Codable {
    case yieldMultiplier
    case growthSpeed
    case offlineCap
    case chainBonus
    case startingLinks
    case autoHarvest
    case autoPulse
}

struct Upgrade: Codable, Identifiable {
    var id: String
    var name: String
    var category: UpgradeCategory
    var effect: UpgradeEffect
    var description: String
    var maxLevel: Int
    var baseCost: Double
    var costGrowth: Double
    var valuePerLevel: Double

    func cost(forLevel level: Int) -> Double {
        baseCost * pow(costGrowth, Double(level))
    }

    func value(atLevel level: Int) -> Double {
        valuePerLevel * Double(level)
    }
}

enum QuestGoal: String, Codable {
    case growPlants
    case solvePuzzles
    case generateEnergy
    case triggerChains
    case discoverSpecies
    case reachNodes
    case unlockZones
    case prestige
}

enum RewardKind: String, Codable {
    case energy
    case boost
    case spores
}

struct Reward: Codable {
    var kind: RewardKind
    var amount: Double
    var boostId: String?
}

struct Quest: Codable, Identifiable {
    var id: String
    var title: String
    var detail: String
    var goal: QuestGoal
    var target: Double
    var reward: Reward
    var order: Int
}

struct Achievement: Codable, Identifiable {
    var id: String
    var title: String
    var detail: String
    var goal: QuestGoal
    var target: Double
}

struct Boost: Codable, Identifiable {
    var id: String
    var name: String
    var detail: String
    var multiplier: Double
    var duration: Double
    var affects: BoostTarget
}

enum BoostTarget: String, Codable {
    case energy
    case growth
    case chain
}

struct ActiveBoost: Codable, Identifiable {
    var id: UUID
    var boostId: String
    var remaining: Double

    init(id: UUID = UUID(), boostId: String, remaining: Double) {
        self.id = id
        self.boostId = boostId
        self.remaining = remaining
    }
}
