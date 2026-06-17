import Foundation

struct GridPoint: Codable, Hashable {
    var col: Int
    var row: Int
}

enum NodeKind: String, Codable, CaseIterable {
    case source
    case conductor
    case splitter
    case mirror
    case gate
    case sink

    var displayName: String {
        switch self {
        case .source: return "Source"
        case .conductor: return "Conductor"
        case .splitter: return "Splitter"
        case .mirror: return "Mirror"
        case .gate: return "Gate"
        case .sink: return "Bloom Sink"
        }
    }

    var summary: String {
        switch self {
        case .source: return "Emits a steady stream of light into the network."
        case .conductor: return "Carries light onward to a single neighbor."
        case .splitter: return "Branches light outward to every connected node."
        case .mirror: return "Redirects light along a new path."
        case .gate: return "Opens only when fed light through enough connected wires."
        case .sink: return "A seed waiting for light. Energize it to bloom."
        }
    }

    var baseCapacity: Int {
        switch self {
        case .source: return 2
        case .conductor: return 2
        case .splitter: return 4
        case .mirror: return 2
        case .gate: return 4
        case .sink: return 2
        }
    }
}

struct PuzzleNode: Codable, Identifiable, Hashable {
    var id: Int
    var kind: NodeKind
    var position: GridPoint
    var gateThreshold: Int

    init(id: Int, kind: NodeKind, position: GridPoint, gateThreshold: Int = 2) {
        self.id = id
        self.kind = kind
        self.position = position
        self.gateThreshold = gateThreshold
    }
}

struct PuzzleLink: Codable, Hashable {
    var a: Int
    var b: Int

    init(_ a: Int, _ b: Int) {
        self.a = min(a, b)
        self.b = max(a, b)
    }

    func contains(_ node: Int) -> Bool {
        a == node || b == node
    }

    func other(than node: Int) -> Int {
        node == a ? b : a
    }
}

struct PuzzleLayout: Codable, Identifiable {
    var id: String
    var name: String
    var zoneId: String
    var rewardSpeciesId: String
    var difficulty: Int
    var columns: Int
    var rows: Int
    var nodes: [PuzzleNode]
    var optimalLinks: Int

    func node(_ id: Int) -> PuzzleNode? {
        nodes.first { $0.id == id }
    }
}

struct FlowSolution {
    var poweredNodes: Set<Int>
    var poweredLinks: Set<PuzzleLink>
    var isSolved: Bool
    var unpoweredSinks: Set<Int>
    var overloadedNodes: Set<Int>
    var efficiency: Double
    var chainOrder: [Int]
}
