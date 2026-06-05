import SwiftUI

enum ClockTheme: String, CaseIterable, Identifiable, Codable {
    case dawn
    case midnight
    case forest
    case ocean

    var id: String { rawValue }

    var title: String {
        switch self {
        case .dawn: L10n.Theme.dawn
        case .midnight: L10n.Theme.midnight
        case .forest: L10n.Theme.forest
        case .ocean: L10n.Theme.ocean
        }
    }

    var accentColor: Color {
        switch self {
        case .dawn: Color(red: 0.98, green: 0.62, blue: 0.42)
        case .midnight: Color(red: 0.55, green: 0.62, blue: 0.98)
        case .forest: Color(red: 0.45, green: 0.78, blue: 0.58)
        case .ocean: Color(red: 0.38, green: 0.72, blue: 0.92)
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
        }
    }

    var requiresPro: Bool {
        switch self {
        case .dawn, .midnight: false
        case .forest, .ocean: true
        }
    }
}
