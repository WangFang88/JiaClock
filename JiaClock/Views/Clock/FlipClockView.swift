import SwiftUI

struct FlipClockView: View {
    @EnvironmentObject private var settingsStore: ClockSettingsStore
    @Environment(\.dismiss) private var dismiss
    @State private var now = Date.now
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private var theme: ClockTheme { settingsStore.theme }
    private var components: (hour: String, minute: String) {
        ClockTimeFormatter.hourMinuteComponents(from: now, settings: settingsStore.settings)
    }

    var body: some View {
        ZStack {
            JiaBackgroundView(theme: theme)
            VStack(spacing: 28) {
                HStack {
                    Button { dismiss() } label: { controlChip("xmark", L10n.Common.close) }
                    Spacer()
                }.padding(.horizontal, 20).padding(.top, 12)
                Spacer(minLength: 0)
                HStack(spacing: 18) {
                    FlipDigitCard(value: components.hour, label: L10n.Flip.hourLabel, accent: theme.accentColor)
                    Text(":").font(.system(size: 56, weight: .light, design: .rounded)).foregroundStyle(.primary.opacity(0.7)).offset(y: -8)
                    FlipDigitCard(value: components.minute, label: L10n.Flip.minuteLabel, accent: theme.accentColor)
                }.padding(.horizontal, 20)
                VStack(spacing: 8) {
                    if settingsStore.settings.showWeekday { Text(ClockTimeFormatter.weekdayString(from: now)).font(.title3.weight(.medium)).foregroundStyle(.secondary) }
                    if settingsStore.settings.showDate { Text(ClockTimeFormatter.dateString(from: now)).font(.title3).foregroundStyle(.secondary) }
                    Text(settingsStore.effectiveTagline).font(.headline.weight(.medium)).foregroundStyle(theme.accentColor.opacity(0.92))
                }
                Spacer(minLength: 0)
            }
        }
        .onReceive(timer) { now = $0 }
    }

    private func controlChip(_ icon: String, _ title: String) -> some View {
        HStack(spacing: 6) { Image(systemName: icon); Text(title) }
            .font(.subheadline.weight(.semibold))
            .padding(.horizontal, 14).padding(.vertical, 10)
            .background(.ultraThinMaterial, in: Capsule())
    }
}

private struct FlipDigitCard: View {
    @Environment(\.colorScheme) private var colorScheme
    let value: String
    let label: String
    let accent: Color

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(LinearGradient(colors: [Color(red: 0.14, green: 0.14, blue: 0.18), Color(red: 0.08, green: 0.08, blue: 0.12)], startPoint: .top, endPoint: .bottom))
                    .overlay { RoundedRectangle(cornerRadius: 22, style: .continuous).strokeBorder(Color.white.opacity(0.08), lineWidth: 1) }
                    .shadow(color: .black.opacity(0.35), radius: 16, x: 0, y: 10)
                VStack(spacing: 0) {
                    Rectangle().fill(LinearGradient(colors: [Color.white.opacity(colorScheme == .dark ? 0.06 : 0.10), .clear], startPoint: .top, endPoint: .bottom)).frame(height: 60)
                    Rectangle().fill(Color.black.opacity(0.55)).frame(height: 2)
                    Rectangle().fill(Color.black.opacity(0.18)).frame(height: 60)
                }
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                Text(value).font(.system(size: 72, weight: .semibold, design: .rounded)).monospacedDigit().foregroundStyle(.white)
            }
            .frame(maxWidth: 140, minHeight: 120, maxHeight: 140)
            Text(label).font(.caption2.weight(.bold)).foregroundStyle(.secondary).tracking(1.2)
        }
        .frame(maxWidth: .infinity)
    }
}
