import SwiftUI

struct WidgetGuideView: View {
    @EnvironmentObject private var settingsStore: ClockSettingsStore
    @Environment(\.dismiss) private var dismiss

    private var theme: ClockTheme { settingsStore.theme }

    var body: some View {
        NavigationStack {
            ZStack {
                JiaBackgroundView(theme: theme)
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 22) {
                        heroSection
                        stepCard(number: 1, icon: "hand.tap.fill", title: L10n.WidgetGuide.step1Title, body: L10n.WidgetGuide.step1Body)
                        stepCard(number: 2, icon: "plus.circle.fill", title: L10n.WidgetGuide.step2Title, body: L10n.WidgetGuide.step2Body)
                        stepCard(number: 3, icon: "magnifyingglass", title: L10n.WidgetGuide.step3Title, body: L10n.WidgetGuide.step3Body)
                        stepCard(number: 4, icon: "square.grid.3x3.fill", title: L10n.WidgetGuide.step4Title, body: L10n.WidgetGuide.step4Body)
                        noteCard
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 24)
                    .frame(maxWidth: 640)
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle(L10n.WidgetGuide.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(L10n.Common.done) { dismiss() }
                }
            }
        }
    }

    private var heroSection: some View {
        JiaCardView(padding: 22) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(theme.accentColor.opacity(0.18))
                            .frame(width: 52, height: 52)
                        Image(systemName: "rectangle.on.rectangle.angled")
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(theme.accentColor)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text(L10n.WidgetGuide.headline)
                            .font(.title3.weight(.bold))
                        Text(L10n.WidgetGuide.subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                widgetPreviewMock
            }
        }
    }

    private var widgetPreviewMock: some View {
        HStack(spacing: 12) {
            widgetMock(size: .small)
            widgetMock(size: .medium)
        }
        .padding(.top, 4)
    }

    private enum MockSize { case small, medium }

    private func widgetMock(size: MockSize) -> some View {
        let isSmall = size == .small
        return VStack(alignment: .leading, spacing: isSmall ? 6 : 8) {
            HStack(spacing: 5) {
                Circle().fill(theme.accentColor.opacity(0.85)).frame(width: 6, height: 6)
                Text(L10n.Home.appName).font(.system(size: 9, weight: .semibold)).foregroundStyle(.white.opacity(0.7))
            }
            Spacer(minLength: 0)
            Text("10:28")
                .font(.system(size: isSmall ? 22 : 28, weight: .ultraLight, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.white)
            if !isSmall {
                Text(L10n.WidgetGuide.mockDate)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.white.opacity(0.65))
            }
        }
        .padding(isSmall ? 10 : 12)
        .frame(width: isSmall ? 88 : 148, height: isSmall ? 88 : 88)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: theme.gradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                }
        }
    }

    private func stepCard(number: Int, icon: String, title: String, body: String) -> some View {
        JiaCardView(padding: 16) {
            HStack(alignment: .top, spacing: 14) {
                ZStack {
                    Circle()
                        .fill(theme.accentColor.opacity(0.16))
                        .frame(width: 36, height: 36)
                    Text("\(number)")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(theme.accentColor)
                }
                VStack(alignment: .leading, spacing: 6) {
                    Label(title, systemImage: icon)
                        .font(.subheadline.weight(.semibold))
                    Text(body)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    private var noteCard: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "info.circle.fill")
                .foregroundStyle(theme.accentColor.opacity(0.9))
            Text(L10n.WidgetGuide.refreshNote)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.primary.opacity(0.04))
        }
    }
}
