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

        purchasingProductID = product.id
        purchaseState = .purchasing

        defer {
            releaseStoreOperationLock()
        }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                purchaseState = .verifying
                switch verification {
                case .verified(let transaction):
                    await finalizeVerifiedPurchase(transaction, verification: verification)
                    purchaseState = .succeeded
                    purchasingProductID = nil
                case .unverified(let transaction, let error):
                    if !finishedTransactionIDs.contains(transaction.id) {
                        finishedTransactionIDs.insert(transaction.id)
                        await transaction.finish()
                    }
                    purchaseState = .failed(error.localizedDescription)
                    purchasingProductID = nil
                    alertMessage = L10n.Pro.transactionUnverified(error.localizedDescription)
                }
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
            await entitlementManager?.refreshEntitlements(syncWithAppStore: true)
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

    private func finalizeVerifiedPurchase(
        _ transaction: Transaction,
        verification: VerificationResult<Transaction>
    ) async {
        await handleVerifiedTransaction(verification, finish: true, syncEntitlements: true)
        await waitForEntitlementConfirmation(productID: transaction.productID)
    }

    /// 等待 Entitlement 同步完成，避免密码验证后因网络延迟导致 UI 误判失败。
    private func waitForEntitlementConfirmation(productID: String) async {
        for attempt in 0..<8 {
            if entitlementManager?.isPro == true {
                if let ids = entitlementManager?.activeProductIDs, ids.contains(productID) {
                    return
                }
                return
            }
            await entitlementManager?.refreshEntitlements(syncWithAppStore: attempt >= 2)
            if attempt < 7 {
                try? await Task.sleep(nanoseconds: 350_000_000)
            }
        }
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
            let shouldSync = !isStoreOperationLocked
            await handleVerifiedTransaction(update, finish: true, syncEntitlements: shouldSync)
        }
    }

    private func handleVerifiedTransaction(
        _ verification: VerificationResult<Transaction>,
        finish: Bool,
        syncEntitlements: Bool = false
    ) async {
        switch verification {
        case .verified(let transaction):
            entitlementManager?.applyVerifiedTransaction(transaction)
            if finish, !finishedTransactionIDs.contains(transaction.id) {
                finishedTransactionIDs.insert(transaction.id)
                await transaction.finish()
            }
            await entitlementManager?.refreshEntitlements(syncWithAppStore: syncEntitlements)
        case .unverified(let transaction, let error):
            if finish, !finishedTransactionIDs.contains(transaction.id) {
                finishedTransactionIDs.insert(transaction.id)
                await transaction.finish()
            }
            if !isStoreOperationLocked {
                alertMessage = L10n.Pro.transactionUnverified(error.localizedDescription)
            }
        }
    }
}
