import Foundation

enum ClockTimeFormatter {
    private static let time24WithSeconds: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale.current
        f.dateFormat = "HH:mm:ss"
        return f
    }()

    private static let time24: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale.current
        f.dateFormat = "HH:mm"
        return f
    }()

    private static let minuteFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale.current
        f.dateFormat = "mm"
        return f
    }()

    private static let secondFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale.current
        f.dateFormat = "ss"
        return f
    }()

    private static let hour24Formatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale.current
        f.dateFormat = "HH"
        return f
    }()

    private static let periodFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale.current
        f.dateFormat = "a"
        return f
    }()

    private static let dateDisplayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale.current
        f.dateStyle = .long
        f.timeStyle = .none
        return f
    }()

    private static let weekdayDisplayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale.current
        f.dateFormat = "EEEE"
        return f
    }()

    static func timeString(from date: Date, settings: ClockSettings) -> String {
        if settings.use24HourFormat {
            return settings.showSeconds
                ? time24WithSeconds.string(from: date)
                : time24.string(from: date)
        }

        let parts = hourMinuteComponents(from: date, settings: settings)
        let clock = if settings.showSeconds {
            "\(parts.hour):\(parts.minute):\(secondString(from: date))"
        } else {
            "\(parts.hour):\(parts.minute)"
        }
        guard let period = parts.period else { return clock }
        return twelveHourTimeString(period: period, clock: clock)
    }

    static func secondString(from date: Date) -> String {
        secondFormatter.string(from: date)
    }

    static func secondDigits(from date: Date) -> (tens: String, ones: String) {
        let seconds = secondString(from: date)
        return (String(seconds.prefix(1)), String(seconds.suffix(1)))
    }

    /// 按 locale 决定上午/下午与时间的前后顺序（与翻页时钟分量一致，避免模板仍走 24 小时）。
    private static func twelveHourTimeString(period: String, clock: String) -> String {
        let format = DateFormatter.dateFormat(fromTemplate: "ahmm", options: 0, locale: Locale.current) ?? "a h:mm"
        if let aIndex = format.firstIndex(of: "a"),
           let hIndex = format.firstIndex(of: "h"),
           aIndex < hIndex {
            return "\(period) \(clock)"
        }
        return "\(clock) \(period)"
    }

    static func hourMinuteComponents(from date: Date, settings: ClockSettings) -> (hour: String, minute: String, period: String?) {
        let minute = minuteFormatter.string(from: date)

        if settings.use24HourFormat {
            return (hour24Formatter.string(from: date), minute, nil)
        }

        let hourValue = Calendar.current.component(.hour, from: date)
        let hour12 = hourValue % 12 == 0 ? 12 : hourValue % 12
        return (String(hour12), minute, periodFormatter.string(from: date))
    }

    static func dateString(from date: Date) -> String {
        dateDisplayFormatter.string(from: date)
    }

    static func weekdayString(from date: Date) -> String {
        weekdayDisplayFormatter.string(from: date)
    }

    /// 复古日历钟用英文星期缩写（MON / TUE …）。
    static func weekdayAbbreviation(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEE"
        return formatter.string(from: date).uppercased()
    }
}
