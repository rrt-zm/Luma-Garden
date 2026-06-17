import SwiftUI

@MainActor
final class AppContainer {
    let store: GameStore

    init() {
        let persistence = PersistenceService()
        let audio = AudioService()
        let haptics = HapticsService()
        store = GameStore(persistence: persistence, audio: audio, haptics: haptics)
    }
}
