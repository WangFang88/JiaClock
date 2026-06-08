import SwiftUI

struct JiaCardView<Content: View>: View {
    var theme: ClockTheme?
    var cornerRadius: CGFloat = 20
    var padding: CGFloat = 16
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(padding)
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(cardFill)
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .strokeBorder(cardStroke, lineWidth: 0.8)
                    }
                    .shadow(color: shadowColor, radius: 14, x: 0, y: 8)
            }
    }

    private var cardFill: some ShapeStyle {
        if let theme {
            theme.cardBackground
        } else {
            Color.white.opacity(0.08)
        }
    }

    private var cardStroke: Color {
        theme?.cardBorder ?? Color.white.opacity(0.12)
    }

    private var shadowColor: Color {
        if let theme, theme.isLightTheme {
            return Color.black.opacity(0.08)
        }
        return Color.black.opacity(0.28)
    }
}
