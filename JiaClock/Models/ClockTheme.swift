import SwiftUI

enum ClockTheme: String, CaseIterable, Identifiable, Codable {
    case dawn
    case midnight
    case forest
    case ocean
    case aurora
    case sakura
    case ember
    case jadeRealm
    case purpleDusk
    case candyFantasy

    var id: String { rawValue }

    var title: String {
        switch self {
        case .dawn: L10n.Theme.dawn
        case .midnight: L10n.Theme.midnight
        case .forest: L10n.Theme.forest
        case .ocean: L10n.Theme.ocean
        case .aurora: L10n.Theme.aurora
        case .sakura: L10n.Theme.sakura
        case .ember: L10n.Theme.ember
        case .jadeRealm: L10n.Theme.jadeRealm
        case .purpleDusk: L10n.Theme.purpleDusk
        case .candyFantasy: L10n.Theme.candyFantasy
        }
    }

    var accentColor: Color {
        switch self {
        case .dawn: Color(red: 0.98, green: 0.62, blue: 0.42)
        case .midnight: Color(red: 0.55, green: 0.62, blue: 0.98)
        case .forest: Color(red: 0.45, green: 0.78, blue: 0.58)
        case .ocean: Color(red: 0.38, green: 0.72, blue: 0.92)
        case .aurora: Color(red: 0.52, green: 0.88, blue: 0.82)
        case .sakura: Color(red: 0.94, green: 0.78, blue: 0.82)
        case .ember: Color(red: 0.98, green: 0.72, blue: 0.58)
        case .jadeRealm: Color(red: 0.48, green: 0.86, blue: 0.68)
        case .purpleDusk: Color(red: 0.82, green: 0.72, blue: 0.94)
        case .candyFantasy: Color(red: 0.96, green: 0.74, blue: 0.86)
        }
    }

    var gradientColors: [Color] {
        switch self {
        case .dawn:
            [Color(red: 0.12, green: 0.10, blue: 0.18), Color(red: 0.28, green: 0.16, blue: 0.32), Color(red: 0.18, green: 0.14, blue: 0.24)]
        case .midnight:
            [Color(red: 0.04, green: 0.06, blue: 0.14), Color(red: 0.08, green: 0.10, blue: 0.22), Color(red: 0.06, green: 0.08, blue: 0.18)]
        case .forest:
            [Color(red: 0.06, green: 0.12, blue: 0.10), Color(red: 0.10, green: 0.20, blue: 0.16), Color(red: 0.08, green: 0.14, blue: 0.12)]
        case .ocean:
            [Color(red: 0.05, green: 0.10, blue: 0.18), Color(red: 0.08, green: 0.18, blue: 0.28), Color(red: 0.06, green: 0.14, blue: 0.22)]
        case .aurora:
            [Color(red: 0.14, green: 0.28, blue: 0.32), Color(red: 0.22, green: 0.42, blue: 0.40), Color(red: 0.18, green: 0.36, blue: 0.38)]
        case .sakura:
            [Color(red: 0.32, green: 0.22, blue: 0.26), Color(red: 0.42, green: 0.30, blue: 0.32), Color(red: 0.38, green: 0.26, blue: 0.29)]
        case .ember:
            [Color(red: 0.30, green: 0.18, blue: 0.14), Color(red: 0.42, green: 0.28, blue: 0.22), Color(red: 0.36, green: 0.24, blue: 0.18)]
        case .jadeRealm:
            [Color(red: 0.14, green: 0.28, blue: 0.22), Color(red: 0.22, green: 0.40, blue: 0.30), Color(red: 0.18, green: 0.34, blue: 0.26)]
        case .purpleDusk:
            [Color(red: 0.26, green: 0.22, blue: 0.34), Color(red: 0.36, green: 0.30, blue: 0.44), Color(red: 0.32, green: 0.26, blue: 0.38)]
        case .candyFantasy:
            [Color(red: 0.34, green: 0.24, blue: 0.30), Color(red: 0.36, green: 0.32, blue: 0.24), Color(red: 0.26, green: 0.28, blue: 0.36)]
        }
    }

    var requiresPro: Bool {
        switch self {
        case .dawn, .midnight: false
        case .forest, .ocean: true
        case .aurora, .sakura, .ember, .jadeRealm, .purpleDusk, .candyFantasy: true
        }
    }
}
