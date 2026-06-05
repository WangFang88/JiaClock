import Foundation

struct ClockSettings: Codable, Equatable {
    var use24HourFormat: Bool = true
    var showSeconds: Bool = true
    var showDate: Bool = true
    var showWeekday: Bool = true
    var customTagline: String = ""
    var selectedTheme: ClockTheme = .dawn
    var standByEnabled: Bool = false
    var focusModeEnabled: Bool = false

    static let `default` = ClockSettings()
}
