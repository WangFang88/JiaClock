import SwiftUI

struct ClockStyleCenterView: View {
    enum PresentationMode {
        case page
        case sheet
    }

    enum StylePickerScene {
        case all
        case deskClock
        case transparentClock
    }

    @EnvironmentObject private var settingsStore: ClockSettingsStore
    @EnvironmentObject private var entitlements: EntitlementManager
    @EnvironmentObject private var storeKit: StoreKitService
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    let mode: PresentationMode
    let scene: StylePickerScene
    var onLaunch: ((ClockStyleLaunchDestination) -> Void)?

    @StateObject private var cameraPermission = CameraPermissionService()
    @State private var showPaywall = false

    private var theme: ClockTheme { settingsStore.theme }
    private var selectedStyle: ClockDisplayStyle { settingsStore.settings.clockDisplayStyle }

    private var gridColumns: [GridItem] {
        let count = horizontalSizeClass == .regular ? 3 : 2
        return Array(repeating: GridItem(.flexible(), spacing: 16), count: count)
    }

    init(
        mode: PresentationMode = .page,
        scene: StylePickerScene = .all,
        onLaunch: ((ClockStyleLaunchDestination) -> Void)? = nil
    ) {
        self.mode = mode
        self.scene = scene
        self.onLaunch = onLaunch
    }

    var body: some View {
        NavigationStack {
            ZStack {
                JiaBackgroundView(theme: theme)
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 28) {
                        headerSection
                        if scene == .all || scene == .deskClock {
                            styleSection(
                                title: L10n.ClockStyleCenter.fullscreenSectionTitle,
                                subtitle: L10n.ClockStyleCenter.fullscreenSectionSubtitle,
                                styles: ClockDisplayStyle.fullscreenCenterStyles
                            )
                        }
                        if scene == .all || scene == .transparentClock {
                            styleSection(
                                title: L10n.ClockStyleCenter.transparentSectionTitle,
                                subtitle: L10n.ClockStyleCenter.transparentSectionSubtitle,
                                styles: ClockDisplayStyle.transparentCenterStyles
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 32)
                    .frame(maxWidth: 980)
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle(mode == .sheet ? L10n.ClockStyleCenter.sheetTitle : L10n.ClockStyleCenter.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(mode == .sheet ? L10n.Common.done : L10n.Common.close) { dismiss() }
                }
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView(highlightFeature: .premiumThemes)
                    .environmentObject(storeKit)
                    .environmentObject(entitlements)
            }
            .onAppear {
                cameraPermission.refreshStatus()
                settingsStore.enforceAccessibleClockStyle(isPro: entitlements.isPro)
            }
            .onChange(of: entitlements.isPro) { _, isPro in
                settingsStore.enforceAccessibleClockStyle(isPro: isPro)
            }
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            if mode == .page {
                Text(L10n.ClockStyleCenter.title)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(theme.primaryTextColor)
            }
            Text(L10n.ClockStyleCenter.subtitle)
                .font(.subheadline)
                .foregroundStyle(theme.secondaryTextColor)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 4)
    }

    private func styleSection(title: String, subtitle: String, styles: [ClockDisplayStyle]) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(theme.primaryTextColor)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(theme.secondaryTextColor)
            }
            LazyVGrid(columns: gridColumns, spacing: 16) {
                ForEach(styles) { style in
                    ClockStylePreviewCard(
                        style: style,
                        isSelected: selectedStyle == style,
                        isLocked: style.isProStyle && !entitlements.isPro,
                        accent: theme.accentColor
                    ) {
                        selectStyle(style)
                    }
                }
            }
        }
    }

    private func selectStyle(_ style: ClockDisplayStyle) {
        if style.isProStyle, !entitlements.isPro {
            showPaywall = true
            return
        }

        ClockStyleRouter.applySelection(
            style,
            settingsStore: settingsStore,
            isPro: entitlements.isPro,
            scene: applyScene(for: style)
        )

        guard let onLaunch else {
            if mode == .sheet { dismiss() }
            return
        }

        let destination = ClockStyleRouter.launchDestination(
            for: style,
            cameraStatus: cameraPermission.status
        )
        dismiss()
        onLaunch(destination)
    }

    private func applyScene(for style: ClockDisplayStyle) -> ClockStyleScene {
        switch scene {
        case .deskClock:
            return .deskClock
        case .transparentClock:
            return .transparentClock
        case .all:
            return style.isTransparentCategory ? .transparentClock : .deskClock
        }
    }
}
