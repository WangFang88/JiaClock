import SwiftUI

struct JiaBackgroundView: View {
    @Environment(\.colorScheme) private var colorScheme
    let theme: ClockTheme

    var body: some View {
        ZStack {
            LinearGradient(colors: theme.gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)
            RadialGradient(
                colors: [theme.accentColor.opacity(colorScheme == .dark ? 0.22 : 0.16), .clear],
                center: .topTrailing, startRadius: 40, endRadius: 420
            )
            RadialGradient(
                colors: [theme.accentColor.opacity(colorScheme == .dark ? 0.12 : 0.08), .clear],
                center: .bottomLeading, startRadius: 20, endRadius: 360
            )
        }
        .ignoresSafeArea()
    }
}
