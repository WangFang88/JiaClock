import SwiftUI

// MARK: - 叠层翻页时钟（上深 / 彩色条 / 下浅）

struct StackedFlipClockView: View {
    let date: Date
    let settings: ClockSettings
    let tagline: String
    let theme: StackedFlipTheme

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        GeometryReader { geo in
            let isLandscape = geo.size.width > geo.size.height
            let isPad = horizontalSizeClass == .regular
            let layout = StackedFlipLayoutMetrics(
                containerSize: geo.size,
                isLandscape: isLandscape,
                isPad: isPad
            )
            let digits = timeDigits(from: date, settings: settings)

            VStack(spacing: layout.metadataSpacing) {
                stackedModule(digits: digits, layout: layout)
                metadataSection(layout: layout)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }

    private func stackedModule(digits: StackedTimeDigits, layout: StackedFlipLayoutMetrics) -> some View {
        VStack(spacing: 0) {
            StackedFlipRowView(
                hourTens: digits.hourTens,
                hourOnes: digits.hourOnes,
                minuteTens: digits.minuteTens,
                minuteOnes: digits.minuteOnes,
                rowBackground: theme.topCardColor,
                digitColor: theme.topDigitColor,
                theme: theme,
                layout: layout,
                isTopRow: true,
                period: digits.period,
                secondsLabel: layout.showSecondsBadge ? digits.seconds : nil
            )
            StackedFlipAccentBar(theme: theme, height: layout.accentBarHeight)
            StackedFlipRowView(
                hourTens: digits.hourTens,
                hourOnes: digits.hourOnes,
                minuteTens: digits.minuteTens,
                minuteOnes: digits.minuteOnes,
                rowBackground: theme.bottomCardColor,
                digitColor: theme.bottomDigitColor,
                theme: theme,
                layout: layout,
                isTopRow: false,
                period: nil,
                secondsLabel: nil
            )
        }
        .clipShape(RoundedRectangle(cornerRadius: layout.outerCornerRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: layout.outerCornerRadius, style: .continuous)
                .strokeBorder(theme.borderColor, lineWidth: 0.8)
        }
        .shadow(color: theme.shadowColor, radius: layout.shadowRadius, x: 0, y: layout.shadowYOffset)
        .shadow(color: theme.glowColor.opacity(0.28), radius: 12, x: 0, y: 0)
        .frame(width: layout.moduleWidth)
    }

    @ViewBuilder
    private func metadataSection(layout: StackedFlipLayoutMetrics) -> some View {
        VStack(spacing: 8) {
            if settings.showWeekday {
                Text(ClockTimeFormatter.weekdayString(from: date))
                    .font(.system(size: layout.weekdayFontSize, weight: .medium, design: .rounded))
                    .foregroundStyle(theme.secondaryTextColor)
                    .shadow(color: theme.shadowColor, radius: 6, x: 0, y: 2)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 5)
                    .background { Capsule().fill(theme.metadataCapsuleFill) }
            }
            if settings.showDate {
                Text(ClockTimeFormatter.dateString(from: date))
                    .font(.system(size: layout.dateFontSize, weight: .regular, design: .rounded))
                    .foregroundStyle(theme.secondaryTextColor.opacity(0.92))
                    .shadow(color: theme.shadowColor, radius: 5, x: 0, y: 2)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 5)
                    .background { Capsule().fill(theme.metadataCapsuleFill.opacity(0.88)) }
            }
            if !tagline.isEmpty {
                Text(tagline)
                    .font(.system(size: layout.taglineFontSize, weight: .medium, design: .rounded))
                    .foregroundStyle(theme.taglineTextColor)
                    .multilineTextAlignment(.center)
                    .shadow(color: theme.shadowColor.opacity(0.85), radius: 4, x: 0, y: 1)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 4)
            }
        }
        .padding(.horizontal, 24)
    }

    private func timeDigits(from date: Date, settings: ClockSettings) -> StackedTimeDigits {
        let hm = ClockTimeFormatter.hourMinuteComponents(from: date, settings: settings)
        let hourPadded: String
        if settings.use24HourFormat {
            hourPadded = hm.hour.count == 1 ? "0\(hm.hour)" : hm.hour
        } else {
            hourPadded = hm.hour.count == 1 ? "0\(hm.hour)" : hm.hour
        }
        let minutePadded = hm.minute.count == 1 ? "0\(hm.minute)" : hm.minute

        var seconds: String?
        if settings.showSeconds {
            let formatter = DateFormatter()
            formatter.dateFormat = "ss"
            seconds = formatter.string(from: date)
        }

        return StackedTimeDigits(
            hourTens: String(hourPadded.prefix(1)),
            hourOnes: String(hourPadded.suffix(1)),
            minuteTens: String(minutePadded.prefix(1)),
            minuteOnes: String(minutePadded.suffix(1)),
            period: hm.period,
            seconds: seconds
        )
    }
}

