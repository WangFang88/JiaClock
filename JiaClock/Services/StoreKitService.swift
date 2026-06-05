import Foundation
import StoreKit

/// StoreKit 2 购买、恢复与交易监听；不伪造 Pro 状态，结果交由 `EntitlementManager` 刷新。
@MainActor
final class StoreKitService: ObservableObject {
    enum PurchaseState: Equatable {
        case idle
        case purchasing
        case pending
        case succeeded
        case cancelled
        case failed(String)
    }

    @Published private(set) var products: [Product] = []
    @Published private(set) var isLoadingProducts = false
    @Published private(set) var purchaseState: PurchaseState = .idle
    @Published private(set) var isRestoring = false
    @Published var alertMessage: String?

    private var entitlementManager: EntitlementManager?
    private var updatesTask: Task<Void, Never>?
    private var handledTransactionIDs = Set<UInt64>()

    var monthlyProduct: Product? { product(for: ProProductID.monthly) }
    var yearlyProduct: Product? { product(for: ProProductID.yearly) }
    var lifetimeProduct: Product? { product(for: ProProductID.lifetime) }

    func configure(entitlementManager: EntitlementManager) {
        self.entitlementManager = entitlementManager
    }

    func start() {
        guard updatesTask == nil else { return }
        updatesTask = Task { [weak self] in
            await self?.listenForTransactionUpdates()
        }
        Task { await loadProducts() }
        Task { await entitlementManager?.refreshEntitlements(syncWithAppStore: true) }
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
        if case .purchasing = purchaseState { return }
        purchaseState = .purchasing
        defer {
            if case .purchasing = purchaseState { purchaseState = .idle }
        }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                await handleVerifiedTransaction(verification, finish: true)
                purchaseState = .succeeded
            case .userCancelled:
                purchaseState = .cancelled
            case .pending:
                purchaseState = .pending
                alertMessage = L10n.Pro.purchasePending
            @unknown default:
                purchaseState = .failed(L10n.Pro.purchaseUnknownError)
                alertMessage = L10n.Pro.purchaseUnknownError
            }
        } catch {
            purchaseState = .failed(error.localizedDescription)
            alertMessage = L10n.Pro.purchaseFailed(error.localizedDescription)
        }
    }

    func restorePurchases() async {
        isRestoring = true
        defer { isRestoring = false }
        do {
            try await AppStore.sync()
            await entitlementManager?.refreshEntitlements()
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
    }

    func subscriptionPeriodDescription(for product: Product) -> String? {
        guard let subscription = product.subscription else { return nil }
        switch subscription.subscriptionPeriod.unit {
        case .month: return L10n.Pro.periodMonthly
        case .year: return L10n.Pro.periodYearly
        default: return nil
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
            await handleVerifiedTransaction(update, finish: true)
        }
    }

    private func handleVerifiedTransaction(_ verification: VerificationResult<Transaction>, finish: Bool) async {
        switch verification {
        case .verified(let transaction):
            let isNew = handledTransactionIDs.insert(transaction.id).inserted
            if isNew {
                await entitlementManager?.refreshEntitlements()
            }
            if finish {
                await transaction.finish()
            }
        case .unverified(_, let error):
            alertMessage = L10n.Pro.transactionUnverified(error.localizedDescription)
        }
    }
}
