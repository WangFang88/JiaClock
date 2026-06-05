import SwiftUI

struct HomeFeatureCard: View {
    let mode: ClockMode
    let accent: Color
    var isLocked: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            JiaCardView(padding: 18) {
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        ZStack {
                            Circle().fill(accent.opacity(0.18)).frame(width: 44, height: 44)
                            Image(systemName: mode.systemImage)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(accent)
                        }
                        Spacer()
                        if isLocked {
                            ProBadgeView(compact: true)
                        } else {
                            Image(systemName: "arrow.up.right")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.secondary)
                        }
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text(mode.title).font(.headline.weight(.semibold)).foregroundStyle(.primary)
                        Text(mode.subtitle).font(.subheadline).foregroundStyle(.secondary).lineLimit(2)
                    }
                    if isLocked {
                        Text(L10n.Common.comingSoon).font(.caption.weight(.medium)).foregroundStyle(.tertiary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .buttonStyle(.plain)
        .opacity(isLocked ? 0.88 : 1)
    }
}
