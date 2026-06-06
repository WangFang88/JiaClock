import SwiftUI

// MARK: - 背景氛围（叠加于摄像头画面上，透明度受控）

enum TransparentClockBackgroundStyle: String, Codable, CaseIterable, Identifiable {
    case cameraOnly
    case softDark
    case warmSunset
    case deepNight
    case aurora
    case cleanLight

    var id: String { rawValue }

    var isPro: Bool { self == .aurora }

    var title: String {
        switch self {
        case .cameraOnly: L10n.Transparent.bgCameraOnly
        case .softDark: L10n.Transparent.bgSoftDark
        case .warmSunset: L10n.Transparent.bgWarmSunset
        case .deepNight: L10n.Transparent.bgDeepNight
        case .aurora: L10n.Transparent.bgAurora
        case .cleanLight: L10n.Transparent.bgCleanLight
        }
    }
}

/// 摄像头画面上的轻量氛围层；不替代相机预览。
struct TransparentClockAtmosphereOverlay: View {
    let style: TransparentClockBackgroundStyle
    let extraDimEnabled: Bool

    var body: some View {
        ZStack {
            atmosphereLayer(for: style)
            if extraDimEnabled {
                Color.black.opacity(0.06).ignoresSafeArea()
            }
        }
        .allowsHitTesting(false)
    }

