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
        ZStack {
            if cameraController.isCameraAvailable {
                CameraPreviewView(session: cameraController.session).ignoresSafeArea()
            } else {
                unavailableBackground
            }
            if darkOverlayEnabled { Color.black.opacity(0.22).ignoresSafeArea().allowsHitTesting(false) }
            clockOverlay
            if showControls { controlsOverlay.transition(.opacity) }
        }
        .ignoresSafeArea()
        .contentShape(Rectangle())
        .onTapGesture { withAnimation(.easeInOut(duration: 0.2)) { showControls.toggle() } }
        .onAppear { isViewVisible = true; resumeCameraIfNeeded() }
        .onDisappear { isViewVisible = false; shouldResumeCamera = false; cameraController.stop() }
        .onChange(of: scenePhase) { phase in handleScenePhaseChange(phase) }
        .onReceive(timer) { now = $0 }
        .statusBarHidden(!showControls)
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
    private var clockOverlay: some View {
        VStack {
            Spacer(minLength: 0)
            switch displayMode {
            case .glassCard:
                GlassMorphClockCard(
                    time: ClockTimeFormatter.timeString(from: now, settings: settingsStore.settings),
                    weekday: settingsStore.settings.showWeekday ? ClockTimeFormatter.weekdayString(from: now) : nil,
                    date: settingsStore.settings.showDate ? ClockTimeFormatter.dateString(from: now) : nil,
                    tagline: settingsStore.effectiveTagline,
                    useLightText: useLightText
                ).padding(.horizontal, 24)
            case .minimalFloating:
                VStack(spacing: 10) {
                    Text(ClockTimeFormatter.timeString(from: now, settings: settingsStore.settings))
                        .font(.system(size: 56, weight: .thin, design: .rounded)).monospacedDigit()
                        .foregroundStyle(useLightText ? .white : Color(red: 0.12, green: 0.12, blue: 0.16))
                    if settingsStore.settings.showWeekday {
                        Text(ClockTimeFormatter.weekdayString(from: now)).font(.subheadline.weight(.medium)).foregroundStyle(useLightText ? .white.opacity(0.82) : .primary.opacity(0.72))
                    }
                }.padding(.horizontal, 32)
            }
            Spacer(minLength: 0)
        }.allowsHitTesting(false)
    }

    private var controlsOverlay: some View {
        VStack {
            HStack(spacing: 10) {
                controlChip("xmark", L10n.Common.close) { dismiss() }
                Spacer()
                controlChip(darkOverlayEnabled ? "moon.fill" : "moon", L10n.Transparent.darkOverlay) { darkOverlayEnabled.toggle() }
                Menu {
                    Picker(L10n.Transparent.displayMode, selection: $displayMode) {
                        ForEach(TransparentDisplayMode.allCases) { Label($0.title, systemImage: $0.systemImage).tag($0) }
                    }
                    Button { useLightText.toggle() } label: {
                        Label(useLightText ? L10n.Transparent.useDarkText : L10n.Transparent.useLightText, systemImage: "textformat")
                    }
                } label: { controlChipLabel("slider.horizontal.3", L10n.Transparent.adjust) }
            }.padding(.horizontal, 20).padding(.top, 12)
            Spacer()
        }
    }

    private func controlChip(_ icon: String, _ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) { controlChipLabel(icon, title) }.buttonStyle(.plain)
    }

    private func controlChipLabel(_ icon: String, _ title: String) -> some View {
        HStack(spacing: 6) { Image(systemName: icon); Text(title) }
            .font(.subheadline.weight(.semibold)).padding(.horizontal, 14).padding(.vertical, 10)
            .background(.ultraThinMaterial, in: Capsule())
            .overlay { Capsule().strokeBorder(Color.white.opacity(0.22), lineWidth: 1) }
    }

    private func handleScenePhaseChange(_ phase: ScenePhase) {
        switch phase {
        case .active: if isViewVisible, shouldResumeCamera { resumeCameraIfNeeded() }
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
