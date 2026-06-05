import Foundation

enum L10n {
    enum Common {
        static var close: String { tr("common.close") }
        static var done: String { tr("common.done") }
        static var comingSoon: String { tr("common.coming_soon") }
        static var pro: String { tr("common.pro") }
    }

    enum Home {
        static var appName: String { tr("home.app_name") }
        static var tagline: String { tr("home.tagline") }
        static var currentTime: String { tr("home.current_time") }
        static var fullScreenClock: String { tr("home.full_screen_clock") }
        static var fullScreenSubtitle: String { tr("home.full_screen_subtitle") }
        static var transparentClock: String { tr("home.transparent_clock") }
        static var transparentSubtitle: String { tr("home.transparent_subtitle") }
        static var flipClock: String { tr("home.flip_clock") }
        static var flipSubtitle: String { tr("home.flip_subtitle") }
        static var widget: String { tr("home.widget") }
        static var widgetSubtitle: String { tr("home.widget_subtitle") }
        static var theme: String { tr("home.theme") }
        static var settings: String { tr("home.settings") }
        static var widgetGuideTitle: String { tr("home.widget_guide_title") }
        static var widgetGuideBody: String { tr("home.widget_guide_body") }
    }

    enum Clock {
        static var defaultTagline: String { tr("clock.default_tagline") }
    }

    enum FullScreen {
        static var title: String { tr("fullscreen.title") }
    }

    enum Flip {
        static var title: String { tr("flip.title") }
        static var hourLabel: String { tr("flip.hour_label") }
        static var minuteLabel: String { tr("flip.minute_label") }
    }

    enum Transparent {
        static var title: String { tr("transparent.title") }
        static var headline: String { tr("transparent.headline") }
        static var value1Title: String { tr("transparent.value1_title") }
        static var value1Body: String { tr("transparent.value1_body") }
        static var value2Title: String { tr("transparent.value2_title") }
        static var value2Body: String { tr("transparent.value2_body") }
        static var permissionTitle: String { tr("transparent.permission_title") }
        static var permissionBody: String { tr("transparent.permission_body") }
        static var privacyTitle: String { tr("transparent.privacy_title") }
        static var privacyBody: String { tr("transparent.privacy_body") }
        static var backgroundStopTitle: String { tr("transparent.background_stop_title") }
        static var backgroundStopBody: String { tr("transparent.background_stop_body") }
        static var enableButton: String { tr("transparent.enable_button") }
        static var permissionDeniedTitle: String { tr("transparent.permission_denied_title") }
        static var permissionDeniedBody: String { tr("transparent.permission_denied_body") }
        static var permissionRestrictedTitle: String { tr("transparent.permission_restricted_title") }
        static var permissionRestrictedBody: String { tr("transparent.permission_restricted_body") }
        static var openSettings: String { tr("transparent.open_settings") }
        static var cameraUnavailableTitle: String { tr("transparent.camera_unavailable_title") }
        static var cameraUnavailableBody: String { tr("transparent.camera_unavailable_body") }
        static var previewWithoutCamera: String { tr("transparent.preview_without_camera") }
        static var darkOverlay: String { tr("transparent.dark_overlay") }
        static var displayMode: String { tr("transparent.display_mode") }
        static var displayModeGlass: String { tr("transparent.display_mode_glass") }
        static var displayModeMinimal: String { tr("transparent.display_mode_minimal") }
        static var useLightText: String { tr("transparent.use_light_text") }
        static var useDarkText: String { tr("transparent.use_dark_text") }
        static var adjust: String { tr("transparent.adjust") }
    }

    enum Settings {
        static var title: String { tr("settings.title") }
        static var timeSection: String { tr("settings.time_section") }
        static var use24Hour: String { tr("settings.use_24_hour") }
        static var showSeconds: String { tr("settings.show_seconds") }
        static var showDate: String { tr("settings.show_date") }
        static var showWeekday: String { tr("settings.show_weekday") }
        static var displaySection: String { tr("settings.display_section") }
        static var customTagline: String { tr("settings.custom_tagline") }
        static var taglinePlaceholder: String { tr("settings.tagline_placeholder") }
        static var theme: String { tr("settings.theme") }
        static var proSection: String { tr("settings.pro_section") }
        static var upgradePro: String { tr("settings.upgrade_pro") }
        static var upgradeProSubtitle: String { tr("settings.upgrade_pro_subtitle") }
        static var legalSection: String { tr("settings.legal_section") }
    }

    enum Theme {
        static var dawn: String { tr("theme.dawn") }
        static var midnight: String { tr("theme.midnight") }
        static var forest: String { tr("theme.forest") }
        static var ocean: String { tr("theme.ocean") }
        static var pickerTitle: String { tr("theme.picker_title") }
    }

    enum Pro {
        static var premiumThemes: String { tr("pro.premium_themes") }
        static var premiumThemesSubtitle: String { tr("pro.premium_themes_subtitle") }
        static var advancedWidgets: String { tr("pro.advanced_widgets") }
        static var advancedWidgetsSubtitle: String { tr("pro.advanced_widgets_subtitle") }
        static var transparentClockPro: String { tr("pro.transparent_clock_pro") }
        static var transparentClockProSubtitle: String { tr("pro.transparent_clock_pro_subtitle") }
        static var focusStatistics: String { tr("pro.focus_statistics") }
        static var focusStatisticsSubtitle: String { tr("pro.focus_statistics_subtitle") }
        static var standByCustomization: String { tr("pro.standby_customization") }
        static var standByCustomizationSubtitle: String { tr("pro.standby_customization_subtitle") }
        static var placeholderTitle: String { tr("pro.placeholder_title") }
        static var placeholderBody: String { tr("pro.placeholder_body") }
    }

    enum Legal {
        static var termsOfService: String { tr("legal.terms_of_service") }
        static var privacyPolicy: String { tr("legal.privacy_policy") }
        static var placeholderBody: String { tr("legal.placeholder_body") }
    }

    private static func tr(_ key: String) -> String {
        String(localized: String.LocalizationValue(key))
    }
}
