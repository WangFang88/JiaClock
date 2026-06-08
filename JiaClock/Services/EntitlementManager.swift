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
        applyEntitlement(from: transaction)
    }

    enum RestoreOutcome: Equatable {
        case restoredActive
        case foundExpired(planTitle: String, expirationDate: Date)
        case nothingFound
    }

    /// 恢复购买专用：结合 `currentEntitlements`、订阅状态与历史交易，识别有效或已过期的 Pro 记录。
    func restoreEntitlements(using products: [Product]) async -> RestoreOutcome {
        isRefreshing = true
        defer { isRefreshing = false }

        logRestoreStep("restoreEntitlements started", extra: "products=\(products.count)")

        if let outcome = await collectActiveEntitlementsFromCurrentEntitlements() {
            logRestoreStep("restoreEntitlements finished", extra: "source=currentEntitlements outcome=\(outcome)")
            return outcome
        }

        if let outcome = await collectActiveEntitlementsFromSubscriptionStatus(products: products) {
            logRestoreStep("restoreEntitlements finished", extra: "source=subscriptionStatus outcome=\(outcome)")
            return outcome
        }

        if let outcome = await collectActiveEntitlementsFromTransactionHistory() {
            logRestoreStep("restoreEntitlements finished", extra: "source=transactionHistory outcome=\(outcome)")
            return outcome
        }

        if let expired = await findLatestExpiredProSubscription(in: products) {
            publishExpiredSubscriptionMetadata(productID: expired.productID, expirationDate: expired.expirationDate)
            logRestoreStep(
                "restoreEntitlements finished",
                extra: "outcome=foundExpired product=\(expired.productID) expiration=\(expired.expirationDate)"
            )
            return .foundExpired(planTitle: planTitle(for: expired.productID), expirationDate: expired.expirationDate)
        }

        logRestoreStep("restoreEntitlements finished", extra: "outcome=nothingFound")
        return .nothingFound
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

    private func applyEntitlement(from transaction: Transaction) {
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

    /// 恢复流程中 Apple 明确标记为有效（含宽限期/账单重试）的订阅，不再用本地过期时间二次过滤。
    private func applyRestoredActiveTransaction(_ transaction: Transaction) {
        guard ProProductID.all.contains(transaction.productID) else { return }
        guard transaction.revocationDate == nil else { return }
        applyEntitlement(from: transaction)
    }

    private func collectActiveEntitlementsFromCurrentEntitlements() async -> RestoreOutcome? {
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

        guard !entitledIDs.isEmpty else { return nil }

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
        return isPro ? .restoredActive : nil
    }

    private func collectActiveEntitlementsFromSubscriptionStatus(products: [Product]) async -> RestoreOutcome? {
        for product in products where ProProductID.subscriptionIDs.contains(product.id) {
            guard let subscription = product.subscription else { continue }
            guard let statuses = try? await subscription.status else {
                logRestoreStep("subscription.status unavailable", extra: "product=\(product.id)")
                continue
            }

            for status in statuses {
                guard case .verified(let transaction) = status.transaction else { continue }
                guard ProProductID.all.contains(transaction.productID) else { continue }

                switch status.state {
                case .subscribed, .inGracePeriod, .inBillingRetryPeriod:
                    logRestoreStep(
                        "subscription.status active",
                        extra: "product=\(transaction.productID) state=\(status.state)"
                    )
                    applyRestoredActiveTransaction(transaction)
                    if isPro { return .restoredActive }
                case .expired, .revoked:
                    continue
                default:
                    continue
                }
            }
        }
        return nil
    }

    private func collectActiveEntitlementsFromTransactionHistory() async -> RestoreOutcome? {
        for await result in Transaction.all {
            guard case .verified(let transaction) = result else { continue }
            guard isActiveProTransaction(transaction) else { continue }

            logRestoreStep("active transaction in history", extra: "product=\(transaction.productID) id=\(transaction.id)")
            applyRestoredActiveTransaction(transaction)
            if isPro { return .restoredActive }
        }
        return nil
    }

    private struct ExpiredSubscriptionRecord {
        let productID: String
        let expirationDate: Date
    }

    private func findLatestExpiredProSubscription(in products: [Product]) async -> ExpiredSubscriptionRecord? {
        var latestExpired: ExpiredSubscriptionRecord?

        for product in products where ProProductID.subscriptionIDs.contains(product.id) {
            guard let subscription = product.subscription else { continue }
            guard let statuses = try? await subscription.status else { continue }

            for status in statuses {
                guard case .verified(let transaction) = status.transaction else { continue }
                guard status.state == .expired else { continue }
                guard let expiration = transaction.expirationDate else { continue }

                logRestoreStep(
                    "subscription.status expired",
                    extra: "product=\(transaction.productID) expiration=\(expiration)"
                )
                if latestExpired == nil || expiration > latestExpired!.expirationDate {
                    latestExpired = ExpiredSubscriptionRecord(productID: transaction.productID, expirationDate: expiration)
                }
            }
        }

        if latestExpired != nil { return latestExpired }

        for await result in Transaction.all {
            guard case .verified(let transaction) = result else { continue }
            guard ProProductID.subscriptionIDs.contains(transaction.productID) else { continue }
            guard let expiration = transaction.expirationDate else { continue }
            guard expiration <= Date() else { continue }
            guard transaction.revocationDate == nil else { continue }

            logRestoreStep(
                "expired transaction in history",
                extra: "product=\(transaction.productID) expiration=\(expiration)"
            )
            if latestExpired == nil || expiration > latestExpired!.expirationDate {
                latestExpired = ExpiredSubscriptionRecord(productID: transaction.productID, expirationDate: expiration)
            }
        }

        return latestExpired
    }

    private func publishExpiredSubscriptionMetadata(productID: String, expirationDate: Date) {
        subscriptionExpirationDate = expirationDate
        activePlanTitle = planTitle(for: productID)
        hasActiveSubscription = false
        hasLifetimeEntitlement = false
        isPro = false
        activeProductIDs = []
        UserDefaults.standard.set(false, forKey: CacheKey.isPro)
    }

    private func logRestoreStep(_ message: String, extra: String? = nil) {
        var parts = ["[StoreKit.Restore]", message]
        if let extra { parts.append(extra) }
        #if DEBUG
        print(parts.joined(separator: " | "))
        #endif
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
