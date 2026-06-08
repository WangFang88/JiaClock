import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var settingsStore: ClockSettingsStore
    @EnvironmentObject private var entitlementManager: EntitlementManager
    @EnvironmentObject private var storeKitService: StoreKitService
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    @StateObject private var cameraPermission = CameraPermissionService()
    @State private var showSettings = false
    @State private var showThemePicker = false
    @State private var showFullScreenClock = false
    @State private var showTransparentIntro = false
    @State private var showTransparentClock = false
    @State private var showStyleCenter = false
    @State private var showWidgetGuide = false
    @State private var showPaywall = false

    private var theme: ClockTheme { settingsStore.theme }
    private var currentStyle: ClockDisplayStyle { settingsStore.settings.clockDisplayStyle }

    private var columnCount: Int {
        if horizontalSizeClass == .regular { return 2 }
        return verticalSizeClass == .compact ? 2 : 1
    }

    var body: some View {
        NavigationStack {
            TimelineView(.periodic(from: .now, by: 1)) { context in
                homeContent(now: context.date)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .sheet(isPresented: $showSettings) {
                SettingsView()
                    .environmentObject(settingsStore)
                    .environmentObject(storeKitService)
                    .environmentObject(entitlementManager)
            }
            .sheet(isPresented: $showThemePicker) {
                ThemePickerView()
                    .environmentObject(settingsStore)
                    .environmentObject(entitlementManager)
                    .environmentObject(storeKitService)
            }
            .sheet(isPresented: $showStyleCenter) {
                ClockStyleCenterView(mode: .sheet, scene: .all, onLaunch: handleStyleLaunch)
                    .environmentObject(settingsStore)
                    .environmentObject(entitlementManager)
                    .environmentObject(storeKitService)
            }
            .sheet(isPresented: $showWidgetGuide) {
                WidgetGuideView()
                    .environmentObject(settingsStore)
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
                    .environmentObject(storeKitService)
                    .environmentObject(entitlementManager)
            }
            .fullScreenCover(isPresented: $showFullScreenClock) {
                FullScreenClockView()
                    .environmentObject(settingsStore)
                    .environmentObject(entitlementManager)
                    .environmentObject(storeKitService)
                    .environment(\.clockStyleLaunch, ClockStyleLaunchHandler(onLaunch: handleStyleLaunchFromFullscreen))
            }
            .sheet(isPresented: $showTransparentIntro) {
                TransparentClockIntroView()
                    .environmentObject(settingsStore)
                    .environmentObject(entitlementManager)
                    .environmentObject(storeKitService)
            }
            .fullScreenCover(isPresented: $showTransparentClock) {
                TransparentClockView()
                    .environmentObject(settingsStore)
                    .environmentObject(entitlementManager)
                    .environmentObject(storeKitService)
                    .environment(\.clockStyleLaunch, ClockStyleLaunchHandler(onLaunch: handleStyleLaunchFromFullscreen))
            }
            .onAppear { cameraPermission.refreshStatus() }
        }
    }

    @ViewBuilder
    private func homeContent(now: Date) -> some View {
        ZStack {
            JiaBackgroundView(theme: theme)
            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    brandSection
                    timePreviewSection(now: now)
                    featureGridSection
                    bottomBarSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 32)
                .frame(maxWidth: horizontalSizeClass == .regular ? 860 : 760)
                .frame(maxWidth: .infinity)
            }
        }
    }

    private var brandSection: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [theme.accentColor.opacity(0.32), theme.accentColor.opacity(0.10)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 52, height: 52)
                    .overlay {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(theme.accentColor.opacity(0.40), lineWidth: 0.8)
                    }
                Image(systemName: "clock.fill")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(theme.accentColor)
            }
            VStack(alignment: .leading, spacing: 5) {
                Text(L10n.Home.appName)
                    .font(.title.weight(.bold))
                    .foregroundStyle(theme.primaryTextColor)
                Text(L10n.Home.tagline)
                    .font(.subheadline)
                    .foregroundStyle(theme.secondaryTextColor)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
            if !entitlementManager.isPro {
                Button { showPaywall = true } label: {
                    ProBadgeView()
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.top, 8)
    }

    private func timePreviewSection(now: Date) -> some View {
        let settings = settingsStore.settings
        return JiaCardView(theme: theme, padding: 24) {
            VStack(spacing: 14) {
                HStack {
                    Text(L10n.Home.currentTime)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(theme.secondaryTextColor)
                    Spacer(minLength: 8)
                    currentStyleBadge
                }
                Text(ClockTimeFormatter.timeString(from: now, settings: settings))
                    .font(.system(size: horizontalSizeClass == .regular ? 56 : 48, weight: .ultraLight, design: .rounded))
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.55)
                    .foregroundStyle(theme.primaryTextColor)
                    .frame(maxWidth: .infinity, alignment: .center)
                if settings.showDate || settings.showWeekday {
                    HStack(spacing: 8) {
                        if settings.showWeekday {
                            Text(ClockTimeFormatter.weekdayString(from: now))
                        }
                        if settings.showDate {
                            Text(ClockTimeFormatter.dateString(from: now))
                        }
                    }
                    .font(.subheadline)
                    .foregroundStyle(theme.secondaryTextColor)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                Text(settingsStore.effectiveTagline)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(theme.accentColor.opacity(0.95))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
            .id("\(settings.use24HourFormat)-\(settings.showSeconds)")
        }
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [theme.accentColor.opacity(0.42), theme.accentColor.opacity(0.10)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.8
                )
        }
    }

    private var currentStyleBadge: some View {
        HStack(spacing: 5) {
            Image(systemName: currentStyle.systemImage)
                .font(.caption2.weight(.semibold))
            Text(currentStyle.title)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
        }
        .foregroundStyle(theme.accentColor)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background {
            Capsule()
                .fill(theme.accentColor.opacity(0.14))
        }
    }

    private var featureGridSection: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: columnCount), spacing: 16) {
            homeEntryCard(
                title: L10n.Home.startClock,
                subtitle: L10n.Home.startClockSubtitle,
                icon: "play.circle.fill",
                featured: true
            ) {
                launchCurrentStyle()
            }
            homeEntryCard(
                title: L10n.Home.transparentClock,
                subtitle: L10n.Home.transparentSubtitle,
                icon: "camera.viewfinder"
            ) {
                settingsStore.update { $0.clockDisplayStyle = .transparentFlip }
                let destination = ClockStyleRouter.launchDestination(
                    for: .transparentFlip,
                    cameraStatus: cameraPermission.status
                )
                handleStyleLaunch(destination)
            }
            homeEntryCard(
                title: L10n.Home.styleCenter,
                subtitle: L10n.Home.styleCenterSubtitle,
                icon: "square.grid.2x2.fill"
            ) {
                showStyleCenter = true
            }
            homeEntryCard(
                title: L10n.Home.widget,
                subtitle: L10n.Home.widgetSubtitle,
                icon: "rectangle.on.rectangle.angled"
            ) {
                showWidgetGuide = true
            }
        }
    }

    private func homeEntryCard(
        title: String,
        subtitle: String,
        icon: String,
        featured: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            JiaCardView(theme: theme, padding: 18) {
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        ZStack {
                            Circle()
                                .fill(
                                    featured
                                        ? theme.accentColor.opacity(0.24)
                                        : theme.accentColor.opacity(0.16)
                                )
                                .frame(width: 44, height: 44)
                            Image(systemName: icon)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(theme.accentColor)
                        }
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(theme.secondaryTextColor)
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text(title)
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(theme.primaryTextColor)
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(theme.secondaryTextColor)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .overlay {
                if featured {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(theme.accentColor.opacity(0.24), lineWidth: 0.8)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var bottomBarSection: some View {
        JiaCardView(theme: theme, padding: 14) {
            HStack(spacing: 12) {
                bottomActionButton(title: L10n.Home.theme, systemImage: "paintpalette.fill") {
                    showThemePicker = true
                }
                bottomActionButton(
                    title: entitlementManager.isPro ? L10n.Pro.alreadyUnlocked : L10n.Settings.upgradePro,
                    systemImage: entitlementManager.isPro ? "checkmark.seal.fill" : "sparkles"
                ) {
                    if !entitlementManager.isPro { showPaywall = true }
                }
                bottomActionButton(title: L10n.Home.settings, systemImage: "gearshape.fill") {
                    showSettings = true
                }
            }
        }
    }

    private func bottomActionButton(title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(theme.accentColor)
                Text(title)
                    .font(.caption)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .foregroundStyle(theme.controlTextColor)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }

    private func launchCurrentStyle() {
        let stored = settingsStore.settings.clockDisplayStyle
        let style = stored.usesFullscreenContainer ? stored : .digital
        let destination = ClockStyleRouter.launchDestination(for: style, cameraStatus: cameraPermission.status)
        handleStyleLaunch(destination)
    }

    private func handleStyleLaunch(_ destination: ClockStyleLaunchDestination) {
        switch destination {
        case .fullscreenContainer:
            showFullScreenClock = true
        case .transparentIntro:
            showTransparentIntro = true
        case .transparentClock:
            showTransparentClock = true
        }
    }

    private func handleStyleLaunchFromFullscreen(_ destination: ClockStyleLaunchDestination) {
        switch destination {
        case .fullscreenContainer:
            break
        case .transparentIntro:
            showFullScreenClock = false
            showTransparentClock = false
            showTransparentIntro = true
        case .transparentClock:
            showFullScreenClock = false
            showTransparentIntro = false
            showTransparentClock = true
        }
    }
}
