import Foundation

enum JiaAppGroup {
    static let identifier = "group.jdarray.JiaClock"
    static let settingsJSONKey = "jia.clock.settings.v1"

    enum Keys {
        static let selectedThemeID = "selectedThemeID"
        static let customSlogan = "customSlogan"
        static let use24HourTime = "use24HourTime"
        static let showDate = "showDate"
        static let showWeekday = "showWeekday"
    }

    static var userDefaults: UserDefaults {
        UserDefaults(suiteName: identifier) ?? .standard
    }
}

struct WidgetSharedSettings: Equatable, Sendable {
    var selectedThemeID: String
    var customSlogan: String
    var use24HourTime: Bool
    var showDate: Bool
    var showWeekday: Bool

    static let `default` = WidgetSharedSettings(
        selectedThemeID: "dawn",
        customSlogan: "",
        use24HourTime: true,
        showDate: true,
        showWeekday: true
    )

    static func load(from defaults: UserDefaults = JiaAppGroup.userDefaults) -> WidgetSharedSettings {
        if defaults.object(forKey: JiaAppGroup.Keys.selectedThemeID) != nil {
            return WidgetSharedSettings(
                selectedThemeID: defaults.string(forKey: JiaAppGroup.Keys.selectedThemeID) ?? "dawn",
                customSlogan: defaults.string(forKey: JiaAppGroup.Keys.customSlogan) ?? "",
                use24HourTime: defaults.object(forKey: JiaAppGroup.Keys.use24HourTime) as? Bool ?? true,
                showDate: defaults.object(forKey: JiaAppGroup.Keys.showDate) as? Bool ?? true,
                showWeekday: defaults.object(forKey: JiaAppGroup.Keys.showWeekday) as? Bool ?? true
            )
        }
        if let data = defaults.data(forKey: JiaAppGroup.settingsJSONKey),
           let payload = try? JSONDecoder().decode(SettingsJSON.self, from: data) {
            return WidgetSharedSettings(
                selectedThemeID: payload.selectedTheme,
                customSlogan: payload.customTagline,
                use24HourTime: payload.use24HourFormat,
                showDate: payload.showDate,
                showWeekday: payload.showWeekday
            )
        }
        return .default
    }

    var effectiveSlogan: String {
        let trimmed = customSlogan.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return String(localized: "clock.default_tagline")
        }
        return trimmed
    }
}

private struct SettingsJSON: Codable {
    var use24HourFormat: Bool = true
    var showDate: Bool = true
    var showWeekday: Bool = true
    var customTagline: String = ""
    var selectedTheme: String = "dawn"
}
