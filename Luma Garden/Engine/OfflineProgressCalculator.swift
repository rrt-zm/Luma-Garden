import Foundation

struct OfflineSummary {
    var elapsedSeconds: Double
    var energyEarned: Double
    var plantsMatured: Int
    var wasCapped: Bool
}

struct OfflineProgressCalculator {
    let economy = EconomyService()
    let growth = GrowthService()

    func apply(state: inout GameState, now: Date) -> OfflineSummary? {
        let rawElapsed = now.timeIntervalSince(state.lastSeen)
        state.lastSeen = now
        guard rawElapsed > 30 else { return nil }

        let cap = economy.offlineCapSeconds(state)
        let elapsed = min(rawElapsed, cap)
        let wasCapped = rawElapsed > cap

        let rateBefore = economy.totalRate(state)
        let matured = growth.advance(state: &state, delta: elapsed)
        let rateAfter = economy.totalRate(state)
        let averageRate = (rateBefore + rateAfter) / 2
        let earned = averageRate * elapsed

        if earned > 0 {
            state.energy += earned
            state.lifetime.energyGenerated += earned
        }
        state.lifetime.secondsPlayed += elapsed

        guard earned > 0 || matured > 0 else { return nil }
        return OfflineSummary(elapsedSeconds: elapsed, energyEarned: earned, plantsMatured: matured, wasCapped: wasCapped)
    }
}
