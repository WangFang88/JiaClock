import SwiftUI

@main
struct JiaClockApp: App {
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
                    settingsStore.enforceAccessibleTheme(isPro: entitlementManager.isPro)
                }
                .onChange(of: entitlementManager.isPro) { _, isPro in
                    settingsStore.enforceAccessibleTheme(isPro: isPro)
                }
        }
    }
}
