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
        static var proStatusActive: String { tr("settings.pro_status_active") }
        static func proExpiresAt(_ date: String) -> String { tr("settings.pro_expires_at", date) }
        static var legalSection: String { tr("settings.legal_section") }
    }

    enum Theme {
        static var dawn: String { tr("theme.dawn") }
        static var midnight: String { tr("theme.midnight") }
        static var forest: String { tr("theme.forest") }
        static var ocean: String { tr("theme.ocean") }
        static var aurora: String { tr("theme.aurora") }
        static var sakura: String { tr("theme.sakura") }
        static var ember: String { tr("theme.ember") }
        static var jadeRealm: String { tr("theme.jade_realm") }
        static var purpleDusk: String { tr("theme.purple_dusk") }
        static var candyFantasy: String { tr("theme.candy_fantasy") }
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
