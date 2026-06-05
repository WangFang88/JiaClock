import SwiftUI

struct FlipClockView: View {
    @EnvironmentObject private var settingsStore: ClockSettingsStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var showControls = true
    private var theme: ClockTheme { settingsStore.theme }

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            clockContent(now: context.date)
        }
        .id(settingsStore.settings.use24HourFormat)
    }

    @ViewBuilder
    private func clockContent(now: Date) -> some View {
        let components = ClockTimeFormatter.hourMinuteComponents(from: now, settings: settingsStore.settings)

        GeometryReader { geo in
            let isLandscape = geo.size.width > geo.size.height
            let isPad = horizontalSizeClass == .regular
            let cardWidth = min(isPad ? 200 : 150, (geo.size.width - (isLandscape ? 120 : 80)) / 2)
            let digitSize = min(isPad ? 88 : 72, cardWidth * 0.48)
            let cardHeight = cardWidth * 0.88

            ZStack {
                JiaBackgroundView(theme: theme)
                VStack(spacing: isLandscape ? 20 : 28) {
                    if showControls {
                        HStack {
                            JiaControlChip(icon: "xmark", title: L10n.Common.close) { dismiss() }
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                        .transition(.opacity)
                    } else {
                        Color.clear.frame(height: 52)
                    }

                    Spacer(minLength: 0)
                    VStack(spacing: 10) {
                        HStack(spacing: isLandscape ? 24 : 18) {
                            FlipDigitCard(value: components.hour, label: L10n.Flip.hourLabel, digitSize: digitSize, cardWidth: cardWidth, cardHeight: cardHeight)
                            Text(":")
                                .font(.system(size: digitSize * 0.72, weight: .light, design: .rounded))
                                .foregroundStyle(.white.opacity(0.72))
                                .offset(y: -cardHeight * 0.08)
                            FlipDigitCard(value: components.minute, label: L10n.Flip.minuteLabel, digitSize: digitSize, cardWidth: cardWidth, cardHeight: cardHeight)
                        }
                        if let period = components.period {
                            Text(period)
                                .font(.title2.weight(.bold))
                                .foregroundStyle(.white.opacity(0.88))
                        }
                    }
                    .frame(maxWidth: .infinity)

                    VStack(spacing: 8) {
                        if settingsStore.settings.showWeekday {
                            Text(ClockTimeFormatter.weekdayString(from: now))
                                .font(isPad ? .title2.weight(.medium) : .title3.weight(.medium))
                                .foregroundStyle(.white.opacity(0.84))
                                .multilineTextAlignment(.center)
                        }
                        if settingsStore.settings.showDate {
                            Text(ClockTimeFormatter.dateString(from: now))
                                .font(isPad ? .title2 : .title3)
                                .foregroundStyle(.white.opacity(0.84))
                                .multilineTextAlignment(.center)
                        }
                        Text(settingsStore.effectiveTagline)
                            .font(isPad ? .title3.weight(.medium) : .headline.weight(.medium))
                            .foregroundStyle(theme.accentColor.opacity(0.92))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 28)
                    }
                    .frame(maxWidth: .infinity)
                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
                .onTapGesture { withAnimation(.easeInOut(duration: 0.2)) { showControls.toggle() } }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

private struct FlipDigitCard: View {
    @Environment(\.colorScheme) private var colorScheme
    let value: String
    let label: String
    let digitSize: CGFloat
    let cardWidth: CGFloat
    let cardHeight: CGFloat

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: colorScheme == .dark
                                ? [Color(red: 0.16, green: 0.16, blue: 0.20), Color(red: 0.08, green: 0.08, blue: 0.12)]
                                : [Color(red: 0.20, green: 0.20, blue: 0.24), Color(red: 0.10, green: 0.10, blue: 0.14)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .strokeBorder(Color.white.opacity(colorScheme == .dark ? 0.10 : 0.14), lineWidth: 1)
                    }
                    .shadow(color: .black.opacity(colorScheme == .dark ? 0.42 : 0.28), radius: 18, x: 0, y: 12)

                VStack(spacing: 0) {
                    Rectangle()
                        .fill(LinearGradient(colors: [Color.white.opacity(colorScheme == .dark ? 0.08 : 0.14), .clear], startPoint: .top, endPoint: .bottom))
                        .frame(height: cardHeight * 0.42)
                    Rectangle()
                        .fill(Color.black.opacity(0.62))
                        .frame(height: 2)
                    Rectangle()
                        .fill(Color.black.opacity(0.14))
                        .frame(height: cardHeight * 0.42)
                }
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))

                Text(value)
                    .font(.system(size: digitSize, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.55)
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 1)
            }
            .frame(width: cardWidth, height: cardHeight)

            Text(label)
                .font(.caption2.weight(.bold))
                .foregroundStyle(.white.opacity(0.72))
                .tracking(1.2)
        }
    }
}
