import SwiftUI

struct FullScreenClockView: View {
    @EnvironmentObject private var settingsStore: ClockSettingsStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var showControls = true
    private var theme: ClockTheme { settingsStore.theme }

    var body: some View {
        let settings = settingsStore.settings
        TimelineView(.periodic(from: .now, by: 1)) { context in
            clockContent(now: context.date, settings: settings)
        }
        .id("\(settings.use24HourFormat)-\(settings.showSeconds)")
    }

    @ViewBuilder
    private func clockContent(now: Date, settings: ClockSettings) -> some View {
        GeometryReader { geo in
            let isLandscape = geo.size.width > geo.size.height
            let isPad = horizontalSizeClass == .regular
            let timeSize = min(isLandscape ? geo.size.height * 0.34 : geo.size.width * (isPad ? 0.16 : 0.22), isPad ? 160 : 120)

            ZStack {
                JiaBackgroundView(theme: theme)
                VStack(spacing: isLandscape ? 12 : 18) {
                    Spacer(minLength: 0)
                    Text(ClockTimeFormatter.timeString(from: now, settings: settings))
                        .font(.system(size: timeSize, weight: .ultraLight, design: .rounded))
                        .monospacedDigit()
                        .minimumScaleFactor(0.45)
                        .lineLimit(1)
                        .padding(.horizontal, 24)
                    if settings.showDate || settings.showWeekday {
                        VStack(spacing: 6) {
                            if settings.showWeekday {
                                Text(ClockTimeFormatter.weekdayString(from: now))
                                    .font(isPad ? .title2.weight(.medium) : .title3.weight(.medium))
                                    .foregroundStyle(.white.opacity(0.84))
                            }
                            if settings.showDate {
                                Text(ClockTimeFormatter.dateString(from: now))
                                    .font(isPad ? .title2 : .title3)
                                    .foregroundStyle(.white.opacity(0.84))
                            }
                        }
                    }
                    Text(settingsStore.effectiveTagline)
                        .font(isPad ? .title3.weight(.medium) : .headline.weight(.medium))
                        .foregroundStyle(theme.accentColor.opacity(0.92))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    Spacer(minLength: 0)
                }
                .frame(maxWidth: isPad ? 900 : .infinity)
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .onTapGesture { withAnimation(.easeInOut(duration: 0.2)) { showControls.toggle() } }

                if showControls {
                    VStack {
                        HStack {
                            JiaControlChip(icon: "xmark", title: L10n.Common.close) { dismiss() }
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                        Spacer()
                    }
                    .transition(.opacity)
                }
            }
        }
        .statusBarHidden(!showControls)
    }
}
