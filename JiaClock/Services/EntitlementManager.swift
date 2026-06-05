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

        var entitledIDs: Set<String> = []
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            guard ProProductID.all.contains(transaction.productID) else { continue }
            if transaction.revocationDate == nil {
                entitledIDs.insert(transaction.productID)
            }
        }

        activeProductIDs = entitledIDs
        hasLifetimeEntitlement = !entitledIDs.intersection(ProProductID.lifetimeIDs).isEmpty
        hasActiveSubscription = !entitledIDs.intersection(ProProductID.subscriptionIDs).isEmpty
        isPro = !entitledIDs.isEmpty

        UserDefaults.standard.set(isPro, forKey: CacheKey.isPro)
    }
}
