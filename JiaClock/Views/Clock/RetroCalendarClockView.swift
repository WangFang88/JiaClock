import SwiftUI

// MARK: - 全屏复古日历钟

struct RetroCalendarClockScreenView: View {
    @EnvironmentObject private var settingsStore: ClockSettingsStore
    @EnvironmentObject private var entitlements: EntitlementManager
    @EnvironmentObject private var storeKit: StoreKitService
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @State private var showControls = true
    @State private var showStyleCenter = false
    @State private var showThemePicker = false
    @Environment(\.clockStyleLaunch) private var clockStyleLaunch

    private var clockTheme: ClockTheme { settingsStore.theme }
    private var retroTheme: RetroCalendarClockTheme {
        RetroCalendarClockThemeLibrary.theme(id: settingsStore.settings.retroCalendarClockThemeID)
    }

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { timeline in
            let now = timeline.date
            GeometryReader { geo in
                let isLandscape = geo.size.width > geo.size.height
                let isPad = horizontalSizeClass == .regular
                let layout = RetroCalendarLayout(
                    container: geo.size,
                    isLandscape: isLandscape,
                    isPad: isPad
                )

                ZStack {
                    JiaBackgroundView(theme: clockTheme)
                    VStack(spacing: layout.footerSpacing) {
                        Spacer(minLength: isLandscape ? 16 : geo.safeAreaInsets.top + 8)
                        RetroCalendarClockView(
                            date: now,
                            theme: retroTheme,
                            settings: settingsStore.settings,
                            layout: layout
                        )
                        footerInfo(now: now, layout: layout)
                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal, layout.horizontalPadding)
                    .zIndex(0)
                    if showControls {
                        controlsOverlay
                            .zIndex(1)
                    }
                }
            }
        }
        .ignoresSafeArea()
        .contentShape(Rectangle())
        .onTapGesture { withAnimation(.easeInOut(duration: 0.2)) { showControls.toggle() } }
        .onAppear {
            settingsStore.enforceAccessibleRetroCalendarTheme(isPro: entitlements.isPro)
        }
        .onChange(of: entitlements.isPro) { _, isPro in
            settingsStore.enforceAccessibleRetroCalendarTheme(isPro: isPro)
        }
        .statusBarHidden(!showControls)
        .sheet(isPresented: $showThemePicker) {
            RetroCalendarThemePickerSheet()
                .environmentObject(settingsStore)
                .environmentObject(entitlements)
                .environmentObject(storeKit)
        }
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
    private func footerInfo(now: Date, layout: RetroCalendarLayout) -> some View {
        VStack(spacing: 8) {
            Text(ClockTimeFormatter.timeString(from: now, settings: settingsStore.settings))
                .font(.system(size: layout.footerTimeSize, weight: .ultraLight, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.white.opacity(0.88))
            if !settingsStore.effectiveTagline.isEmpty {
                Text(settingsStore.effectiveTagline)
                    .font(.system(size: layout.footerTaglineSize, weight: .medium, design: .rounded))
                    .foregroundStyle(clockTheme.accentColor.opacity(0.92))
                    .multilineTextAlignment(.center)
            }
        }
    }

    private var controlsOverlay: some View {
        VStack {
            HStack(spacing: 10) {
                JiaControlChip(icon: "xmark", title: L10n.Common.close) { dismiss() }
                Spacer(minLength: 8)
                JiaControlChip(icon: "paintpalette.fill", title: L10n.RetroCalendar.colorSectionTitle) {
                    showThemePicker = true
                }
                JiaControlChip(icon: "square.grid.2x2", title: L10n.ClockStyleCenter.entryButton) {
                    showStyleCenter = true
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            Spacer()
        }
        .transition(.opacity)
    }
}

// MARK: - Layout

struct RetroCalendarLayout {
    let shellWidth: CGFloat
    let shellHeight: CGFloat
    let cornerRadius: CGFloat
    let horizontalPadding: CGFloat
    let footerSpacing: CGFloat
    let footerTimeSize: CGFloat
    let footerTaglineSize: CGFloat
    let labelFontSize: CGFloat
    let dayFontSize: CGFloat
    let dateFontSize: CGFloat
    let analogSize: CGFloat
    let flipCardWidth: CGFloat
    let flipCardHeight: CGFloat
    let compact: Bool

    init(container: CGSize, isLandscape: Bool, isPad: Bool, compact: Bool = false) {
        self.compact = compact
        if compact {
            shellWidth = 140
            shellHeight = 72
            cornerRadius = 12
            horizontalPadding = 0
            footerSpacing = 0
            footerTimeSize = 0
            footerTaglineSize = 0
            labelFontSize = 7
            dayFontSize = 14
            dateFontSize = 22
            analogSize = 36
            flipCardWidth = 32
            flipCardHeight = 28
        } else if isLandscape {
            shellWidth = container.width * (isPad ? 0.68 : 0.65)
            shellHeight = container.height * (isPad ? 0.52 : 0.48)
            cornerRadius = isPad ? 32 : 26
            horizontalPadding = isPad ? 40 : 24
            footerSpacing = isPad ? 20 : 14
            footerTimeSize = isPad ? 28 : 22
            footerTaglineSize = isPad ? 16 : 14
            labelFontSize = isPad ? 11 : 10
            dayFontSize = isPad ? 26 : 22
            dateFontSize = isPad ? 44 : 38
            analogSize = isPad ? 88 : 72
            flipCardWidth = isPad ? 72 : 58
            flipCardHeight = isPad ? 52 : 44
        } else {
            shellWidth = container.width * (isPad ? 0.88 : 0.88)
            shellHeight = shellWidth * 0.42
            cornerRadius = isPad ? 28 : 24
            horizontalPadding = isPad ? 32 : 20
            footerSpacing = isPad ? 22 : 16
            footerTimeSize = isPad ? 32 : 26
            footerTaglineSize = isPad ? 16 : 14
            labelFontSize = isPad ? 11 : 10
            dayFontSize = isPad ? 24 : 20
            dateFontSize = isPad ? 42 : 36
            analogSize = isPad ? 80 : 68
            flipCardWidth = isPad ? 68 : 56
            flipCardHeight = isPad ? 48 : 40
        }
    }
}

// MARK: - 整体复古钟

struct RetroCalendarClockView: View {
    let date: Date
    let theme: RetroCalendarClockTheme
    let settings: ClockSettings
    let layout: RetroCalendarLayout

    var body: some View {
        RetroClockShellView(theme: theme, layout: layout) {
            RetroCalendarPanelView(theme: theme, layout: layout) {
                HStack(spacing: layout.compact ? 6 : 12) {
                    RetroFlipDayView(
                        weekday: ClockTimeFormatter.weekdayAbbreviation(from: date),
                        theme: theme,
                        layout: layout
                    )
                    RetroFlipDateView(
                        day: Calendar.current.component(.day, from: date),
                        theme: theme,
                        layout: layout
                    )
                    Spacer(minLength: layout.compact ? 2 : 6)
                    RetroAnalogClockView(
                        date: date,
                        showSeconds: settings.showSeconds,
                        theme: theme,
                        size: layout.analogSize
                    )
                }
            }
        }
        .frame(width: layout.shellWidth, height: layout.shellHeight + (layout.compact ? 0 : 14))
    }
}

// MARK: - 外壳

struct RetroClockShellView<Content: View>: View {
    let theme: RetroCalendarClockTheme
    let layout: RetroCalendarLayout
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            if !layout.compact {
                decorativeButtons
                    .padding(.bottom, 6)
            }
            ZStack {
                RoundedRectangle(cornerRadius: layout.cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: theme.shellGradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(alignment: .top) {
                        RoundedRectangle(cornerRadius: layout.cornerRadius, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [theme.shellHighlight, .clear],
                                    startPoint: .top,
                                    endPoint: .center
                                )
                            )
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: layout.cornerRadius, style: .continuous)
                            .strokeBorder(theme.borderColor, lineWidth: layout.compact ? 0.8 : 1.2)
                    }
                    .shadow(color: theme.shadowColor, radius: layout.compact ? 6 : 18, x: 0, y: layout.compact ? 4 : 12)
                    .shadow(color: theme.shellShadow, radius: layout.compact ? 4 : 8, x: 0, y: layout.compact ? 2 : 4)

                content()
                    .padding(layout.compact ? 8 : 16)
            }
            .frame(width: layout.shellWidth, height: layout.shellHeight)
            if !layout.compact {
                decorativeFeet
                    .padding(.top, 4)
            }
        }
    }

