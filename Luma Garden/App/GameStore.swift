import SwiftUI
import Observation

struct SolveOutcome: Identifiable {
    let id = UUID()
    var puzzleName: String
    var speciesName: String
    var energyReward: Double
    var efficiency: Double
    var firstDiscovery: Bool
    var bloomed: Bool
}

@MainActor
@Observable
final class GameStore {
    var state: GameState
    var pendingOfflineSummary: OfflineSummary?
    var lastSolveOutcome: SolveOutcome?
    var recentUnlockName: String?

    private let economy = EconomyService()
    private let growth = GrowthService()
    private let offline = OfflineProgressCalculator()
    private let solver = FlowSolver()
    private let persistence: PersistenceService
    private let audio: AudioService
    private let haptics: HapticsService
    private let clock = GameClock()

    private var saveAccumulator: Double = 0
    private var dirty = false

    init(persistence: PersistenceService, audio: AudioService, haptics: HapticsService) {
        self.persistence = persistence
        self.audio = audio
        self.haptics = haptics
        if let loaded = persistence.load() {
            self.state = loaded
        } else {
            self.state = GameState.newGame()
        }
        bootstrap()
        audio.configure()
        audio.applySettings(state.settings)
        haptics.enabled = state.settings.hapticsEnabled
        haptics.prepare()
        pendingOfflineSummary = offline.apply(state: &state, now: Date())
        applyAutomationToOffline()
        clock.onTick = { [weak self] delta in
            self?.tick(delta)
        }
        clock.start()
    }

    private func bootstrap() {
        for kind in ContentCatalog.nodeKinds(forZone: "seed_field") {
            state.unlockedNodeKinds.insert(kind.rawValue)
        }
        if ContentCatalog.zone(state.currentZoneId) == nil {
            state.currentZoneId = "seed_field"
        }
    }

    private func applyAutomationToOffline() {
        guard var summary = pendingOfflineSummary else { return }
        if !economy.hasAutomation(.autoHarvest, in: state) {
            let penalty = summary.energyEarned * 0.5
            state.energy -= penalty
            state.lifetime.energyGenerated -= penalty
            summary.energyEarned -= penalty
            pendingOfflineSummary = summary
        }
    }

    func tick(_ delta: Double) {
        let matured = growth.advance(state: &state, delta: delta)
        if matured > 0 {
            state.lifetime.plantsGrown += matured
            haptics.bloom()
        }
        _ = growth.accrueEnergy(state: &state, delta: delta)
        growth.decayBoosts(state: &state, delta: delta)
        state.lifetime.secondsPlayed += delta
        refreshAchievements()
        saveAccumulator += delta
        dirty = true
        if saveAccumulator >= 6 {
            save()
        }
    }

    var energyPerSecond: Double { economy.totalRate(state) }
    var yieldMultiplier: Double { economy.yieldMultiplier(state) }
    var capacityBonus: Int { economy.capacityBonus(state) }

    func currentZone() -> Zone {
        ContentCatalog.zone(state.currentZoneId) ?? ContentCatalog.zones[0]
    }

    func unlockedZones() -> [Zone] {
        ContentCatalog.zones.filter { state.unlockedZoneIds.contains($0.id) }.sorted { $0.order < $1.order }
    }

    func availablePuzzles(zoneId: String) -> [PuzzleLayout] {
        PuzzleFactory.puzzles(forZone: zoneId)
    }

    func solve(layout: PuzzleLayout, links: Set<PuzzleLink>) {
        let solution = solver.solve(layout: layout, links: links, capacityBonus: capacityBonus)
        guard solution.isSolved else { return }
        let firstTime = !state.solvedPuzzleIds.contains(layout.id)
        let reward = economy.solveReward(layout: layout, efficiency: solution.efficiency, state: state, firstTime: firstTime)
        state.energy += reward
        state.lifetime.energyGenerated += reward
        state.lifetime.puzzlesSolved += 1
        state.lifetime.chainsTriggered += 1
        state.lifetime.bestChainBonus = max(state.lifetime.bestChainBonus, solution.efficiency * economy.chainMultiplier(state))
        state.solvedPuzzleIds.insert(layout.id)

        var firstDiscovery = false
        if !state.discoveredSpeciesIds.contains(layout.rewardSpeciesId) {
            state.discoveredSpeciesIds.insert(layout.rewardSpeciesId)
            state.unlockedSpeciesIds.insert(layout.rewardSpeciesId)
            state.lifetime.speciesDiscovered += 1
            firstDiscovery = true
        }

        let bloomed = plantSpecies(layout.rewardSpeciesId, zoneId: layout.zoneId)
        if solution.efficiency >= 0.85 {
            activateBoost("boost_solve")
        }
        audio.playSolve()
        haptics.solved()
        let speciesName = ContentCatalog.species(layout.rewardSpeciesId)?.name ?? "Bloom"
        lastSolveOutcome = SolveOutcome(puzzleName: layout.name, speciesName: speciesName, energyReward: reward, efficiency: solution.efficiency, firstDiscovery: firstDiscovery, bloomed: bloomed)
        refreshAchievements()
        save()
    }

