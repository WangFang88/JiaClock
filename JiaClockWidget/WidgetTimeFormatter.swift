import Foundation

enum WidgetTimeFormatter {
    static func timeString(from date: Date, use24Hour: Bool) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = use24Hour ? "HH:mm" : "h:mm a"
        return formatter.string(from: date)
    }

    static func dateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.setLocalizedDateFormatFromTemplate("MMMd")
        return formatter.string(from: date)
    }

    static func weekdayString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }

    static func nextMinuteBoundary(from date: Date = .now) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        guard let base = calendar.date(from: components) else { return date.addingTimeInterval(60) }
        return calendar.date(byAdding: .minute, value: 1, to: base) ?? date.addingTimeInterval(60)
    }
}
