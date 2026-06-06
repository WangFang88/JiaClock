import SwiftUI

/// 透明时钟专用翻页时间显示：独立数字卡片悬浮于摄像头画面上。
struct TransparentFlipClockView: View {
    let date: Date
    let settings: ClockSettings
    let tagline: String
    let flipTheme: TransparentFlipTheme
    var useLightText: Bool = true

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var overlayTextColor: Color {
        useLightText ? .white : Color(red: 0.12, green: 0.12, blue: 0.16)
    }

    var body: some View {
        GeometryReader { geo in
            let isLandscape = geo.size.width > geo.size.height
            let isPad = horizontalSizeClass == .regular
            let layout = FlipLayoutMetrics(
                size: geo.size,
                isLandscape: isLandscape,
                isPad: isPad,
                showSeconds: settings.showSeconds
            )
            let digits = digitGroups(from: date, settings: settings)

            VStack(spacing: layout.sectionSpacing) {
                flipRow(digits: digits, layout: layout)
                if let period = digits.period {
                    Text(period)
                        .font(.system(size: layout.periodFontSize, weight: .semibold, design: .rounded))
                        .foregroundStyle(useLightText ? flipTheme.digitColor.opacity(0.92) : overlayTextColor)
                        .shadow(color: flipTheme.shadowColor, radius: 8, x: 0, y: 2)
                }
                metadataSection(layout: layout)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }

    @ViewBuilder
    private func flipRow(digits: FlipDigitGroups, layout: FlipLayoutMetrics) -> some View {
        HStack(spacing: layout.digitSpacing) {
            TransparentFlipDigitCard(digit: digits.hourTens, theme: flipTheme, layout: layout, useLightText: useLightText)
            TransparentFlipDigitCard(digit: digits.hourOnes, theme: flipTheme, layout: layout, useLightText: useLightText)
            TransparentFlipColonView(theme: flipTheme, size: layout.colonSize, offsetY: -layout.cardHeight * 0.06, useLightText: useLightText)
            TransparentFlipDigitCard(digit: digits.minuteTens, theme: flipTheme, layout: layout, useLightText: useLightText)
            TransparentFlipDigitCard(digit: digits.minuteOnes, theme: flipTheme, layout: layout, useLightText: useLightText)
            if let secondTens = digits.secondTens, let secondOnes = digits.secondOnes {
                TransparentFlipColonView(theme: flipTheme, size: layout.colonSize * 0.92, offsetY: -layout.cardHeight * 0.06, useLightText: useLightText)
                TransparentFlipDigitCard(digit: secondTens, theme: flipTheme, layout: layout, useLightText: useLightText)
                TransparentFlipDigitCard(digit: secondOnes, theme: flipTheme, layout: layout, useLightText: useLightText)
            }
        }
    }

    @ViewBuilder
    private func metadataSection(layout: FlipLayoutMetrics) -> some View {
        VStack(spacing: 8) {
            if settings.showWeekday {
                Text(ClockTimeFormatter.weekdayString(from: date))
                    .font(.system(size: layout.weekdayFontSize, weight: .medium, design: .rounded))
                    .foregroundStyle(useLightText ? flipTheme.secondaryTextColor : overlayTextColor)
                    .shadow(color: flipTheme.shadowColor, radius: 6, x: 0, y: 2)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 5)
                    .background { Capsule().fill(flipTheme.metadataCapsuleFill) }
            }
            if settings.showDate {
                Text(ClockTimeFormatter.dateString(from: date))
                    .font(.system(size: layout.dateFontSize, weight: .regular, design: .rounded))
                    .foregroundStyle(useLightText ? flipTheme.secondaryTextColor.opacity(0.92) : overlayTextColor.opacity(0.88))
                    .shadow(color: flipTheme.shadowColor, radius: 5, x: 0, y: 2)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 5)
                    .background { Capsule().fill(flipTheme.metadataCapsuleFill.opacity(0.88)) }
            }
            if !tagline.isEmpty {
                Text(tagline)
                    .font(.system(size: layout.taglineFontSize, weight: .medium, design: .rounded))
                    .foregroundStyle(useLightText ? flipTheme.taglineTextColor : overlayTextColor.opacity(0.88))
                    .multilineTextAlignment(.center)
                    .shadow(color: flipTheme.shadowColor.opacity(0.85), radius: 4, x: 0, y: 1)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 4)
            }
        }
        .padding(.horizontal, 24)
    }

    private func digitGroups(from date: Date, settings: ClockSettings) -> FlipDigitGroups {
        let hm = ClockTimeFormatter.hourMinuteComponents(from: date, settings: settings)
        let hourPadded = String(format: "%02d", Int(hm.hour) ?? 0)
        let minutePadded = String(format: "%02d", Int(hm.minute) ?? 0)

        var secondTens: String?
        var secondOnes: String?
        if settings.showSeconds {
            let formatter = DateFormatter()
            formatter.dateFormat = "ss"
            let seconds = formatter.string(from: date)
            secondTens = String(seconds.prefix(1))
            secondOnes = String(seconds.suffix(1))
        }

        return FlipDigitGroups(
            hourTens: String(hourPadded.prefix(1)),
            hourOnes: String(hourPadded.suffix(1)),
            minuteTens: String(minutePadded.prefix(1)),
            minuteOnes: String(minutePadded.suffix(1)),
            secondTens: secondTens,
            secondOnes: secondOnes,
            period: hm.period
        )
    }
}

