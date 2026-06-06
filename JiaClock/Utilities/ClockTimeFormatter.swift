import Foundation

enum ClockTimeFormatter {
    static func timeString(from date: Date, settings: ClockSettings) -> String {
        if settings.use24HourFormat {
            let formatter = DateFormatter()
            formatter.locale = Locale.current
            formatter.dateFormat = settings.showSeconds ? "HH:mm:ss" : "HH:mm"
            return formatter.string(from: date)
        }

        let parts = hourMinuteComponents(from: date, settings: settings)
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "ss"
        let clock = if settings.showSeconds {
            "\(parts.hour):\(parts.minute):\(formatter.string(from: date))"
        } else {
            "\(parts.hour):\(parts.minute)"
        }
        guard let period = parts.period else { return clock }
        return twelveHourTimeString(period: period, clock: clock)
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
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "mm"
        let minute = formatter.string(from: date)

        if settings.use24HourFormat {
            formatter.dateFormat = "HH"
            return (formatter.string(from: date), minute, nil)
        }

        let hourValue = Calendar.current.component(.hour, from: date)
        let hour12 = hourValue % 12 == 0 ? 12 : hourValue % 12
        formatter.dateFormat = "a"
        return (String(hour12), minute, formatter.string(from: date))
    }

    static func dateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    static func weekdayString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }

    /// 复古日历钟用英文星期缩写（MON / TUE …）。
    static func weekdayAbbreviation(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEE"
        return formatter.string(from: date).uppercased()
    }
}
