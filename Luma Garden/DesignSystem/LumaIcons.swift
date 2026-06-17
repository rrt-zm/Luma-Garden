import SwiftUI

enum LumaGlyph {
    case garden
    case puzzle
    case zones
    case upgrades
    case codex
    case quests
    case stats
    case zen
    case prestige
    case settings
    case close
    case lock
    case check
    case spark
    case boost
}

struct GlyphView: View {
    var glyph: LumaGlyph
    var size: CGFloat
    var color: Color
    var filled: Bool = false

    var body: some View {
        Canvas { context, canvasSize in
            let rect = CGRect(origin: .zero, size: canvasSize).insetBy(dx: canvasSize.width * 0.12, dy: canvasSize.height * 0.12)
            let path = LumaIconPath.path(for: glyph, in: rect)
            if filled {
                context.fill(path, with: .color(color))
            }
            context.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: max(1.4, size * 0.07), lineCap: .round, lineJoin: .round))
        }
        .frame(width: size, height: size)
    }
}

enum LumaIconPath {
    static func path(for glyph: LumaGlyph, in r: CGRect) -> Path {
        var p = Path()
        let w = r.width
        let h = r.height
        let x = r.minX
        let y = r.minY
        func pt(_ fx: Double, _ fy: Double) -> CGPoint { CGPoint(x: x + fx * w, y: y + fy * h) }
        switch glyph {
        case .garden:
            p.move(to: pt(0.5, 1.0))
            p.addLine(to: pt(0.5, 0.45))
            p.addQuadCurve(to: pt(0.2, 0.2), control: pt(0.2, 0.5))
            p.addQuadCurve(to: pt(0.5, 0.45), control: pt(0.45, 0.35))
            p.move(to: pt(0.5, 0.55))
            p.addQuadCurve(to: pt(0.82, 0.28), control: pt(0.82, 0.58))
            p.addQuadCurve(to: pt(0.5, 0.55), control: pt(0.56, 0.42))
        case .puzzle:
            p.addEllipse(in: CGRect(x: x + 0.06 * w, y: y + 0.06 * h, width: 0.22 * w, height: 0.22 * h))
            p.addEllipse(in: CGRect(x: x + 0.72 * w, y: y + 0.18 * h, width: 0.22 * w, height: 0.22 * h))
            p.addEllipse(in: CGRect(x: x + 0.38 * w, y: y + 0.7 * h, width: 0.22 * w, height: 0.22 * h))
            p.move(to: pt(0.27, 0.18)); p.addLine(to: pt(0.74, 0.27))
            p.move(to: pt(0.2, 0.27)); p.addLine(to: pt(0.46, 0.7))
            p.move(to: pt(0.82, 0.4)); p.addLine(to: pt(0.55, 0.74))
        case .zones:
            p.move(to: pt(0.5, 0.08)); p.addLine(to: pt(0.92, 0.32)); p.addLine(to: pt(0.92, 0.68))
            p.addLine(to: pt(0.5, 0.92)); p.addLine(to: pt(0.08, 0.68)); p.addLine(to: pt(0.08, 0.32)); p.closeSubpath()
            p.move(to: pt(0.5, 0.34)); p.addLine(to: pt(0.7, 0.45)); p.addLine(to: pt(0.7, 0.6))
            p.addLine(to: pt(0.5, 0.7)); p.addLine(to: pt(0.3, 0.6)); p.addLine(to: pt(0.3, 0.45)); p.closeSubpath()
        case .upgrades:
            p.move(to: pt(0.15, 0.6)); p.addLine(to: pt(0.5, 0.22)); p.addLine(to: pt(0.85, 0.6))
            p.move(to: pt(0.25, 0.85)); p.addLine(to: pt(0.5, 0.55)); p.addLine(to: pt(0.75, 0.85))
        case .codex:
            p.addRoundedRect(in: CGRect(x: x + 0.18 * w, y: y + 0.1 * h, width: 0.64 * w, height: 0.8 * h), cornerSize: CGSize(width: 0.08 * w, height: 0.08 * w))
            p.move(to: pt(0.5, 0.1)); p.addLine(to: pt(0.5, 0.9))
            p.move(to: pt(0.3, 0.34)); p.addLine(to: pt(0.42, 0.34))
            p.move(to: pt(0.58, 0.34)); p.addLine(to: pt(0.7, 0.34))
        case .quests:
            p.move(to: pt(0.2, 0.3)); p.addLine(to: pt(0.42, 0.5)); p.addLine(to: pt(0.82, 0.16))
            p.move(to: pt(0.2, 0.7)); p.addLine(to: pt(0.42, 0.9)); p.addLine(to: pt(0.82, 0.56))
        case .stats:
            p.move(to: pt(0.12, 0.88)); p.addLine(to: pt(0.12, 0.12))
            p.move(to: pt(0.12, 0.88)); p.addLine(to: pt(0.9, 0.88))
            p.move(to: pt(0.28, 0.7)); p.addLine(to: pt(0.46, 0.45)); p.addLine(to: pt(0.62, 0.58)); p.addLine(to: pt(0.84, 0.24))
        case .zen:
            p.addEllipse(in: CGRect(x: x + 0.2 * w, y: y + 0.2 * h, width: 0.6 * w, height: 0.6 * h))
            p.addEllipse(in: CGRect(x: x + 0.43 * w, y: y + 0.43 * h, width: 0.14 * w, height: 0.14 * h))
        case .prestige:
            for i in 0..<8 {
                let a = Double(i) / 8 * 2 * .pi
                p.move(to: pt(0.5, 0.5))
                p.addLine(to: pt(0.5 + cos(a) * 0.42, 0.5 + sin(a) * 0.42))
            }
            p.addEllipse(in: CGRect(x: x + 0.36 * w, y: y + 0.36 * h, width: 0.28 * w, height: 0.28 * h))
        case .settings:
            p.addEllipse(in: CGRect(x: x + 0.34 * w, y: y + 0.34 * h, width: 0.32 * w, height: 0.32 * h))
            for i in 0..<6 {
                let a = Double(i) / 6 * 2 * .pi
                p.move(to: pt(0.5 + cos(a) * 0.34, 0.5 + sin(a) * 0.34))
                p.addLine(to: pt(0.5 + cos(a) * 0.46, 0.5 + sin(a) * 0.46))
            }
        case .close:
            p.move(to: pt(0.25, 0.25)); p.addLine(to: pt(0.75, 0.75))
            p.move(to: pt(0.75, 0.25)); p.addLine(to: pt(0.25, 0.75))
        case .lock:
            p.addRoundedRect(in: CGRect(x: x + 0.25 * w, y: y + 0.45 * h, width: 0.5 * w, height: 0.45 * h), cornerSize: CGSize(width: 0.06 * w, height: 0.06 * w))
            p.move(to: pt(0.33, 0.45)); p.addLine(to: pt(0.33, 0.3))
            p.addQuadCurve(to: pt(0.67, 0.3), control: pt(0.5, 0.1))
            p.addLine(to: pt(0.67, 0.45))
        case .check:
            p.move(to: pt(0.2, 0.55)); p.addLine(to: pt(0.42, 0.78)); p.addLine(to: pt(0.82, 0.26))
        case .spark:
            p.move(to: pt(0.5, 0.1)); p.addLine(to: pt(0.58, 0.42)); p.addLine(to: pt(0.9, 0.5))
            p.addLine(to: pt(0.58, 0.58)); p.addLine(to: pt(0.5, 0.9)); p.addLine(to: pt(0.42, 0.58))
            p.addLine(to: pt(0.1, 0.5)); p.addLine(to: pt(0.42, 0.42)); p.closeSubpath()
        case .boost:
            p.move(to: pt(0.5, 0.08)); p.addLine(to: pt(0.74, 0.5)); p.addLine(to: pt(0.56, 0.5))
            p.addLine(to: pt(0.56, 0.92)); p.addLine(to: pt(0.32, 0.46)); p.addLine(to: pt(0.5, 0.46)); p.closeSubpath()
        }
        return p
    }
}

