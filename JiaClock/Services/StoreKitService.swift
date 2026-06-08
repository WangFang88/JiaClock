import Foundation
import StoreKit
import os

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

    private enum PurchaseFlowError: Error {
        case timedOut
    }

    @Published private(set) var products: [Product] = []
    @Published private(set) var isLoadingProducts = false
    @Published private(set) var purchaseState: PurchaseState = .idle
    @Published private(set) var purchasingProductID: String?
    @Published private(set) var isRestoring = false
    @Published var alertMessage: String?

    private let log = Logger(subsystem: Bundle.main.bundleIdentifier ?? "JiaClock", category: "StoreKit")

    private var entitlementManager: EntitlementManager?
    private var updatesTask: Task<Void, Never>?
    private var finishedTransactionIDs = Set<UInt64>()
    /// 当前 `product.purchase()` 会话 ID，用于忽略并发的 Transaction.updates 重复处理。
    private var activePurchaseSessionID: UUID?
    /// 购买 / 恢复互斥锁，防止重复触发 StoreKit 流程。
    private var isStoreOperationLocked = false
    private var operationWatchdogTask: Task<Void, Never>?
    private var idleResetTask: Task<Void, Never>?

    /// StoreKit 系统弹窗最长等待时间（秒）。
    private static let purchaseDialogTimeout: TimeInterval = 180
    /// 验证阶段超时（秒）。
    private static let verifyingTimeout: TimeInterval = 30
    /// 互斥锁兜底释放时间（秒）。
    private static let operationWatchdogTimeout: TimeInterval = 200

    var monthlyProduct: Product? { product(for: ProProductID.monthly) }
    var yearlyProduct: Product? { product(for: ProProductID.yearly) }
    var lifetimeProduct: Product? { product(for: ProProductID.lifetime) }

    var isPurchaseInProgress: Bool {
        switch purchaseState {
        case .purchasing, .verifying:
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
        operationWatchdogTask?.cancel()
        idleResetTask?.cancel()
    }

    // MARK: - Public entry points (UI)

    /// 从 UI 发起购买；使用独立 Task，避免 Paywall sheet 关闭时取消 StoreKit 流程。
    func requestPurchase(_ product: Product) {
        logStep("requestPurchase tapped", productID: product.id, extra: "busy=\(isStoreBusy) state=\(purchaseState) locked=\(isStoreOperationLocked)")

        if isPurchaseInProgress || isStoreOperationLocked {
            logStep("requestPurchase rejected — operation in progress")
            alertMessage = L10n.Pro.operationInProgress
            return
        }

        Task {
            await purchase(product)
        }
    }

    /// 从 UI 发起恢复购买；同样独立于 View 生命周期。
    func requestRestorePurchases() {
        logStep("requestRestorePurchases tapped", extra: "busy=\(isStoreBusy)")

        if isStoreBusy {
            logStep("requestRestorePurchases rejected — store busy")
            alertMessage = L10n.Pro.operationInProgress
            return
        }

        Task {
            await restorePurchases()
        }
    }

    /// Paywall 打开时清理上一轮异常残留，避免按钮永久 disabled。
    func recoverFromStalePurchaseStateIfNeeded() {
        guard !isStoreOperationLocked else { return }

        switch purchaseState {
        case .purchasing, .verifying:
            logStep("recoverFromStalePurchaseStateIfNeeded — resetting stuck state", extra: "\(purchaseState)")
            purchaseState = .idle
            purchasingProductID = nil
            activePurchaseSessionID = nil
        default:
            break
        }
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
                    logStep("loadProducts succeeded", extra: "count=\(products.count)")
                    return
                }
            } catch {
                logStep("loadProducts attempt \(attempt + 1) failed", extra: error.localizedDescription)
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
        logStep("purchase flow started", productID: product.id)

        guard acquireStoreOperationLock() else {
            logStep("purchase aborted — could not acquire lock")
            return
        }

        let sessionID = UUID()
        activePurchaseSessionID = sessionID
        purchasingProductID = product.id
        purchaseState = .purchasing
        startOperationWatchdog()

        defer {
            logStep("purchase flow cleanup", extra: "session=\(sessionID.uuidString.prefix(8)) finalState=\(purchaseState)")
            cancelOperationWatchdog()
            if activePurchaseSessionID == sessionID {
                activePurchaseSessionID = nil
            }
            releaseStoreOperationLock()

            switch purchaseState {
            case .purchasing, .verifying:
                logStep("purchase abnormal exit — forcing idle", extra: "\(purchaseState)")
                purchaseState = .idle
                purchasingProductID = nil
            default:
                break
            }
        }

        do {
            logStep("calling product.purchase()", productID: product.id, extra: "session=\(sessionID.uuidString.prefix(8))")
            let result = try await withTimeout(seconds: Self.purchaseDialogTimeout) {
                try await product.purchase()
            }

            guard activePurchaseSessionID == sessionID else {
                logStep("purchase result ignored — session superseded")
                return
            }

            logStep("product.purchase() returned", extra: "\(describePurchaseResult(result))")

            switch result {
            case .success(let verification):
                purchaseState = .verifying
                logStep("verifying transaction", productID: product.id)
                try await withTimeout(seconds: Self.verifyingTimeout) { () -> Void in
                    await completePurchase(from: verification, sessionID: sessionID)
                }
            case .userCancelled:
                logStep("user cancelled purchase dialog")
                purchaseState = .cancelled
                purchasingProductID = nil
                scheduleReturnToIdle()
            case .pending:
                logStep("purchase pending approval")
                purchaseState = .pending
                purchasingProductID = nil
                alertMessage = L10n.Pro.purchasePending
                scheduleReturnToIdle()
            @unknown default:
                logStep("purchase unknown result")
                purchaseState = .failed(L10n.Pro.purchaseUnknownError)
                purchasingProductID = nil
                alertMessage = L10n.Pro.purchaseUnknownError
                scheduleReturnToIdle()
            }
        } catch is PurchaseFlowError {
            logStep("purchase timed out")
            purchaseState = .failed(L10n.Pro.purchaseTimedOut)
            purchasingProductID = nil
            alertMessage = L10n.Pro.purchaseTimedOut
            scheduleReturnToIdle()
        } catch is CancellationError {
            logStep("purchase task cancelled")
            purchaseState = .cancelled
            purchasingProductID = nil
            scheduleReturnToIdle()
        } catch {
            logStep("purchase threw error", extra: error.localizedDescription)
            purchaseState = .failed(error.localizedDescription)
            purchasingProductID = nil
            alertMessage = L10n.Pro.purchaseFailed(error.localizedDescription)
            scheduleReturnToIdle()
        }

        logStep("purchase flow finished", extra: "state=\(purchaseState)")
    }

    func restorePurchases() async {
        logStep("restorePurchases started")

        guard acquireStoreOperationLock() else {
            logStep("restorePurchases aborted — could not acquire lock")
            return
        }

        isRestoring = true
        startOperationWatchdog()

        defer {
            logStep("restorePurchases cleanup")
            cancelOperationWatchdog()
            isRestoring = false
            releaseStoreOperationLock()
        }

        do {
            logStep("calling AppStore.sync()")
            try await withTimeout(seconds: Self.purchaseDialogTimeout) {
                try await AppStore.sync()
            }
            await entitlementManager?.refreshEntitlements(syncWithAppStore: false)
            if entitlementManager?.isPro == true {
                logStep("restore succeeded — pro active")
                alertMessage = L10n.Pro.restoreSucceeded
            } else {
                logStep("restore completed — no entitlements found")
                alertMessage = L10n.Pro.restoreNothingFound
            }
        } catch is PurchaseFlowError {
            logStep("restore timed out")
            alertMessage = L10n.Pro.purchaseTimedOut
        } catch {
            logStep("restore failed", extra: error.localizedDescription)
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
        logStep("resetPurchaseState")
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

    // MARK: - Lock & watchdog

    private func acquireStoreOperationLock() -> Bool {
        guard !isStoreOperationLocked else {
            logStep("acquireStoreOperationLock failed — already locked")
            alertMessage = L10n.Pro.operationInProgress
            return false
        }
        isStoreOperationLocked = true
        logStep("acquireStoreOperationLock succeeded")
        return true
    }

    private func releaseStoreOperationLock() {
        guard isStoreOperationLocked else { return }
        isStoreOperationLocked = false
        logStep("releaseStoreOperationLock")
    }

    private func startOperationWatchdog() {
        operationWatchdogTask?.cancel()
        operationWatchdogTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(Self.operationWatchdogTimeout * 1_000_000_000))
            guard !Task.isCancelled else { return }
            await self?.forceResetStoreOperation(reason: "watchdog timeout after \(Self.operationWatchdogTimeout)s")
        }
    }

    private func cancelOperationWatchdog() {
        operationWatchdogTask?.cancel()
        operationWatchdogTask = nil
    }

    private func forceResetStoreOperation(reason: String) {
        logStep("forceResetStoreOperation", extra: reason)
        activePurchaseSessionID = nil
        purchasingProductID = nil
        isRestoring = false
        releaseStoreOperationLock()
        purchaseState = .idle
        alertMessage = L10n.Pro.purchaseTimedOut
    }

    private func scheduleReturnToIdle(after seconds: TimeInterval = 0.6) {
        idleResetTask?.cancel()
        idleResetTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
            guard !Task.isCancelled else { return }
            guard let self else { return }
            switch self.purchaseState {
            case .cancelled, .failed, .pending:
                self.logStep("scheduleReturnToIdle — resetting to idle from \(self.purchaseState)")
                self.purchaseState = .idle
                self.purchasingProductID = nil
            default:
                break
            }
        }
    }

    // MARK: - Purchase completion

    private func completePurchase(
        from verification: VerificationResult<Transaction>,
        sessionID: UUID
    ) async {
        guard activePurchaseSessionID == sessionID else {
            logStep("completePurchase ignored — session superseded")
            return
        }

        switch verification {
        case .verified(let transaction):
            logStep("transaction verified", productID: transaction.productID, extra: "id=\(transaction.id)")
            entitlementManager?.applyVerifiedTransaction(transaction)
            await finishTransactionIfNeeded(transaction)
            purchaseState = .succeeded
            purchasingProductID = nil
            logStep("purchase succeeded")
        case .unverified(let transaction, let error):
            logStep("transaction unverified", productID: transaction.productID, extra: error.localizedDescription)
            await finishTransactionIfNeeded(transaction)
            purchaseState = .failed(error.localizedDescription)
            purchasingProductID = nil
            alertMessage = L10n.Pro.transactionUnverified(error.localizedDescription)
            scheduleReturnToIdle()
        }
    }

    private func finishTransactionIfNeeded(_ transaction: Transaction) async {
        guard !finishedTransactionIDs.contains(transaction.id) else { return }
        finishedTransactionIDs.insert(transaction.id)
        await transaction.finish()
        logStep("transaction finished", extra: "id=\(transaction.id)")
    }

    // MARK: - Transaction updates

    private func listenForTransactionUpdates() async {
        for await update in Transaction.updates {
            if activePurchaseSessionID != nil {
                logStep("Transaction.updates skipped — active purchase session")
                continue
            }
            logStep("Transaction.updates received — handling background update")
            await handleBackgroundTransactionUpdate(update)
        }
    }

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

    // MARK: - Helpers

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

    private func withTimeout<T>(
        seconds: TimeInterval,
        operation: @escaping @Sendable () async throws -> T
    ) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                try await operation()
            }
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                throw PurchaseFlowError.timedOut
            }
            guard let result = try await group.next() else {
                throw PurchaseFlowError.timedOut
            }
            group.cancelAll()
            return result
        }
    }

    private func describePurchaseResult(_ result: Product.PurchaseResult) -> String {
        switch result {
        case .success: return "success"
        case .userCancelled: return "userCancelled"
        case .pending: return "pending"
        @unknown default: return "unknown"
        }
    }

    private func logStep(_ message: String, productID: String? = nil, extra: String? = nil) {
        var parts = ["[StoreKit]", message]
        if let productID { parts.append("product=\(productID)") }
        if let extra { parts.append(extra) }
        let line = parts.joined(separator: " | ")
        log.info("\(line, privacy: .public)")
        #if DEBUG
        print(line)
        #endif
    }
}