    @ViewBuilder
    private func atmosphereLayer(for style: TransparentClockBackgroundStyle) -> some View {
        switch style {
        case .cameraOnly:
            Color.clear.ignoresSafeArea()
        case .softDark:
            Color.black.opacity(0.08).ignoresSafeArea()
        case .warmSunset:
            LinearGradient(
                colors: [
                    Color(red: 0.98, green: 0.55, blue: 0.32).opacity(0.20),
                    Color(red: 0.96, green: 0.42, blue: 0.58).opacity(0.14),
                    Color(red: 0.92, green: 0.68, blue: 0.38).opacity(0.10),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        case .deepNight:
            LinearGradient(
                colors: [
                    Color(red: 0.04, green: 0.06, blue: 0.18).opacity(0.24),
                    Color(red: 0.08, green: 0.10, blue: 0.22).opacity(0.18),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        case .aurora:
            LinearGradient(
                colors: [
                    Color(red: 0.22, green: 0.52, blue: 0.88).opacity(0.18),
                    Color(red: 0.38, green: 0.82, blue: 0.72).opacity(0.14),
                    Color(red: 0.58, green: 0.38, blue: 0.92).opacity(0.16),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        case .cleanLight:
            LinearGradient(
                colors: [
                    Color.white.opacity(0.16),
                    Color(red: 0.94, green: 0.96, blue: 1.0).opacity(0.12),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
    }
}

// MARK: - 透明翻页主题

struct TransparentFlipTheme: Identifiable, Equatable {
    let id: String
    let isPro: Bool
    let suggestedBackground: TransparentClockBackgroundStyle
    let cardGradient: [Color]
    let cardMaterialOpacity: Double
    let digitColor: Color
    let secondaryTextColor: Color
    let taglineTextColor: Color
    let borderColor: Color
    let dividerColor: Color
    let shadowColor: Color
    let glowColor: Color
    let colonColor: Color
    let highlightTop: Color
    let highlightBottom: Color
    let metadataCapsuleFill: Color
    let previewGradient: [Color]

    var title: String { TransparentFlipThemeLibrary.title(for: id) }

    static func == (lhs: TransparentFlipTheme, rhs: TransparentFlipTheme) -> Bool {
        lhs.id == rhs.id
    }
}

enum TransparentFlipThemeLibrary {
    static let defaultThemeID = "glassWhite"

    static let all: [TransparentFlipTheme] = [
        glassWhite, midnightBlack, sunsetOrange,
        sakuraPink, creamBeige, skyBlue, forestGreen, neonPurple,
    ]

    static func theme(id: String) -> TransparentFlipTheme {
        all.first { $0.id == id } ?? glassWhite
    }

    static func title(for id: String) -> String {
        switch id {
        case "glassWhite": L10n.Transparent.flipThemeGlassWhite
        case "midnightBlack": L10n.Transparent.flipThemeMidnightBlack
        case "sunsetOrange": L10n.Transparent.flipThemeSunsetOrange
        case "sakuraPink": L10n.Transparent.flipThemeSakuraPink
        case "creamBeige": L10n.Transparent.flipThemeCreamBeige
        case "skyBlue": L10n.Transparent.flipThemeSkyBlue
        case "forestGreen": L10n.Transparent.flipThemeForestGreen
        case "neonPurple": L10n.Transparent.flipThemeNeonPurple
        default: L10n.Transparent.flipThemeGlassWhite
        }
    }

    // MARK: Free

    static let glassWhite = TransparentFlipTheme(
        id: "glassWhite",
        isPro: false,
        suggestedBackground: .cameraOnly,
        cardGradient: [Color.white.opacity(0.42), Color.white.opacity(0.22)],
        cardMaterialOpacity: 0.45,
        digitColor: .white,
        secondaryTextColor: Color.white.opacity(0.92),
        taglineTextColor: Color.white.opacity(0.82),
        borderColor: Color.white.opacity(0.38),
        dividerColor: Color.white.opacity(0.22),
        shadowColor: Color.black.opacity(0.32),
        glowColor: Color.white.opacity(0.40),
        colonColor: Color.white.opacity(0.90),
        highlightTop: Color.white.opacity(0.18),
        highlightBottom: Color.black.opacity(0.08),
        metadataCapsuleFill: Color.white.opacity(0.14),
        previewGradient: [Color.white.opacity(0.55), Color(red: 0.88, green: 0.92, blue: 0.98).opacity(0.35)]
    )

    static let midnightBlack = TransparentFlipTheme(
        id: "midnightBlack",
        isPro: false,
        suggestedBackground: .deepNight,
        cardGradient: [Color(red: 0.10, green: 0.10, blue: 0.14).opacity(0.72), Color(red: 0.04, green: 0.04, blue: 0.08).opacity(0.82)],
        cardMaterialOpacity: 0.25,
        digitColor: .white,
        secondaryTextColor: Color.white.opacity(0.88),
        taglineTextColor: Color.white.opacity(0.76),
        borderColor: Color.white.opacity(0.16),
        dividerColor: Color.white.opacity(0.12),
        shadowColor: Color.black.opacity(0.55),
        glowColor: Color.white.opacity(0.12),
        colonColor: Color.white.opacity(0.82),
        highlightTop: Color.white.opacity(0.06),
        highlightBottom: Color.black.opacity(0.22),
        metadataCapsuleFill: Color.black.opacity(0.28),
        previewGradient: [Color(red: 0.12, green: 0.12, blue: 0.18), Color(red: 0.04, green: 0.04, blue: 0.08)]
    )

    static let sunsetOrange = TransparentFlipTheme(
        id: "sunsetOrange",
        isPro: false,
        suggestedBackground: .warmSunset,
        cardGradient: [
            Color(red: 0.98, green: 0.62, blue: 0.38).opacity(0.78),
            Color(red: 0.94, green: 0.48, blue: 0.32).opacity(0.68),
        ],
        cardMaterialOpacity: 0.20,
        digitColor: Color(red: 0.18, green: 0.08, blue: 0.04),
        secondaryTextColor: Color.white.opacity(0.94),
        taglineTextColor: Color.white.opacity(0.86),
        borderColor: Color.white.opacity(0.32),
        dividerColor: Color(red: 0.42, green: 0.18, blue: 0.08).opacity(0.35),
        shadowColor: Color(red: 0.55, green: 0.22, blue: 0.08).opacity(0.45),
        glowColor: Color(red: 1.0, green: 0.72, blue: 0.42).opacity(0.55),
        colonColor: Color(red: 0.22, green: 0.10, blue: 0.06),
        highlightTop: Color.white.opacity(0.22),
        highlightBottom: Color(red: 0.45, green: 0.18, blue: 0.06).opacity(0.18),
        metadataCapsuleFill: Color.black.opacity(0.16),
        previewGradient: [Color(red: 0.98, green: 0.62, blue: 0.38), Color(red: 0.94, green: 0.42, blue: 0.48)]
    )

    // MARK: Pro

    static let sakuraPink = TransparentFlipTheme(
        id: "sakuraPink",
        isPro: true,
        suggestedBackground: .warmSunset,
        cardGradient: [
            Color(red: 0.96, green: 0.72, blue: 0.82).opacity(0.72),
            Color(red: 0.92, green: 0.58, blue: 0.72).opacity(0.62),
        ],
        cardMaterialOpacity: 0.28,
        digitColor: Color(red: 0.42, green: 0.16, blue: 0.26),
        secondaryTextColor: Color.white.opacity(0.92),
        taglineTextColor: Color.white.opacity(0.84),
        borderColor: Color.white.opacity(0.36),
        dividerColor: Color(red: 0.55, green: 0.22, blue: 0.32).opacity(0.28),
        shadowColor: Color(red: 0.55, green: 0.18, blue: 0.32).opacity(0.38),
        glowColor: Color(red: 1.0, green: 0.82, blue: 0.90).opacity(0.45),
        colonColor: Color(red: 0.48, green: 0.18, blue: 0.28),
        highlightTop: Color.white.opacity(0.20),
        highlightBottom: Color(red: 0.55, green: 0.22, blue: 0.32).opacity(0.12),
        metadataCapsuleFill: Color.black.opacity(0.14),
        previewGradient: [Color(red: 0.96, green: 0.72, blue: 0.82), Color(red: 0.92, green: 0.58, blue: 0.72)]
    )

    static let creamBeige = TransparentFlipTheme(
        id: "creamBeige",
        isPro: true,
        suggestedBackground: .cleanLight,
        cardGradient: [
            Color(red: 0.96, green: 0.90, blue: 0.78).opacity(0.82),
            Color(red: 0.90, green: 0.82, blue: 0.68).opacity(0.72),
        ],
        cardMaterialOpacity: 0.22,
        digitColor: Color(red: 0.32, green: 0.24, blue: 0.16),
        secondaryTextColor: Color(red: 0.28, green: 0.22, blue: 0.16).opacity(0.92),
        taglineTextColor: Color(red: 0.32, green: 0.24, blue: 0.18).opacity(0.82),
        borderColor: Color.white.opacity(0.42),
        dividerColor: Color(red: 0.45, green: 0.35, blue: 0.22).opacity(0.28),
        shadowColor: Color(red: 0.35, green: 0.25, blue: 0.12).opacity(0.32),
        glowColor: Color(red: 1.0, green: 0.94, blue: 0.82).opacity(0.35),
        colonColor: Color(red: 0.38, green: 0.28, blue: 0.18),
        highlightTop: Color.white.opacity(0.28),
        highlightBottom: Color(red: 0.45, green: 0.32, blue: 0.18).opacity(0.10),
        metadataCapsuleFill: Color.white.opacity(0.22),
        previewGradient: [Color(red: 0.96, green: 0.90, blue: 0.78), Color(red: 0.88, green: 0.78, blue: 0.62)]
    )

    static let skyBlue = TransparentFlipTheme(
        id: "skyBlue",
        isPro: true,
        suggestedBackground: .cleanLight,
        cardGradient: [
            Color(red: 0.62, green: 0.84, blue: 0.98).opacity(0.72),
            Color(red: 0.48, green: 0.72, blue: 0.94).opacity(0.62),
        ],
        cardMaterialOpacity: 0.30,
        digitColor: Color(red: 0.08, green: 0.22, blue: 0.42),
        secondaryTextColor: Color.white.opacity(0.94),
        taglineTextColor: Color.white.opacity(0.86),
        borderColor: Color.white.opacity(0.38),
        dividerColor: Color(red: 0.12, green: 0.32, blue: 0.52).opacity(0.25),
        shadowColor: Color(red: 0.08, green: 0.28, blue: 0.52).opacity(0.38),
        glowColor: Color(red: 0.72, green: 0.92, blue: 1.0).opacity(0.48),
        colonColor: Color(red: 0.10, green: 0.28, blue: 0.48),
        highlightTop: Color.white.opacity(0.22),
        highlightBottom: Color(red: 0.08, green: 0.22, blue: 0.42).opacity(0.12),
        metadataCapsuleFill: Color.black.opacity(0.14),
        previewGradient: [Color(red: 0.62, green: 0.84, blue: 0.98), Color(red: 0.48, green: 0.72, blue: 0.94)]
    )

    static let forestGreen = TransparentFlipTheme(
        id: "forestGreen",
        isPro: true,
        suggestedBackground: .softDark,
        cardGradient: [
            Color(red: 0.18, green: 0.42, blue: 0.32).opacity(0.78),
            Color(red: 0.10, green: 0.28, blue: 0.22).opacity(0.82),
        ],
        cardMaterialOpacity: 0.22,
        digitColor: Color(red: 0.92, green: 0.96, blue: 0.90),
        secondaryTextColor: Color(red: 0.92, green: 0.96, blue: 0.90).opacity(0.92),
        taglineTextColor: Color(red: 0.88, green: 0.94, blue: 0.86).opacity(0.82),
        borderColor: Color(red: 0.72, green: 0.92, blue: 0.78).opacity(0.28),
        dividerColor: Color(red: 0.62, green: 0.82, blue: 0.68).opacity(0.22),
        shadowColor: Color.black.opacity(0.48),
        glowColor: Color(red: 0.62, green: 0.92, blue: 0.72).opacity(0.32),
        colonColor: Color(red: 0.88, green: 0.96, blue: 0.90),
        highlightTop: Color.white.opacity(0.10),
        highlightBottom: Color.black.opacity(0.18),
        metadataCapsuleFill: Color.black.opacity(0.22),
        previewGradient: [Color(red: 0.18, green: 0.42, blue: 0.32), Color(red: 0.10, green: 0.28, blue: 0.22)]
    )

    static let neonPurple = TransparentFlipTheme(
        id: "neonPurple",
        isPro: true,
        suggestedBackground: .aurora,
        cardGradient: [
            Color(red: 0.52, green: 0.32, blue: 0.92).opacity(0.72),
            Color(red: 0.32, green: 0.22, blue: 0.68).opacity(0.78),
        ],
        cardMaterialOpacity: 0.24,
        digitColor: .white,
        secondaryTextColor: Color.white.opacity(0.92),
        taglineTextColor: Color.white.opacity(0.82),
        borderColor: Color(red: 0.78, green: 0.62, blue: 1.0).opacity(0.42),
        dividerColor: Color(red: 0.62, green: 0.48, blue: 0.92).opacity(0.35),
        shadowColor: Color(red: 0.32, green: 0.12, blue: 0.62).opacity(0.55),
        glowColor: Color(red: 0.72, green: 0.48, blue: 1.0).opacity(0.58),
        colonColor: Color.white.opacity(0.90),
        highlightTop: Color.white.opacity(0.14),
        highlightBottom: Color.black.opacity(0.20),
        metadataCapsuleFill: Color.black.opacity(0.24),
        previewGradient: [Color(red: 0.52, green: 0.32, blue: 0.92), Color(red: 0.28, green: 0.48, blue: 0.92)]
    )
}
