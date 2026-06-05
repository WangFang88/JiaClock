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
        case .aurora: Color(red: 0.38, green: 0.94, blue: 0.82)
        case .sakura: Color(red: 0.98, green: 0.72, blue: 0.82)
        case .ember: Color(red: 0.98, green: 0.55, blue: 0.22)
        case .jadeRealm: Color(red: 0.28, green: 0.82, blue: 0.55)
        case .purpleDusk: Color(red: 0.72, green: 0.58, blue: 0.95)
        case .candyFantasy: Color(red: 0.98, green: 0.52, blue: 0.78)
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
            [Color(red: 0.03, green: 0.06, blue: 0.14), Color(red: 0.05, green: 0.16, blue: 0.20), Color(red: 0.04, green: 0.10, blue: 0.18)]
        case .sakura:
            [Color(red: 0.16, green: 0.08, blue: 0.12), Color(red: 0.26, green: 0.12, blue: 0.18), Color(red: 0.20, green: 0.10, blue: 0.15)]
        case .ember:
            [Color(red: 0.12, green: 0.05, blue: 0.04), Color(red: 0.26, green: 0.09, blue: 0.06), Color(red: 0.18, green: 0.07, blue: 0.05)]
        case .jadeRealm:
            [Color(red: 0.03, green: 0.09, blue: 0.07), Color(red: 0.05, green: 0.17, blue: 0.11), Color(red: 0.04, green: 0.13, blue: 0.09)]
        case .purpleDusk:
            [Color(red: 0.09, green: 0.05, blue: 0.15), Color(red: 0.16, green: 0.08, blue: 0.26), Color(red: 0.12, green: 0.06, blue: 0.20)]
        case .candyFantasy:
            [Color(red: 0.11, green: 0.07, blue: 0.16), Color(red: 0.19, green: 0.09, blue: 0.21), Color(red: 0.15, green: 0.08, blue: 0.18)]
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