    private var decorativeButtons: some View {
        HStack(spacing: layout.compact ? 6 : 10) {
            ForEach(0..<3, id: \.self) { _ in
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [theme.shellGradient[0], theme.shellGradient[1].opacity(0.85)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: layout.compact ? 8 : 14, height: layout.compact ? 5 : 8)
                    .overlay {
                        Capsule()
                            .strokeBorder(theme.borderColor.opacity(0.4), lineWidth: 0.5)
                    }
                    .shadow(color: theme.shadowColor.opacity(0.25), radius: 2, x: 0, y: 1)
            }
        }
    }

    private var decorativeFeet: some View {
        HStack(spacing: layout.shellWidth * 0.52) {
            foot
            foot
        }
    }

    private var foot: some View {
        RoundedRectangle(cornerRadius: 2, style: .continuous)
            .fill(theme.footColor)
            .frame(width: layout.compact ? 10 : 16, height: layout.compact ? 4 : 6)
            .shadow(color: theme.shadowColor.opacity(0.3), radius: 2, x: 0, y: 1)
    }
}

// MARK: - 内面板

struct RetroCalendarPanelView<Content: View>: View {
    let theme: RetroCalendarClockTheme
    let layout: RetroCalendarLayout
    @ViewBuilder let content: () -> Content

