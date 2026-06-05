import Combine
import Foundation
import SwiftUI
#if canImport(WidgetKit)
import WidgetKit
#endif

@MainActor
final class ClockSettingsStore: ObservableObject {
    @Published var settings: ClockSettings {
        didSet {
            guard settings != oldValue else { return }
            persist()
        }
    }

    private let sharedDefaults: UserDefaults
    private let storageKey = JiaAppGroup.settingsJSONKey

    init(defaults: UserDefaults? = nil) {
        let suite = UserDefaults(suiteName: JiaAppGroup.identifier)
        self.sharedDefaults = suite ?? defaults ?? .standard

        if let data = sharedDefaults.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode(ClockSettings.self, from: data) {
            self.settings = decoded
        } else if
            let legacy = UserDefaults.standard.data(forKey: storageKey),
            let decoded = try? JSONDecoder().decode(ClockSettings.self, from: legacy) {
            self.settings = decoded
            persist()
        } else {
            self.settings = .default
        }
        syncWidgetFlatKeys()
    }

    var theme: ClockTheme {
        get { settings.selectedTheme }
        set { settings.selectedTheme = newValue }
    }

    var effectiveTagline: String {
        let trimmed = settings.customTagline.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? L10n.Clock.defaultTagline : trimmed
    }

    func update(_ transform: (inout ClockSettings) -> Void) {
        var copy = settings
        transform(&copy)
        settings = copy
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(settings) else { return }
        sharedDefaults.set(data, forKey: storageKey)
        syncWidgetFlatKeys()
        UserDefaults.standard.set(data, forKey: storageKey)
        reloadWidgetsIfNeeded()
    }

    private func syncWidgetFlatKeys() {
        sharedDefaults.set(settings.selectedTheme.rawValue, forKey: JiaAppGroup.Keys.selectedThemeID)
        sharedDefaults.set(settings.customTagline, forKey: JiaAppGroup.Keys.customSlogan)
        sharedDefaults.set(settings.use24HourFormat, forKey: JiaAppGroup.Keys.use24HourTime)
        sharedDefaults.set(settings.showDate, forKey: JiaAppGroup.Keys.showDate)
        sharedDefaults.set(settings.showWeekday, forKey: JiaAppGroup.Keys.showWeekday)
    }

    private func reloadWidgetsIfNeeded() {
        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadAllTimelines()
        #endif
    }
}

extension ClockSettingsStore {
    static let appGroupIdentifier = JiaAppGroup.identifier
}
