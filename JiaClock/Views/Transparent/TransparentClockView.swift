import SwiftUI

struct TransparentClockView: View {
    @EnvironmentObject private var settingsStore: ClockSettingsStore
    @EnvironmentObject private var entitlements: EntitlementManager
    @EnvironmentObject private var storeKit: StoreKitService
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase

    @StateObject private var cameraController = CameraSessionController()
    @State private var now = Date.now
    @State private var showControls = true
    @State private var darkOverlayEnabled = false
    @State private var useLightText = true
    @State private var showThemePicker = false
    @State private var showStyleCenter = false
    @State private var showPaywall = false
    @State private var isViewVisible = false
    @State private var shouldResumeCamera = false

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var displayStyle: TransparentClockDisplayStyle {
        settingsStore.settings.transparentClockDisplayStyle
    }

    private var flipTheme: TransparentFlipTheme {
        TransparentFlipThemeLibrary.theme(id: settingsStore.settings.transparentFlipThemeID)
    }

    private var stackedTheme: StackedFlipTheme {
        StackedFlipThemeLibrary.theme(id: settingsStore.settings.stackedFlipThemeID)
    }

    private var backgroundStyle: TransparentClockBackgroundStyle {
        settingsStore.settings.transparentClockBackgroundStyle
    }

    var body: some View {
        let settings = settingsStore.settings
        return ZStack {
            interactiveBackground
            clockOverlay(settings: settings)
        }
        .ignoresSafeArea()
        .safeAreaInset(edge: .top, spacing: 0) {
            if showControls {
                controlsBar
            }
        }
        .onAppear {
            isViewVisible = true
            settingsStore.enforceAccessibleClockStyle(isPro: entitlements.isPro)
            resumeCameraIfNeeded()
        }
        .onDisappear { isViewVisible = false; shouldResumeCamera = false; cameraController.stop() }
        .onChange(of: scenePhase) { _, phase in handleScenePhaseChange(phase) }
        .onChange(of: entitlements.isPro) { _, isPro in
            settingsStore.enforceAccessibleClockStyle(isPro: isPro)
        }
        .onReceive(timer) { now = $0 }
        .statusBarHidden(true)
        .sheet(isPresented: $showThemePicker) {
            TransparentFlipThemePickerSheet()
                .environmentObject(settingsStore)
                .environmentObject(entitlements)
                .environmentObject(storeKit)
        }
        .sheet(isPresented: $showStyleCenter) {
            ClockStyleCenterView(mode: .sheet)
                .environmentObject(settingsStore)
                .environmentObject(entitlements)
                .environmentObject(storeKit)
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(highlightFeature: .transparentClockAdvanced)
                .environmentObject(storeKit)
                .environmentObject(entitlements)
        }
    }

