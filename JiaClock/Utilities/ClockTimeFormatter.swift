import Foundation

enum ClockTimeFormatter {
    static func timeString(from date: Date, settings: ClockSettings) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        if settings.use24HourFormat {
            formatter.dateFormat = settings.showSeconds ? "HH:mm:ss" : "HH:mm"
        } else {
            let template = settings.showSeconds ? "jmss" : "jms"
            formatter.setLocalizedDateFormatFromTemplate(template)
        }
        return formatter.string(from: date)
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
}
