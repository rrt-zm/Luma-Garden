import Foundation
import SwiftData

@Model
final class GameSnapshot {
    var key: String
    var version: Int
    var payload: Data
    var updatedAt: Date

    init(key: String = "primary", version: Int, payload: Data, updatedAt: Date = Date()) {
        self.key = key
        self.version = version
        self.payload = payload
        self.updatedAt = updatedAt
    }
}

final class PersistenceService {
    private let container: ModelContainer?
    private let context: ModelContext?
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init() {
        encoder = JSONEncoder()
        decoder = JSONDecoder()
        let configuration = ModelConfiguration("LumaGarden", schema: Schema([GameSnapshot.self]))
        if let container = try? ModelContainer(for: GameSnapshot.self, configurations: configuration) {
            self.container = container
            self.context = ModelContext(container)
        } else {
            self.container = nil
            self.context = nil
        }
    }

    func load() -> GameState? {
        guard let context else { return nil }
        let descriptor = FetchDescriptor<GameSnapshot>(predicate: #Predicate { $0.key == "primary" })
        guard let snapshot = try? context.fetch(descriptor).first else { return nil }
        guard var state = try? decoder.decode(GameState.self, from: snapshot.payload) else { return nil }
        state = migrate(state)
        return state
    }

    func save(_ state: GameState) {
        guard let context else { return }
        guard let data = try? encoder.encode(state) else { return }
        let descriptor = FetchDescriptor<GameSnapshot>(predicate: #Predicate { $0.key == "primary" })
        if let existing = try? context.fetch(descriptor).first {
            existing.payload = data
            existing.version = state.schemaVersion
            existing.updatedAt = Date()
        } else {
            context.insert(GameSnapshot(version: state.schemaVersion, payload: data))
        }
        try? context.save()
    }

    func reset() {
        guard let context else { return }
        try? context.delete(model: GameSnapshot.self)
        try? context.save()
    }

    private func migrate(_ state: GameState) -> GameState {
        var migrated = state
        if migrated.schemaVersion < GameState.currentSchema {
            migrated.schemaVersion = GameState.currentSchema
        }
        return migrated
    }
}
