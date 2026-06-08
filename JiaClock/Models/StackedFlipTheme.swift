import SwiftUI

// MARK: - 透明时钟显示模式

enum TransparentClockDisplayStyle: String, Codable, CaseIterable, Identifiable {
    case fullScreenTransparentFlip
    case transparentFlip
    case stackedFlip
    case minimalFloating

    var id: String { rawValue }

    var title: String {
        switch self {
        case .fullScreenTransparentFlip: L10n.Transparent.displayModeFullScreenFlip
        case .transparentFlip: L10n.Transparent.displayModeCardFlip
        case .stackedFlip: L10n.Transparent.displayModeStackedFlip
        case .minimalFloating: L10n.Transparent.displayModeMinimal
        }
    }

    var systemImage: String {
        switch self {
        case .fullScreenTransparentFlip: "rectangle.inset.filled"
        case .transparentFlip: "book.pages.fill"
        case .stackedFlip: "rectangle.stack.fill"
        case .minimalFloating: "textformat.size.larger"
        }
    }
}

// MARK: - 叠层翻页主题

struct StackedFlipTheme: Identifiable, Equatable {
    let id: String
    let isPro: Bool
    let topCardColor: Color
    let topDigitColor: Color
    let middleAccentColors: [Color]
    let bottomCardColor: Color
    let bottomDigitColor: Color
    let borderColor: Color
    let shadowColor: Color
    let glowColor: Color
    let secondaryTextColor: Color
    let taglineTextColor: Color
    let metadataCapsuleFill: Color
    let atmosphereOverlayColors: [Color]
    let atmosphereOpacity: Double

    var title: String { StackedFlipThemeLibrary.title(for: id) }

    static func == (lhs: StackedFlipTheme, rhs: StackedFlipTheme) -> Bool {
        lhs.id == rhs.id
    }
}

enum StackedFlipThemeLibrary {
    static let defaultThemeID = "orangeClassic"

    static let all: [StackedFlipTheme] = [
        orangeClassic, blueCalm, beigeSoft,
        redEnergy, greenForest, purpleNeon,
    ]

    static func theme(id: String) -> StackedFlipTheme {
        all.first { $0.id == id } ?? orangeClassic
    }

    static func title(for id: String) -> String {
        switch id {
        case "orangeClassic": L10n.Transparent.stackedThemeOrangeClassic
        case "blueCalm": L10n.Transparent.stackedThemeBlueCalm
        case "redEnergy": L10n.Transparent.stackedThemeRedEnergy
        case "greenForest": L10n.Transparent.stackedThemeGreenForest
        case "purpleNeon": L10n.Transparent.stackedThemePurpleNeon
        case "beigeSoft": L10n.Transparent.stackedThemeBeigeSoft
        default: L10n.Transparent.stackedThemeOrangeClassic
        }
    }

    static let orangeClassic = StackedFlipTheme(
        id: "orangeClassic",
        isPro: false,
        topCardColor: Color(red: 0.14, green: 0.14, blue: 0.16),
        topDigitColor: .white,
        middleAccentColors: [
            Color(red: 0.98, green: 0.58, blue: 0.32),
            Color(red: 0.96, green: 0.48, blue: 0.28),
        ],
        bottomCardColor: Color(red: 0.98, green: 0.96, blue: 0.92),
        bottomDigitColor: Color(red: 0.22, green: 0.20, blue: 0.18),
        borderColor: Color.white.opacity(0.22),
        shadowColor: Color.black.opacity(0.42),
        glowColor: Color(red: 0.98, green: 0.62, blue: 0.38).opacity(0.45),
        secondaryTextColor: Color.white.opacity(0.92),
        taglineTextColor: Color.white.opacity(0.82),
        metadataCapsuleFill: Color.black.opacity(0.18),
        atmosphereOverlayColors: [
            Color(red: 0.98, green: 0.55, blue: 0.28),
            Color(red: 0.92, green: 0.42, blue: 0.32),
        ],
        atmosphereOpacity: 0.18
    )

    static let blueCalm = StackedFlipTheme(
        id: "blueCalm",
        isPro: false,
        topCardColor: Color(red: 0.10, green: 0.16, blue: 0.28),
        topDigitColor: .white,
        middleAccentColors: [
            Color(red: 0.42, green: 0.72, blue: 0.96),
            Color(red: 0.32, green: 0.58, blue: 0.88),
        ],
        bottomCardColor: Color(red: 0.92, green: 0.96, blue: 1.0),
        bottomDigitColor: Color(red: 0.08, green: 0.18, blue: 0.32),
        borderColor: Color.white.opacity(0.20),
        shadowColor: Color.black.opacity(0.40),
        glowColor: Color(red: 0.52, green: 0.78, blue: 1.0).opacity(0.40),
        secondaryTextColor: Color.white.opacity(0.90),
        taglineTextColor: Color.white.opacity(0.80),
        metadataCapsuleFill: Color.black.opacity(0.16),
        atmosphereOverlayColors: [
            Color(red: 0.12, green: 0.22, blue: 0.42),
            Color(red: 0.18, green: 0.32, blue: 0.52),
        ],
        atmosphereOpacity: 0.16
    )

