import Foundation

enum ClockMode: String, CaseIterable, Identifiable, Codable {
    case fullScreen
    case transparent
    case flip
    case widget

    var id: String { rawValue }

    var title: String {
        switch self {
        case .fullScreen: L10n.Home.fullScreenClock
        case .transparent: L10n.Home.transparentClock
        case .flip: L10n.Home.flipClock
        case .widget: L10n.Home.widget
        }
    }

    var subtitle: String {
        switch self {
        case .fullScreen: L10n.Home.fullScreenSubtitle
        case .transparent: L10n.Home.transparentSubtitle
        case .flip: L10n.Home.flipSubtitle
        case .widget: L10n.Home.widgetSubtitle
        }
    }

    var systemImage: String {
        switch self {
        case .fullScreen: "clock.fill"
        case .transparent: "camera.viewfinder"
        case .flip: "rectangle.split.2x1.fill"
        case .widget: "square.grid.2x2.fill"
        }
    }

    var isAvailableInRoundOne: Bool { true }
}
