import Foundation

struct EnergyValue: Codable, Equatable, Comparable {
    var raw: Double

    init(_ raw: Double = 0) {
        self.raw = max(0, raw)
    }

    static let zero = EnergyValue(0)

    static func < (lhs: EnergyValue, rhs: EnergyValue) -> Bool {
        lhs.raw < rhs.raw
    }

    static func + (lhs: EnergyValue, rhs: EnergyValue) -> EnergyValue {
        EnergyValue(lhs.raw + rhs.raw)
    }

    static func - (lhs: EnergyValue, rhs: EnergyValue) -> EnergyValue {
        EnergyValue(lhs.raw - rhs.raw)
    }

    static func * (lhs: EnergyValue, rhs: Double) -> EnergyValue {
        EnergyValue(lhs.raw * rhs)
    }

    func canAfford(_ cost: EnergyValue) -> Bool {
        raw + 0.0001 >= cost.raw
    }
}

enum EnergyFormatter {
    private static let suffixes = ["", "K", "M", "B", "T", "aa", "ab", "ac", "ad", "ae", "af", "ag", "ah", "ai", "aj"]

    static func string(_ value: EnergyValue) -> String {
        string(value.raw)
    }

    static func string(_ raw: Double) -> String {
        let value = max(0, raw)
        if value < 1000 {
            if value < 10 && value != value.rounded() {
                return String(format: "%.1f", value)
            }
            return String(Int(value.rounded()))
        }
        let exponent = Int(floor(log10(value)) / 3)
        let clamped = min(exponent, suffixes.count - 1)
        let scaled = value / pow(1000, Double(clamped))
        let suffix = suffixes[clamped]
        if scaled >= 100 {
            return String(format: "%.0f%@", scaled, suffix)
        } else if scaled >= 10 {
            return String(format: "%.1f%@", scaled, suffix)
        }
        return String(format: "%.2f%@", scaled, suffix)
    }

    static func rate(_ raw: Double) -> String {
        "\(string(raw))/s"
    }
}
