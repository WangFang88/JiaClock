import SwiftUI

/// 未解锁 Pro 时展示引导；已解锁则显示内容。
struct ProGateView<Content: View, Locked: View>: View {
    let feature: ProFeature
    @ViewBuilder var content: () -> Content
    @ViewBuilder var locked: () -> Locked

    @EnvironmentObject private var entitlements: EntitlementManager
    @State private var showPaywall = false

    init(
        feature: ProFeature,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder locked: @escaping () -> Locked
    ) {
        self.feature = feature
        self.content = content
        self.locked = locked
    }

    var body: some View {
        Group {
            if entitlements.hasAccess(to: feature) {
                content()
            } else {
                locked()
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(highlightFeature: feature)
        }
        .environment(\.openPaywall) {
            showPaywall = true
        }
    }
}

extension ProGateView where Locked == DefaultProLockedView {
    init(feature: ProFeature, @ViewBuilder content: @escaping () -> Content) {
        self.init(feature: feature, content: content) {
            DefaultProLockedView(feature: feature)
        }
    }
}

struct DefaultProLockedView: View {
    let feature: ProFeature
    @Environment(\.openPaywall) private var openPaywall

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: feature.systemImage)
                .font(.system(size: 34))
                .foregroundStyle(Color(red: 0.98, green: 0.78, blue: 0.38))
            Text(feature.title)
                .font(.headline.weight(.semibold))
            Text(L10n.Pro.gateMessage)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button(L10n.Pro.unlockButton) { openPaywall?() }
                .font(.body.weight(.semibold))
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Capsule(style: .continuous).fill(Color.white.opacity(0.92)))
                .foregroundStyle(Color(red: 0.12, green: 0.12, blue: 0.16))
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
        }
    }
}

private struct OpenPaywallKey: EnvironmentKey {
    static let defaultValue: (() -> Void)? = nil
}

extension EnvironmentValues {
    var openPaywall: (() -> Void)? {
        get { self[OpenPaywallKey.self] }
        set { self[OpenPaywallKey.self] = newValue }
    }
}
