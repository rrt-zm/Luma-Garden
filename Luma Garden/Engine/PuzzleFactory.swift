import Foundation

enum PuzzleFactory {
    static let puzzlesPerZone = 8

    static func puzzles(forZone zoneId: String) -> [PuzzleLayout] {
        guard let zone = ContentCatalog.zone(zoneId) else { return [] }
        let zoneSpecies = ContentCatalog.species(inZone: zoneId)
        return (0..<puzzlesPerZone).map { index in
            let species = zoneSpecies[index % max(1, zoneSpecies.count)]
            return generate(zone: zone, localIndex: index, rewardSpeciesId: species.id)
        }
    }

    static func allPuzzles() -> [PuzzleLayout] {
        ContentCatalog.zones.flatMap { puzzles(forZone: $0.id) }
    }

    static func zen(zoneId: String, variant: Int) -> PuzzleLayout {
        let zone = ContentCatalog.zone(zoneId) ?? ContentCatalog.zones[0]
        let speciesList = ContentCatalog.species(inZone: zone.id)
        let species = speciesList[variant % max(1, speciesList.count)]
        let localIndex = 2 + (variant % 6)
        return generate(zone: zone, localIndex: localIndex, rewardSpeciesId: species.id)
    }

    static func puzzle(id: String) -> PuzzleLayout? {
        let parts = id.split(separator: "#")
        guard parts.count == 2, let index = Int(parts[1]) else { return nil }
        let zoneId = String(parts[0])
        let all = puzzles(forZone: zoneId)
        return all.first { $0.id == id } ?? (index < all.count ? all[index] : nil)
    }

    private static func generate(zone: Zone, localIndex: Int, rewardSpeciesId: String) -> PuzzleLayout {
        let zi = zone.order
        let seed = UInt64(0xA53 &+ zi &* 131 &+ localIndex &* 977)
        var rng = SeededGenerator(seed: seed)

        let cols = 4 + min(2, zi) + (localIndex >= 5 ? 1 : 0)
        let rows = 5 + min(3, zi) + (localIndex >= 3 ? 1 : 0)
        let spineLength = min(cols * rows - 2, 4 + localIndex / 2 + zi)

        let allowMirror = zoneAllows(.mirror, zoneOrder: zi)
        let allowSplitter = zoneAllows(.splitter, zoneOrder: zi)
        let allowGate = zoneAllows(.gate, zoneOrder: zi)

        var occupied = Set<GridPoint>()
        var spine = buildWalk(cols: cols, rows: rows, length: spineLength, occupied: &occupied, rng: &rng)
        if spine.count < 3 {
            spine = [GridPoint(col: 0, row: 0), GridPoint(col: 1, row: 0), GridPoint(col: 2, row: 0)]
            occupied = Set(spine)
        }

        var positions = spine
        var edges: [(Int, Int)] = []
        for i in 0..<(spine.count - 1) {
            edges.append((i, i + 1))
        }

        let branchCount = (allowSplitter ? (localIndex >= 2 ? 1 : 0) : 0) + (localIndex >= 5 ? 1 : 0) + (zi >= 3 ? 1 : 0)
        var branchEndIndices: [Int] = []
        var splitterIndices = Set<Int>()
        for _ in 0..<branchCount {
            guard spine.count > 2 else { break }
            let anchorIndex = 1 + rng.int(0..<(spine.count - 1))
            let branch = buildBranch(from: positions[anchorIndex], cols: cols, rows: rows, length: 1 + rng.int(0..<3), occupied: &occupied, rng: &rng)
            guard !branch.isEmpty else { continue }
            splitterIndices.insert(anchorIndex)
            var prev = anchorIndex
            for point in branch {
                positions.append(point)
                let newIndex = positions.count - 1
                edges.append((prev, newIndex))
                prev = newIndex
            }
            branchEndIndices.append(prev)
        }

        var kinds = [NodeKind](repeating: .conductor, count: positions.count)
        kinds[0] = .source
        var thresholds = [Int](repeating: 2, count: positions.count)

        var sinkIndices = Set<Int>()
        sinkIndices.insert(positions.count - 1 == 0 ? 0 : spine.count - 1)
        for end in branchEndIndices { sinkIndices.insert(end) }
        if sinkIndices.contains(0) { sinkIndices.remove(0); sinkIndices.insert(spine.count - 1) }
        for index in sinkIndices { kinds[index] = .sink }

        for index in splitterIndices where kinds[index] == .conductor {
            kinds[index] = allowSplitter ? .splitter : .conductor
        }

        let degree = nodeDegrees(edges: edges, count: positions.count)

        if allowGate {
            for index in 0..<positions.count where kinds[index] == .splitter && degree[index] >= 3 {
                if rng.chance(0.6) {
                    kinds[index] = .gate
                    thresholds[index] = 2
                }
            }
        }

        if allowMirror {
            for index in 1..<positions.count where kinds[index] == .conductor && degree[index] == 2 {
                if isCorner(index: index, positions: positions, edges: edges) && rng.chance(0.5) {
                    kinds[index] = .mirror
                }
            }
        }

        let nodes = (0..<positions.count).map { index in
            PuzzleNode(id: index, kind: kinds[index], position: positions[index], gateThreshold: thresholds[index])
        }

        let id = "\(zone.id)#\(localIndex)"
        let name = "\(zone.name) \(romanNumeral(localIndex + 1))"
        let layout = PuzzleLayout(
            id: id,
            name: name,
            zoneId: zone.id,
            rewardSpeciesId: rewardSpeciesId,
            difficulty: zi * puzzlesPerZone + localIndex + 1,
            columns: cols,
            rows: rows,
            nodes: nodes,
            optimalLinks: edges.count
        )
        return layout
    }