    func liveSolution(layout: PuzzleLayout, links: Set<PuzzleLink>) -> FlowSolution {
        solver.solve(layout: layout, links: links, capacityBonus: capacityBonus)
    }

    @discardableResult
    private func plantSpecies(_ speciesId: String, zoneId: String) -> Bool {
        guard let species = ContentCatalog.species(speciesId), let zone = ContentCatalog.zone(zoneId) else { return false }
        guard state.plants(inZone: zoneId).count < state.capacity(forZone: zone) else { return false }
        let growthSeconds = species.growthSeconds
        let slot = state.nextSlot(inZone: zoneId)
        let sway = Double((species.id.hashValue & 0xFFF)) / 4096.0
        let plant = Plant(speciesId: speciesId, zoneId: zoneId, slot: slot, growthSeconds: growthSeconds, swaySeed: sway)
        state.plants.append(plant)
        audio.playBloom()
        return true
    }

    func cultivate(speciesId: String) -> Bool {
        guard let species = ContentCatalog.species(speciesId) else { return false }
        let cost = economy.cultivateCost(speciesId: speciesId, state: state)
        guard state.energy.canSpend(cost) else { return false }
        guard let zone = ContentCatalog.zone(species.zoneId), state.plants(inZone: species.zoneId).count < state.capacity(forZone: zone) else { return false }
        state.energy -= cost
        _ = plantSpecies(speciesId, zoneId: species.zoneId)
        haptics.tap()
        save()
        return true
    }

    func cultivateCost(speciesId: String) -> Double {
        economy.cultivateCost(speciesId: speciesId, state: state)
    }

    func canCultivate(speciesId: String) -> Bool {
        guard let species = ContentCatalog.species(speciesId), let zone = ContentCatalog.zone(species.zoneId) else { return false }
        return state.plants(inZone: species.zoneId).count < state.capacity(forZone: zone)
    }

    func expandCost(zoneId: String) -> Double {
        guard let zone = ContentCatalog.zone(zoneId) else { return .infinity }
        return economy.plotExpandCost(zone: zone, state: state)
    }

    func expandPlot(zoneId: String) -> Bool {
        guard let zone = ContentCatalog.zone(zoneId) else { return false }
        let cost = economy.plotExpandCost(zone: zone, state: state)
        guard state.energy.canSpend(cost) else { return false }
        state.energy -= cost
        state.expandedPlots[zoneId, default: 0] += 1
        haptics.unlock()
        save()
        return true
    }

    func upgradeCost(_ upgrade: Upgrade) -> Double {
        economy.upgradeCost(upgrade, state: state)
    }

    func canBuyUpgrade(_ upgrade: Upgrade) -> Bool {
        state.upgradeLevel(upgrade.id) < upgrade.maxLevel && state.energy.canSpend(upgradeCost(upgrade))
    }

    func buyUpgrade(_ upgrade: Upgrade) {
        guard canBuyUpgrade(upgrade) else { return }
        let cost = upgradeCost(upgrade)
        state.energy -= cost
        state.upgradeLevels[upgrade.id, default: 0] += 1
        audio.playUnlock()
        haptics.unlock()
        save()
    }

    func canUnlockZone(_ zone: Zone) -> Bool {
        !state.unlockedZoneIds.contains(zone.id) && state.energy.canSpend(zone.unlockCost) && previousZoneUnlocked(zone)
    }

    func previousZoneUnlocked(_ zone: Zone) -> Bool {
        guard zone.order > 0 else { return true }
        guard let previous = ContentCatalog.zones.first(where: { $0.order == zone.order - 1 }) else { return true }
        return state.unlockedZoneIds.contains(previous.id)
    }

    func unlockZone(_ zone: Zone) {
        guard canUnlockZone(zone) else { return }
        state.energy -= zone.unlockCost
        state.unlockedZoneIds.insert(zone.id)
        state.lifetime.zonesUnlocked = state.unlockedZoneIds.count
        for kind in ContentCatalog.nodeKinds(forZone: zone.id) {
            state.unlockedNodeKinds.insert(kind.rawValue)
        }
        state.currentZoneId = zone.id
        recentUnlockName = zone.name
        audio.playUnlock()
        haptics.unlock()
        refreshAchievements()
        save()
    }

