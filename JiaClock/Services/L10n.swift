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
        static var dayHourglass: String { tr("home.day_hourglass") }
        static var dayHourglassSubtitle: String { tr("home.day_hourglass_subtitle") }
        static var widget: String { tr("home.widget") }
        static var widgetSubtitle: String { tr("home.widget_subtitle") }
        static var theme: String { tr("home.theme") }
        static var settings: String { tr("home.settings") }
        static var widgetGuideTitle: String { tr("home.widget_guide_title") }
        static var widgetGuideBody: String { tr("home.widget_guide_body") }
        static var startClock: String { tr("home.start_clock") }
        static var startClockSubtitle: String { tr("home.start_clock_subtitle") }
        static var styleCenter: String { tr("home.style_center") }
        static var styleCenterSubtitle: String { tr("home.style_center_subtitle") }
    }

    enum WidgetGuide {
        static var title: String { tr("widget_guide.title") }
        static var headline: String { tr("widget_guide.headline") }
        static var subtitle: String { tr("widget_guide.subtitle") }
        static var step1Title: String { tr("widget_guide.step1_title") }
        static var step1Body: String { tr("widget_guide.step1_body") }
        static var step2Title: String { tr("widget_guide.step2_title") }
        static var step2Body: String { tr("widget_guide.step2_body") }
        static var step3Title: String { tr("widget_guide.step3_title") }
        static var step3Body: String { tr("widget_guide.step3_body") }
        static var step4Title: String { tr("widget_guide.step4_title") }
        static var step4Body: String { tr("widget_guide.step4_body") }
        static var refreshNote: String { tr("widget_guide.refresh_note") }
        static var mockDate: String { tr("widget_guide.mock_date") }
    }

    enum Clock {
        static var defaultTagline: String { tr("clock.default_tagline") }
    }

    enum ClockStyleCenter {
        static var title: String { tr("clock_style_center.title") }
        static var subtitle: String { tr("clock_style_center.subtitle") }
        static var sheetTitle: String { tr("clock_style_center.sheet_title") }
        static var entryButton: String { tr("clock_style_center.entry_button") }
        static var cameraBadge: String { tr("clock_style_center.camera_badge") }
        static var digitalTitle: String { tr("clock_style_center.digital_title") }
        static var digitalSubtitle: String { tr("clock_style_center.digital_subtitle") }
        static var flipTitle: String { tr("clock_style_center.flip_title") }
        static var flipSubtitle: String { tr("clock_style_center.flip_subtitle") }
        static var transparentFlipTitle: String { tr("clock_style_center.transparent_flip_title") }
        static var transparentFlipSubtitle: String { tr("clock_style_center.transparent_flip_subtitle") }
        static var fullScreenTransparentFlipSubtitle: String { tr("clock_style_center.fullscreen_transparent_flip_subtitle") }
        static var stackedFlipTitle: String { tr("clock_style_center.stacked_flip_title") }
        static var stackedFlipSubtitle: String { tr("clock_style_center.stacked_flip_subtitle") }
        static var retroCalendarTitle: String { tr("clock_style_center.retro_calendar_title") }
        static var retroCalendarSubtitle: String { tr("clock_style_center.retro_calendar_subtitle") }
        static var dayHourglassTitle: String { tr("clock_style_center.day_hourglass_title") }
        static var dayHourglassSubtitle: String { tr("clock_style_center.day_hourglass_subtitle") }
        static var minimalFloatingTitle: String { tr("clock_style_center.minimal_floating_title") }
        static var minimalFloatingSubtitle: String { tr("clock_style_center.minimal_floating_subtitle") }
        static var fullscreenSectionTitle: String { tr("clock_style_center.fullscreen_section_title") }
        static var fullscreenSectionSubtitle: String { tr("clock_style_center.fullscreen_section_subtitle") }
        static var transparentSectionTitle: String { tr("clock_style_center.transparent_section_title") }
        static var transparentSectionSubtitle: String { tr("clock_style_center.transparent_section_subtitle") }
    }

    enum RetroCalendar {
        static var colorSectionTitle: String { tr("retro_calendar.color_section_title") }
        static var themeClassicYellow: String { tr("retro_calendar.theme.classic_yellow") }
        static var themeCreamWhite: String { tr("retro_calendar.theme.cream_white") }
        static var themeSunsetOrange: String { tr("retro_calendar.theme.sunset_orange") }
        static var themeMintGreen: String { tr("retro_calendar.theme.mint_green") }
        static var themeSkyBlue: String { tr("retro_calendar.theme.sky_blue") }
        static var themeRetroRed: String { tr("retro_calendar.theme.retro_red") }
    }

    enum FullScreen {
        static var title: String { tr("fullscreen.title") }
    }

    enum Flip {
        static var title: String { tr("flip.title") }
        static var hourLabel: String { tr("flip.hour_label") }
        static var minuteLabel: String { tr("flip.minute_label") }
    }

    enum Hourglass {
        static var title: String { tr("hourglass.title") }
        static var themeButton: String { tr("hourglass.theme_button") }
        static var themeSheetTitle: String { tr("hourglass.theme_sheet_title") }
        static var showPercent: String { tr("hourglass.show_percent") }
        static var showRemaining: String { tr("hourglass.show_remaining") }
        static var pureMode: String { tr("hourglass.pure_mode") }
        static var themeGoldenNight: String { tr("hourglass.theme.golden_night") }
        static var themeSoftDawn: String { tr("hourglass.theme.soft_dawn") }
        static var themeCalmForest: String { tr("hourglass.theme.calm_forest") }
        static func todayPassed(_ percent: Int) -> String { tr("hourglass.today_passed", "\(percent)") }
        static func untilDayEnds(_ time: String) -> String { tr("hourglass.until_day_ends", time) }
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
        static var displayModeFullScreenFlip: String { tr("transparent.display_mode_fullscreen_flip") }
        static var displayModeCardFlip: String { tr("transparent.display_mode_card_flip") }
        static var displayModeStackedFlip: String { tr("transparent.display_mode_stacked_flip") }
        static var displayModeMinimal: String { tr("transparent.display_mode_minimal") }
        static var displayModeSectionTitle: String { tr("transparent.display_mode_section_title") }
        static var bigDigitStyleSectionTitle: String { tr("transparent.big_digit_style_section_title") }
        static var bigDigitSoftPinkWhite: String { tr("transparent.big_digit_soft_pink_white") }
        static var bigDigitPureWhite: String { tr("transparent.big_digit_pure_white") }
        static var bigDigitJiaOrange: String { tr("transparent.big_digit_jia_orange") }
        static var bigDigitIceBlue: String { tr("transparent.big_digit_ice_blue") }
        static var hideControls: String { tr("transparent.hide_controls") }
        static var flipThemeButton: String { tr("transparent.flip_theme_button") }
        static var flipThemeSheetTitle: String { tr("transparent.flip_theme_sheet_title") }
        static var flipThemeSectionTitle: String { tr("transparent.flip_theme_section_title") }
        static var flipBackgroundSectionTitle: String { tr("transparent.flip_background_section_title") }
        static var flipThemeGlassWhite: String { tr("transparent.flip_theme.glass_white") }
        static var flipThemeMidnightBlack: String { tr("transparent.flip_theme.midnight_black") }
        static var flipThemeSunsetOrange: String { tr("transparent.flip_theme.sunset_orange") }
        static var flipThemeSakuraPink: String { tr("transparent.flip_theme.sakura_pink") }
        static var flipThemeCreamBeige: String { tr("transparent.flip_theme.cream_beige") }
        static var flipThemeSkyBlue: String { tr("transparent.flip_theme.sky_blue") }
        static var flipThemeForestGreen: String { tr("transparent.flip_theme.forest_green") }
        static var flipThemeNeonPurple: String { tr("transparent.flip_theme.neon_purple") }
        static var bgCameraOnly: String { tr("transparent.bg.camera_only") }
        static var bgSoftDark: String { tr("transparent.bg.soft_dark") }
        static var bgWarmSunset: String { tr("transparent.bg.warm_sunset") }
        static var bgDeepNight: String { tr("transparent.bg.deep_night") }
        static var bgAurora: String { tr("transparent.bg.aurora") }
        static var bgCleanLight: String { tr("transparent.bg.clean_light") }
        static var stackedThemeSectionTitle: String { tr("transparent.stacked_theme_section_title") }
        static var stackedThemeOrangeClassic: String { tr("transparent.stacked_theme.orange_classic") }
        static var stackedThemeBlueCalm: String { tr("transparent.stacked_theme.blue_calm") }
        static var stackedThemeRedEnergy: String { tr("transparent.stacked_theme.red_energy") }
        static var stackedThemeGreenForest: String { tr("transparent.stacked_theme.green_forest") }
        static var stackedThemePurpleNeon: String { tr("transparent.stacked_theme.purple_neon") }
        static var stackedThemeBeigeSoft: String { tr("transparent.stacked_theme.beige_soft") }
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
        static var proStatusActive: String { tr("settings.pro_status_active") }
        static func proExpiresAt(_ date: String) -> String { tr("settings.pro_expires_at", date) }
        static var legalSection: String { tr("settings.legal_section") }
    }

    enum Theme {
        static var jiaWarmGlow: String { tr("theme.jia_warm_glow") }
        static var quietNight: String { tr("theme.quiet_night") }
        static var creamDawn: String { tr("theme.cream_dawn") }
        static var clearGlass: String { tr("theme.clear_glass") }
        static var forestBreath: String { tr("theme.forest_breath") }
        static var oceanCalm: String { tr("theme.ocean_calm") }
        static var sakuraDusk: String { tr("theme.sakura_dusk") }
        static var auroraNight: String { tr("theme.aurora_night") }
        static var jiaWarmGlowDesc: String { tr("theme.jia_warm_glow_desc") }
        static var quietNightDesc: String { tr("theme.quiet_night_desc") }
        static var creamDawnDesc: String { tr("theme.cream_dawn_desc") }
        static var clearGlassDesc: String { tr("theme.clear_glass_desc") }
        static var forestBreathDesc: String { tr("theme.forest_breath_desc") }
        static var oceanCalmDesc: String { tr("theme.ocean_calm_desc") }
        static var sakuraDuskDesc: String { tr("theme.sakura_dusk_desc") }
        static var auroraNightDesc: String { tr("theme.aurora_night_desc") }
        static var pickerTitle: String { tr("theme.picker_title") }
    }

    enum Pro {
        static var premiumThemes: String { tr("pro.premium_themes") }
        static var premiumThemesSubtitle: String { tr("pro.premium_themes_subtitle") }
        static var advancedWidgets: String { tr("pro.advanced_widgets") }
        static var advancedWidgetsSubtitle: String { tr("pro.advanced_widgets_subtitle") }
        static var transparentClockAdvanced: String { tr("pro.transparent_clock_advanced") }
        static var transparentClockAdvancedSubtitle: String { tr("pro.transparent_clock_advanced_subtitle") }
        static var transparentFlipMode: String { tr("pro.transparent_flip_mode") }
        static var transparentFlipModeSubtitle: String { tr("pro.transparent_flip_mode_subtitle") }
        static var neonTransparentMode: String { tr("pro.neon_transparent_mode") }
        static var neonTransparentModeSubtitle: String { tr("pro.neon_transparent_mode_subtitle") }
        static var glassMorphAdvanced: String { tr("pro.glass_morph_advanced") }
        static var glassMorphAdvancedSubtitle: String { tr("pro.glass_morph_advanced_subtitle") }
        static var customFonts: String { tr("pro.custom_fonts") }
        static var customFontsSubtitle: String { tr("pro.custom_fonts_subtitle") }
        static var customColors: String { tr("pro.custom_colors") }
        static var customColorsSubtitle: String { tr("pro.custom_colors_subtitle") }
        static var customBackgroundPhotos: String { tr("pro.custom_background_photos") }
        static var customBackgroundPhotosSubtitle: String { tr("pro.custom_background_photos_subtitle") }
        static var multipleCustomTaglines: String { tr("pro.multiple_custom_taglines") }
        static var multipleCustomTaglinesSubtitle: String { tr("pro.multiple_custom_taglines_subtitle") }
        static var shootModeHideUI: String { tr("pro.shoot_mode_hide_ui") }
        static var shootModeHideUISubtitle: String { tr("pro.shoot_mode_hide_ui_subtitle") }
        static var burnInProtection: String { tr("pro.burn_in_protection") }
        static var burnInProtectionSubtitle: String { tr("pro.burn_in_protection_subtitle") }
        static var nightAdvancedMode: String { tr("pro.night_advanced_mode") }
        static var nightAdvancedModeSubtitle: String { tr("pro.night_advanced_mode_subtitle") }
        static var adFree: String { tr("pro.ad_free") }
        static var adFreeSubtitle: String { tr("pro.ad_free_subtitle") }
        static var paywallTitle: String { tr("pro.paywall_title") }
        static var paywallSubtitle: String { tr("pro.paywall_subtitle") }
        static var paywallValueHeadline: String { tr("pro.paywall_value_headline") }
        static var paywallValueBody: String { tr("pro.paywall_value_body") }
        static var paywallFeaturesTitle: String { tr("pro.paywall_features_title") }
        static var paywallPlansTitle: String { tr("pro.paywall_plans_title") }
        static var planMonthly: String { tr("pro.plan_monthly") }
        static var planYearly: String { tr("pro.plan_yearly") }
        static var planLifetime: String { tr("pro.plan_lifetime") }
        static var recommendedBadge: String { tr("pro.recommended_badge") }
        static var lifetimeBadge: String { tr("pro.lifetime_badge") }
        static var lifetimeHint: String { tr("pro.lifetime_hint") }
        static var restorePurchases: String { tr("pro.restore_purchases") }
        static var subscriptionDisclosure: String { tr("pro.subscription_disclosure") }
        static var loadingProducts: String { tr("pro.loading_products") }
        static var processing: String { tr("pro.processing") }
        static var operationInProgress: String { tr("pro.operation_in_progress") }
        static var productsUnavailable: String { tr("pro.products_unavailable") }
        static var unlockButton: String { tr("pro.unlock_button") }
        static var gateMessage: String { tr("pro.gate_message") }
        static var alreadyUnlocked: String { tr("pro.already_unlocked") }
        static var alertTitle: String { tr("pro.alert_title") }
        static var restoreSucceeded: String { tr("pro.restore_succeeded") }
        static var restoreNothingFound: String { tr("pro.restore_nothing_found") }
        static var purchasePending: String { tr("pro.purchase_pending") }
        static var purchaseUnknownError: String { tr("pro.purchase_unknown_error") }
        static var periodMonthly: String { tr("pro.period_monthly") }
        static var periodYearly: String { tr("pro.period_yearly") }
        static func productsLoadFailed(_ detail: String) -> String { tr("pro.products_load_failed", detail) }
        static func purchaseFailed(_ detail: String) -> String { tr("pro.purchase_failed", detail) }
        static func restoreFailed(_ detail: String) -> String { tr("pro.restore_failed", detail) }
        static func transactionUnverified(_ detail: String) -> String { tr("pro.transaction_unverified", detail) }
    }

    enum Legal {
        static var termsOfService: String { tr("legal.terms_of_service") }
        static var privacyPolicy: String { tr("legal.privacy_policy") }

        static var privacyEffectiveDate: String { tr("legal.privacy.effective_date") }
        static var privacyIntro: String { tr("legal.privacy.intro") }
        static var privacyCameraTitle: String { tr("legal.privacy.section.camera.title") }
        static var privacyCameraBody: String { tr("legal.privacy.section.camera.body") }
        static var privacyWidgetTitle: String { tr("legal.privacy.section.widget.title") }
        static var privacyWidgetBody: String { tr("legal.privacy.section.widget.body") }
        static var privacyPurchasesTitle: String { tr("legal.privacy.section.purchases.title") }
        static var privacyPurchasesBody: String { tr("legal.privacy.section.purchases.body") }
        static var privacyStorageTitle: String { tr("legal.privacy.section.storage.title") }
        static var privacyStorageBody: String { tr("legal.privacy.section.storage.body") }
        static var privacyChangesTitle: String { tr("legal.privacy.section.changes.title") }
        static var privacyChangesBody: String { tr("legal.privacy.section.changes.body") }
        static var privacyContactTitle: String { tr("legal.privacy.section.contact.title") }
        static var privacyContactBody: String { tr("legal.privacy.section.contact.body") }

        static var termsEffectiveDate: String { tr("legal.terms.effective_date") }
        static var termsIntro: String { tr("legal.terms.intro") }
        static var termsServiceTitle: String { tr("legal.terms.section.service.title") }
        static var termsServiceBody: String { tr("legal.terms.section.service.body") }
        static var termsRulesTitle: String { tr("legal.terms.section.rules.title") }
        static var termsRulesBody: String { tr("legal.terms.section.rules.body") }
        static var termsProTitle: String { tr("legal.terms.section.pro.title") }
        static var termsProBody: String { tr("legal.terms.section.pro.body") }
        static var termsSubscriptionsTitle: String { tr("legal.terms.section.subscriptions.title") }
        static var termsSubscriptionsBody: String { tr("legal.terms.section.subscriptions.body") }
        static var termsRefundsTitle: String { tr("legal.terms.section.refunds.title") }
        static var termsRefundsBody: String { tr("legal.terms.section.refunds.body") }
        static var termsLimitationsTitle: String { tr("legal.terms.section.limitations.title") }
        static var termsLimitationsBody: String { tr("legal.terms.section.limitations.body") }
        static var termsCameraTitle: String { tr("legal.terms.section.camera.title") }
        static var termsCameraBody: String { tr("legal.terms.section.camera.body") }
        static var termsDisclaimerTitle: String { tr("legal.terms.section.disclaimer.title") }
        static var termsDisclaimerBody: String { tr("legal.terms.section.disclaimer.body") }
        static var termsUpdatesTitle: String { tr("legal.terms.section.updates.title") }
        static var termsUpdatesBody: String { tr("legal.terms.section.updates.body") }
        static var termsContactTitle: String { tr("legal.terms.section.contact.title") }
        static var termsContactBody: String { tr("legal.terms.section.contact.body") }
    }

    private static func tr(_ key: String) -> String {
        String(localized: String.LocalizationValue(key))
    }

    private static func tr(_ key: String, _ arg: String) -> String {
        String(format: String(localized: String.LocalizationValue(key)), locale: Locale.current, arg)
    }
}