    static let beigeSoft = StackedFlipTheme(
        id: "beigeSoft",
        isPro: false,
        topCardColor: Color(red: 0.32, green: 0.22, blue: 0.16),
        topDigitColor: .white,
        middleAccentColors: [
            Color(red: 0.88, green: 0.72, blue: 0.48),
            Color(red: 0.82, green: 0.62, blue: 0.38),
        ],
        bottomCardColor: Color(red: 0.98, green: 0.94, blue: 0.86),
        bottomDigitColor: Color(red: 0.35, green: 0.26, blue: 0.18),
        borderColor: Color.white.opacity(0.24),
        shadowColor: Color(red: 0.28, green: 0.18, blue: 0.10).opacity(0.38),
        glowColor: Color(red: 0.92, green: 0.78, blue: 0.52).opacity(0.35),
        secondaryTextColor: Color.white.opacity(0.90),
        taglineTextColor: Color.white.opacity(0.80),
        metadataCapsuleFill: Color.black.opacity(0.16),
        atmosphereOverlayColors: [
            Color(red: 0.88, green: 0.72, blue: 0.48),
            Color(red: 0.78, green: 0.58, blue: 0.38),
        ],
        atmosphereOpacity: 0.14
    )

    static let redEnergy = StackedFlipTheme(
        id: "redEnergy",
        isPro: true,
        topCardColor: Color(red: 0.28, green: 0.10, blue: 0.10),
        topDigitColor: .white,
        middleAccentColors: [
            Color(red: 0.96, green: 0.42, blue: 0.38),
            Color(red: 0.92, green: 0.32, blue: 0.36),
        ],
        bottomCardColor: Color(red: 1.0, green: 0.96, blue: 0.94),
        bottomDigitColor: Color(red: 0.42, green: 0.12, blue: 0.12),
        borderColor: Color.white.opacity(0.20),
        shadowColor: Color(red: 0.45, green: 0.08, blue: 0.08).opacity(0.45),
        glowColor: Color(red: 1.0, green: 0.48, blue: 0.42).opacity(0.48),
        secondaryTextColor: Color.white.opacity(0.92),
        taglineTextColor: Color.white.opacity(0.82),
        metadataCapsuleFill: Color.black.opacity(0.18),
        atmosphereOverlayColors: [
            Color(red: 0.92, green: 0.32, blue: 0.28),
            Color(red: 0.78, green: 0.22, blue: 0.28),
        ],
        atmosphereOpacity: 0.16
    )

    static let greenForest = StackedFlipTheme(
        id: "greenForest",
        isPro: true,
        topCardColor: Color(red: 0.08, green: 0.22, blue: 0.16),
        topDigitColor: Color(red: 0.94, green: 0.98, blue: 0.94),
        middleAccentColors: [
            Color(red: 0.48, green: 0.82, blue: 0.62),
            Color(red: 0.38, green: 0.68, blue: 0.52),
        ],
        bottomCardColor: Color(red: 0.92, green: 0.98, blue: 0.94),
        bottomDigitColor: Color(red: 0.08, green: 0.28, blue: 0.18),
        borderColor: Color(red: 0.72, green: 0.92, blue: 0.78).opacity(0.28),
        shadowColor: Color.black.opacity(0.44),
        glowColor: Color(red: 0.52, green: 0.88, blue: 0.68).opacity(0.38),
        secondaryTextColor: Color(red: 0.92, green: 0.98, blue: 0.92).opacity(0.92),
        taglineTextColor: Color(red: 0.88, green: 0.96, blue: 0.88).opacity(0.82),
        metadataCapsuleFill: Color.black.opacity(0.20),
        atmosphereOverlayColors: [
            Color(red: 0.08, green: 0.28, blue: 0.18),
            Color(red: 0.12, green: 0.38, blue: 0.24),
        ],
        atmosphereOpacity: 0.18
    )

    static let purpleNeon = StackedFlipTheme(
        id: "purpleNeon",
        isPro: true,
        topCardColor: Color(red: 0.12, green: 0.06, blue: 0.22),
        topDigitColor: .white,
        middleAccentColors: [
            Color(red: 0.72, green: 0.38, blue: 0.96),
            Color(red: 0.52, green: 0.32, blue: 0.88),
        ],
        bottomCardColor: Color(red: 0.94, green: 0.92, blue: 0.98),
        bottomDigitColor: Color(red: 0.22, green: 0.10, blue: 0.38),
        borderColor: Color(red: 0.78, green: 0.58, blue: 1.0).opacity(0.32),
        shadowColor: Color(red: 0.32, green: 0.08, blue: 0.52).opacity(0.50),
        glowColor: Color(red: 0.72, green: 0.48, blue: 1.0).opacity(0.52),
        secondaryTextColor: Color.white.opacity(0.92),
        taglineTextColor: Color.white.opacity(0.82),
        metadataCapsuleFill: Color.black.opacity(0.22),
        atmosphereOverlayColors: [
            Color(red: 0.32, green: 0.12, blue: 0.52),
            Color(red: 0.18, green: 0.08, blue: 0.32),
        ],
        atmosphereOpacity: 0.20
    )
}

/// 叠层翻页模式下的轻量氛围叠加（不替代摄像头）。
struct StackedFlipAtmosphereOverlay: View {
    let theme: StackedFlipTheme

    var body: some View {
        LinearGradient(
            colors: theme.atmosphereOverlayColors.map { $0.opacity(theme.atmosphereOpacity) },
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}
