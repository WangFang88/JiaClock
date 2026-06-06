import SwiftUI

struct RetroCalendarClockTheme: Identifiable, Equatable {
    let id: String
    let isPro: Bool
    let shellGradient: [Color]
    let shellHighlight: Color
    let shellShadow: Color
    let panelColor: Color
    let flipCardColor: Color
    let flipCardTextColor: Color
    let labelColor: Color
    let clockFaceColor: Color
    let clockHandColor: Color
    let clockTickColor: Color
    let borderColor: Color
    let shadowColor: Color
    let accentColor: Color
    let footColor: Color

    var title: String { RetroCalendarClockThemeLibrary.title(for: id) }

    static func == (lhs: RetroCalendarClockTheme, rhs: RetroCalendarClockTheme) -> Bool {
        lhs.id == rhs.id
    }
}

enum RetroCalendarClockThemeLibrary {
    static let defaultThemeID = "classicYellow"

    static let all: [RetroCalendarClockTheme] = [
        classicYellow, creamWhite, sunsetOrange,
        mintGreen, skyBlue, retroRed,
    ]

    static func theme(id: String) -> RetroCalendarClockTheme {
        all.first { $0.id == id } ?? classicYellow
    }

    static func title(for id: String) -> String {
        switch id {
        case "classicYellow": L10n.RetroCalendar.themeClassicYellow
        case "creamWhite": L10n.RetroCalendar.themeCreamWhite
        case "sunsetOrange": L10n.RetroCalendar.themeSunsetOrange
        case "mintGreen": L10n.RetroCalendar.themeMintGreen
        case "skyBlue": L10n.RetroCalendar.themeSkyBlue
        case "retroRed": L10n.RetroCalendar.themeRetroRed
        default: L10n.RetroCalendar.themeClassicYellow
        }
    }

    static let classicYellow = RetroCalendarClockTheme(
        id: "classicYellow",
        isPro: false,
        shellGradient: [
            Color(red: 0.98, green: 0.88, blue: 0.28),
            Color(red: 0.94, green: 0.78, blue: 0.18),
        ],
        shellHighlight: Color.white.opacity(0.45),
        shellShadow: Color(red: 0.72, green: 0.58, blue: 0.08).opacity(0.55),
        panelColor: Color(red: 0.98, green: 0.96, blue: 0.90),
        flipCardColor: Color(red: 0.96, green: 0.94, blue: 0.86),
        flipCardTextColor: Color(red: 0.18, green: 0.16, blue: 0.14),
        labelColor: Color(red: 0.42, green: 0.38, blue: 0.32),
        clockFaceColor: Color.white,
        clockHandColor: Color(red: 0.22, green: 0.20, blue: 0.18),
        clockTickColor: Color(red: 0.35, green: 0.32, blue: 0.28).opacity(0.65),
        borderColor: Color(red: 0.82, green: 0.68, blue: 0.12).opacity(0.55),
        shadowColor: Color.black.opacity(0.38),
        accentColor: Color(red: 0.92, green: 0.72, blue: 0.12),
        footColor: Color(red: 0.88, green: 0.72, blue: 0.14)
    )

    static let creamWhite = RetroCalendarClockTheme(
        id: "creamWhite",
        isPro: false,
        shellGradient: [
            Color(red: 0.98, green: 0.96, blue: 0.92),
            Color(red: 0.92, green: 0.88, blue: 0.82),
        ],
        shellHighlight: Color.white.opacity(0.72),
        shellShadow: Color(red: 0.62, green: 0.55, blue: 0.45).opacity(0.35),
        panelColor: Color(red: 1.0, green: 0.98, blue: 0.94),
        flipCardColor: Color(red: 0.98, green: 0.96, blue: 0.90),
        flipCardTextColor: Color(red: 0.32, green: 0.24, blue: 0.18),
        labelColor: Color(red: 0.48, green: 0.40, blue: 0.32),
        clockFaceColor: Color.white,
        clockHandColor: Color(red: 0.35, green: 0.26, blue: 0.18),
        clockTickColor: Color(red: 0.45, green: 0.36, blue: 0.28).opacity(0.55),
        borderColor: Color.white.opacity(0.55),
        shadowColor: Color.black.opacity(0.28),
        accentColor: Color(red: 0.88, green: 0.72, blue: 0.52),
        footColor: Color(red: 0.85, green: 0.78, blue: 0.68)
    )

