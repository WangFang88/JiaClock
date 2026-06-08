import Foundation

struct ClockSettings: Codable, Equatable {
    var use24HourFormat: Bool = true
    var showSeconds: Bool = true
    var showDate: Bool = true
    var showWeekday: Bool = true
    var customTagline: String = ""
    var selectedTheme: ClockTheme = .jiaWarmGlow
    var clockDisplayStyle: ClockDisplayStyle = .digital
    var retroCalendarClockThemeID: String = RetroCalendarClockThemeLibrary.defaultThemeID
    var transparentFlipThemeID: String = TransparentFlipThemeLibrary.defaultThemeID
    var transparentBigDigitStyle: TransparentBigDigitStyle = .softPinkWhite
    var transparentClockBackgroundStyle: TransparentClockBackgroundStyle = .cameraOnly
    var transparentClockDisplayStyle: TransparentClockDisplayStyle = .fullScreenTransparentFlip
    var stackedFlipThemeID: String = StackedFlipThemeLibrary.defaultThemeID
    var dayHourglassThemeID: String = DayHourglassThemeLibrary.defaultThemeID
    var dayHourglassShowPercent: Bool = true
    var dayHourglassShowRemainingTime: Bool = true
    var dayHourglassPureMode: Bool = false
    var standByEnabled: Bool = false
    var focusModeEnabled: Bool = false

    static let `default` = ClockSettings()
}
