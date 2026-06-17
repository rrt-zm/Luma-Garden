import SwiftUI

struct PuzzleBoardView: View {
    @Environment(\.luma) private var luma
    @Bindable var session: PuzzleSession
    var quality: QualityPreference
    var onWire: () -> Void

    @State private var dragStart: Int?
    @State private var dragPoint: CGPoint?
    @State private var selected: Int?

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            ZStack {
                TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
                    let t = timeline.date.timeIntervalSinceReferenceDate
                    Canvas { context, _ in
                        drawLinks(&context, size: size, time: t)
                        drawDragLine(&context, size: size)
                    }
                }
                ForEach(session.layout.nodes) { node in
                    nodeView(node, size: size)
                        .position(center(of: node, in: size))
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        if dragStart == nil {
                            dragStart = hitNode(at: value.startLocation, size: size)
                        }
                        dragPoint = value.location
                    }
                    .onEnded { value in
                        defer { dragStart = nil; dragPoint = nil }
                        let translation = hypot(value.translation.width, value.translation.height)
                        guard let start = dragStart else { return }
                        if translation < 10 {
                            handleTap(start)
                        } else if let end = hitNode(at: value.location, size: size), end != start {
                            session.toggleLink(start, end)
                            selected = nil
                            onWire()
                        }
                    }
            )
        }
    }

    private func handleTap(_ node: Int) {
        if let current = selected {
            if current == node {
                selected = nil
            } else {
                session.toggleLink(current, node)
                selected = nil
                onWire()
            }
        } else {
            selected = node
        }
    }

    private func nodeView(_ node: PuzzleNode, size: CGSize) -> some View {
        let radius = nodeRadius(size)
        let powered = session.solution.poweredNodes.contains(node.id)
        let overloaded = session.solution.overloadedNodes.contains(node.id)
        let unpoweredSink = session.solution.unpoweredSinks.contains(node.id)
        let color = luma.node(node.kind)
        let ringColor: Color = overloaded ? luma.warning : (powered ? color : luma.textFaint)
        return ZStack {
            Circle()
                .fill(powered ? color.opacity(0.22) : luma.panel)
                .frame(width: radius * 2, height: radius * 2)
            Circle()
                .stroke(ringColor.opacity(selected == node.id ? 1 : 0.8), lineWidth: selected == node.id ? 3 : 2)
                .frame(width: radius * 2, height: radius * 2)
            NodeGlyph(kind: node.kind, size: radius * 1.5, color: powered ? color : luma.textSoft)
            if node.kind == .gate {
                Text("\(max(2, node.gateThreshold))")
                    .font(LumaFont.mono(10))
                    .foregroundStyle(luma.text)
                    .offset(y: radius * 0.9)
            }
        }
        .lumaGlow(powered && quality.glowEnabled ? color : .clear, radius: 14, intensity: powered ? 0.7 : 0)
        .scaleEffect(unpoweredSink ? 1.0 : 1.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: powered)
    }

    private func drawLinks(_ context: inout GraphicsContext, size: CGSize, time: Double) {
        for link in session.links {
            guard let a = session.layout.node(link.a), let b = session.layout.node(link.b) else { continue }
            let pa = center(of: a, in: size)
            let pb = center(of: b, in: size)
            let powered = session.solution.poweredLinks.contains(link)
            var path = Path()
            path.move(to: pa)
            path.addLine(to: pb)
            let baseColor = powered ? luma.glow : luma.textFaint
            context.stroke(path, with: .color(baseColor.opacity(powered ? 0.7 : 0.45)), style: StrokeStyle(lineWidth: powered ? 4 : 2.5, lineCap: .round))
            if powered && quality != .calm {
                let count = 2
                for i in 0..<count {
                    let frac = ((time * 0.5) + Double(i) / Double(count)).truncatingRemainder(dividingBy: 1)
                    let p = CGPoint(x: pa.x + (pb.x - pa.x) * frac, y: pa.y + (pb.y - pa.y) * frac)
                    let dot = CGRect(x: p.x - 3.5, y: p.y - 3.5, width: 7, height: 7)
                    context.fill(Circle().path(in: dot), with: .color(luma.accentGlow.opacity(0.9)))
                }
            }
        }
    }

    private func drawDragLine(_ context: inout GraphicsContext, size: CGSize) {
        guard let start = dragStart, let point = dragPoint, let node = session.layout.node(start) else { return }
        var path = Path()
        path.move(to: center(of: node, in: size))
        path.addLine(to: point)
        context.stroke(path, with: .color(luma.accent.opacity(0.6)), style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [6, 6]))
    }

    private func nodeRadius(_ size: CGSize) -> CGFloat {
        let cell = min(size.width / CGFloat(session.layout.columns), size.height / CGFloat(session.layout.rows))
        return max(16, min(30, cell * 0.34))
    }

    private func center(of node: PuzzleNode, in size: CGSize) -> CGPoint {
        let padX = size.width * 0.1
        let padY = size.height * 0.08
        let innerW = size.width - padX * 2
        let innerH = size.height - padY * 2
        let x = padX + (CGFloat(node.position.col) + 0.5) / CGFloat(session.layout.columns) * innerW
        let y = padY + (CGFloat(node.position.row) + 0.5) / CGFloat(session.layout.rows) * innerH
        return CGPoint(x: x, y: y)
    }

    private func hitNode(at point: CGPoint, size: CGSize) -> Int? {
        let radius = nodeRadius(size) * 1.7
        var best: Int?
        var bestDistance = radius
        for node in session.layout.nodes {
            let c = center(of: node, in: size)
            let d = hypot(c.x - point.x, c.y - point.y)
            if d < bestDistance {
                bestDistance = d
                best = node.id
            }
        }
        return best
    }
}