private struct FlipDigitGroups {
    let hourTens: String
    let hourOnes: String
    let minuteTens: String
    let minuteOnes: String
    let secondTens: String?
    let secondOnes: String?
    let period: String?
}

struct FlipLayoutMetrics {
    let cardWidth: CGFloat
    let cardHeight: CGFloat
    let digitFontSize: CGFloat
    let colonSize: CGFloat
    let digitSpacing: CGFloat
    let sectionSpacing: CGFloat
    let periodFontSize: CGFloat
    let weekdayFontSize: CGFloat
    let dateFontSize: CGFloat
    let taglineFontSize: CGFloat
    let cornerRadius: CGFloat

    init(size: CGSize, isLandscape: Bool, isPad: Bool, showSeconds: Bool, compact: Bool = false) {
        let digitSlots = showSeconds ? 6 : 4
        let colonSlots = showSeconds ? 2 : 1
        let horizontalPadding: CGFloat = compact ? 8 : (isLandscape ? 72 : 40)
        let colonFactor: CGFloat = 0.52
        let available = max(size.width - horizontalPadding, 120)
        let slotWidth = available / (CGFloat(digitSlots) + CGFloat(colonSlots) * colonFactor)

        if compact {
            cardWidth = min(28, slotWidth)
            digitSpacing = 3
            sectionSpacing = 8
            weekdayFontSize = 10
            dateFontSize = 9
            taglineFontSize = 8
            periodFontSize = 12
            cornerRadius = 8
        } else if isLandscape {
            cardWidth = min(isPad ? 118 : 98, slotWidth)
            digitSpacing = isPad ? 10 : 8
            sectionSpacing = isPad ? 22 : 18
            weekdayFontSize = isPad ? 20 : 17
            dateFontSize = isPad ? 18 : 16
            taglineFontSize = isPad ? 16 : 14
            periodFontSize = isPad ? 28 : 24
            cornerRadius = 18
        } else {
            cardWidth = min(isPad ? 86 : 68, slotWidth)
            digitSpacing = isPad ? 8 : 6
            sectionSpacing = isPad ? 20 : 16
            weekdayFontSize = isPad ? 18 : 15
            dateFontSize = isPad ? 17 : 15
            taglineFontSize = isPad ? 15 : 13
            periodFontSize = isPad ? 24 : 20
            cornerRadius = 16
        }

        cardHeight = cardWidth * 1.14
        digitFontSize = cardWidth * 0.78
        colonSize = digitFontSize * 0.42
    }
}

