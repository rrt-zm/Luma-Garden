import Foundation

struct FlowSolver {
    func solve(layout: PuzzleLayout, links: Set<PuzzleLink>, capacityBonus: Int = 0) -> FlowSolution {
        var adjacency: [Int: [Int]] = [:]
        var degree: [Int: Int] = [:]
        for link in links {
            adjacency[link.a, default: []].append(link.b)
            adjacency[link.b, default: []].append(link.a)
            degree[link.a, default: 0] += 1
            degree[link.b, default: 0] += 1
        }

        var powered = Set<Int>()
        for node in layout.nodes where node.kind == .source {
            powered.insert(node.id)
        }

        var changed = true
        while changed {
            changed = false
            for node in layout.nodes where !powered.contains(node.id) {
                let neighbors = adjacency[node.id] ?? []
                let poweredNeighbors = neighbors.filter { powered.contains($0) }.count
                if node.kind == .gate {
                    if poweredNeighbors >= 1 && (degree[node.id] ?? 0) >= max(2, node.gateThreshold) {
                        powered.insert(node.id)
                        changed = true
                    }
                } else if poweredNeighbors >= 1 {
                    powered.insert(node.id)
                    changed = true
                }
            }
        }

        var poweredLinks = Set<PuzzleLink>()
        for link in links where powered.contains(link.a) && powered.contains(link.b) {
            poweredLinks.insert(link)
        }

        var overloaded = Set<Int>()
        for node in layout.nodes {
            let capacity = node.kind.baseCapacity + capacityBonus
            if (degree[node.id] ?? 0) > capacity {
                overloaded.insert(node.id)
            }
        }

        var unpoweredSinks = Set<Int>()
        for node in layout.nodes where node.kind == .sink && !powered.contains(node.id) {
            unpoweredSinks.insert(node.id)
        }

        let solved = unpoweredSinks.isEmpty && overloaded.isEmpty
        let usedLinks = max(1, links.count)
        let efficiency = min(1, Double(layout.optimalLinks) / Double(usedLinks))
        let chainOrder = solved ? breadthOrder(layout: layout, adjacency: adjacency, powered: powered) : []

        return FlowSolution(
            poweredNodes: powered,
            poweredLinks: poweredLinks,
            isSolved: solved,
            unpoweredSinks: unpoweredSinks,
            overloadedNodes: overloaded,
            efficiency: efficiency,
            chainOrder: chainOrder
        )
    }

    private func breadthOrder(layout: PuzzleLayout, adjacency: [Int: [Int]], powered: Set<Int>) -> [Int] {
        var visited = Set<Int>()
        var order: [Int] = []
        var queue: [Int] = layout.nodes.filter { $0.kind == .source }.map { $0.id }
        for id in queue { visited.insert(id) }
        var head = 0
        while head < queue.count {
            let current = queue[head]
            head += 1
            order.append(current)
            for neighbor in (adjacency[current] ?? []).sorted() where powered.contains(neighbor) && !visited.contains(neighbor) {
                visited.insert(neighbor)
                queue.append(neighbor)
            }
        }
        return order
    }

    func defaultLinkRange(for layout: PuzzleLayout) -> Int {
        max(layout.columns, layout.rows)
    }
}
