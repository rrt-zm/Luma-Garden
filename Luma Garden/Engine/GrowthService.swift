import Foundation

struct GrowthService {
    let economy = EconomyService()

    func advance(state: inout GameState, delta: Double) -> Int {
        let growth = economy.growthMultiplier(state)
        var newlyMatured = 0
        for index in state.plants.indices {
            let before = state.plants[index].stage
            state.plants[index].plantedElapsed += delta * growth
            let after = state.plants[index].stage
            if before != .mature && after == .mature {
                newlyMatured += 1
            }
        }
        return newlyMatured
    }

    func accrueEnergy(state: inout GameState, delta: Double) -> Double {
        let earned = economy.totalRate(state) * delta
        guard earned > 0 else { return 0 }
        state.energy += earned
        state.lifetime.energyGenerated += earned
        return earned
    }

    func decayBoosts(state: inout GameState, delta: Double) {
        for index in state.activeBoosts.indices {
            state.activeBoosts[index].remaining -= delta
        }
        state.activeBoosts.removeAll { $0.remaining <= 0 }
    }
}
