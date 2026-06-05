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

    init() {
        isPro = UserDefaults.standard.bool(forKey: CacheKey.isPro)
    }

    func hasAccess(to feature: ProFeature) -> Bool {
        isPro || !feature.isGatedThisRound
    }

    func refreshEntitlements() async {
        isRefreshing = true
        defer { isRefreshing = false }

        try? await AppStore.sync()

        var entitledIDs: Set<String> = []
        var latestSubscriptionExpiration: Date?
        var latestSubscriptionProductID: String?

        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            guard ProProductID.all.contains(transaction.productID) else { continue }
            guard transaction.revocationDate == nil else { continue }
            if let expiration = transaction.expirationDate, expiration <= Date() { continue }

            entitledIDs.insert(transaction.productID)

            if ProProductID.subscriptionIDs.contains(transaction.productID),
               let expiration = transaction.expirationDate {
                if latestSubscriptionExpiration == nil || expiration > latestSubscriptionExpiration! {
                    latestSubscriptionExpiration = expiration
                    latestSubscriptionProductID = transaction.productID
                }
            }
        }

        activeProductIDs = entitledIDs
        hasLifetimeEntitlement = !entitledIDs.intersection(ProProductID.lifetimeIDs).isEmpty
        hasActiveSubscription = !entitledIDs.intersection(ProProductID.subscriptionIDs).isEmpty
        isPro = !entitledIDs.isEmpty
        subscriptionExpirationDate = latestSubscriptionExpiration

        if hasLifetimeEntitlement {
            activePlanTitle = planTitle(for: ProProductID.lifetime)
        } else if let productID = latestSubscriptionProductID {
            activePlanTitle = planTitle(for: productID)
        } else {
            activePlanTitle = nil
        }

        UserDefaults.standard.set(isPro, forKey: CacheKey.isPro)
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