    var body: some View {
        RoundedRectangle(cornerRadius: layout.compact ? 8 : 14, style: .continuous)
            .fill(theme.panelColor)
            .overlay {
                RoundedRectangle(cornerRadius: layout.compact ? 8 : 14, style: .continuous)
                    .strokeBorder(Color.black.opacity(0.06), lineWidth: 0.5)
            }
            .overlay(alignment: .top) {
                LinearGradient(colors: [Color.black.opacity(0.06), .clear], startPoint: .top, endPoint: .bottom)
                    .frame(height: layout.compact ? 12 : 24)
                    .clipShape(RoundedRectangle(cornerRadius: layout.compact ? 8 : 14, style: .continuous))
            }
            .shadow(color: Color.black.opacity(0.12), radius: 4, x: 0, y: 2)
            .overlay {
                content()
                    .padding(.horizontal, layout.compact ? 6 : 14)
                    .padding(.vertical, layout.compact ? 6 : 12)
            }
    }
}

// MARK: - DAY / DATE

struct RetroFlipDayView: View {
    let weekday: String
    let theme: RetroCalendarClockTheme
    let layout: RetroCalendarLayout

    var body: some View {
        VStack(spacing: layout.compact ? 3 : 6) {
            Text("DAY")
                .font(.system(size: layout.labelFontSize, weight: .bold, design: .default))
                .tracking(0.8)
                .foregroundStyle(theme.labelColor)
            RetroFlipCard(
                text: weekday,
                fontSize: layout.dayFontSize,
                theme: theme,
                width: layout.flipCardWidth,
                height: layout.flipCardHeight
            )
        }
    }
}

struct RetroFlipDateView: View {
    let day: Int
    let theme: RetroCalendarClockTheme
    let layout: RetroCalendarLayout

    var body: some View {
        VStack(spacing: layout.compact ? 3 : 6) {
            Text("DATE")
                .font(.system(size: layout.labelFontSize, weight: .bold, design: .default))
                .tracking(0.8)
                .foregroundStyle(theme.labelColor)
            RetroFlipCard(
                text: "\(day)",
                fontSize: layout.dateFontSize,
                theme: theme,
                width: layout.flipCardWidth * (layout.compact ? 1.05 : 1.15),
                height: layout.flipCardHeight * (layout.compact ? 1.05 : 1.12)
            )
        }
    }
}

struct RetroFlipCard: View {
    let text: String
    let fontSize: CGFloat
    let theme: RetroCalendarClockTheme
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: height * 0.14, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [theme.flipCardColor, theme.flipCardColor.opacity(0.88)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay {
                    RoundedRectangle(cornerRadius: height * 0.14, style: .continuous)
                        .strokeBorder(Color.black.opacity(0.08), lineWidth: 0.6)
                }
                .overlay(alignment: .top) {
                    LinearGradient(colors: [Color.white.opacity(0.35), .clear], startPoint: .top, endPoint: .bottom)
                        .frame(height: height * 0.45)
                        .clipShape(RoundedRectangle(cornerRadius: height * 0.14, style: .continuous))
                }
                .shadow(color: Color.black.opacity(0.10), radius: 2, x: 0, y: 1)

            VStack(spacing: 0) {
                Color.clear.frame(height: height * 0.5)
                Rectangle().fill(Color.black.opacity(0.10)).frame(height: 1)
                Color.clear.frame(height: height * 0.5 - 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: height * 0.14, style: .continuous))

            Text(text)
                .font(.system(size: fontSize, weight: .medium, design: .serif))
                .monospacedDigit()
                .foregroundStyle(theme.flipCardTextColor)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
        }
        .frame(width: width, height: height)
    }
}

// MARK: - 模拟表盘

struct RetroAnalogClockView: View {
    let date: Date
    let showSeconds: Bool
    let theme: RetroCalendarClockTheme
    let size: CGFloat

