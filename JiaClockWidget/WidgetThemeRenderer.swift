import SwiftUI

struct WidgetThemeRenderer {
    let themeID: String

    private var resolvedID: String {
        switch themeID {
        case "dawn": return "jiaWarmGlow"
        case "midnight": return "quietNight"
        case "forest": return "forestBreath"
        case "ocean": return "oceanCalm"
        default: return themeID
        }
    }

    var accent: Color {
        switch resolvedID {
        case "quietNight": Color(red: 0.58, green: 0.68, blue: 0.98)
        case "creamDawn": Color(red: 0.92, green: 0.58, blue: 0.38)
        case "clearGlass": Color(red: 0.88, green: 0.90, blue: 0.96)
        case "forestBreath": Color(red: 0.72, green: 0.88, blue: 0.52)
        case "oceanCalm": Color(red: 0.42, green: 0.78, blue: 0.92)
        case "sakuraDusk": Color(red: 0.98, green: 0.62, blue: 0.72)
        case "auroraNight": Color(red: 0.72, green: 0.48, blue: 0.98)
        default: Color(red: 0.98, green: 0.62, blue: 0.38)
        }
    }

    var gradientColors: [Color] {
        switch resolvedID {
        case "quietNight":
            [Color(red: 0.03, green: 0.05, blue: 0.12), Color(red: 0.06, green: 0.08, blue: 0.20)]
        case "creamDawn":
            [Color(red: 0.98, green: 0.95, blue: 0.90), Color(red: 0.94, green: 0.88, blue: 0.78)]
        case "clearGlass":
            [Color(red: 0.10, green: 0.12, blue: 0.18), Color(red: 0.14, green: 0.16, blue: 0.22)]
        case "forestBreath":
            [Color(red: 0.04, green: 0.10, blue: 0.08), Color(red: 0.08, green: 0.16, blue: 0.12)]
        case "oceanCalm":
            [Color(red: 0.03, green: 0.08, blue: 0.16), Color(red: 0.06, green: 0.14, blue: 0.24)]
        case "sakuraDusk":
            [Color(red: 0.14, green: 0.06, blue: 0.12), Color(red: 0.22, green: 0.10, blue: 0.18)]
        case "auroraNight":
            [Color(red: 0.06, green: 0.04, blue: 0.14), Color(red: 0.10, green: 0.06, blue: 0.22)]
        default:
            [Color(red: 0.08, green: 0.06, blue: 0.14), Color(red: 0.18, green: 0.10, blue: 0.22)]
        }
    }

    var primaryText: Color {
        resolvedID == "creamDawn" ? Color(red: 0.14, green: 0.12, blue: 0.10) : .white
    }

    var secondaryText: Color {
        resolvedID == "creamDawn" ? Color(red: 0.32, green: 0.28, blue: 0.24).opacity(0.88) : Color.white.opacity(0.82)
    }

    var tertiaryText: Color {
        resolvedID == "creamDawn" ? Color(red: 0.32, green: 0.28, blue: 0.24).opacity(0.62) : Color.white.opacity(0.58)
    }

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
