import SwiftUI

enum TransparentDisplayMode: String, CaseIterable, Identifiable {
    case glassCard
    case minimalFloating
    var id: String { rawValue }
    var title: String {
        switch self {
        case .glassCard: L10n.Transparent.displayModeGlass
        case .minimalFloating: L10n.Transparent.displayModeMinimal
        }
    }
    var systemImage: String {
        switch self {
        case .glassCard: "rectangle.inset.filled"
        case .minimalFloating: "textformat.size.larger"
        }
    }
}

struct TransparentClockView: View {
    @EnvironmentObject private var settingsStore: ClockSettingsStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase

    @StateObject private var cameraController = CameraSessionController()
    @State private var now = Date.now
    @State private var showControls = true
    @State private var darkOverlayEnabled = true
    @State private var useLightText = true
    @State private var displayMode: TransparentDisplayMode = .glassCard
    @State private var isViewVisible = false
    @State private var shouldResumeCamera = false

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

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
        .onAppear { isViewVisible = true; resumeCameraIfNeeded() }
        .onDisappear { isViewVisible = false; shouldResumeCamera = false; cameraController.stop() }
        .onChange(of: scenePhase) { _, phase in handleScenePhaseChange(phase) }
        .onReceive(timer) { now = $0 }
        .id("\(settings.use24HourFormat)-\(settings.showSeconds)")
        .statusBarHidden(true)
    }

    /// 仅背景层响应点击，用于显示/隐藏控制栏；不与顶部按钮争抢触摸。
    private var interactiveBackground: some View {
        ZStack {
            if cameraController.isCameraAvailable {
                CameraPreviewView(session: cameraController.session).ignoresSafeArea()
            } else {
                unavailableBackground
            }
            if darkOverlayEnabled { Color.black.opacity(0.22).ignoresSafeArea().allowsHitTesting(false) }
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
            switch displayMode {
            case .glassCard:
                GlassMorphClockCard(
                    time: ClockTimeFormatter.timeString(from: now, settings: settings),
                    weekday: settings.showWeekday ? ClockTimeFormatter.weekdayString(from: now) : nil,
                    date: settings.showDate ? ClockTimeFormatter.dateString(from: now) : nil,
                    tagline: settingsStore.effectiveTagline,
                    useLightText: useLightText
                ).padding(.horizontal, 24)
            case .minimalFloating:
                VStack(spacing: 10) {
                    Text(ClockTimeFormatter.timeString(from: now, settings: settings))
                        .font(.system(size: 56, weight: .thin, design: .rounded))
                        .monospacedDigit()
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)
                        .foregroundStyle(useLightText ? .white : Color(red: 0.12, green: 0.12, blue: 0.16))
                    if settings.showWeekday || settings.showDate {
                        VStack(spacing: 4) {
                            if settings.showWeekday {
                                Text(ClockTimeFormatter.weekdayString(from: now))
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(useLightText ? .white.opacity(0.82) : .primary.opacity(0.72))
                            }
                            if settings.showDate {
                                Text(ClockTimeFormatter.dateString(from: now))
                                    .font(.subheadline)
                                    .foregroundStyle(useLightText ? .white.opacity(0.72) : .primary.opacity(0.62))
                            }
                        }
                    }
                    if !settingsStore.effectiveTagline.isEmpty {
                        Text(settingsStore.effectiveTagline)
                            .font(.footnote.weight(.medium))
                            .foregroundStyle(useLightText ? .white.opacity(0.88) : Color(red: 0.12, green: 0.12, blue: 0.16).opacity(0.88))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 8)
                    }
                }
                .padding(.horizontal, 32)
            }
            Spacer(minLength: 0)
        }.allowsHitTesting(false)
    }

    private var controlsBar: some View {
        HStack(spacing: 10) {
            JiaControlChip(icon: "xmark", title: L10n.Common.close) { dismiss() }
            Spacer(minLength: 8)
            JiaControlChip(icon: darkOverlayEnabled ? "moon.fill" : "moon", title: L10n.Transparent.darkOverlay) { darkOverlayEnabled.toggle() }
            Menu {
                Picker(L10n.Transparent.displayMode, selection: $displayMode) {
                    ForEach(TransparentDisplayMode.allCases) { Label($0.title, systemImage: $0.systemImage).tag($0) }
                }
                Button { useLightText.toggle() } label: {
                    Label(useLightText ? L10n.Transparent.useDarkText : L10n.Transparent.useLightText, systemImage: "textformat")
                }
            } label: {
                JiaControlChip(icon: "slider.horizontal.3", title: L10n.Transparent.adjust, action: nil)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial.opacity(0.35))
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
