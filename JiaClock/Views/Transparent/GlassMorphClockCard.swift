import SwiftUI

struct GlassMorphClockCard: View {
    let time: String
    let weekday: String?
    let date: String?
    let tagline: String
    let useLightText: Bool
    var compact: Bool = false

    private var primaryColor: Color { useLightText ? .white : Color(red: 0.10, green: 0.10, blue: 0.12) }
    private var secondaryColor: Color { useLightText ? Color.white.opacity(0.82) : Color(red: 0.22, green: 0.22, blue: 0.26) }

    var body: some View {
        VStack(spacing: compact ? 10 : 16) {
            Text(time).font(.system(size: compact ? 52 : 68, weight: .ultraLight, design: .rounded)).monospacedDigit().lineLimit(1).minimumScaleFactor(0.55).foregroundStyle(primaryColor)
            if weekday != nil || date != nil {
                VStack(spacing: 6) {
                    if let weekday { Text(weekday).font(compact ? .subheadline.weight(.medium) : .title3.weight(.medium)).foregroundStyle(secondaryColor) }
                    if let date { Text(date).font(compact ? .subheadline : .title3).foregroundStyle(secondaryColor) }
                }
            }
            if !tagline.isEmpty {
                Text(tagline).font(compact ? .footnote.weight(.medium) : .headline.weight(.medium)).foregroundStyle(primaryColor.opacity(0.92)).multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, compact ? 24 : 36).padding(.vertical, compact ? 22 : 32)
        .background {
            RoundedRectangle(cornerRadius: compact ? 24 : 32, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: compact ? 24 : 32, style: .continuous)
                        .strokeBorder(LinearGradient(colors: [Color.white.opacity(0.55), Color.white.opacity(0.12)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                }
        }
        .shadow(color: .black.opacity(0.22), radius: 24, x: 0, y: 14)
    }
}
