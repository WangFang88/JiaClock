import SwiftUI

@main
struct JiaClockApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var settingsStore = ClockSettingsStore()
    @StateObject private var entitlementManager = EntitlementManager()
    @StateObject private var storeKitService = StoreKitService()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(settingsStore)
                .environmentObject(entitlementManager)
                .environmentObject(storeKitService)
                .task {
                    storeKitService.configure(entitlementManager: entitlementManager)
                    storeKitService.start()
                    await entitlementManager.refreshEntitlements()
                    entitlementManager.startPeriodicRefresh()
                    settingsStore.enforceAccessibleTheme(isPro: entitlementManager.isPro)
                    settingsStore.enforceAccessibleClockStyle(isPro: entitlementManager.isPro)
                }
                .onChange(of: scenePhase) { _, phase in
                    switch phase {
                    case .active:
                        entitlementManager.startPeriodicRefresh()
                        Task { await entitlementManager.refreshEntitlements() }
                    case .inactive, .background:
                        entitlementManager.stopPeriodicRefresh()
                    @unknown default:
                        entitlementManager.stopPeriodicRefresh()
                    }
                }
                .onChange(of: entitlementManager.isPro) { _, isPro in
                    settingsStore.enforceAccessibleTheme(isPro: isPro)
                    settingsStore.enforceAccessibleClockStyle(isPro: isPro)
                }
        }
    }
}