private struct StackedTimeDigits {
    let hourTens: String
    let hourOnes: String
    let minuteTens: String
    let minuteOnes: String
    let period: String?
    let seconds: String?
}

struct StackedFlipLayoutMetrics {
    let moduleWidth: CGFloat
    let rowHeight: CGFloat
    let accentBarHeight: CGFloat
    let digitBlockWidth: CGFloat
    let digitBlockHeight: CGFloat
    let digitFontSize: CGFloat
    let pairSpacing: CGFloat
    let hourMinuteGap: CGFloat
    let outerCornerRadius: CGFloat
    let blockCornerRadius: CGFloat
    let shadowRadius: CGFloat
    let shadowYOffset: CGFloat
    let metadataSpacing: CGFloat
    let weekdayFontSize: CGFloat
    let dateFontSize: CGFloat
    let taglineFontSize: CGFloat
    let showSecondsBadge: Bool

    init(containerSize: CGSize, isLandscape: Bool, isPad: Bool) {
        let widthRatio: CGFloat = isLandscape ? 0.55 : 0.78
        moduleWidth = containerSize.width * widthRatio

        if isLandscape {
            rowHeight = isPad ? 92 : 78
            accentBarHeight = 26
            digitBlockWidth = isPad ? 58 : 50
            outerCornerRadius = 28
            metadataSpacing = isPad ? 22 : 18
            weekdayFontSize = isPad ? 20 : 17
            dateFontSize = isPad ? 18 : 16
            taglineFontSize = isPad ? 16 : 14
            showSecondsBadge = false
        } else {
            rowHeight = isPad ? 82 : 72
            accentBarHeight = 30
            digitBlockWidth = isPad ? 52 : 46
            outerCornerRadius = 24
            metadataSpacing = isPad ? 20 : 16
            weekdayFontSize = isPad ? 18 : 15
            dateFontSize = isPad ? 17 : 15
            taglineFontSize = isPad ? 15 : 13
            showSecondsBadge = true
        }

        digitBlockHeight = rowHeight * 0.72
        digitFontSize = digitBlockWidth * 0.82
        pairSpacing = isLandscape ? 6 : 5
        hourMinuteGap = isLandscape ? 18 : 14
        blockCornerRadius = isLandscape ? 16 : 14
        shadowRadius = isLandscape ? 22 : 18
        shadowYOffset = isLandscape ? 14 : 12
    }
}

// MARK: - Row

struct StackedFlipRowView: View {
    let hourTens: String
    let hourOnes: String
    let minuteTens: String
    let minuteOnes: String
    let rowBackground: Color
    let digitColor: Color
    let theme: StackedFlipTheme
    let layout: StackedFlipLayoutMetrics
    let isTopRow: Bool
    let period: String?
    let secondsLabel: String?

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            rowBackground
            HStack(spacing: layout.hourMinuteGap) {
                StackedFlipNumberPairView(
                    tens: hourTens,
                    ones: hourOnes,
                    digitColor: digitColor,
                    theme: theme,
                    layout: layout,
                    isTopRow: isTopRow
                )
                StackedFlipNumberPairView(
                    tens: minuteTens,
                    ones: minuteOnes,
                    digitColor: digitColor,
                    theme: theme,
                    layout: layout,
                    isTopRow: isTopRow
                )
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, layout.pairSpacing * 2)

            if isTopRow {
                HStack(spacing: 6) {
                    if let secondsLabel {
                        Text(secondsLabel)
                            .font(.system(size: layout.digitFontSize * 0.28, weight: .semibold, design: .rounded))
                            .monospacedDigit()
                            .foregroundStyle(digitColor.opacity(0.72))
                    }
                    if let period {
                        Text(period)
                            .font(.system(size: layout.digitFontSize * 0.26, weight: .medium, design: .rounded))
                            .foregroundStyle(digitColor.opacity(0.68))
                    }
                }
                .padding(.trailing, 12)
                .padding(.bottom, 8)
            }
        }
        .frame(height: layout.rowHeight)
    }
}

// MARK: - Number Pair

struct StackedFlipNumberPairView: View {
    let tens: String
    let ones: String
    let digitColor: Color
    let theme: StackedFlipTheme
    let layout: StackedFlipLayoutMetrics
    let isTopRow: Bool

    var body: some View {
        HStack(spacing: layout.pairSpacing) {
            StackedFlipDigitBlock(digit: tens, digitColor: digitColor, theme: theme, layout: layout, isTopRow: isTopRow)
            StackedFlipDigitBlock(digit: ones, digitColor: digitColor, theme: theme, layout: layout, isTopRow: isTopRow)
        }
    }
}