struct NodeGlyph: View {
    var kind: NodeKind
    var size: CGFloat
    var color: Color

    var body: some View {
        Canvas { context, canvasSize in
            let rect = CGRect(origin: .zero, size: canvasSize).insetBy(dx: canvasSize.width * 0.18, dy: canvasSize.height * 0.18)
            let path = shapePath(in: rect)
            context.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: max(1.4, size * 0.08), lineCap: .round, lineJoin: .round))
        }
        .frame(width: size, height: size)
    }

    private func shapePath(in r: CGRect) -> Path {
        var p = Path()
        switch kind {
        case .source:
            p.addEllipse(in: r.insetBy(dx: r.width * 0.22, dy: r.height * 0.22))
            for i in 0..<6 {
                let a = Double(i) / 6 * 2 * .pi
                let c = CGPoint(x: r.midX, y: r.midY)
                p.move(to: CGPoint(x: c.x + cos(a) * r.width * 0.32, y: c.y + sin(a) * r.width * 0.32))
                p.addLine(to: CGPoint(x: c.x + cos(a) * r.width * 0.5, y: c.y + sin(a) * r.width * 0.5))
            }
        case .conductor:
            p.addEllipse(in: r.insetBy(dx: r.width * 0.16, dy: r.height * 0.16))
        case .splitter:
            p.move(to: CGPoint(x: r.midX, y: r.maxY)); p.addLine(to: CGPoint(x: r.midX, y: r.midY))
            p.addLine(to: CGPoint(x: r.minX, y: r.minY))
            p.move(to: CGPoint(x: r.midX, y: r.midY)); p.addLine(to: CGPoint(x: r.maxX, y: r.minY))
        case .mirror:
            p.move(to: CGPoint(x: r.minX, y: r.maxY)); p.addLine(to: CGPoint(x: r.maxX, y: r.minY))
            p.move(to: CGPoint(x: r.minX, y: r.midY)); p.addLine(to: CGPoint(x: r.midX, y: r.midY))
        case .gate:
            let cx = r.midX, cy = r.midY, rad = r.width * 0.42
            for i in 0..<6 {
                let a = Double(i) / 6 * 2 * .pi - .pi / 2
                let pnt = CGPoint(x: cx + cos(a) * rad, y: cy + sin(a) * rad)
                if i == 0 { p.move(to: pnt) } else { p.addLine(to: pnt) }
            }
            p.closeSubpath()
        case .sink:
            for i in 0..<5 {
                let a = Double(i) / 5 * 2 * .pi - .pi / 2
                let c = CGPoint(x: r.midX, y: r.midY)
                let tip = CGPoint(x: c.x + cos(a) * r.width * 0.45, y: c.y + sin(a) * r.width * 0.45)
                p.move(to: c)
                p.addQuadCurve(to: tip, control: CGPoint(x: c.x + cos(a - 0.4) * r.width * 0.3, y: c.y + sin(a - 0.4) * r.width * 0.3))
            }
        }
        return p
    }
}
