import Foundation
import SwiftUI

/// 样式选择后由首页 / 全屏容器处理的跳转回调。
struct ClockStyleLaunchHandler {
    let onLaunch: (ClockStyleLaunchDestination) -> Void
}

private struct ClockStyleLaunchKey: EnvironmentKey {
    static let defaultValue: ClockStyleLaunchHandler? = nil
}

extension EnvironmentValues {
    var clockStyleLaunch: ClockStyleLaunchHandler? {
        get { self[ClockStyleLaunchKey.self] }
        set { self[ClockStyleLaunchKey.self] = newValue }
    }
}

enum ClockStyleScene {
    case deskClock
    case transparentClock
}

enum ClockDisplayStyle: String, Codable, CaseIterable, Identifiable {
    case digital
    case flip
    case transparentFlip
    case stackedFlip
    case retroCalendar
    case dayHourglass
    case minimalFloating

    var id: String { rawValue }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        switch raw {
        case "retroCalendarClock": self = .retroCalendar
        default:
            guard let style = ClockDisplayStyle(rawValue: raw) else {
                self = .digital
                return
            }
            self = style
        }
    }

    /// 样式中心展示顺序。
    static let centerStyles: [ClockDisplayStyle] = fullscreenCenterStyles + transparentCenterStyles

    /// 全屏桌面样式（无需摄像头）。
    static let fullscreenCenterStyles: [ClockDisplayStyle] = [
        .digital, .flip, .retroCalendar, .dayHourglass,
    ]

    /// 透明实景样式（需摄像头权限流程）。
    static let transparentCenterStyles: [ClockDisplayStyle] = [
        .transparentFlip, .stackedFlip, .minimalFloating,
    ]

    var isTransparentCategory: Bool {
        Self.transparentCenterStyles.contains(self)
    }

    static func freeStyles(for scene: ClockStyleScene) -> [ClockDisplayStyle] {
        switch scene {
        case .deskClock:
            return [.digital, .flip]
        case .transparentClock:
            return [.transparentFlip]
        }
    }

    static func requiresProAccess(_ style: ClockDisplayStyle) -> Bool {
        switch style {
        case .digital, .flip, .transparentFlip:
            return false
        case .retroCalendar, .dayHourglass, .stackedFlip, .minimalFloating:
            return true
        }
    }

    static func isAccessible(_ style: ClockDisplayStyle, for scene: ClockStyleScene, isPro: Bool) -> Bool {
        if isPro { return true }
        return freeStyles(for: scene).contains(style)
    }

    var title: String {
        switch self {
        case .digital: L10n.ClockStyleCenter.digitalTitle
        case .flip: L10n.ClockStyleCenter.flipTitle
        case .transparentFlip: L10n.ClockStyleCenter.transparentFlipTitle
        case .stackedFlip: L10n.ClockStyleCenter.stackedFlipTitle
        case .retroCalendar: L10n.ClockStyleCenter.retroCalendarTitle
        case .dayHourglass: L10n.ClockStyleCenter.dayHourglassTitle
        case .minimalFloating: L10n.ClockStyleCenter.minimalFloatingTitle
        }
    }

    var subtitle: String {
        switch self {
        case .digital: L10n.ClockStyleCenter.digitalSubtitle
        case .flip: L10n.ClockStyleCenter.flipSubtitle
        case .transparentFlip: L10n.ClockStyleCenter.transparentFlipSubtitle
        case .stackedFlip: L10n.ClockStyleCenter.stackedFlipSubtitle
        case .retroCalendar: L10n.ClockStyleCenter.retroCalendarSubtitle
        case .dayHourglass: L10n.ClockStyleCenter.dayHourglassSubtitle
        case .minimalFloating: L10n.ClockStyleCenter.minimalFloatingSubtitle
        }
    }

    var systemImage: String {
        switch self {
        case .digital: "textformat.123"
        case .flip: "rectangle.split.2x1.fill"
        case .transparentFlip: "book.pages.fill"
        case .stackedFlip: "rectangle.stack.fill"
        case .retroCalendar: "calendar.day.timeline.leading"
        case .dayHourglass: "hourglass"
        case .minimalFloating: "textformat.size.larger"
        }
    }

    /// 样式本身是否为 Pro（与主题 Pro 分层独立）。
    var isProStyle: Bool {
        Self.requiresProAccess(self)
    }

    var requiresCamera: Bool {
        switch self {
        case .transparentFlip, .stackedFlip, .minimalFloating: true
        default: false
        }
    }

    var showsCameraBadge: Bool { requiresCamera }

    var usesFullscreenContainer: Bool {
        switch self {
        case .digital, .flip, .retroCalendar, .dayHourglass: true
        default: false
        }
    }

    var supportsLandscape: Bool { true }
    var supportsPortrait: Bool { true }

    /// 同步透明时钟子样式字段（与 `TransparentClockDisplayStyle` 对齐）。
    func apply(to settings: inout ClockSettings) {
        settings.clockDisplayStyle = self
        if let transparent = transparentClockDisplayStyle {
            settings.transparentClockDisplayStyle = transparent
        }
    }

    var transparentClockDisplayStyle: TransparentClockDisplayStyle? {
        switch self {
        case .transparentFlip: .transparentFlip
        case .stackedFlip: .stackedFlip
        case .minimalFloating: .minimalFloating
        default: nil
        }
    }

    static func isSelected(_ style: ClockDisplayStyle, in settings: ClockSettings) -> Bool {
        settings.clockDisplayStyle == style
    }
}

// MARK: - 跳转

enum ClockStyleLaunchDestination: Equatable {
    case fullscreenContainer
    case transparentIntro
    case transparentClock
}

enum ClockStyleRouter {
    @MainActor
    static func launchDestination(
        for style: ClockDisplayStyle,
        cameraStatus: CameraPermissionService.Status
    ) -> ClockStyleLaunchDestination {
        guard style.requiresCamera else { return .fullscreenContainer }
        return cameraStatus == .authorized ? .transparentClock : .transparentIntro
    }

    @MainActor
    static func applySelection(
        _ style: ClockDisplayStyle,
        settingsStore: ClockSettingsStore,
        isPro: Bool,
        scene: ClockStyleScene
    ) {
        guard ClockDisplayStyle.isAccessible(style, for: scene, isPro: isPro) else { return }
        settingsStore.update { settings in
            style.apply(to: &settings)
        }
    }
}
