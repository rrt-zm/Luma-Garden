import Foundation

struct GameState: Codable {
    var schemaVersion: Int
    var energy: Double
    var spores: Double
    var lifetime: LifetimeStats
    var settings: GameSettings
    var onboardingComplete: Bool
    var currentZoneId: String
    var unlockedZoneIds: Set<String>
    var unlockedSpeciesIds: Set<String>
    var discoveredSpeciesIds: Set<String>
    var unlockedNodeKinds: Set<String>
    var plants: [Plant]
    var expandedPlots: [String: Int]
    var solvedPuzzleIds: Set<String>
    var upgradeLevels: [String: Int]
    var questProgress: [String: Double]
    var claimedQuestIds: Set<String>
    var unlockedAchievementIds: Set<String>
    var activeBoosts: [ActiveBoost]
    var lastSeen: Date

    static let currentSchema = 1

    static func newGame() -> GameState {
        GameState(
            schemaVersion: currentSchema,
            energy: 0,
            spores: 0,
            lifetime: LifetimeStats(),
            settings: .default,
            onboardingComplete: false,
            currentZoneId: "seed_field",
            unlockedZoneIds: ["seed_field"],
            unlockedSpeciesIds: [],
            discoveredSpeciesIds: [],
            unlockedNodeKinds: [NodeKind.source.rawValue, NodeKind.conductor.rawValue, NodeKind.sink.rawValue],
            plants: [],
            expandedPlots: [:],
            solvedPuzzleIds: [],
            upgradeLevels: [:],
            questProgress: [:],
            claimedQuestIds: [],
            unlockedAchievementIds: [],
            activeBoosts: [],
            lastSeen: Date()
        )
    }

    func upgradeLevel(_ id: String) -> Int {
        upgradeLevels[id] ?? 0
    }

    func plants(inZone zoneId: String) -> [Plant] {
        plants.filter { $0.zoneId == zoneId }
    }

    func capacity(forZone zone: Zone) -> Int {
        zone.capacity + (expandedPlots[zone.id] ?? 0)
    }

    func nextSlot(inZone zoneId: String) -> Int {
        let used = Set(plants(inZone: zoneId).map { $0.slot })
        var slot = 0
        while used.contains(slot) { slot += 1 }
        return slot
    }

    var prestigeMultiplier: Double {
        1 + spores * 0.02
    }
}
