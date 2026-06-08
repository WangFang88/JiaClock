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

    /// 订阅过期或未购买 Pro 时，回退到免费主题。
    func enforceAccessibleTheme(isPro: Bool) {
        guard !isPro, theme.requiresPro else { return }
        theme = .jiaWarmGlow
    }

    /// 透明翻页 / 叠层翻页主题 / 背景：非 Pro 时回退到免费项。
    func enforceAccessibleTransparentFlipTheme(isPro: Bool) {
        let theme = TransparentFlipThemeLibrary.theme(id: settings.transparentFlipThemeID)
        if !isPro, theme.isPro {
            update { $0.transparentFlipThemeID = TransparentFlipThemeLibrary.defaultThemeID }
        }
        if !isPro, settings.transparentClockBackgroundStyle.isPro {
            update { $0.transparentClockBackgroundStyle = .softDark }
        }
        let stacked = StackedFlipThemeLibrary.theme(id: settings.stackedFlipThemeID)
        if !isPro, stacked.isPro {
            update { $0.stackedFlipThemeID = StackedFlipThemeLibrary.defaultThemeID }
        }
    }

    /// 统一样式 Pro / 主题 Pro：非 Pro 时回退。
    func enforceAccessibleClockStyle(isPro: Bool) {
        enforceAccessibleTransparentFlipTheme(isPro: isPro)
        enforceAccessibleRetroCalendarTheme(isPro: isPro)
        enforceAccessibleDayHourglassTheme(isPro: isPro)

        if !isPro, settings.clockDisplayStyle.isProStyle {
            update {
                $0.clockDisplayStyle = .digital
                $0.transparentClockDisplayStyle = .transparentFlip
            }
        }
    }

    /// 一日沙漏主题：非 Pro 时回退到免费项。
    func enforceAccessibleDayHourglassTheme(isPro: Bool) {
        let hourglass = DayHourglassThemeLibrary.theme(id: settings.dayHourglassThemeID)
        if !isPro, hourglass.isPro {
            update { $0.dayHourglassThemeID = DayHourglassThemeLibrary.defaultThemeID }
        }
    }

    /// 复古日历钟主题：非 Pro 时回退到免费项。
    func enforceAccessibleRetroCalendarTheme(isPro: Bool) {
        let retro = RetroCalendarClockThemeLibrary.theme(id: settings.retroCalendarClockThemeID)
        if !isPro, retro.isPro {
            update { $0.retroCalendarClockThemeID = RetroCalendarClockThemeLibrary.defaultThemeID }
        }
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