    private var interactiveBackground: some View {
        ZStack {
            if cameraController.isCameraAvailable {
                CameraPreviewView(session: cameraController.session).ignoresSafeArea()
            } else {
                unavailableBackground
            }
            TransparentClockAtmosphereOverlay(style: backgroundStyle, extraDimEnabled: darkOverlayEnabled)
            if displayStyle == .stackedFlip {
                StackedFlipAtmosphereOverlay(theme: stackedTheme)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { withAnimation(.easeInOut(duration: 0.2)) { showControls.toggle() } }
    }

    private var unavailableBackground: some View {
        ZStack {
            LinearGradient(colors: [Color(red: 0.08, green: 0.10, blue: 0.14), Color(red: 0.14, green: 0.16, blue: 0.22)], startPoint: .topLeading, endPoint: .bottomTrailing)
            VStack(spacing: 12) {
                Image(systemName: "camera.fill").font(.largeTitle).foregroundStyle(.white.opacity(0.6))
                Text(L10n.Transparent.cameraUnavailableTitle).font(.headline).foregroundStyle(.white.opacity(0.88))
                Text(L10n.Transparent.cameraUnavailableBody).font(.subheadline).foregroundStyle(.white.opacity(0.65)).multilineTextAlignment(.center).padding(.horizontal, 32)
            }
        }.ignoresSafeArea()
    }

    @ViewBuilder
    private func clockOverlay(settings: ClockSettings) -> some View {
        VStack {
            Spacer(minLength: 0)
            switch displayStyle {
            case .transparentFlip:
                TransparentFlipClockView(
                    date: now,
                    settings: settings,
                    tagline: settingsStore.effectiveTagline,
                    flipTheme: flipTheme,
                    useLightText: useLightText
                )
                .padding(.horizontal, 16)
            case .stackedFlip:
                StackedFlipClockView(
                    date: now,
                    settings: settings,
                    tagline: settingsStore.effectiveTagline,
                    theme: stackedTheme,
                    useLightText: useLightText
                )
                .padding(.horizontal, 16)
            case .minimalFloating:
                VStack(spacing: 10) {
                    Text(ClockTimeFormatter.timeString(from: now, settings: settings))
                        .font(.system(size: 56, weight: .thin, design: .rounded))
                        .monospacedDigit()
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)
                        .foregroundStyle(useLightText ? .white : Color(red: 0.12, green: 0.12, blue: 0.16))
                        .shadow(color: .black.opacity(0.45), radius: 10, x: 0, y: 3)
                    if settings.showWeekday || settings.showDate {
                        VStack(spacing: 4) {
                            if settings.showWeekday {
                                Text(ClockTimeFormatter.weekdayString(from: now))
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(useLightText ? .white.opacity(0.88) : .primary.opacity(0.72))
                                    .shadow(color: .black.opacity(0.35), radius: 6, x: 0, y: 2)
                            }
                            if settings.showDate {
                                Text(ClockTimeFormatter.dateString(from: now))
                                    .font(.subheadline)
                                    .foregroundStyle(useLightText ? .white.opacity(0.82) : .primary.opacity(0.62))
                                    .shadow(color: .black.opacity(0.35), radius: 6, x: 0, y: 2)
                            }
                        }
                    }
                    if !settingsStore.effectiveTagline.isEmpty {
                        Text(settingsStore.effectiveTagline)
                            .font(.footnote.weight(.medium))
                            .foregroundStyle(useLightText ? .white.opacity(0.82) : Color(red: 0.12, green: 0.12, blue: 0.16).opacity(0.88))
                            .multilineTextAlignment(.center)
                            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 1)
                            .padding(.horizontal, 8)
                    }
                }
                .padding(.horizontal, 32)
            }
            Spacer(minLength: 0)
        }.allowsHitTesting(false)
    }

    private var controlsBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                JiaControlChip(icon: "xmark", title: L10n.Common.close) { dismiss() }
                Spacer(minLength: 8)
                JiaControlChip(icon: "paintpalette.fill", title: L10n.Transparent.flipThemeButton) {
                    showThemePicker = true
                }
                JiaControlChip(icon: "square.grid.2x2", title: L10n.ClockStyleCenter.entryButton) {
                    showStyleCenter = true
                }
                JiaControlChip(icon: showControls ? "eye.slash" : "eye", title: L10n.Transparent.hideControls) {
                    withAnimation(.easeInOut(duration: 0.2)) { showControls = false }
                }
                JiaControlChip(icon: darkOverlayEnabled ? "moon.fill" : "moon", title: L10n.Transparent.darkOverlay) { darkOverlayEnabled.toggle() }
                Menu {
                    transparentStyleButton(.transparentFlip)
                    transparentStyleButton(.stackedFlip)
                    transparentStyleButton(.minimalFloating)
                    Button { useLightText.toggle() } label: {
                        Label(useLightText ? L10n.Transparent.useDarkText : L10n.Transparent.useLightText, systemImage: "textformat")
                    }
                } label: {
                    JiaControlChip(icon: "slider.horizontal.3", title: L10n.Transparent.adjust, action: nil)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    @ViewBuilder
    private func transparentStyleButton(_ style: ClockDisplayStyle) -> some View {
        Button {
            if style.isProStyle, !entitlements.isPro {
                showPaywall = true
                return
            }
            ClockStyleRouter.applySelection(style, settingsStore: settingsStore)
        } label: {
            Label(style.title, systemImage: style.systemImage)
        }
    }

    private func handleScenePhaseChange(_ phase: ScenePhase) {
        switch phase {
        case .active:
            if isViewVisible { resumeCameraIfNeeded() }
        case .inactive, .background:
            shouldResumeCamera = isViewVisible && cameraController.isCameraAvailable
            cameraController.stop()
        @unknown default: cameraController.stop()
        }
    }

    private func resumeCameraIfNeeded() {
        guard isViewVisible, scenePhase == .active, cameraController.isCameraAvailable else { return }
        cameraController.start()
        shouldResumeCamera = false
    }
}
