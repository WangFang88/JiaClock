import SwiftUI
import UIKit

struct FullScreenClockView: View {
    @EnvironmentObject private var settingsStore: ClockSettingsStore
    @Environment(\.dismiss) private var dismiss
    @State private var now = Date.now
    @State private var showControls = true
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private var theme: ClockTheme { settingsStore.theme }

    var body: some View {
        ZStack {
            JiaBackgroundView(theme: theme)
            VStack(spacing: 18) {
                Spacer(minLength: 0)
                Text(ClockTimeFormatter.timeString(from: now, settings: settingsStore.settings))
                    .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 120 : 84, weight: .ultraLight, design: .rounded))
                    .monospacedDigit().minimumScaleFactor(0.5).lineLimit(1)
                if settingsStore.settings.showDate || settingsStore.settings.showWeekday {
                    VStack(spacing: 6) {
                        if settingsStore.settings.showWeekday {
                            Text(ClockTimeFormatter.weekdayString(from: now)).font(.title3.weight(.medium)).foregroundStyle(.secondary)
                        }
                        if settingsStore.settings.showDate {
                            Text(ClockTimeFormatter.dateString(from: now)).font(.title3).foregroundStyle(.secondary)
                        }
                    }
                }
                Text(settingsStore.effectiveTagline).font(.headline.weight(.medium)).foregroundStyle(theme.accentColor.opacity(0.92))
                Spacer(minLength: 0)
            }
            .contentShape(Rectangle())
            .onTapGesture { withAnimation(.easeInOut(duration: 0.2)) { showControls.toggle() } }
            if showControls {
                VStack {
                    HStack {
                        Button { dismiss() } label: { controlChip("xmark", L10n.Common.close) }
                        Spacer()
                    }.padding(.horizontal, 20).padding(.top, 12)
                    Spacer()
                }.transition(.opacity)
            }
        }
        .statusBarHidden(!showControls)
        .onReceive(timer) { now = $0 }
    }

    private func controlChip(_ icon: String, _ title: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
            Text(title)
        }
        .font(.subheadline.weight(.semibold))
        .padding(.horizontal, 14).padding(.vertical, 10)
        .background(.ultraThinMaterial, in: Capsule())
    }
}