    func selectZone(_ zoneId: String) {
        guard state.unlockedZoneIds.contains(zoneId) else { return }
        state.currentZoneId = zoneId
        audio.startAmbience()
        save()
    }

    func questProgress(_ quest: Quest) -> Double {
        progressValue(for: quest.goal)
    }

    func isQuestComplete(_ quest: Quest) -> Bool {
        questProgress(quest) >= quest.target
    }

    func isQuestClaimed(_ quest: Quest) -> Bool {
        state.claimedQuestIds.contains(quest.id)
    }

    func claimQuest(_ quest: Quest) {
        guard isQuestComplete(quest), !isQuestClaimed(quest) else { return }
        state.claimedQuestIds.insert(quest.id)
        applyReward(quest.reward)
        audio.playUnlock()
        haptics.unlock()
        save()
    }

    private func applyReward(_ reward: Reward) {
        switch reward.kind {
        case .energy:
            state.energy += reward.amount
            state.lifetime.energyGenerated += reward.amount
        case .spores:
            state.spores += reward.amount
        case .boost:
            if let boostId = reward.boostId { activateBoost(boostId) }
        }
    }

    func activateBoost(_ boostId: String) {
        guard let boost = ContentCatalog.boost(boostId) else { return }
        state.activeBoosts.removeAll { $0.boostId == boostId }
        state.activeBoosts.append(ActiveBoost(boostId: boostId, remaining: boost.duration))
    }

    func achievementProgress(_ achievement: Achievement) -> Double {
        progressValue(for: achievement.goal)
    }

    func isAchievementUnlocked(_ achievement: Achievement) -> Bool {
        state.unlockedAchievementIds.contains(achievement.id)
    }

    private func refreshAchievements() {
        for achievement in ContentCatalog.achievements where !state.unlockedAchievementIds.contains(achievement.id) {
            if progressValue(for: achievement.goal) >= achievement.target {
                state.unlockedAchievementIds.insert(achievement.id)
            }
        }
    }

    private func progressValue(for goal: QuestGoal) -> Double {
        switch goal {
        case .growPlants: return Double(state.lifetime.plantsGrown)
        case .solvePuzzles: return Double(state.lifetime.puzzlesSolved)
        case .generateEnergy: return state.lifetime.energyGenerated
        case .triggerChains: return Double(state.lifetime.chainsTriggered)
        case .discoverSpecies: return Double(state.discoveredSpeciesIds.count)
        case .reachNodes: return 0
        case .unlockZones: return Double(state.unlockedZoneIds.count)
        case .prestige: return Double(state.lifetime.prestigeCount)
        }
    }

    func prestigeGain() -> Double {
        economy.sporesFor(energyGenerated: state.lifetime.energyGenerated)
    }

    func canPrestige() -> Bool {
        prestigeGain() >= 1
    }

    func prestige() {
        let gain = prestigeGain()
        guard gain >= 1 else { return }
        let preservedSpores = state.spores + gain
        let preservedDiscoveries = state.discoveredSpeciesIds
        let preservedAchievements = state.unlockedAchievementIds
        let preservedSettings = state.settings
        let preservedStats = state.lifetime

        var fresh = GameState.newGame()
        fresh.spores = preservedSpores
        fresh.discoveredSpeciesIds = preservedDiscoveries
        fresh.unlockedAchievementIds = preservedAchievements
        fresh.settings = preservedSettings
        fresh.lifetime = preservedStats
        fresh.lifetime.prestigeCount += 1
        fresh.onboardingComplete = true
        state = fresh
        bootstrap()
        refreshAchievements()
        audio.playPrestige()
        haptics.unlock()
        save()
    }

    func completeOnboarding() {
        state.onboardingComplete = true
        save()
    }

    func resetTutorial() {
        state.onboardingComplete = false
        save()
    }

    func updateSettings(_ settings: GameSettings) {
        state.settings = settings
        audio.applySettings(settings)
        haptics.enabled = settings.hapticsEnabled
        save()
    }

    func resetProgress() {
        persistence.reset()
        state = GameState.newGame()
        bootstrap()
        audio.applySettings(state.settings)
        save()
    }

    func playTap() { audio.playTap(); haptics.tap() }
    func playWire() { audio.playWire(); haptics.wire() }

    func save() {
        state.lastSeen = Date()
        persistence.save(state)
        saveAccumulator = 0
        dirty = false
    }

    func handleBackground() {
        save()
    }
}

extension Double {
    func canSpend(_ cost: Double) -> Bool {
        self + 0.0001 >= cost
    }
}
