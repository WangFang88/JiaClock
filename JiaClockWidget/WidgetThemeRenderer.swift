import SwiftUI

struct WidgetThemeRenderer {
    let themeID: String

    var accent: Color {
        switch themeID {
        case "midnight": Color(red: 0.55, green: 0.62, blue: 0.98)
        case "forest": Color(red: 0.45, green: 0.78, blue: 0.58)
        case "ocean": Color(red: 0.38, green: 0.72, blue: 0.92)
        case "aurora": Color(red: 0.52, green: 0.88, blue: 0.82)
        case "sakura": Color(red: 0.94, green: 0.78, blue: 0.82)
        case "ember": Color(red: 0.98, green: 0.72, blue: 0.58)
        case "jadeRealm": Color(red: 0.48, green: 0.86, blue: 0.68)
        case "purpleDusk": Color(red: 0.82, green: 0.72, blue: 0.94)
        case "candyFantasy": Color(red: 0.96, green: 0.74, blue: 0.86)
        default: Color(red: 0.98, green: 0.62, blue: 0.42)
        }
    }

    var gradientColors: [Color] {
        switch themeID {
        case "midnight": [Color(red: 0.04, green: 0.06, blue: 0.14), Color(red: 0.10, green: 0.12, blue: 0.24)]
        case "forest": [Color(red: 0.06, green: 0.12, blue: 0.10), Color(red: 0.10, green: 0.20, blue: 0.16)]
        case "ocean": [Color(red: 0.05, green: 0.10, blue: 0.18), Color(red: 0.08, green: 0.18, blue: 0.28)]
        case "aurora": [Color(red: 0.14, green: 0.28, blue: 0.32), Color(red: 0.22, green: 0.42, blue: 0.40)]
        case "sakura": [Color(red: 0.32, green: 0.22, blue: 0.26), Color(red: 0.42, green: 0.30, blue: 0.32)]
        case "ember": [Color(red: 0.30, green: 0.18, blue: 0.14), Color(red: 0.42, green: 0.28, blue: 0.22)]
        case "jadeRealm": [Color(red: 0.14, green: 0.28, blue: 0.22), Color(red: 0.22, green: 0.40, blue: 0.30)]
        case "purpleDusk": [Color(red: 0.26, green: 0.22, blue: 0.34), Color(red: 0.36, green: 0.30, blue: 0.44)]
        case "candyFantasy": [Color(red: 0.34, green: 0.24, blue: 0.30), Color(red: 0.26, green: 0.28, blue: 0.36)]
        default: [Color(red: 0.12, green: 0.10, blue: 0.18), Color(red: 0.24, green: 0.14, blue: 0.30)]
        }
    }

    var primaryText: Color { .white }
    var secondaryText: Color { Color.white.opacity(0.78) }
    var tertiaryText: Color { Color.white.opacity(0.58) }

    @ViewBuilder
    func background(showThemeBackground: Bool) -> some View {
        if showThemeBackground {
            ZStack {
                LinearGradient(colors: gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)
                RadialGradient(colors: [accent.opacity(0.28), .clear], center: .topTrailing, startRadius: 8, endRadius: 120)
            }
        } else {
            ZStack {
                LinearGradient(colors: [Color(red: 0.10, green: 0.10, blue: 0.14), Color(red: 0.16, green: 0.14, blue: 0.20)], startPoint: .topLeading, endPoint: .bottomTrailing)
                RadialGradient(colors: [accent.opacity(0.18), .clear], center: .topTrailing, startRadius: 8, endRadius: 100)
            }
        }
    }
}
