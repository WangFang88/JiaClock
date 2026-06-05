import SwiftUI

struct TransparentClockIntroView: View {
    @EnvironmentObject private var settingsStore: ClockSettingsStore
    @Environment(\.dismiss) private var dismiss

    @StateObject private var permissionService = CameraPermissionService()
    @State private var showTransparentClock = false
    @State private var showDeniedAlert = false
    @State private var showRestrictedAlert = false
    @State private var showUnavailableAlert = false
    @State private var isRequestingPermission = false

    private var theme: ClockTheme { settingsStore.theme }

    var body: some View {
        NavigationStack {
            ZStack {
                JiaBackgroundView(theme: theme)
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        heroSection
                        valueCard(L10n.Transparent.value1Title, L10n.Transparent.value1Body, "sparkles.rectangle.stack.fill")
                        valueCard(L10n.Transparent.value2Title, L10n.Transparent.value2Body, "iphone.and.arrow.forward")
                        valueCard(L10n.Transparent.permissionTitle, L10n.Transparent.permissionBody, "camera.fill")
                        valueCard(L10n.Transparent.privacyTitle, L10n.Transparent.privacyBody, "lock.shield.fill")
                        valueCard(L10n.Transparent.backgroundStopTitle, L10n.Transparent.backgroundStopBody, "pause.circle.fill")
                        JiaPrimaryButton(title: L10n.Transparent.enableButton, systemImage: "camera.viewfinder") {
                            Task { await enableTransparentClock() }
                        }
                        .disabled(isRequestingPermission)
                        .padding(.top, 8)
                    }
                    .padding(20).frame(maxWidth: 640).frame(maxWidth: .infinity)
                }
            }
            .navigationTitle(L10n.Transparent.title)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) { Button(L10n.Common.close) { dismiss() } }
            }
            .fullScreenCover(isPresented: $showTransparentClock) {
                TransparentClockView().environmentObject(settingsStore)
            }
            .alert(L10n.Transparent.permissionDeniedTitle, isPresented: $showDeniedAlert) {
                Button(L10n.Transparent.openSettings) { permissionService.openSettings() }
                Button(L10n.Common.close, role: .cancel) {}
            } message: { Text(L10n.Transparent.permissionDeniedBody) }
            .alert(L10n.Transparent.permissionRestrictedTitle, isPresented: $showRestrictedAlert) {
                Button(L10n.Common.done, role: .cancel) {}
            } message: { Text(L10n.Transparent.permissionRestrictedBody) }
            .alert(L10n.Transparent.cameraUnavailableTitle, isPresented: $showUnavailableAlert) {
                Button(L10n.Transparent.previewWithoutCamera) { showTransparentClock = true }
                Button(L10n.Common.close, role: .cancel) {}
            } message: { Text(L10n.Transparent.cameraUnavailableBody) }
            .onAppear { permissionService.refreshStatus() }
        }
    }

    private var heroSection: some View {
        JiaCardView(padding: 24) {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: "camera.viewfinder").font(.largeTitle.weight(.semibold)).foregroundStyle(theme.accentColor)
                Text(L10n.Transparent.headline).font(.title2.weight(.bold))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func valueCard(_ title: String, _ body: String, _ icon: String) -> some View {
        JiaCardView {
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: icon).font(.title3.weight(.semibold)).foregroundStyle(theme.accentColor).frame(width: 28)
                VStack(alignment: .leading, spacing: 8) {
                    Text(title).font(.headline.weight(.semibold))
                    Text(body).font(.subheadline).foregroundStyle(.secondary)
                }
            }
        }
    }

    @MainActor
    private func enableTransparentClock() async {
        isRequestingPermission = true
        defer { isRequestingPermission = false }
        if permissionService.isSimulatorOrNoCamera { showUnavailableAlert = true; return }
        switch await permissionService.requestAccessIfNeeded() {
        case .authorized:
            // 权限弹窗关闭后 scene 可能尚未 active，延迟一帧再打开以确保相机可启动
            try? await Task.sleep(nanoseconds: 200_000_000)
            showTransparentClock = true
        case .denied: showDeniedAlert = true
        case .restricted: showRestrictedAlert = true
        case .unavailable: showUnavailableAlert = true
        case .notDetermined: break
        }
    }
}