struct TransparentFlipDigitCard: View {
    let digit: String
    let theme: TransparentFlipTheme
    let layout: FlipLayoutMetrics
    var useLightText: Bool = true

    private var digitTextColor: Color {
        useLightText ? theme.digitColor : Color(red: 0.12, green: 0.12, blue: 0.16)
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: layout.cornerRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: theme.cardGradient,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .background {
                    RoundedRectangle(cornerRadius: layout.cornerRadius, style: .continuous)
                        .fill(.ultraThinMaterial.opacity(theme.cardMaterialOpacity))
                }
                .overlay {
                    RoundedRectangle(cornerRadius: layout.cornerRadius, style: .continuous)
                        .strokeBorder(theme.borderColor, lineWidth: 0.8)
                }
                .overlay(alignment: .top) {
                    LinearGradient(
                        colors: [theme.highlightTop, .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: layout.cardHeight * 0.45)
                    .clipShape(RoundedRectangle(cornerRadius: layout.cornerRadius, style: .continuous))
                }
                .overlay(alignment: .bottom) {
                    LinearGradient(
                        colors: [.clear, theme.highlightBottom],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: layout.cardHeight * 0.35)
                    .clipShape(RoundedRectangle(cornerRadius: layout.cornerRadius, style: .continuous))
                }
                .shadow(color: theme.shadowColor, radius: 16, x: 0, y: 10)
                .shadow(color: theme.glowColor.opacity(0.35), radius: 8, x: 0, y: 0)

            VStack(spacing: 0) {
                Color.clear.frame(height: layout.cardHeight * 0.5)
                Rectangle()
                    .fill(theme.dividerColor)
                    .frame(height: 1)
                Color.clear.frame(height: layout.cardHeight * 0.5 - 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: layout.cornerRadius, style: .continuous))

            Text(digit)
                .font(.system(size: layout.digitFontSize, weight: .light, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(digitTextColor)
                .shadow(color: theme.shadowColor.opacity(0.85), radius: 6, x: 0, y: 2)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
        }
        .frame(width: layout.cardWidth, height: layout.cardHeight)
    }
}

struct TransparentFlipColonView: View {
    let theme: TransparentFlipTheme
    let size: CGFloat
    let offsetY: CGFloat
    var useLightText: Bool = true

    private var colonTextColor: Color {
        useLightText ? theme.colonColor : Color(red: 0.12, green: 0.12, blue: 0.16)
    }

    var body: some View {
        Text(":")
            .font(.system(size: size, weight: .medium, design: .rounded))
            .foregroundStyle(colonTextColor)
            .shadow(color: theme.glowColor, radius: 5, x: 0, y: 0)
            .shadow(color: theme.shadowColor, radius: 6, x: 0, y: 2)
            .offset(y: offsetY)
    }
}

/// 主题选择 Sheet 用的小型翻页预览（固定 10:28）。
struct TransparentFlipThemePreviewClock: View {
    let theme: TransparentFlipTheme
    var showSeconds: Bool = false

    var body: some View {
        let layout = FlipLayoutMetrics(
            size: CGSize(width: showSeconds ? 220 : 160, height: 56),
            isLandscape: true,
            isPad: false,
            showSeconds: showSeconds,
            compact: true
        )
        HStack(spacing: layout.digitSpacing) {
            TransparentFlipDigitCard(digit: "1", theme: theme, layout: layout)
            TransparentFlipDigitCard(digit: "0", theme: theme, layout: layout)
            TransparentFlipColonView(theme: theme, size: layout.colonSize, offsetY: -2)
            TransparentFlipDigitCard(digit: "2", theme: theme, layout: layout)
            TransparentFlipDigitCard(digit: "8", theme: theme, layout: layout)
        }
    }
}
