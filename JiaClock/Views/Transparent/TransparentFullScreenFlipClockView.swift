import SwiftUI

/// 透明时钟专用全屏大数字翻页层：无卡片、无底色，真实翻页动画。
struct TransparentFullScreenFlipClockView: View {
    let date: Date
    let showSeconds: Bool
    let use24HourTime: Bool
    let digitStyle: TransparentFullScreenDigitStyle
    let showDateInfo: Bool
    let showWeekday: Bool
    let weekdayText: String
    let dateText: String
    let slogan: String

    var body: some View {
        GeometryReader { geo in
            let components = timeComponents(from: date)
            let landscape = geo.size.width > geo.size.height
            let metrics = TransparentFullScreenFlipMetrics(
                container: geo.size,
                isLandscape: landscape,
                showSeconds: showSeconds,
                groupCount: components.groups.count
            )

            VStack(spacing: metrics.footerSpacing) {
                Spacer(minLength: 0)
                clockGroupsLayout(components: components, metrics: metrics, isLandscape: landscape)
                Spacer(minLength: 0)
                if shouldShowFooter(isLandscape: landscape) {
                    footerView(metrics: metrics)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }

    @ViewBuilder
    private func clockGroupsLayout(
        components: TransparentFlipTimeComponents,
        metrics: TransparentFullScreenFlipMetrics,
        isLandscape: Bool
    ) -> some View {
        if isLandscape {
            HStack(spacing: metrics.groupSpacing) {
                ForEach(Array(components.groups.enumerated()), id: \.offset) { _, group in
                    TransparentFlipNumberGroup(
                        tens: group.tens,
                        ones: group.ones,
                        fontSize: metrics.digitFontSize,
                        pairSpacing: metrics.pairSpacing,
                        style: digitStyle
                    )
                    .equatable()
                }
            }
            .frame(maxWidth: metrics.targetTotalWidth)
        } else {
            VStack(spacing: metrics.portraitGroupGap) {
                ForEach(Array(components.groups.enumerated()), id: \.offset) { _, group in
                    TransparentFlipNumberGroup(
                        tens: group.tens,
                        ones: group.ones,
                        fontSize: metrics.digitFontSize,
                        pairSpacing: metrics.pairSpacing,
                        style: digitStyle
                    )
                    .equatable()
                }
            }
            .frame(maxWidth: metrics.targetTotalWidth)
        }
    }

    @ViewBuilder
    private func footerView(metrics: TransparentFullScreenFlipMetrics) -> some View {
        VStack(spacing: 5) {
            if let period = timeComponents(from: date).period, !use24HourTime {
                Text(period)
                    .font(.system(size: metrics.footerFontSize, weight: .semibold, design: .rounded))
                    .foregroundStyle(digitStyle.digitColor.opacity(0.82))
                    .shadow(color: digitStyle.shadowColor, radius: 4, x: 0, y: 2)
            }
            if showWeekday, !weekdayText.isEmpty {
                Text(weekdayText)
                    .font(.system(size: metrics.footerFontSize, weight: .medium, design: .rounded))
                    .foregroundStyle(digitStyle.digitColor.opacity(0.78))
                    .shadow(color: digitStyle.shadowColor, radius: 4, x: 0, y: 2)
            }
            if showDateInfo, !dateText.isEmpty {
                Text(dateText)
                    .font(.system(size: metrics.footerFontSize * 0.92, weight: .regular, design: .rounded))
                    .foregroundStyle(digitStyle.digitColor.opacity(0.72))
                    .shadow(color: digitStyle.shadowColor, radius: 4, x: 0, y: 2)
            }
            if !slogan.isEmpty {
                Text(slogan)
                    .font(.system(size: metrics.footerFontSize * 0.88, weight: .medium, design: .rounded))
                    .foregroundStyle(digitStyle.digitColor.opacity(0.70))
                    .multilineTextAlignment(.center)
                    .shadow(color: digitStyle.shadowColor, radius: 3, x: 0, y: 1)
                    .padding(.horizontal, 24)
            }
        }
        .padding(.bottom, 14)
    }

    private func shouldShowFooter(isLandscape: Bool) -> Bool {
        if isLandscape { return false }
        return showDateInfo || showWeekday || !slogan.isEmpty || !use24HourTime
    }

    private func timeComponents(from date: Date) -> TransparentFlipTimeComponents {
        var settings = ClockSettings.default
        settings.use24HourFormat = use24HourTime
        settings.showSeconds = showSeconds

        let hm = ClockTimeFormatter.hourMinuteComponents(from: date, settings: settings)
        let hourValue = Int(hm.hour) ?? 0
        let hourPadded = String(format: "%02d", hourValue)
        let minutePadded = String(format: "%02d", Int(hm.minute) ?? 0)

        var groups: [TransparentFlipDigitPair] = [
            TransparentFlipDigitPair(
                tens: hourPadded[hourPadded.startIndex],
                ones: hourPadded[hourPadded.index(after: hourPadded.startIndex)]
            ),
            TransparentFlipDigitPair(
                tens: minutePadded[minutePadded.startIndex],
                ones: minutePadded[minutePadded.index(after: minutePadded.startIndex)]
            ),
        ]

        if showSeconds {
            let seconds = ClockTimeFormatter.secondString(from: date)
            groups.append(
                TransparentFlipDigitPair(
                    tens: seconds[seconds.startIndex],
                    ones: seconds[seconds.index(after: seconds.startIndex)]
                )
            )
        }

        return TransparentFlipTimeComponents(groups: groups, period: hm.period)
    }
}

private struct TransparentFlipDigitPair {
    let tens: Character
    let ones: Character
}

private struct TransparentFlipTimeComponents {
    let groups: [TransparentFlipDigitPair]
    let period: String?
}

private struct TransparentFullScreenFlipMetrics {
    let digitFontSize: CGFloat
    let pairSpacing: CGFloat
    let groupSpacing: CGFloat
    let portraitGroupGap: CGFloat
    let targetTotalWidth: CGFloat
    let footerFontSize: CGFloat
    let footerSpacing: CGFloat

    init(container: CGSize, isLandscape: Bool, showSeconds: Bool, groupCount: Int) {
        let widthFactor: CGFloat = isLandscape ? 0.94 : 0.80
        targetTotalWidth = container.width * widthFactor

        let digitSlotWidth: CGFloat = 0.68
        let pairInnerGap: CGFloat = 0.04
        let groupGapUnits: CGFloat = isLandscape ? 0.32 : 0.14

        if isLandscape {
            let groups = CGFloat(groupCount)
            let totalDigitSlots = groups * 2
            let widthDenominator = totalDigitSlots * digitSlotWidth
                + (groups - 1) * groupGapUnits
                + totalDigitSlots * pairInnerGap
            let byWidth = targetTotalWidth / widthDenominator
            let byHeight = container.height * 0.78
            digitFontSize = min(byWidth, byHeight)
        } else {
            let rows = CGFloat(groupCount)
            let rowHeightUnits = rows * 1.12 + max(rows - 1, 0) * groupGapUnits
            let byHeight = container.height * 0.58 / rowHeightUnits
            let byWidth = targetTotalWidth / (2 * digitSlotWidth + pairInnerGap)
            digitFontSize = min(byWidth, byHeight)
        }

        pairSpacing = digitFontSize * 0.04
        groupSpacing = digitFontSize * (isLandscape ? 0.32 : 0.14)
        portraitGroupGap = digitFontSize * 0.14
        footerFontSize = max(12, digitFontSize * 0.12)
        footerSpacing = isLandscape ? 0 : 10
    }
}