    var body: some View {
        let calendar = Calendar.current
        let hour = Double(calendar.component(.hour, from: date) % 12)
        let minute = Double(calendar.component(.minute, from: date))
        let second = Double(calendar.component(.second, from: date))

        ZStack {
            Circle()
                .fill(theme.clockFaceColor)
                .overlay {
                    Circle()
                        .strokeBorder(theme.clockTickColor.opacity(0.35), lineWidth: 1)
                }
                .shadow(color: Color.black.opacity(0.08), radius: 3, x: 0, y: 2)

            ForEach(0..<12, id: \.self) { index in
                let isMajor = index % 3 == 0
                Capsule()
                    .fill(theme.clockTickColor)
                    .frame(width: isMajor ? 1.8 : 1, height: isMajor ? size * 0.09 : size * 0.05)
                    .offset(y: -(size * 0.38))
                    .rotationEffect(.degrees(Double(index) * 30))
            }

            clockHand(length: size * 0.22, width: 2.8, angle: hourAngle(hour: hour, minute: minute))
            clockHand(length: size * 0.32, width: 2, angle: minuteAngle(minute: minute, second: second))
            if showSeconds {
                clockHand(length: size * 0.34, width: 0.8, angle: second * 6 - 90, color: theme.accentColor.opacity(0.85))
            }

            Circle()
                .fill(theme.clockHandColor)
                .frame(width: size * 0.07, height: size * 0.07)
            Circle()
                .fill(theme.clockFaceColor)
                .frame(width: size * 0.025, height: size * 0.025)
        }
        .frame(width: size, height: size)
    }

    private func clockHand(length: CGFloat, width: CGFloat, angle: Double, color: Color? = nil) -> some View {
        Capsule()
            .fill(color ?? theme.clockHandColor)
            .frame(width: width, height: length)
            .offset(y: -length / 2)
            .rotationEffect(.degrees(angle))
    }

    private func hourAngle(hour: Double, minute: Double) -> Double {
        (hour + minute / 60) / 12 * 360 - 90
    }

    private func minuteAngle(minute: Double, second: Double) -> Double {
        (minute + second / 60) / 60 * 360 - 90
    }
}

// MARK: - 预览（样式选择用）

struct RetroCalendarClockPreview: View {
    let theme: RetroCalendarClockTheme

    var body: some View {
        RetroCalendarClockView(
            date: Date.now,
            theme: theme,
            settings: .default,
            layout: RetroCalendarLayout(
                container: CGSize(width: 140, height: 80),
                isLandscape: true,
                isPad: false,
                compact: true
            )
        )
    }
}

// MARK: - 复古日历钟颜色选择

struct RetroCalendarThemePickerSheet: View {
    @EnvironmentObject private var settingsStore: ClockSettingsStore
    @EnvironmentObject private var entitlements: EntitlementManager
    @EnvironmentObject private var storeKit: StoreKitService
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @State private var showPaywall = false

    private var selectedID: String { settingsStore.settings.retroCalendarClockThemeID }

    var body: some View {
        NavigationStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(RetroCalendarClockThemeLibrary.all) { theme in
                        retroThemeCard(theme)
                    }
                }
                .padding(20)
            }
            .background(Color(red: 0.08, green: 0.08, blue: 0.10))
            .navigationTitle(L10n.RetroCalendar.colorSectionTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(L10n.Common.done) { dismiss() }
                }
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView(highlightFeature: .premiumThemes)
                    .environmentObject(storeKit)
                    .environmentObject(entitlements)
            }
        }
        .presentationDetents([.height(horizontalSizeClass == .regular ? 220 : 200)])
        .presentationDragIndicator(.visible)
    }

    private func retroThemeCard(_ theme: RetroCalendarClockTheme) -> some View {
        let isSelected = selectedID == theme.id
        let locked = theme.isPro && !entitlements.isPro
        let cardWidth: CGFloat = horizontalSizeClass == .regular ? 140 : 120

        return Button {
            if theme.isPro, !entitlements.isPro {
                showPaywall = true
                return
            }
            settingsStore.update { $0.retroCalendarClockThemeID = theme.id }
        } label: {
            VStack(spacing: 8) {
                RetroCalendarClockPreview(theme: theme)
                    .scaleEffect(0.72)
                    .frame(width: cardWidth, height: 72)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(isSelected ? theme.accentColor : Color.white.opacity(0.12), lineWidth: isSelected ? 2 : 1)
                    }
                HStack(spacing: 4) {
                    Text(theme.title).font(.caption.weight(.semibold)).foregroundStyle(.white.opacity(0.88))
                    if theme.isPro { ProBadgeView(compact: true) }
                    if locked {
                        Image(systemName: "lock.fill").font(.caption2).foregroundStyle(.white.opacity(0.5))
                    }
                }
            }
            .frame(width: cardWidth)
        }
        .buttonStyle(.plain)
    }
}
