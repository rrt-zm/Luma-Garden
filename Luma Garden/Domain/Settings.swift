import Foundation

enum ThemePreference: String, Codable, CaseIterable {
    case dark
    case light
    case system

    var label: String {
        switch self {
        case .dark: return "Dark"
        case .light: return "Light"
        case .system: return "System"
        }
    }
}

enum QualityPreference: String, Codable, CaseIterable {
    case high
    case balanced
    case calm

    var label: String {
        switch self {
        case .high: return "High"
        case .balanced: return "Balanced"
        case .calm: return "Calm"
        }
    }

    var moteCount: Int {
        switch self {
        case .high: return 64
        case .balanced: return 36
        case .calm: return 16
        }
    }

    var glowEnabled: Bool {
        self != .calm
    }
}

struct GameSettings: Codable {
    var soundEnabled: Bool
    var musicEnabled: Bool
    var ambienceEnabled: Bool
    var hapticsEnabled: Bool
    var theme: ThemePreference
    var quality: QualityPreference

    static let `default` = GameSettings(
        soundEnabled: true,
        musicEnabled: true,
        ambienceEnabled: true,
        hapticsEnabled: true,
        theme: .dark,
        quality: .high
    )
}

struct LifetimeStats: Codable {
    var puzzlesSolved: Int = 0
    var plantsGrown: Int = 0
    var energyGenerated: Double = 0
    var chainsTriggered: Int = 0
    var speciesDiscovered: Int = 0
    var secondsPlayed: Double = 0
    var prestigeCount: Int = 0
    var bestChainBonus: Double = 0
    var zonesUnlocked: Int = 1
}