    private static func zoneAllows(_ kind: NodeKind, zoneOrder: Int) -> Bool {
        switch kind {
        case .splitter: return true
        case .mirror: return zoneOrder >= 1
        case .gate: return zoneOrder >= 2
        default: return true
        }
    }

    private static func buildWalk(cols: Int, rows: Int, length: Int, occupied: inout Set<GridPoint>, rng: inout SeededGenerator) -> [GridPoint] {
        var current = GridPoint(col: rng.int(0..<cols), row: rng.int(0..<rows))
        occupied.insert(current)
        var path = [current]
        while path.count < length {
            let candidates = neighbors(of: current, cols: cols, rows: rows).filter { !occupied.contains($0) }
            guard !candidates.isEmpty else { break }
            current = candidates[rng.int(0..<candidates.count)]
            occupied.insert(current)
            path.append(current)
        }
        return path
    }

    private static func buildBranch(from start: GridPoint, cols: Int, rows: Int, length: Int, occupied: inout Set<GridPoint>, rng: inout SeededGenerator) -> [GridPoint] {
        var current = start
        var branch: [GridPoint] = []
        for _ in 0..<length {
            let candidates = neighbors(of: current, cols: cols, rows: rows).filter { !occupied.contains($0) }
            guard !candidates.isEmpty else { break }
            current = candidates[rng.int(0..<candidates.count)]
            occupied.insert(current)
            branch.append(current)
        }
        return branch
    }

    private static func neighbors(of point: GridPoint, cols: Int, rows: Int) -> [GridPoint] {
        var result: [GridPoint] = []
        if point.col > 0 { result.append(GridPoint(col: point.col - 1, row: point.row)) }
        if point.col < cols - 1 { result.append(GridPoint(col: point.col + 1, row: point.row)) }
        if point.row > 0 { result.append(GridPoint(col: point.col, row: point.row - 1)) }
        if point.row < rows - 1 { result.append(GridPoint(col: point.col, row: point.row + 1)) }
        return result
    }

    private static func nodeDegrees(edges: [(Int, Int)], count: Int) -> [Int] {
        var degree = [Int](repeating: 0, count: count)
        for edge in edges {
            degree[edge.0] += 1
            degree[edge.1] += 1
        }
        return degree
    }

    private static func isCorner(index: Int, positions: [GridPoint], edges: [(Int, Int)]) -> Bool {
        let connected = edges.compactMap { edge -> Int? in
            if edge.0 == index { return edge.1 }
            if edge.1 == index { return edge.0 }
            return nil
        }
        guard connected.count == 2 else { return false }
        let a = positions[connected[0]]
        let b = positions[connected[1]]
        let here = positions[index]
        let dx1 = a.col - here.col
        let dy1 = a.row - here.row
        let dx2 = b.col - here.col
        let dy2 = b.row - here.row
        return (dx1 != dx2) && (dy1 != dy2)
    }

    private static func romanNumeral(_ value: Int) -> String {
        let table: [(Int, String)] = [(10, "X"), (9, "IX"), (5, "V"), (4, "IV"), (1, "I")]
        var remaining = value
        var result = ""
        for (number, symbol) in table {
            while remaining >= number {
                result += symbol
                remaining -= number
            }
        }
        return result.isEmpty ? "I" : result
    }
}
