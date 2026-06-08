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
    private var purchaseConfirmedExpirations: [String: Date] = [:]
    private var periodicRefreshTask: Task<Void, Never>?

    private static let periodicRefreshIntervalNanoseconds: UInt64 = 3_600_000_000_000

    init() {
        isPro = false
    }

    deinit {
        periodicRefreshTask?.cancel()
    }

    func startPeriodicRefresh() {
        guard periodicRefreshTask == nil else { return }
        periodicRefreshTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: Self.periodicRefreshIntervalNanoseconds)
                guard !Task.isCancelled else { return }
                await self?.refreshEntitlements()
            }
        }
    }

    func stopPeriodicRefresh() {
        periodicRefreshTask?.cancel()
        periodicRefreshTask = nil
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
        recordPurchaseConfirmation(for: transaction)

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
            entitledIDs: activeProductIDs.union(activePendingPurchaseConfirmedIDs()),
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
        for id in entitledIDs {
            purchaseConfirmedExpirations.removeValue(forKey: id)
        }
        pruneExpiredPurchaseConfirmations()
        entitledIDs.formUnion(activePendingPurchaseConfirmedIDs())

        publishEntitlements(
            entitledIDs: entitledIDs,
            latestSubscriptionExpiration: latestSubscriptionExpiration,
            latestSubscriptionProductID: latestSubscriptionProductID
        )

        UserDefaults.standard.set(isPro, forKey: CacheKey.isPro)
    }

    enum RestoreResult: Equatable {
        case active
        case foundExpired(planTitle: String, expirationDate: Date)
        case notFound
    }

    /// 恢复购买：先查 currentEntitlements，再通过 subscription.status 向 Apple 验证订阅状态。
    func restorePurchases(using products: [Product]) async -> RestoreResult {
        await refreshEntitlements(syncWithAppStore: false)
        if isPro { return .active }

        var latestExpired: (productID: String, expirationDate: Date)?

        for product in products where ProProductID.subscriptionIDs.contains(product.id) {
            guard let subscription = product.subscription,
                  let statuses = try? await subscription.status else { continue }

            for status in statuses {
                guard case .verified(let transaction) = status.transaction else { continue }
                guard ProProductID.all.contains(transaction.productID) else { continue }

                switch status.state {
                case .subscribed, .inGracePeriod, .inBillingRetryPeriod:
                    applyRestoredTransaction(transaction)
                    if isPro { return .active }
                case .expired:
                    if let expiration = transaction.expirationDate,
                       latestExpired == nil || expiration > latestExpired!.expirationDate {
                        latestExpired = (transaction.productID, expiration)
                    }
                default:
                    continue
                }
            }
        }

        if isPro { return .active }

        if let expired = latestExpired {
            subscriptionExpirationDate = expired.expirationDate
            activePlanTitle = planTitle(for: expired.productID)
            return .foundExpired(
                planTitle: planTitle(for: expired.productID),
                expirationDate: expired.expirationDate
            )
        }

        return .notFound
    }

    private func applyRestoredTransaction(_ transaction: Transaction) {
        guard ProProductID.all.contains(transaction.productID) else { return }
        guard transaction.revocationDate == nil else { return }
        recordPurchaseConfirmation(for: transaction)

        var latestSubscriptionExpiration: Date?
        var latestSubscriptionProductID: String?

        if ProProductID.subscriptionIDs.contains(transaction.productID),
           let expiration = transaction.expirationDate {
            latestSubscriptionExpiration = expiration
            latestSubscriptionProductID = transaction.productID
        }

        var entitledIDs = activeProductIDs.union(activePendingPurchaseConfirmedIDs())
        entitledIDs.insert(transaction.productID)

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

    private func recordPurchaseConfirmation(for transaction: Transaction) {
        purchaseConfirmedProductIDs.insert(transaction.productID)
        if ProProductID.lifetimeIDs.contains(transaction.productID) {
            purchaseConfirmedExpirations[transaction.productID] = .distantFuture
        } else if let expiration = transaction.expirationDate {
            purchaseConfirmedExpirations[transaction.productID] = expiration
        } else {
            purchaseConfirmedExpirations.removeValue(forKey: transaction.productID)
        }
    }

    private func activePendingPurchaseConfirmedIDs(at date: Date = .now) -> Set<String> {
        Set(
            purchaseConfirmedProductIDs.filter { id in
                guard let expiration = purchaseConfirmedExpirations[id] else { return false }
                return expiration > date
            }
        )
    }

    private func pruneExpiredPurchaseConfirmations(at date: Date = .now) {
        let activePending = activePendingPurchaseConfirmedIDs(at: date)
        purchaseConfirmedProductIDs = activePending
        purchaseConfirmedExpirations = purchaseConfirmedExpirations.filter { id, expiration in
            activePending.contains(id) && expiration > date
        }
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
