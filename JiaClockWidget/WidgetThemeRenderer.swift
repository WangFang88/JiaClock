import SwiftUI

struct WidgetThemeRenderer {
    let themeID: String

    var accent: Color {
        switch themeID {
        case "midnight": Color(red: 0.55, green: 0.62, blue: 0.98)
        case "forest": Color(red: 0.45, green: 0.78, blue: 0.58)
        case "ocean": Color(red: 0.38, green: 0.72, blue: 0.92)
        default: Color(red: 0.98, green: 0.62, blue: 0.42)
        }
    }

    var gradientColors: [Color] {
        switch themeID {
        case "midnight": [Color(red: 0.04, green: 0.06, blue: 0.14), Color(red: 0.10, green: 0.12, blue: 0.24)]
        case "forest": [Color(red: 0.06, green: 0.12, blue: 0.10), Color(red: 0.10, green: 0.20, blue: 0.16)]
        case "ocean": [Color(red: 0.05, green: 0.10, blue: 0.18), Color(red: 0.08, green: 0.18, blue: 0.28)]
        default: [Color(red: 0.10, green: 0.08, blue: 0.14), Color(red: 0.22, green: 0.12, blue: 0.18)]
        }
    }

    var primaryText: Color { .white }
    var secondaryText: Color { Color.white.opacity(0.82) }
    var tertiaryText: Color { Color.white.opacity(0.58) }

    @ViewBuilder
    func background(showThemeBackground: Bool) -> some View {
        ZStack {
            LinearGradient(
                colors: showThemeBackground ? gradientColors : [
                    Color(red: 0.10, green: 0.10, blue: 0.14),
                    Color(red: 0.16, green: 0.14, blue: 0.20),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            RadialGradient(
                colors: [accent.opacity(showThemeBackground ? 0.32 : 0.20), .clear],
                center: .topTrailing,
                startRadius: 8,
                endRadius: showThemeBackground ? 160 : 110
            )
            RadialGradient(
                colors: [accent.opacity(0.08), .clear],
                center: .bottomLeading,
                startRadius: 4,
                endRadius: 120
            )
        }
    }
}
