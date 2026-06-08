import Foundation
import StoreKit

/// StoreKit 2 购买、恢复与交易监听；不伪造 Pro 状态，结果交由 `EntitlementManager` 刷新。
@MainActor
final class StoreKitService: ObservableObject {
    enum PurchaseState: Equatable {
        case idle
        case purchasing
        case verifying
        case pending
        case succeeded
        case cancelled
        case failed(String)
    }

    @Published private(set) var products: [Product] = []
    @Published private(set) var isLoadingProducts = false
    @Published private(set) var purchaseState: PurchaseState = .idle
    @Published private(set) var purchasingProductID: String?
    @Published private(set) var isRestoring = false
    @Published var alertMessage: String?

    private var entitlementManager: EntitlementManager?
    private var updatesTask: Task<Void, Never>?
    private var finishedTransactionIDs = Set<UInt64>()
    /// 当前 `product.purchase()` 会话 ID，用于忽略并发的 Transaction.updates 重复处理。
    private var activePurchaseSessionID: UUID?
    /// 购买 / 恢复互斥锁，防止重复触发 StoreKit 流程。
    private var isStoreOperationLocked = false

    var monthlyProduct: Product? { product(for: ProProductID.monthly) }
    var yearlyProduct: Product? { product(for: ProProductID.yearly) }
    var lifetimeProduct: Product? { product(for: ProProductID.lifetime) }

    var isPurchaseInProgress: Bool {
        switch purchaseState {
        case .purchasing, .verifying, .pending:
            return true
        default:
            return false
        }
    }

    var isStoreBusy: Bool {
        isStoreOperationLocked || isPurchaseInProgress || isRestoring
    }

    func configure(entitlementManager: EntitlementManager) {
        self.entitlementManager = entitlementManager
    }

    func start() {
        guard updatesTask == nil else { return }
        updatesTask = Task { [weak self] in
            await self?.listenForTransactionUpdates()
        }
        Task { await loadProducts() }
        Task { await entitlementManager?.refreshEntitlements() }
    }

    deinit {
        updatesTask?.cancel()
    }

    func loadProducts() async {
        isLoadingProducts = true
        defer { isLoadingProducts = false }

        for attempt in 0..<3 {
            do {
                var loaded = try await Product.products(for: ProProductID.all)
                if loaded.isEmpty {
                    loaded = await loadProductsIndividually()
                }
                if !loaded.isEmpty {
                    products = loaded.sorted { sortRank(for: $0.id) < sortRank(for: $1.id) }
                    return
                }
            } catch {
                if attempt == 2 {
                    alertMessage = L10n.Pro.productsLoadFailed(error.localizedDescription)
                }
            }
            if attempt < 2 {
                try? await Task.sleep(nanoseconds: 1_500_000_000)
            }
        }
    }

    private func loadProductsIndividually() async -> [Product] {
        var merged: [Product] = []
        for id in ProProductID.all {
            guard let product = try? await Product.products(for: [id]).first else { continue }
            if !merged.contains(where: { $0.id == product.id }) {
                merged.append(product)
            }
        }
        return merged
    }

    func purchase(_ product: Product) async {
        guard acquireStoreOperationLock() else { return }

        let sessionID = UUID()
        activePurchaseSessionID = sessionID
        purchasingProductID = product.id
        purchaseState = .purchasing

        defer {
            if activePurchaseSessionID == sessionID {
                activePurchaseSessionID = nil
            }
            releaseStoreOperationLock()
        }

        do {
            let result = try await product.purchase()
            guard activePurchaseSessionID == sessionID else { return }

            switch result {
            case .success(let verification):
                purchaseState = .verifying
                await completePurchase(from: verification, sessionID: sessionID)
            case .userCancelled:
                purchaseState = .cancelled
                purchasingProductID = nil
            case .pending:
                purchaseState = .pending
                purchasingProductID = nil
                alertMessage = L10n.Pro.purchasePending
            @unknown default:
                purchaseState = .failed(L10n.Pro.purchaseUnknownError)
                purchasingProductID = nil
                alertMessage = L10n.Pro.purchaseUnknownError
            }
        } catch {
            purchaseState = .failed(error.localizedDescription)
            purchasingProductID = nil
            alertMessage = L10n.Pro.purchaseFailed(error.localizedDescription)
        }
    }

