import Foundation
import StoreKit

/// Pro 权限真相源：以 StoreKit `Transaction.currentEntitlements` 为准；本地缓存仅用于启动时的显示优化。
@MainActor
final class EntitlementManager: ObservableObject {
    @Published private(set) var isPro = false
    @Published private(set) var isRefreshing = false
    @Published private(set) var activeProductIDs: Set<String> = []
    @Published private(set) var hasLifetimeEntitlement = false
    @Published private(set) var hasActiveSubscription = false
    @Published private(set) var activePlanTitle: String?
    @Published private(set) var subscriptionExpirationDate: Date?

    private enum CacheKey {
        static let isPro = "pro.entitlement.cached.isPro"
    }

    /// 购买刚完成时 `currentEntitlements` 可能尚未包含新订阅；暂存直至 StoreKit 同步确认。
    private var purchaseConfirmedProductIDs: Set<String> = []

    init() {
        isPro = false
    }

    func hasAccess(to feature: ProFeature) -> Bool {
        isPro || !feature.isGatedThisRound
    }

    func canAccessStyle(_ style: ClockDisplayStyle, for scene: ClockStyleScene) -> Bool {
        ClockDisplayStyle.isAccessible(style, for: scene, isPro: isPro)
    }

    /// 将购买回调中的已验证交易立即并入 Pro 状态，避免刷新前 `isPro` 仍为 false。
    func applyVerifiedTransaction(_ transaction: Transaction) {
        guard isActiveProTransaction(transaction) else { return }
        purchaseConfirmedProductIDs.insert(transaction.productID)

        var latestSubscriptionExpiration: Date?
        var latestSubscriptionProductID: String?

        if ProProductID.subscriptionIDs.contains(transaction.productID),
           let expiration = transaction.expirationDate {
            latestSubscriptionExpiration = expiration
            latestSubscriptionProductID = transaction.productID
        } else if let existingSubscription = activeProductIDs.first(where: { ProProductID.subscriptionIDs.contains($0) }) {
            latestSubscriptionProductID = existingSubscription
        }

        publishEntitlements(
            entitledIDs: activeProductIDs.union(purchaseConfirmedProductIDs),
            latestSubscriptionExpiration: latestSubscriptionExpiration,
            latestSubscriptionProductID: latestSubscriptionProductID
        )
        UserDefaults.standard.set(isPro, forKey: CacheKey.isPro)
    }

    func refreshEntitlements(syncWithAppStore: Bool = false) async {
        isRefreshing = true
        defer { isRefreshing = false }

        if syncWithAppStore {
            try? await AppStore.sync()
        }

        var entitledIDs: Set<String> = []
        var latestSubscriptionExpiration: Date?
        var latestSubscriptionProductID: String?

        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            guard isActiveProTransaction(transaction) else { continue }

            entitledIDs.insert(transaction.productID)

            if ProProductID.subscriptionIDs.contains(transaction.productID),
               let expiration = transaction.expirationDate {
                if latestSubscriptionExpiration == nil || expiration > latestSubscriptionExpiration! {
                    latestSubscriptionExpiration = expiration
                    latestSubscriptionProductID = transaction.productID
                }
            }
        }

        purchaseConfirmedProductIDs.subtract(entitledIDs)
        entitledIDs.formUnion(purchaseConfirmedProductIDs)

        publishEntitlements(
            entitledIDs: entitledIDs,
            latestSubscriptionExpiration: latestSubscriptionExpiration,
            latestSubscriptionProductID: latestSubscriptionProductID
        )

        UserDefaults.standard.set(isPro, forKey: CacheKey.isPro)
    }

    private func isActiveProTransaction(_ transaction: Transaction) -> Bool {
        guard ProProductID.all.contains(transaction.productID) else { return false }
        guard transaction.revocationDate == nil else { return false }
        if let expiration = transaction.expirationDate, expiration <= Date() { return false }
        return true
    }

    private func publishEntitlements(
        entitledIDs: Set<String>,
        latestSubscriptionExpiration: Date?,
        latestSubscriptionProductID: String?
    ) {
        activeProductIDs = entitledIDs
        hasLifetimeEntitlement = !entitledIDs.intersection(ProProductID.lifetimeIDs).isEmpty
        hasActiveSubscription = !entitledIDs.intersection(ProProductID.subscriptionIDs).isEmpty
        isPro = !entitledIDs.isEmpty
        if let latestSubscriptionExpiration {
            subscriptionExpirationDate = latestSubscriptionExpiration
        } else if !hasActiveSubscription {
            subscriptionExpirationDate = nil
        }

        if hasLifetimeEntitlement {
            activePlanTitle = planTitle(for: ProProductID.lifetime)
        } else if let productID = latestSubscriptionProductID {
            activePlanTitle = planTitle(for: productID)
        } else {
            activePlanTitle = nil
        }
    }

    private func planTitle(for productID: String) -> String {
        switch productID {
        case ProProductID.monthly: L10n.Pro.planMonthly
        case ProProductID.yearly: L10n.Pro.planYearly
        case ProProductID.lifetime: L10n.Pro.planLifetime
        default: productID
        }
    }
}
