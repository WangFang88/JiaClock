import Foundation

enum ClockTimeFormatter {
    static func timeString(from date: Date, settings: ClockSettings) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        if settings.use24HourFormat {
            formatter.dateFormat = settings.showSeconds ? "HH:mm:ss" : "HH:mm"
        } else {
            formatter.dateFormat = settings.showSeconds ? "h:mm:ss a" : "h:mm a"
        }
        return formatter.string(from: date)
    }

    static func hourMinuteComponents(from date: Date, settings: ClockSettings) -> (hour: String, minute: String) {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = settings.use24HourFormat ? "HH" : "hh"
        let hour = formatter.string(from: date)
        formatter.dateFormat = "mm"
        return (hour, formatter.string(from: date))
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
