import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var settingsStore: ClockSettingsStore
    @EnvironmentObject private var entitlementManager: EntitlementManager
    @EnvironmentObject private var storeKitService: StoreKitService
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @State private var now = Date.now
    @State private var showSettings = false
    @State private var showThemePicker = false
    @State private var showFullScreenClock = false
    @State private var showFlipClock = false
    @State private var showTransparentIntro = false
    @State private var showWidgetGuide = false

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private var theme: ClockTheme { settingsStore.theme }
    private var columnCount: Int { horizontalSizeClass == .regular ? 2 : 1 }

    var body: some View {
        NavigationStack {
            ZStack {
                JiaBackgroundView(theme: theme)
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        brandSection
                        timePreviewSection
                        featureGridSection
                        bottomBarSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 32)
                    .frame(maxWidth: 760)
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .sheet(isPresented: $showSettings) {
                SettingsView()
                    .environmentObject(settingsStore)
                    .environmentObject(storeKitService)
                    .environmentObject(entitlementManager)
            }
            .sheet(isPresented: $showThemePicker) { ThemePickerView().environmentObject(settingsStore) }
            .fullScreenCover(isPresented: $showFullScreenClock) { FullScreenClockView().environmentObject(settingsStore) }
            .fullScreenCover(isPresented: $showFlipClock) { FlipClockView().environmentObject(settingsStore) }
            .sheet(isPresented: $showTransparentIntro) { TransparentClockIntroView().environmentObject(settingsStore) }
            .alert(L10n.Home.widgetGuideTitle, isPresented: $showWidgetGuide) {
                Button(L10n.Common.done, role: .cancel) {}
            } message: { Text(L10n.Home.widgetGuideBody) }
            .onReceive(timer) { now = $0 }
        }
    }

    private var brandSection: some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(theme.accentColor.opacity(0.22))
                    .frame(width: 48, height: 48)
                Image(systemName: "clock.fill").font(.title3.weight(.semibold)).foregroundStyle(theme.accentColor)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(L10n.Home.appName).font(.title2.weight(.bold))
                Text(L10n.Home.tagline).font(.subheadline).foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.top, 8)
    }

    private var timePreviewSection: some View {
        let settings = settingsStore.settings
        return JiaCardView(padding: 22) {
            VStack(spacing: 10) {
                Text(L10n.Home.currentTime).font(.caption.weight(.semibold)).foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(ClockTimeFormatter.timeString(from: now, settings: settings))
                    .font(.system(size: 44, weight: .light, design: .rounded))
                    .monospacedDigit().lineLimit(1).minimumScaleFactor(0.6)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if settings.showDate || settings.showWeekday {
                    HStack(spacing: 8) {
                        if settings.showWeekday { Text(ClockTimeFormatter.weekdayString(from: now)) }
                        if settings.showDate { Text(ClockTimeFormatter.dateString(from: now)) }
                    }
                    .font(.subheadline).foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                Text(settingsStore.effectiveTagline).font(.footnote).foregroundStyle(theme.accentColor.opacity(0.95))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .id("\(settings.use24HourFormat)-\(settings.showSeconds)")
        }
    }

    private var featureGridSection: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: columnCount), spacing: 16) {
            HomeFeatureCard(mode: .fullScreen, accent: theme.accentColor) { showFullScreenClock = true }
            HomeFeatureCard(mode: .transparent, accent: theme.accentColor) { showTransparentIntro = true }
            HomeFeatureCard(mode: .flip, accent: theme.accentColor) { showFlipClock = true }
            HomeFeatureCard(mode: .widget, accent: theme.accentColor) { showWidgetGuide = true }
        }
    }

    private var bottomBarSection: some View {
        JiaCardView(padding: 14) {
            HStack(spacing: 12) {
                bottomActionButton(title: L10n.Home.theme, systemImage: "paintpalette.fill") { showThemePicker = true }
                bottomActionButton(title: L10n.Settings.customTagline, systemImage: "text.quote") { showSettings = true }
                bottomActionButton(title: L10n.Home.settings, systemImage: "gearshape.fill") { showSettings = true }
            }
        }
    }

    private func bottomActionButton(title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: systemImage).font(.body.weight(.semibold))
                Text(title).font(.caption).lineLimit(1).minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity).padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }
}
