import SwiftUI

struct ThemePickerView: View {
    @EnvironmentObject private var settingsStore: ClockSettingsStore
    @EnvironmentObject private var entitlements: EntitlementManager
    @EnvironmentObject private var storeKit: StoreKitService
    @Environment(\.dismiss) private var dismiss
    @State private var showPaywall = false

    private var theme: ClockTheme { settingsStore.theme }

    var body: some View {
        NavigationStack {
            ZStack {
                JiaBackgroundView(theme: theme)
                ScrollView {
                    VStack(spacing: 14) {
                        ForEach(ClockTheme.allCases) { item in
                            Button { selectTheme(item) } label: { themeRow(item) }
                                .buttonStyle(.plain)
                        }
                    }
                    .padding(20)
                    .frame(maxWidth: 640)
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle(L10n.Theme.pickerTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(L10n.Common.done) { dismiss() }
                        .font(.body.weight(.medium))
                        .foregroundStyle(theme.accentColor)
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .sheet(isPresented: $showPaywall) {
                PaywallView(highlightFeature: .premiumThemes)
                    .environmentObject(storeKit)
                    .environmentObject(entitlements)
            }
            .onChange(of: showPaywall) { _, isShowing in
                if !isShowing {
                    Task { await entitlements.refreshEntitlements() }
                }
            }
        }
    }

    private func selectTheme(_ item: ClockTheme) {
        if item.requiresPro, !entitlements.hasAccess(to: .premiumThemes) {
            showPaywall = true
            return
        }
        settingsStore.theme = item
    }

    private func themeRow(_ item: ClockTheme) -> some View {
        let isSelected = settingsStore.theme == item
        return JiaCardView(theme: theme, padding: 14) {
            HStack(spacing: 14) {
                ThemePreviewSwatch(theme: item)
                    .frame(width: 72, height: 72)
                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 8) {
                        Text(item.title)
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(theme.primaryTextColor)
                        if item.requiresPro { ProBadgeView(compact: true) }
                    }
                    Text(item.description)
                        .font(.caption)
                        .foregroundStyle(theme.secondaryTextColor)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 8)
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(item.accentColor)
                } else if item.requiresPro, !entitlements.hasAccess(to: .premiumThemes) {
                    Image(systemName: "lock.fill")
                        .font(.subheadline)
                        .foregroundStyle(theme.secondaryTextColor)
                }
            }
        }
        .overlay {
            if isSelected {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(item.accentColor.opacity(0.55), lineWidth: 1.2)
            }
        }
    }
}

private struct ThemePreviewSwatch: View {
    let theme: ClockTheme

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: theme.gradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            RadialGradient(
                colors: [theme.accentColor.opacity(0.35), .clear],
                center: theme.glowCenter,
                startRadius: 4,
                endRadius: 48
            )
            VStack(spacing: 4) {
                Text("10:28")
                    .font(.system(size: 15, weight: .ultraLight, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(theme.isLightTheme ? theme.primaryTextColor : .white)
                Capsule()
                    .fill(theme.accentColor.opacity(0.75))
                    .frame(width: 28, height: 3)
            }
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(theme.cardBorder, lineWidth: 0.6)
        }
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
