import Foundation

/// Pro 功能清单；本轮仅对部分入口做拦截，其余为下一轮预留。
enum ProFeature: String, CaseIterable, Identifiable, Codable {
    case premiumThemes
    case transparentClockAdvanced
    case transparentFlipMode
    case neonTransparentMode
    case glassMorphAdvanced
    case customFonts
    case customColors
    case customBackgroundPhotos
    case widgetAdvancedStyles
    case multipleCustomTaglines
    case shootModeHideUI
    case burnInProtection
    case nightAdvancedMode
    case adFree

    var id: String { rawValue }

    var title: String {
        switch self {
        case .premiumThemes: L10n.Pro.premiumThemes
        case .transparentClockAdvanced: L10n.Pro.transparentClockAdvanced
        case .transparentFlipMode: L10n.Pro.transparentFlipMode
        case .neonTransparentMode: L10n.Pro.neonTransparentMode
        case .glassMorphAdvanced: L10n.Pro.glassMorphAdvanced
        case .customFonts: L10n.Pro.customFonts
        case .customColors: L10n.Pro.customColors
        case .customBackgroundPhotos: L10n.Pro.customBackgroundPhotos
        case .widgetAdvancedStyles: L10n.Pro.advancedWidgets
        case .multipleCustomTaglines: L10n.Pro.multipleCustomTaglines
        case .shootModeHideUI: L10n.Pro.shootModeHideUI
        case .burnInProtection: L10n.Pro.burnInProtection
        case .nightAdvancedMode: L10n.Pro.nightAdvancedMode
        case .adFree: L10n.Pro.adFree
        }
    }

    var subtitle: String {
        switch self {
        case .premiumThemes: L10n.Pro.premiumThemesSubtitle
        case .transparentClockAdvanced: L10n.Pro.transparentClockAdvancedSubtitle
        case .transparentFlipMode: L10n.Pro.transparentFlipModeSubtitle
        case .neonTransparentMode: L10n.Pro.neonTransparentModeSubtitle
        case .glassMorphAdvanced: L10n.Pro.glassMorphAdvancedSubtitle
        case .customFonts: L10n.Pro.customFontsSubtitle
        case .customColors: L10n.Pro.customColorsSubtitle
        case .customBackgroundPhotos: L10n.Pro.customBackgroundPhotosSubtitle
        case .widgetAdvancedStyles: L10n.Pro.advancedWidgetsSubtitle
        case .multipleCustomTaglines: L10n.Pro.multipleCustomTaglinesSubtitle
        case .shootModeHideUI: L10n.Pro.shootModeHideUISubtitle
        case .burnInProtection: L10n.Pro.burnInProtectionSubtitle
        case .nightAdvancedMode: L10n.Pro.nightAdvancedModeSubtitle
        case .adFree: L10n.Pro.adFreeSubtitle
        }
    }

    var systemImage: String {
        switch self {
        case .premiumThemes: "paintpalette.fill"
        case .transparentClockAdvanced: "camera.filters"
        case .transparentFlipMode: "book.pages.fill"
        case .neonTransparentMode: "sparkles"
        case .glassMorphAdvanced: "rectangle.inset.filled"
        case .customFonts: "textformat"
        case .customColors: "eyedropper.halffull"
        case .customBackgroundPhotos: "photo.on.rectangle.angled"
        case .widgetAdvancedStyles: "square.grid.3x3.fill"
        case .multipleCustomTaglines: "text.quote"
        case .shootModeHideUI: "eye.slash.fill"
        case .burnInProtection: "display"
        case .nightAdvancedMode: "moon.stars.fill"
        case .adFree: "hand.raised.slash.fill"
        }
    }

    /// 本轮已接入 Pro 拦截的功能。
    var isGatedThisRound: Bool {
        switch self {
        case .premiumThemes: true
        default: false
        }
    }

    /// Paywall 上展示的核心卖点（精简列表）。
    static var paywallHighlights: [ProFeature] {
        [
            .premiumThemes,
            .transparentClockAdvanced,
            .transparentFlipMode,
            .widgetAdvancedStyles,
            .shootModeHideUI,
        ]
    }
}
