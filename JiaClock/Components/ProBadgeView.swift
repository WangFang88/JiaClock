import SwiftUI

struct ProBadgeView: View {
    var compact: Bool = false

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "sparkles").font(compact ? .caption2.weight(.bold) : .caption.weight(.bold))
            Text(L10n.Common.pro).font(compact ? .caption2.weight(.bold) : .caption.weight(.bold))
        }
        .padding(.horizontal, compact ? 6 : 8)
        .padding(.vertical, compact ? 3 : 4)
        .background {
            Capsule(style: .continuous)
                .fill(LinearGradient(
                    colors: [Color(red: 0.98, green: 0.78, blue: 0.38), Color(red: 0.92, green: 0.58, blue: 0.24)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ))
        }
        .foregroundStyle(Color(red: 0.22, green: 0.12, blue: 0.04))
    }
}
