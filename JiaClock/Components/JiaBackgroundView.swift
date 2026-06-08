import SwiftUI

struct JiaBackgroundView: View {
    let theme: ClockTheme

    var body: some View {
        ZStack {
            LinearGradient(
                colors: theme.gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            RadialGradient(
                colors: [theme.accentColor.opacity(0.28), .clear],
                center: theme.glowCenter,
                startRadius: 20,
                endRadius: 480
            )
            RadialGradient(
                colors: [theme.accentColor.opacity(0.12), .clear],
                center: .bottomLeading,
                startRadius: 10,
                endRadius: 340
            )
            if theme == .jiaWarmGlow {
                RadialGradient(
                    colors: [Color(red: 0.98, green: 0.55, blue: 0.32).opacity(0.18), .clear],
                    center: UnitPoint(x: 0.75, y: 0.15),
                    startRadius: 8,
                    endRadius: 280
                )
            }
        }
        .ignoresSafeArea()
    }
}
