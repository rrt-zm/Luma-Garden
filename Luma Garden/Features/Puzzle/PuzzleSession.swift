import SwiftUI
import Observation

@MainActor
@Observable
final class PuzzleSession {
    let layout: PuzzleLayout
    var links: Set<PuzzleLink> = []
    var solution: FlowSolution
    private let solve: (PuzzleLayout, Set<PuzzleLink>) -> FlowSolution

    init(layout: PuzzleLayout, solve: @escaping (PuzzleLayout, Set<PuzzleLink>) -> FlowSolution) {
        self.layout = layout
        self.solve = solve
        self.solution = solve(layout, [])
    }

    var isSolved: Bool { solution.isSolved }

    func toggleLink(_ a: Int, _ b: Int) {
        guard a != b else { return }
        let link = PuzzleLink(a, b)
        if links.contains(link) {
            links.remove(link)
        } else {
            links.insert(link)
        }
        recompute()
    }

    func removeLinks(touching node: Int) {
        links = links.filter { !$0.contains(node) }
        recompute()
    }

    func clear() {
        links.removeAll()
        recompute()
    }

    private func recompute() {
        solution = solve(layout, links)
    }
}
