import SwiftUI

enum ClockTheme: String, CaseIterable, Identifiable, Codable {
    case jiaWarmGlow
    case quietNight
    case creamDawn
    case clearGlass
    case forestBreath
    case oceanCalm
    case sakuraDusk
    case auroraNight

    var id: String { rawValue }

    init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self)
        if let theme = ClockTheme(rawValue: raw) {
            self = theme
        } else {
            self = Self.migrated(fromLegacy: raw)
        }
    }

    static func migrated(fromLegacy raw: String) -> ClockTheme {
        switch raw {
        case "dawn": return .jiaWarmGlow
        case "midnight": return .quietNight
        case "forest": return .forestBreath
        case "ocean": return .oceanCalm
        default: return .jiaWarmGlow
        }
    }

    var title: String {
        switch self {
        case .jiaWarmGlow: L10n.Theme.jiaWarmGlow
        case .quietNight: L10n.Theme.quietNight
        case .creamDawn: L10n.Theme.creamDawn
        case .clearGlass: L10n.Theme.clearGlass
        case .forestBreath: L10n.Theme.forestBreath
        case .oceanCalm: L10n.Theme.oceanCalm
        case .sakuraDusk: L10n.Theme.sakuraDusk
        case .auroraNight: L10n.Theme.auroraNight
        }
    }

    var description: String {
        switch self {
        case .jiaWarmGlow: L10n.Theme.jiaWarmGlowDesc
        case .quietNight: L10n.Theme.quietNightDesc
        case .creamDawn: L10n.Theme.creamDawnDesc
        case .clearGlass: L10n.Theme.clearGlassDesc
        case .forestBreath: L10n.Theme.forestBreathDesc
        case .oceanCalm: L10n.Theme.oceanCalmDesc
        case .sakuraDusk: L10n.Theme.sakuraDuskDesc
        case .auroraNight: L10n.Theme.auroraNightDesc
        }
    }

    var isLightTheme: Bool {
        switch self {
        case .creamDawn, .clearGlass: true
        default: false
        }
    }

    var accentColor: Color {
        switch self {
        case .jiaWarmGlow: Color(red: 0.98, green: 0.62, blue: 0.38)
        case .quietNight: Color(red: 0.58, green: 0.68, blue: 0.98)
        case .creamDawn: Color(red: 0.92, green: 0.58, blue: 0.38)
        case .clearGlass: Color(red: 0.88, green: 0.90, blue: 0.96)
        case .forestBreath: Color(red: 0.72, green: 0.88, blue: 0.52)
        case .oceanCalm: Color(red: 0.42, green: 0.78, blue: 0.92)
        case .sakuraDusk: Color(red: 0.98, green: 0.62, blue: 0.72)
        case .auroraNight: Color(red: 0.72, green: 0.48, blue: 0.98)
        }
    }

    var gradientColors: [Color] {
        switch self {
        case .jiaWarmGlow:
            [
                Color(red: 0.08, green: 0.06, blue: 0.14),
                Color(red: 0.18, green: 0.10, blue: 0.22),
                Color(red: 0.12, green: 0.08, blue: 0.16),
            ]
        case .quietNight:
            [
                Color(red: 0.03, green: 0.05, blue: 0.12),
                Color(red: 0.06, green: 0.08, blue: 0.20),
                Color(red: 0.04, green: 0.06, blue: 0.16),
            ]
        case .creamDawn:
            [
                Color(red: 0.98, green: 0.95, blue: 0.90),
                Color(red: 0.96, green: 0.90, blue: 0.82),
                Color(red: 0.94, green: 0.88, blue: 0.78),
            ]
        case .clearGlass:
            [
                Color(red: 0.10, green: 0.12, blue: 0.18),
                Color(red: 0.14, green: 0.16, blue: 0.22),
                Color(red: 0.11, green: 0.13, blue: 0.19),
            ]
        case .forestBreath:
            [
                Color(red: 0.04, green: 0.10, blue: 0.08),
                Color(red: 0.08, green: 0.16, blue: 0.12),
                Color(red: 0.06, green: 0.12, blue: 0.10),
            ]
        case .oceanCalm:
            [
                Color(red: 0.03, green: 0.08, blue: 0.16),
                Color(red: 0.06, green: 0.14, blue: 0.24),
                Color(red: 0.04, green: 0.10, blue: 0.20),
            ]
        case .sakuraDusk:
            [
                Color(red: 0.14, green: 0.06, blue: 0.12),
                Color(red: 0.22, green: 0.10, blue: 0.18),
                Color(red: 0.18, green: 0.08, blue: 0.14),
            ]
        case .auroraNight:
            [
                Color(red: 0.06, green: 0.04, blue: 0.14),
                Color(red: 0.10, green: 0.06, blue: 0.22),
                Color(red: 0.08, green: 0.05, blue: 0.18),
            ]
        }
    }

    var primaryTextColor: Color {
        isLightTheme ? Color(red: 0.14, green: 0.12, blue: 0.10) : .white
    }

    var secondaryTextColor: Color {
        isLightTheme ? Color(red: 0.32, green: 0.28, blue: 0.24).opacity(0.88) : Color.white.opacity(0.78)
    }

    var cardBackground: Color {
        isLightTheme ? Color.white.opacity(0.52) : Color.white.opacity(0.07)
    }

    var cardBorder: Color {
        isLightTheme ? accentColor.opacity(0.22) : Color.white.opacity(0.14)
    }

    var controlBackground: Color {
        isLightTheme ? Color.white.opacity(0.65) : Color.white.opacity(0.10)
    }

    var controlTextColor: Color {
        isLightTheme ? Color(red: 0.18, green: 0.16, blue: 0.14) : Color.white.opacity(0.92)
    }

    var transparentClockOverlayOpacity: Double {
        switch self {
        case .clearGlass: 0.0
        case .creamDawn: 0.06
        case .jiaWarmGlow: 0.10
        case .quietNight: 0.14
        default: 0.12
        }
    }

    var requiresPro: Bool {
        switch self {
        case .jiaWarmGlow, .quietNight, .creamDawn, .clearGlass: false
        case .forestBreath, .oceanCalm, .sakuraDusk, .auroraNight: true
        }
    }

    var glowCenter: UnitPoint {
        switch self {
        case .jiaWarmGlow, .sakuraDusk: .topTrailing
        case .quietNight, .auroraNight: .topLeading
        case .creamDawn: .bottomTrailing
        default: .center
        }
    }
}
