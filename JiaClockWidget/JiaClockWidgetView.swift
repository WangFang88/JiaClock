import SwiftUI
import WidgetKit

struct JiaClockWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: JiaClockWidgetEntry

    private var theme: WidgetThemeRenderer { WidgetThemeRenderer(themeID: entry.settings.selectedThemeID) }
    private var timeText: String { WidgetTimeFormatter.timeString(from: entry.date, use24Hour: entry.settings.use24HourTime) }

    var body: some View {
        Group {
            switch family {
            case .systemSmall: smallLayout
            case .systemMedium: mediumLayout
            case .systemLarge: largeLayout
            default: mediumLayout
            }
        }
        .containerBackground(for: .widget) {
            theme.background(showThemeBackground: family == .systemLarge)
        }
    }

    private var smallLayout: some View {
        VStack(alignment: .leading, spacing: 8) {
            brandMark
            Spacer(minLength: 0)
            Text(timeText)
                .font(.system(size: 36, weight: .ultraLight, design: .rounded))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .foregroundStyle(theme.primaryText)
            if entry.settings.showDate || entry.settings.showWeekday {
                Text(subtitleLine)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(theme.secondaryText)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
    }

    private var mediumLayout: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 10) {
                brandMark
                Text(timeText)
                    .font(.system(size: 46, weight: .ultraLight, design: .rounded))
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.65)
                    .foregroundStyle(theme.primaryText)
                metaLines
            }
            Spacer(minLength: 0)
            VStack(alignment: .trailing, spacing: 8) {
                accentDotLine
                Text(entry.settings.effectiveSlogan)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(theme.accent.opacity(0.92))
                    .lineLimit(3)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: 120)
            }
        }
        .padding(16)
    }

    private var largeLayout: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                brandMark
                Spacer()
                Image(systemName: "clock.fill")
                    .foregroundStyle(theme.accent.opacity(0.85))
            }
            Spacer(minLength: 0)
            Text(timeText)
                .font(.system(size: 68, weight: .ultraLight, design: .rounded))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .foregroundStyle(theme.primaryText)
            metaLines
            accentDotLine
            Text(entry.settings.effectiveSlogan)
                .font(.headline.weight(.medium))
                .foregroundStyle(theme.accent.opacity(0.92))
                .lineLimit(2)
            Spacer(minLength: 0)
            HStack {
                Spacer()
                Text(String(localized: "widget.brand_footer"))
                    .font(.caption2)
                    .foregroundStyle(theme.tertiaryText)
            }
        }
        .padding(20)
    }

    private var brandMark: some View {
        HStack(spacing: 6) {
            Circle().fill(theme.accent.opacity(0.85)).frame(width: 7, height: 7)
            Text(String(localized: "home.app_name"))
                .font(.caption2.weight(.semibold))
                .foregroundStyle(theme.secondaryText)
        }
    }

    private var accentDotLine: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .fill(theme.accent.opacity(0.35 + Double(i) * 0.2))
                    .frame(width: 4, height: 4)
            }
        }
    }

    private var metaLines: some View {
        VStack(alignment: .leading, spacing: 4) {
            if entry.settings.showWeekday {
                Text(WidgetTimeFormatter.weekdayString(from: entry.date))
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(theme.secondaryText)
            }
            if entry.settings.showDate {
                Text(WidgetTimeFormatter.dateString(from: entry.date))
                    .font(.subheadline)
                    .foregroundStyle(theme.tertiaryText)
            }
        }
    }

    private var subtitleLine: String {
        switch (entry.settings.showWeekday, entry.settings.showDate) {
        case (true, true): "\(WidgetTimeFormatter.weekdayString(from: entry.date)) · \(WidgetTimeFormatter.dateString(from: entry.date))"
        case (true, false): WidgetTimeFormatter.weekdayString(from: entry.date)
        case (false, true): WidgetTimeFormatter.dateString(from: entry.date)
        default: ""
        }
    }
}
