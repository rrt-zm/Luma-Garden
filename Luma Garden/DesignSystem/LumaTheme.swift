import SwiftUI

extension Color {
    init(hex: String) {
        var value: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&value)
        let r = Double((value >> 16) & 0xFF) / 255
        let g = Double((value >> 8) & 0xFF) / 255
        let b = Double(value & 0xFF) / 255
        self.init(.sRGB, red: r, green: g, blue: b, opacity: 1)
    }
}

struct LumaTheme {
    var moodHue: Double
    var accentHue: Double
    var isDark: Bool
    var backgroundTop: Color
    var backgroundBottom: Color

    var primary: Color { Color(hue: moodHue, saturation: 0.62, brightness: isDark ? 0.98 : 0.62) }
    var accent: Color { Color(hue: accentHue, saturation: 0.7, brightness: isDark ? 0.98 : 0.6) }
    var glow: Color { Color(hue: moodHue, saturation: 0.5, brightness: 1) }
    var accentGlow: Color { Color(hue: accentHue, saturation: 0.55, brightness: 1) }

    var text: Color { isDark ? Color.white.opacity(0.94) : Color(hex: "10141A") }
    var textSoft: Color { isDark ? Color.white.opacity(0.6) : Color(hex: "10141A").opacity(0.55) }
    var textFaint: Color { isDark ? Color.white.opacity(0.32) : Color(hex: "10141A").opacity(0.3) }

    var panel: Color { isDark ? Color.white.opacity(0.06) : Color.white.opacity(0.55) }
    var panelStrong: Color { isDark ? Color.white.opacity(0.10) : Color.white.opacity(0.75) }
    var panelStroke: Color { isDark ? Color.white.opacity(0.12) : Color.black.opacity(0.08) }
    var bar: Color { isDark ? Color(hue: moodHue, saturation: 0.30, brightness: 0.12) : Color(hue: moodHue, saturation: 0.10, brightness: 0.96) }

    var success: Color { Color(hue: 0.42, saturation: 0.6, brightness: isDark ? 0.95 : 0.55) }
    var warning: Color { Color(hue: 0.06, saturation: 0.75, brightness: isDark ? 0.98 : 0.7) }

    func node(_ kind: NodeKind) -> Color {
        switch kind {
        case .source: return Color(hue: accentHue, saturation: 0.6, brightness: 1)
        case .conductor: return Color(hue: moodHue, saturation: 0.5, brightness: 0.95)
        case .splitter: return Color(hue: moodHue + 0.08, saturation: 0.6, brightness: 0.97)
        case .mirror: return Color(hue: moodHue - 0.06, saturation: 0.55, brightness: 0.96)
        case .gate: return Color(hue: 0.09, saturation: 0.7, brightness: 0.98)
        case .sink: return Color(hue: moodHue + 0.04, saturation: 0.7, brightness: 1)
        }
    }

    func rarity(_ rarity: Rarity) -> Color {
        switch rarity {
        case .common: return Color(hue: 0.46, saturation: 0.4, brightness: 0.85)
        case .uncommon: return Color(hue: 0.55, saturation: 0.55, brightness: 0.95)
        case .rare: return Color(hue: 0.62, saturation: 0.6, brightness: 0.98)
        case .radiant: return Color(hue: 0.78, saturation: 0.6, brightness: 1)
        case .mythic: return Color(hue: 0.09, saturation: 0.7, brightness: 1)
        }
    }

    static func make(zone: Zone, preference: ThemePreference, systemDark: Bool) -> LumaTheme {
        let isDark: Bool
        switch preference {
        case .dark: isDark = true
        case .light: isDark = false
        case .system: isDark = systemDark
        }
        let top: Color
        let bottom: Color
        if isDark {
            top = Color(hex: zone.backgroundTop)
            bottom = Color(hex: zone.backgroundBottom)
        } else {
            top = Color(hue: zone.moodHue, saturation: 0.12, brightness: 0.97)
            bottom = Color(hue: zone.accentHue, saturation: 0.16, brightness: 0.9)
        }
        return LumaTheme(moodHue: zone.moodHue, accentHue: zone.accentHue, isDark: isDark, backgroundTop: top, backgroundBottom: bottom)
    }

    static let fallback = LumaTheme(moodHue: 0.46, accentHue: 0.4, isDark: true, backgroundTop: Color(hex: "0B1418"), backgroundBottom: Color(hex: "06090C"))
}

private struct LumaThemeKey: EnvironmentKey {
    static let defaultValue = LumaTheme.fallback
}

extension EnvironmentValues {
    var luma: LumaTheme {
        get { self[LumaThemeKey.self] }
        set { self[LumaThemeKey.self] = newValue }
    }
}

enum LumaMetric {
    static let tabBarInset: CGFloat = 96
    static let cornerLarge: CGFloat = 28
    static let cornerMedium: CGFloat = 20
    static let cornerSmall: CGFloat = 14
    static let spacing: CGFloat = 16
    static let spacingLarge: CGFloat = 24
}

enum LumaFont {
    static func display(_ size: CGFloat) -> Font { .system(size: size, weight: .semibold, design: .rounded) }
    static func title(_ size: CGFloat) -> Font { .system(size: size, weight: .medium, design: .rounded) }
    static func body(_ size: CGFloat) -> Font { .system(size: size, weight: .regular, design: .rounded) }
    static func mono(_ size: CGFloat) -> Font { .system(size: size, weight: .medium, design: .rounded).monospacedDigit() }
}
