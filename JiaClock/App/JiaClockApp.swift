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
                    settingsStore.enforceAccessibleTheme(isPro: entitlementManager.isPro)
                }
                .onChange(of: scenePhase) { _, phase in
                    if phase == .active {
                        Task { await entitlementManager.refreshEntitlements() }
                    }
                }
                .onChange(of: entitlementManager.isPro) { _, isPro in
                    settingsStore.enforceAccessibleTheme(isPro: isPro)
                }
        }
    }
}
