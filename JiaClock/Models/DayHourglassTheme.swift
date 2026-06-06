import SwiftUI

struct DayHourglassTheme: Identifiable, Equatable {
    let id: String
    /// 预留 Pro 高级主题
    let isPro: Bool
    let backgroundColors: [Color]
    let sandColor: Color
    let sandHighlight: Color
    let glassStroke: Color
    let glowColor: Color
    let particleColor: Color
    let textPrimary: Color
    let textSecondary: Color
    let accentColor: Color

    var title: String { DayHourglassThemeLibrary.title(for: id) }

    static func == (lhs: DayHourglassTheme, rhs: DayHourglassTheme) -> Bool {
        lhs.id == rhs.id
    }
}

enum DayHourglassThemeLibrary {
    static let defaultThemeID = "goldenNight"

    static let all: [DayHourglassTheme] = [goldenNight, softDawn, calmForest]

    static func theme(id: String) -> DayHourglassTheme {
        all.first { $0.id == id } ?? goldenNight
    }

    static func title(for id: String) -> String {
        switch id {
        case "goldenNight": L10n.Hourglass.themeGoldenNight
        case "softDawn": L10n.Hourglass.themeSoftDawn
        case "calmForest": L10n.Hourglass.themeCalmForest
        default: L10n.Hourglass.themeGoldenNight
        }
    }

    static let goldenNight = DayHourglassTheme(
        id: "goldenNight",
        isPro: false,
        backgroundColors: [
            Color(red: 0.04, green: 0.04, blue: 0.06),
            Color(red: 0.08, green: 0.06, blue: 0.10),
        ],
        sandColor: Color(red: 0.96, green: 0.68, blue: 0.32),
        sandHighlight: Color(red: 1.0, green: 0.82, blue: 0.48),
        glassStroke: Color(red: 0.98, green: 0.72, blue: 0.38).opacity(0.72),
        glowColor: Color(red: 0.98, green: 0.62, blue: 0.28),
        particleColor: Color(red: 1.0, green: 0.78, blue: 0.42),
        textPrimary: Color.white.opacity(0.94),
        textSecondary: Color.white.opacity(0.68),
        accentColor: Color(red: 0.98, green: 0.62, blue: 0.38)
    )

    static let softDawn = DayHourglassTheme(
        id: "softDawn",
        isPro: true,
        backgroundColors: [
            Color(red: 0.06, green: 0.10, blue: 0.22),
            Color(red: 0.18, green: 0.14, blue: 0.20),
            Color(red: 0.28, green: 0.16, blue: 0.14),
        ],
        sandColor: Color(red: 0.92, green: 0.78, blue: 0.52),
        sandHighlight: Color(red: 1.0, green: 0.90, blue: 0.68),
        glassStroke: Color(red: 0.88, green: 0.72, blue: 0.52).opacity(0.65),
        glowColor: Color(red: 0.92, green: 0.58, blue: 0.38),
        particleColor: Color(red: 0.96, green: 0.82, blue: 0.62),
        textPrimary: Color.white.opacity(0.92),
        textSecondary: Color.white.opacity(0.66),
        accentColor: Color(red: 0.92, green: 0.68, blue: 0.48)
    )

    static let calmForest = DayHourglassTheme(
        id: "calmForest",
        isPro: true,
        backgroundColors: [
            Color(red: 0.04, green: 0.08, blue: 0.06),
            Color(red: 0.06, green: 0.12, blue: 0.10),
        ],
        sandColor: Color(red: 0.88, green: 0.72, blue: 0.42),
        sandHighlight: Color(red: 0.96, green: 0.86, blue: 0.58),
        glassStroke: Color(red: 0.62, green: 0.82, blue: 0.58).opacity(0.45),
        glowColor: Color(red: 0.72, green: 0.88, blue: 0.52),
        particleColor: Color(red: 0.82, green: 0.92, blue: 0.62),
        textPrimary: Color(red: 0.92, green: 0.96, blue: 0.90),
        textSecondary: Color(red: 0.72, green: 0.82, blue: 0.72),
        accentColor: Color(red: 0.78, green: 0.88, blue: 0.55)
    )
}
