import SwiftUI

/// 全屏时钟容器：仅承载非透明样式。
struct FullScreenClockContainerView: View {
    @EnvironmentObject private var settingsStore: ClockSettingsStore

    var body: some View {
        switch settingsStore.settings.clockDisplayStyle {
        case .digital:
            DigitalFullScreenClockView()
        case .flip:
            FlipClockView()
        case .dayHourglass:
            DayHourglassScreenView()
        case .retroCalendar:
            RetroCalendarClockScreenView()
        case .transparentFlip, .stackedFlip, .minimalFloating:
            DigitalFullScreenClockView()
        }
    }
}

struct FullScreenClockView: View {
    var body: some View {
        FullScreenClockContainerView()
    }
}

// MARK: - 数字全屏时钟

struct DigitalFullScreenClockView: View {
    @EnvironmentObject private var settingsStore: ClockSettingsStore
    @EnvironmentObject private var entitlements: EntitlementManager
    @EnvironmentObject private var storeKit: StoreKitService
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var showControls = true
    @Environment(\.clockStyleLaunch) private var clockStyleLaunch
    @State private var showStyleCenter = false
    private var theme: ClockTheme { settingsStore.theme }

    var body: some View {
        let settings = settingsStore.settings
        TimelineView(.periodic(from: .now, by: 1)) { context in
            clockContent(now: context.date, settings: settings)
        }
        .id("\(settings.use24HourFormat)-\(settings.showSeconds)")
        .sheet(isPresented: $showStyleCenter) {
            ClockStyleCenterView(mode: .sheet, onLaunch: { destination in
                showStyleCenter = false
                if destination != .fullscreenContainer {
                    dismiss()
                    clockStyleLaunch?.onLaunch(destination)
                }
            })
        }
    }

    @ViewBuilder
    private func clockContent(now: Date, settings: ClockSettings) -> some View {
        GeometryReader { geo in
            let isLandscape = geo.size.width > geo.size.height
            let isPad = horizontalSizeClass == .regular
            let timeSize: CGFloat = {
                if isLandscape {
                    return min(geo.size.height * (isPad ? 0.42 : 0.38), isPad ? 200 : 160)
                }
                return min(geo.size.width * (isPad ? 0.16 : 0.22), isPad ? 160 : 120)
            }()

            ZStack {
                JiaBackgroundView(theme: theme)
                VStack(spacing: isLandscape ? 14 : 18) {
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
                        .padding(.horizontal, isLandscape ? 48 : 32)
                    Spacer(minLength: 0)
                }
                .frame(maxWidth: isPad ? 900 : .infinity)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
                .onTapGesture { withAnimation(.easeInOut(duration: 0.2)) { showControls.toggle() } }

                if showControls {
                    VStack {
                        HStack(spacing: 10) {
                            JiaControlChip(icon: "xmark", title: L10n.Common.close) { dismiss() }
                            Spacer(minLength: 8)
                            JiaControlChip(icon: "square.grid.2x2", title: L10n.ClockStyleCenter.entryButton) {
                                showStyleCenter = true
                            }
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
