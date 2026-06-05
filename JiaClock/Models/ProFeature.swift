import Foundation

enum ProFeature: String, CaseIterable, Identifiable, Codable {
    case premiumThemes
    case advancedWidgets
    case transparentClockPro
    case focusStatistics
    case standByCustomization

    var id: String { rawValue }

    var title: String {
        switch self {
        case .premiumThemes: L10n.Pro.premiumThemes
        case .advancedWidgets: L10n.Pro.advancedWidgets
        case .transparentClockPro: L10n.Pro.transparentClockPro
        case .focusStatistics: L10n.Pro.focusStatistics
        case .standByCustomization: L10n.Pro.standByCustomization
        }
    }

    var subtitle: String {
        switch self {
        case .premiumThemes: L10n.Pro.premiumThemesSubtitle
        case .advancedWidgets: L10n.Pro.advancedWidgetsSubtitle
        case .transparentClockPro: L10n.Pro.transparentClockProSubtitle
        case .focusStatistics: L10n.Pro.focusStatisticsSubtitle
        case .standByCustomization: L10n.Pro.standByCustomizationSubtitle
        }
    }

    var systemImage: String {
        switch self {
        case .premiumThemes: "paintpalette.fill"
        case .advancedWidgets: "square.grid.3x3.fill"
        case .transparentClockPro: "camera.filters"
        case .focusStatistics: "chart.bar.fill"
        case .standByCustomization: "moon.stars.fill"
        }
    }
}
