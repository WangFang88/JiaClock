import SwiftUI

@main
struct JiaClockApp: App {
    @StateObject private var settingsStore = ClockSettingsStore()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(settingsStore)
        }
    }
}
