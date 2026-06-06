import SwiftUI

struct TransparentFlipThemePickerSheet: View {
    @EnvironmentObject private var settingsStore: ClockSettingsStore
    @EnvironmentObject private var entitlements: EntitlementManager
    @EnvironmentObject private var storeKit: StoreKitService
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @State private var showPaywall = false

    private var displayStyle: TransparentClockDisplayStyle {
        settingsStore.settings.transparentClockDisplayStyle
    }

    private var selectedFlipThemeID: String { settingsStore.settings.transparentFlipThemeID }
    private var selectedStackedThemeID: String { settingsStore.settings.stackedFlipThemeID }
    private var selectedBackground: TransparentClockBackgroundStyle {
        settingsStore.settings.transparentClockBackgroundStyle
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    displayModeSection
                    if displayStyle == .transparentFlip {
                        flipThemeSection
                        backgroundSection
                    } else if displayStyle == .stackedFlip {
                        stackedThemeSection
                    } else if displayStyle == .minimalFloating {
                        backgroundSection
                    }
                }
                .padding(20)
            }
            .background(Color(red: 0.08, green: 0.08, blue: 0.10))
            .navigationTitle(L10n.ClockStyleCenter.sheetTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(L10n.Common.done) { dismiss() }
                }
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView(highlightFeature: .premiumThemes)
                    .environmentObject(storeKit)
                    .environmentObject(entitlements)
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Display Mode

    private var displayModeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.Transparent.displayModeSectionTitle)
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.92))

            if horizontalSizeClass == .regular {
                HStack(spacing: 10) {
                    ForEach(TransparentClockDisplayStyle.allCases) { style in
                        displayModeChip(style)
                    }
                }
            } else {
                VStack(spacing: 10) {
                    ForEach(TransparentClockDisplayStyle.allCases) { style in
                        displayModeChip(style)
                    }
                }
            }
        }
    }

    private func displayModeChip(_ style: TransparentClockDisplayStyle) -> some View {
        let isSelected = displayStyle == style
        let clockStyle = clockDisplayStyle(for: style)
        let locked = clockStyle.isProStyle && !entitlements.isPro
        return Button {
            if locked {
                showPaywall = true
                return
            }
            ClockStyleRouter.applySelection(
                clockStyle,
                settingsStore: settingsStore,
                isPro: entitlements.isPro,
                scene: .transparentClock
            )
        } label: {
            HStack(spacing: 10) {
                Image(systemName: style.systemImage)
                    .font(.body.weight(.medium))
                    .foregroundStyle(isSelected ? Color(red: 0.98, green: 0.62, blue: 0.42) : .white.opacity(0.65))
                    .frame(width: 24)
                Text(style.title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.88))
                Spacer(minLength: 0)
                if clockStyle.isProStyle { ProBadgeView(compact: true) }
                if locked {
                    Image(systemName: "lock.fill")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.55))
                }
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color(red: 0.98, green: 0.62, blue: 0.42))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white.opacity(isSelected ? 0.12 : 0.06))
                    .overlay {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(isSelected ? Color.white.opacity(0.35) : Color.white.opacity(0.08), lineWidth: 1)
                    }
            }
        }
        .buttonStyle(.plain)
    }

    private func clockDisplayStyle(for style: TransparentClockDisplayStyle) -> ClockDisplayStyle {
        switch style {
        case .transparentFlip: .transparentFlip
        case .stackedFlip: .stackedFlip
        case .minimalFloating: .minimalFloating
        }
    }

    // MARK: - Transparent Flip Themes

    private var flipThemeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.Transparent.flipThemeSectionTitle)
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.92))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(TransparentFlipThemeLibrary.all) { theme in
                        flipThemeCard(theme)
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }

    private func flipThemeCard(_ theme: TransparentFlipTheme) -> some View {
        let isSelected = selectedFlipThemeID == theme.id
        let locked = theme.isPro && !entitlements.isPro

        return Button {
            selectFlipTheme(theme)
        } label: {
            VStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: theme.previewGradient,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: cardPreviewWidth, height: 88)
                    TransparentFlipThemePreviewClock(theme: theme)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(isSelected ? Color.white.opacity(0.85) : Color.white.opacity(0.12), lineWidth: isSelected ? 2 : 1)
                }

                HStack(spacing: 6) {
                    Text(theme.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.92))
                        .lineLimit(1)
                    if theme.isPro { ProBadgeView(compact: true) }
                    if locked {
                        Image(systemName: "lock.fill")
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.55))
                    }
                }
            }
            .frame(width: cardPreviewWidth)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Stacked Flip Themes

    private var stackedThemeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.Transparent.stackedThemeSectionTitle)
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.92))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(StackedFlipThemeLibrary.all) { theme in
                        stackedThemeCard(theme)
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }

    private func stackedThemeCard(_ theme: StackedFlipTheme) -> some View {
        let isSelected = selectedStackedThemeID == theme.id
        let locked = theme.isPro && !entitlements.isPro

        return Button {
            selectStackedTheme(theme)
        } label: {
            VStack(spacing: 10) {
                StackedFlipThemePreview(theme: theme)
                    .frame(width: cardPreviewWidth, height: 88)
                    .overlay {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .strokeBorder(isSelected ? Color.white.opacity(0.85) : Color.clear, lineWidth: 2)
                    }

                HStack(spacing: 6) {
                    Text(theme.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.92))
                        .lineLimit(1)
                    if theme.isPro { ProBadgeView(compact: true) }
                    if locked {
                        Image(systemName: "lock.fill")
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.55))
                    }
                }
            }
            .frame(width: cardPreviewWidth)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Background

    private var backgroundSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.Transparent.flipBackgroundSectionTitle)
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.92))

            if horizontalSizeClass == .regular {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    ForEach(TransparentClockBackgroundStyle.allCases) { style in
                        backgroundChip(style)
                    }
                }
            } else {
                VStack(spacing: 10) {
                    ForEach(TransparentClockBackgroundStyle.allCases) { style in
                        backgroundChip(style)
                    }
                }
            }
        }
    }

    private func backgroundChip(_ style: TransparentClockBackgroundStyle) -> some View {
        let isSelected = selectedBackground == style
        let locked = style.isPro && !entitlements.isPro

        return Button {
            selectBackground(style)
        } label: {
            HStack(spacing: 10) {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.clear)
                    .background { backgroundSwatch(for: style) }
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .frame(width: 36, height: 28)
                    .overlay {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.18), lineWidth: 0.5)
                    }
                Text(style.title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.88))
                Spacer(minLength: 0)
                if style.isPro { ProBadgeView(compact: true) }
                if locked {
                    Image(systemName: "lock.fill").font(.caption).foregroundStyle(.white.opacity(0.5))
                }
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color(red: 0.98, green: 0.62, blue: 0.42))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white.opacity(isSelected ? 0.12 : 0.06))
                    .overlay {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(isSelected ? Color.white.opacity(0.35) : Color.white.opacity(0.08), lineWidth: 1)
                    }
            }
        }
        .buttonStyle(.plain)
    }

    private var cardPreviewWidth: CGFloat {
        horizontalSizeClass == .regular ? 168 : 148
    }

    private func selectFlipTheme(_ theme: TransparentFlipTheme) {
        if theme.isPro, !entitlements.isPro {
            showPaywall = true
            return
        }
        settingsStore.update {
            $0.transparentFlipThemeID = theme.id
            $0.transparentClockBackgroundStyle = theme.suggestedBackground
        }
    }

    private func selectStackedTheme(_ theme: StackedFlipTheme) {
        if theme.isPro, !entitlements.isPro {
            showPaywall = true
            return
        }
        settingsStore.update { $0.stackedFlipThemeID = theme.id }
    }

    private func selectBackground(_ style: TransparentClockBackgroundStyle) {
        if style.isPro, !entitlements.isPro {
            showPaywall = true
            return
        }
        settingsStore.update { $0.transparentClockBackgroundStyle = style }
    }

    @ViewBuilder
    private func backgroundSwatch(for style: TransparentClockBackgroundStyle) -> some View {
        switch style {
        case .cameraOnly:
            LinearGradient(colors: [.gray.opacity(0.3), .gray.opacity(0.5)], startPoint: .top, endPoint: .bottom)
        case .softDark:
            Color.black.opacity(0.45)
        case .warmSunset:
            LinearGradient(colors: [Color.orange.opacity(0.7), Color.pink.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .deepNight:
            LinearGradient(colors: [Color(red: 0.08, green: 0.10, blue: 0.22), Color.black], startPoint: .top, endPoint: .bottom)
        case .aurora:
            LinearGradient(colors: [Color.blue.opacity(0.6), Color.green.opacity(0.5), Color.purple.opacity(0.6)], startPoint: .leading, endPoint: .trailing)
        case .cleanLight:
            LinearGradient(colors: [Color.white.opacity(0.85), Color(red: 0.92, green: 0.94, blue: 0.98)], startPoint: .top, endPoint: .bottom)
        }
    }
}
