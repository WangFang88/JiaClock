import Foundation

/// 24 小时一日进度计算（基于用户当前时区，00:00 → 24:00）。
enum DayProgressCalculator {
    static let secondsPerDay = 86_400

    static func secondsPassedToday(for date: Date, calendar: Calendar = .current) -> Int {
        let start = calendar.startOfDay(for: date)
        let elapsed = date.timeIntervalSince(start)
        return min(secondsPerDay, max(0, Int(elapsed)))
    }

    static func dayProgress(for date: Date, calendar: Calendar = .current) -> Double {
        Double(secondsPassedToday(for: date, calendar: calendar)) / Double(secondsPerDay)
    }

    static func secondsRemainingToday(for date: Date, calendar: Calendar = .current) -> Int {
        max(0, secondsPerDay - secondsPassedToday(for: date, calendar: calendar))
    }

    static func formattedRemainingTime(for date: Date, calendar: Calendar = .current) -> String {
        let remaining = secondsRemainingToday(for: date, calendar: calendar)
        let hours = remaining / 3600
        let minutes = (remaining % 3600) / 60
        let seconds = remaining % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    static func percentPassed(for date: Date, calendar: Calendar = .current) -> Int {
        Int((dayProgress(for: date, calendar: calendar) * 100).rounded())
    }
}