    func restorePurchases() async {
        guard acquireStoreOperationLock() else { return }

        isRestoring = true
        defer {
            isRestoring = false
            releaseStoreOperationLock()
        }

        do {
            try await AppStore.sync()
            await entitlementManager?.refreshEntitlements(syncWithAppStore: false)
            if entitlementManager?.isPro == true {
                alertMessage = L10n.Pro.restoreSucceeded
            } else {
                alertMessage = L10n.Pro.restoreNothingFound
            }
        } catch {
            alertMessage = L10n.Pro.restoreFailed(error.localizedDescription)
        }
    }

    func productDisplayName(_ product: Product) -> String {
        product.displayName
    }

    func productDisplayPrice(_ product: Product) -> String {
        product.displayPrice
    }

    func resetPurchaseState() {
        purchaseState = .idle
        purchasingProductID = nil
    }

    func subscriptionPeriodDescription(for product: Product) -> String? {
        guard let subscription = product.subscription else { return nil }
        switch subscription.subscriptionPeriod.unit {
        case .month: return L10n.Pro.periodMonthly
        case .year: return L10n.Pro.periodYearly
        default: return nil
        }
    }

    private func acquireStoreOperationLock() -> Bool {
        guard !isStoreOperationLocked else {
            alertMessage = L10n.Pro.operationInProgress
            return false
        }
        isStoreOperationLocked = true
        return true
    }

    private func releaseStoreOperationLock() {
        isStoreOperationLocked = false
    }

    /// 单次购买完成：只处理 `product.purchase()` 返回的交易，不再调用 `AppStore.sync()`。
    private func completePurchase(
        from verification: VerificationResult<Transaction>,
        sessionID: UUID
    ) async {
        guard activePurchaseSessionID == sessionID else { return }

        switch verification {
        case .verified(let transaction):
            entitlementManager?.applyVerifiedTransaction(transaction)
            await finishTransactionIfNeeded(transaction)
            purchaseState = .succeeded
            purchasingProductID = nil
        case .unverified(let transaction, let error):
            await finishTransactionIfNeeded(transaction)
            purchaseState = .failed(error.localizedDescription)
            purchasingProductID = nil
            alertMessage = L10n.Pro.transactionUnverified(error.localizedDescription)
        }
    }

    private func finishTransactionIfNeeded(_ transaction: Transaction) async {
        guard !finishedTransactionIDs.contains(transaction.id) else { return }
        finishedTransactionIDs.insert(transaction.id)
        await transaction.finish()
    }

    private func product(for id: String) -> Product? {
        products.first { $0.id == id }
    }

    private func sortRank(for productID: String) -> Int {
        switch productID {
        case ProProductID.monthly: return 0
        case ProProductID.yearly: return 1
        case ProProductID.lifetime: return 2
        default: return 99
        }
    }

    private func listenForTransactionUpdates() async {
        for await update in Transaction.updates {
            // 活跃购买会话中由 `product.purchase()` 结果统一收尾，避免重复 finish / 重复 sync 触发密码弹窗。
            if activePurchaseSessionID != nil || isStoreOperationLocked {
                continue
            }
            await handleBackgroundTransactionUpdate(update)
        }
    }

    /// 处理非当前购买会话的后台交易（如家庭批准、续订等）。
    private func handleBackgroundTransactionUpdate(_ verification: VerificationResult<Transaction>) async {
        switch verification {
        case .verified(let transaction):
            entitlementManager?.applyVerifiedTransaction(transaction)
            await finishTransactionIfNeeded(transaction)
            await entitlementManager?.refreshEntitlements(syncWithAppStore: false)
        case .unverified(let transaction, let error):
            await finishTransactionIfNeeded(transaction)
            alertMessage = L10n.Pro.transactionUnverified(error.localizedDescription)
        }
    }
}
