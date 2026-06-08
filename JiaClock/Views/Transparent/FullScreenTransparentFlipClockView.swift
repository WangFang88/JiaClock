import SwiftUI

/// 全屏透明翻页：摄像头背景上的超大号无底色翻页数字。
struct FullScreenTransparentFlipClockView: View {
    let date: Date
    let showSeconds: Bool
    let use24HourTime: Bool
    let colorStyle: TransparentBigDigitStyle
    let showDate: Bool
    let showWeekday: Bool
    let slogan: String

    var body: some View {
        GeometryReader { geo in
            let isLandscape = geo.size.width > geo.size.height
            let components = timeComponents(from: date)
            let metrics = FullScreenFlipMetrics(
                container: geo.size,
                isLandscape: isLandscape,
                showSeconds: showSeconds,
                groupCount: components.groups.count
            )

            VStack(spacing: metrics.footerSpacing) {
                Spacer(minLength: 0)
                timeGroupsView(components: components, metrics: metrics, isLandscape: isLandscape)
                Spacer(minLength: 0)
                if shouldShowFooter(isLandscape: isLandscape) {
                    footerView(metrics: metrics)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }

    @ViewBuilder
    private func timeGroupsView(
        components: FlipTimeComponents,
        metrics: FullScreenFlipMetrics,
        isLandscape: Bool
    ) -> some View {
        if isLandscape {
            HStack(spacing: 0) {
                ForEach(Array(components.groups.enumerated()), id: \.offset) { index, group in
                    if index > 0 {
                        TransparentFlipTimeSeparator(width: metrics.groupSpacing)
                    }
                    TransparentBigFlipGroup(
                        tens: group.tens,
                        ones: group.ones,
                        fontSize: metrics.digitFontSize,
                        pairSpacing: metrics.pairSpacing,
                        style: colorStyle
                    )
                }
            }
            .frame(maxWidth: metrics.targetTotalWidth)
        } else if showSeconds && components.groups.count == 3 {
            VStack(spacing: metrics.portraitGroupGap) {
                ForEach(Array(components.groups.enumerated()), id: \.offset) { _, group in
                    TransparentBigFlipGroup(
                        tens: group.tens,
                        ones: group.ones,
                        fontSize: metrics.digitFontSize,
                        pairSpacing: metrics.pairSpacing,
                        style: colorStyle
                    )
                }
            }
        } else {
            portraitPairsLayout(components: components, metrics: metrics)
        }
    }

    @ViewBuilder
    private func portraitPairsLayout(components: FlipTimeComponents, metrics: FullScreenFlipMetrics) -> some View {
        let groups = components.groups
        if groups.count == 2 {
            HStack(spacing: metrics.groupSpacing) {
                TransparentBigFlipGroup(
                    tens: groups[0].tens,
                    ones: groups[0].ones,
                    fontSize: metrics.digitFontSize,
                    pairSpacing: metrics.pairSpacing,
                    style: colorStyle
                )
                TransparentBigFlipGroup(
                    tens: groups[1].tens,
                    ones: groups[1].ones,
                    fontSize: metrics.digitFontSize,
                    pairSpacing: metrics.pairSpacing,
                    style: colorStyle
                )
            }
        } else if groups.count == 3 {
            VStack(spacing: metrics.portraitGroupGap) {
                HStack(spacing: metrics.groupSpacing) {
                    TransparentBigFlipGroup(
                        tens: groups[0].tens,
                        ones: groups[0].ones,
                        fontSize: metrics.digitFontSize,
                        pairSpacing: metrics.pairSpacing,
                        style: colorStyle
                    )
                    TransparentBigFlipGroup(
                        tens: groups[1].tens,
                        ones: groups[1].ones,
                        fontSize: metrics.digitFontSize,
                        pairSpacing: metrics.pairSpacing,
                        style: colorStyle
                    )
                }
                TransparentBigFlipGroup(
                    tens: groups[2].tens,
                    ones: groups[2].ones,
                    fontSize: metrics.digitFontSize * 0.92,
                    pairSpacing: metrics.pairSpacing,
                    style: colorStyle
                )
            }
        }
    }

    @ViewBuilder
    private func footerView(metrics: FullScreenFlipMetrics) -> some View {
        VStack(spacing: 6) {
            if let period = timeComponents(from: date).period, !use24HourTime {
                Text(period)
                    .font(.system(size: metrics.footerFontSize, weight: .semibold, design: .rounded))
                    .foregroundStyle(colorStyle.digitColor.opacity(0.82))
                    .shadow(color: colorStyle.shadowColor, radius: 4, x: 0, y: 2)
            }
            if showWeekday {
                Text(ClockTimeFormatter.weekdayString(from: date))
                    .font(.system(size: metrics.footerFontSize, weight: .medium, design: .rounded))
                    .foregroundStyle(colorStyle.digitColor.opacity(0.78))
                    .shadow(color: colorStyle.shadowColor, radius: 4, x: 0, y: 2)
            }
            if showDate {
                Text(ClockTimeFormatter.dateString(from: date))
                    .font(.system(size: metrics.footerFontSize * 0.92, weight: .regular, design: .rounded))
                    .foregroundStyle(colorStyle.digitColor.opacity(0.72))
                    .shadow(color: colorStyle.shadowColor, radius: 4, x: 0, y: 2)
            }
            if !slogan.isEmpty {
                Text(slogan)
                    .font(.system(size: metrics.footerFontSize * 0.88, weight: .medium, design: .rounded))
                    .foregroundStyle(colorStyle.digitColor.opacity(0.70))
                    .multilineTextAlignment(.center)
                    .shadow(color: colorStyle.shadowColor, radius: 3, x: 0, y: 1)
                    .padding(.horizontal, 24)
            }
        }
        .padding(.bottom, 12)
    }

    private func shouldShowFooter(isLandscape: Bool) -> Bool {
        if isLandscape { return false }
        return showDate || showWeekday || !slogan.isEmpty || !use24HourTime
    }

    private func timeComponents(from date: Date) -> FlipTimeComponents {
        var settings = ClockSettings.default
        settings.use24HourFormat = use24HourTime
        settings.showSeconds = showSeconds

        let hm = ClockTimeFormatter.hourMinuteComponents(from: date, settings: settings)
        let hourValue = Int(hm.hour) ?? 0
        let hourPadded = String(format: "%02d", hourValue)
        let minutePadded = String(format: "%02d", Int(hm.minute) ?? 0)

        var groups: [DigitPair] = [
            DigitPair(tens: hourPadded[hourPadded.startIndex], ones: hourPadded[hourPadded.index(after: hourPadded.startIndex)]),
            DigitPair(
                tens: minutePadded[minutePadded.startIndex],
                ones: minutePadded[minutePadded.index(after: minutePadded.startIndex)]
            ),
        ]

        if showSeconds {
            let seconds = ClockTimeFormatter.secondString(from: date)
            groups.append(
                DigitPair(
                    tens: seconds[seconds.startIndex],
                    ones: seconds[seconds.index(after: seconds.startIndex)]
                )
            )
        }

        return FlipTimeComponents(groups: groups, period: hm.period)
    }
}

private struct DigitPair {
    let tens: Character
    let ones: Character
}

private struct FlipTimeComponents {
    let groups: [DigitPair]
    let period: String?
}

private struct FullScreenFlipMetrics {
    let digitFontSize: CGFloat
    let pairSpacing: CGFloat
    let groupSpacing: CGFloat
    let portraitGroupGap: CGFloat
    let targetTotalWidth: CGFloat
    let footerFontSize: CGFloat
    let footerSpacing: CGFloat

    init(container: CGSize, isLandscape: Bool, showSeconds: Bool, groupCount: Int) {
        let widthFactor: CGFloat = isLandscape ? 0.94 : 0.90
        targetTotalWidth = container.width * widthFactor

        let digitSlots = CGFloat(groupCount * 2)
        let separatorSlots = CGFloat(max(groupCount - 1, 0))
        let byWidth = targetTotalWidth / (digitSlots * 0.56 + separatorSlots * 0.30 + digitSlots * 0.04)

        let byHeight: CGFloat
        if isLandscape {
            byHeight = container.height * 0.78
        } else if showSeconds && groupCount == 3 {
            byHeight = container.height * 0.24
        } else if showSeconds {
            byHeight = container.height * 0.30
        } else {
            byHeight = container.height * 0.42
        }

        digitFontSize = min(byWidth, byHeight)
        pairSpacing = digitFontSize * 0.04
        groupSpacing = digitFontSize * 0.30
        portraitGroupGap = digitFontSize * 0.12
        footerFontSize = max(12, digitFontSize * 0.13)
        footerSpacing = isLandscape ? 0 : 8
    }
}