// MARK: - Digit Block

struct StackedFlipDigitBlock: View {
    let digit: String
    let digitColor: Color
    let theme: StackedFlipTheme
    let layout: StackedFlipLayoutMetrics
    let isTopRow: Bool

    private var blockFill: Color {
        if isTopRow {
            Color.white.opacity(0.08)
        } else {
            Color.black.opacity(0.04)
        }
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: layout.blockCornerRadius, style: .continuous)
                .fill(blockFill)
                .overlay {
                    RoundedRectangle(cornerRadius: layout.blockCornerRadius, style: .continuous)
                        .strokeBorder(Color.white.opacity(isTopRow ? 0.10 : 0.06), lineWidth: 0.5)
                }
                .overlay(alignment: .top) {
                    LinearGradient(
                        colors: [Color.white.opacity(isTopRow ? 0.12 : 0.18), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: layout.digitBlockHeight * 0.42)
                    .clipShape(RoundedRectangle(cornerRadius: layout.blockCornerRadius, style: .continuous))
                }

            VStack(spacing: 0) {
                Color.clear.frame(height: layout.digitBlockHeight * 0.5)
                Rectangle()
                    .fill(Color.black.opacity(isTopRow ? 0.18 : 0.08))
                    .frame(height: 1)
                Color.clear.frame(height: layout.digitBlockHeight * 0.5 - 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: layout.blockCornerRadius, style: .continuous))

            Text(digit)
                .font(.system(size: layout.digitFontSize, weight: .light, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(digitColor)
                .shadow(color: theme.shadowColor.opacity(0.6), radius: 4, x: 0, y: 2)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
        }
        .frame(width: layout.digitBlockWidth, height: layout.digitBlockHeight)
    }
}

// MARK: - Accent Bar

struct StackedFlipAccentBar: View {
    let theme: StackedFlipTheme
    let height: CGFloat

    var body: some View {
        ZStack {
            LinearGradient(
                colors: theme.middleAccentColors,
                startPoint: .leading,
                endPoint: .trailing
            )
            LinearGradient(
                colors: [Color.white.opacity(0.22), .clear],
                startPoint: .top,
                endPoint: .bottom
            )
            HStack(spacing: 6) {
                Circle()
                    .fill(Color.white.opacity(0.55))
                    .frame(width: 4, height: 4)
                RoundedRectangle(cornerRadius: 1, style: .continuous)
                    .fill(Color.white.opacity(0.35))
                    .frame(width: 18, height: 2)
                Circle()
                    .fill(Color.white.opacity(0.55))
                    .frame(width: 4, height: 4)
            }
        }
        .frame(height: height)
    }
}

// MARK: - 主题选择预览

struct StackedFlipThemePreview: View {
    let theme: StackedFlipTheme

    var body: some View {
        let layout = StackedFlipLayoutMetrics(
            containerSize: CGSize(width: 140, height: 100),
            isLandscape: false,
            isPad: false
        )
        VStack(spacing: 0) {
            previewRow(
                hour: "1", hour2: "5",
                minute: "0", minute2: "2",
                background: theme.topCardColor,
                digitColor: theme.topDigitColor,
                layout: layout,
                isTop: true
            )
            StackedFlipAccentBar(theme: theme, height: 14)
            previewRow(
                hour: "1", hour2: "5",
                minute: "0", minute2: "2",
                background: theme.bottomCardColor,
                digitColor: theme.bottomDigitColor,
                layout: layout,
                isTop: false
            )
        }
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .strokeBorder(theme.borderColor.opacity(0.6), lineWidth: 0.6)
        }
    }

    private func previewRow(
        hour: String, hour2: String,
        minute: String, minute2: String,
        background: Color,
        digitColor: Color,
        layout: StackedFlipLayoutMetrics,
        isTop: Bool
    ) -> some View {
        ZStack {
            background
            HStack(spacing: 8) {
                HStack(spacing: 3) {
                    miniBlock(digit: hour, color: digitColor, isTop: isTop)
                    miniBlock(digit: hour2, color: digitColor, isTop: isTop)
                }
                HStack(spacing: 3) {
                    miniBlock(digit: minute, color: digitColor, isTop: isTop)
                    miniBlock(digit: minute2, color: digitColor, isTop: isTop)
                }
            }
        }
        .frame(height: 36)
    }

    private func miniBlock(digit: String, color: Color, isTop: Bool) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(isTop ? Color.white.opacity(0.08) : Color.black.opacity(0.04))
            Text(digit)
                .font(.system(size: 16, weight: .light, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(color)
        }
        .frame(width: 18, height: 26)
    }
}
