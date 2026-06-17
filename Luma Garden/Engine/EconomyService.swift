import Foundation

struct EconomyService {
    func yieldMultiplier(_ state: GameState) -> Double {
        var multiplier = state.prestigeMultiplier
        for upgrade in ContentCatalog.upgrades where upgrade.effect == .yieldMultiplier {
            let level = state.upgradeLevel(upgrade.id)
            multiplier *= 1 + upgrade.value(atLevel: level)
        }
        for active in state.activeBoosts {
            if let boost = ContentCatalog.boost(active.boostId), boost.affects == .energy {
                multiplier *= boost.multiplier
            }
        }
        return multiplier
    }

    func growthMultiplier(_ state: GameState) -> Double {
        var multiplier = 1.0
        for upgrade in ContentCatalog.upgrades where upgrade.effect == .growthSpeed {
            let level = state.upgradeLevel(upgrade.id)
            multiplier *= 1 + upgrade.value(atLevel: level)
        }
        for active in state.activeBoosts {
            if let boost = ContentCatalog.boost(active.boostId), boost.affects == .growth {
                multiplier *= boost.multiplier
            }
        }
        return multiplier
    }

    func chainMultiplier(_ state: GameState) -> Double {
        var multiplier = 1.0
        for upgrade in ContentCatalog.upgrades where upgrade.effect == .chainBonus {
            let level = state.upgradeLevel(upgrade.id)
            multiplier *= 1 + upgrade.value(atLevel: level)
        }
        return multiplier
    }

    func capacityBonus(_ state: GameState) -> Int {
        var bonus = 0
        for upgrade in ContentCatalog.upgrades where upgrade.effect == .startingLinks {
            bonus += Int(upgrade.value(atLevel: state.upgradeLevel(upgrade.id)))
        }
        return bonus
    }

    func offlineCapSeconds(_ state: GameState) -> Double {
        var seconds = ContentCatalog.offlineBaseCapSeconds
        for upgrade in ContentCatalog.upgrades where upgrade.effect == .offlineCap {
            seconds += upgrade.value(atLevel: state.upgradeLevel(upgrade.id))
        }
        return seconds
    }

    func hasAutomation(_ effect: UpgradeEffect, in state: GameState) -> Bool {
        ContentCatalog.upgrades.contains { $0.effect == effect && state.upgradeLevel($0.id) > 0 }
    }

    func plantRate(_ plant: Plant, state: GameState) -> Double {
        guard let species = ContentCatalog.species(plant.speciesId) else { return 0 }
        return species.baseRate * plant.yieldFactor * yieldMultiplier(state)
    }

    func totalRate(_ state: GameState) -> Double {
        state.plants.reduce(0) { $0 + plantRate($1, state: state) }
    }

    func cultivateCost(speciesId: String, state: GameState) -> Double {
        guard let species = ContentCatalog.species(speciesId) else { return .infinity }
        let plantCount = Double(state.plants.count)
        let rarityFactor = pow(2.4, Double(species.rarity.order))
        return ContentCatalog.cultivateBaseCost * rarityFactor * species.baseRate * pow(1.18, plantCount)
    }

    func plotExpandCost(zone: Zone, state: GameState) -> Double {
        let extra = max(0, state.plants(inZone: zone.id).count - zone.capacity)
        let base = ContentCatalog.plotExpandBaseCost * pow(10, Double(zone.order))
        return base * pow(2.0, Double(extra))
    }

    func upgradeCost(_ upgrade: Upgrade, state: GameState) -> Double {
        upgrade.cost(forLevel: state.upgradeLevel(upgrade.id))
    }

    func solveReward(layout: PuzzleLayout, efficiency: Double, state: GameState, firstTime: Bool) -> Double {
        guard let species = ContentCatalog.species(layout.rewardSpeciesId) else { return 0 }
        let base = species.baseRate * 18 * Double(layout.difficulty)
        let chainBonus = 1 + efficiency * chainMultiplier(state)
        let firstFactor = firstTime ? 2.5 : 1
        return base * chainBonus * firstFactor * state.prestigeMultiplier
    }

    func sporesFor(energyGenerated: Double) -> Double {
        guard energyGenerated > 1_000 else { return 0 }
        return floor(pow(energyGenerated / 1_000, 0.4))
    }
}