    static let sunsetOrange = RetroCalendarClockTheme(
        id: "sunsetOrange",
        isPro: false,
        shellGradient: [
            Color(red: 0.98, green: 0.62, blue: 0.32),
            Color(red: 0.94, green: 0.48, blue: 0.26),
        ],
        shellHighlight: Color.white.opacity(0.38),
        shellShadow: Color(red: 0.72, green: 0.32, blue: 0.12).opacity(0.45),
        panelColor: Color(red: 0.99, green: 0.96, blue: 0.91),
        flipCardColor: Color(red: 0.98, green: 0.94, blue: 0.88),
        flipCardTextColor: Color(red: 0.28, green: 0.14, blue: 0.08),
        labelColor: Color(red: 0.52, green: 0.28, blue: 0.16),
        clockFaceColor: Color.white,
        clockHandColor: Color(red: 0.32, green: 0.16, blue: 0.08),
        clockTickColor: Color(red: 0.45, green: 0.22, blue: 0.12).opacity(0.6),
        borderColor: Color(red: 0.88, green: 0.42, blue: 0.18).opacity(0.5),
        shadowColor: Color.black.opacity(0.32),
        accentColor: Color(red: 0.98, green: 0.58, blue: 0.28),
        footColor: Color(red: 0.88, green: 0.42, blue: 0.18)
    )

    static let mintGreen = RetroCalendarClockTheme(
        id: "mintGreen",
        isPro: true,
        shellGradient: [
            Color(red: 0.72, green: 0.90, blue: 0.82),
            Color(red: 0.58, green: 0.82, blue: 0.72),
        ],
        shellHighlight: Color.white.opacity(0.48),
        shellShadow: Color(red: 0.28, green: 0.52, blue: 0.38).opacity(0.38),
        panelColor: Color(red: 0.98, green: 1.0, blue: 0.98),
        flipCardColor: Color(red: 0.94, green: 0.98, blue: 0.94),
        flipCardTextColor: Color(red: 0.12, green: 0.28, blue: 0.20),
        labelColor: Color(red: 0.28, green: 0.42, blue: 0.32),
        clockFaceColor: Color.white,
        clockHandColor: Color(red: 0.14, green: 0.32, blue: 0.22),
        clockTickColor: Color(red: 0.22, green: 0.38, blue: 0.28).opacity(0.55),
        borderColor: Color(red: 0.52, green: 0.78, blue: 0.62).opacity(0.45),
        shadowColor: Color.black.opacity(0.28),
        accentColor: Color(red: 0.58, green: 0.82, blue: 0.65),
        footColor: Color(red: 0.48, green: 0.72, blue: 0.55)
    )

    static let skyBlue = RetroCalendarClockTheme(
        id: "skyBlue",
        isPro: true,
        shellGradient: [
            Color(red: 0.62, green: 0.82, blue: 0.96),
            Color(red: 0.48, green: 0.72, blue: 0.92),
        ],
        shellHighlight: Color.white.opacity(0.52),
        shellShadow: Color(red: 0.18, green: 0.42, blue: 0.62).opacity(0.38),
        panelColor: Color(red: 0.96, green: 0.98, blue: 1.0),
        flipCardColor: Color(red: 0.92, green: 0.96, blue: 1.0),
        flipCardTextColor: Color(red: 0.08, green: 0.22, blue: 0.38),
        labelColor: Color(red: 0.22, green: 0.38, blue: 0.52),
        clockFaceColor: Color.white,
        clockHandColor: Color(red: 0.10, green: 0.26, blue: 0.42),
        clockTickColor: Color(red: 0.18, green: 0.32, blue: 0.48).opacity(0.55),
        borderColor: Color(red: 0.42, green: 0.68, blue: 0.88).opacity(0.45),
        shadowColor: Color.black.opacity(0.28),
        accentColor: Color(red: 0.48, green: 0.72, blue: 0.94),
        footColor: Color(red: 0.38, green: 0.62, blue: 0.82)
    )

    static let retroRed = RetroCalendarClockTheme(
        id: "retroRed",
        isPro: true,
        shellGradient: [
            Color(red: 0.92, green: 0.32, blue: 0.32),
            Color(red: 0.78, green: 0.22, blue: 0.24),
        ],
        shellHighlight: Color.white.opacity(0.32),
        shellShadow: Color(red: 0.48, green: 0.08, blue: 0.10).opacity(0.48),
        panelColor: Color(red: 0.99, green: 0.95, blue: 0.92),
        flipCardColor: Color(red: 0.98, green: 0.92, blue: 0.88),
        flipCardTextColor: Color(red: 0.42, green: 0.12, blue: 0.12),
        labelColor: Color(red: 0.58, green: 0.22, blue: 0.20),
        clockFaceColor: Color.white,
        clockHandColor: Color(red: 0.38, green: 0.10, blue: 0.10),
        clockTickColor: Color(red: 0.52, green: 0.18, blue: 0.16).opacity(0.6),
        borderColor: Color(red: 0.72, green: 0.22, blue: 0.20).opacity(0.45),
        shadowColor: Color.black.opacity(0.35),
        accentColor: Color(red: 0.92, green: 0.38, blue: 0.32),
        footColor: Color(red: 0.68, green: 0.18, blue: 0.18)
    )
}
