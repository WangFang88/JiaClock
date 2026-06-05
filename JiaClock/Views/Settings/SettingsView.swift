import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var settingsStore: ClockSettingsStore
    @EnvironmentObject private var storeKit: StoreKitService
    @EnvironmentObject private var entitlements: EntitlementManager
    @Environment(\.dismiss) private var dismiss
    @State private var showThemePicker = false
    @State private var showPaywall = false
    @State private var selectedLegal: LegalDocumentType?
    private var theme: ClockTheme { settingsStore.theme }

    var body: some View {
        NavigationStack {
            ZStack {
                JiaBackgroundView(theme: theme)
                Form {
                    Section(L10n.Settings.timeSection) {
                        Toggle(L10n.Settings.use24Hour, isOn: boolBinding(\.use24HourFormat))
                        Toggle(L10n.Settings.showSeconds, isOn: boolBinding(\.showSeconds))
                        Toggle(L10n.Settings.showDate, isOn: boolBinding(\.showDate))
                        Toggle(L10n.Settings.showWeekday, isOn: boolBinding(\.showWeekday))
                    }
                    Section(L10n.Settings.displaySection) {
                        TextField(L10n.Settings.taglinePlaceholder, text: stringBinding(\.customTagline))
                        Button { showThemePicker = true } label: {
                            HStack { Text(L10n.Settings.theme); Spacer(); Text(theme.title).foregroundStyle(.secondary) }
                        }
                    }
                    Section(L10n.Settings.proSection) {
                        Button { showPaywall = true } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(L10n.Settings.upgradePro).font(.body.weight(.semibold))
                                    Text(L10n.Settings.upgradeProSubtitle).font(.caption).foregroundStyle(.secondary)
                                }
                                Spacer()
                                ProBadgeView()
                            }
                        }
                        Button {
                            Task { await storeKit.restorePurchases() }
                        } label: {
                            HStack {
                                Text(L10n.Pro.restorePurchases)
                                Spacer()
                                if storeKit.isRestoring { ProgressView().controlSize(.small) }
                            }
                        }
                        .disabled(storeKit.isRestoring)
                    }
                    Section(L10n.Settings.legalSection) {
                        ForEach(LegalDocumentType.allCases) { doc in
                            Button(doc.title) { selectedLegal = doc }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(L10n.Settings.title)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button(L10n.Common.done) { dismiss() } } }
            .sheet(isPresented: $showThemePicker) {
                ThemePickerView()
                    .environmentObject(settingsStore)
                    .environmentObject(entitlements)
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
                    .environmentObject(storeKit)
                    .environmentObject(entitlements)
            }
            .alert(L10n.Pro.alertTitle, isPresented: alertBinding) {
                Button(L10n.Common.done, role: .cancel) {}
            } message: {
                Text(storeKit.alertMessage ?? "")
            }
            .sheet(item: $selectedLegal) { LegalDocumentView(type: $0) }
        }
    }

    private var alertBinding: Binding<Bool> {
        Binding(
            get: { storeKit.alertMessage != nil && !showPaywall },
            set: { if !$0 { storeKit.alertMessage = nil } }
        )
    }

    private func boolBinding(_ keyPath: WritableKeyPath<ClockSettings, Bool>) -> Binding<Bool> {
        Binding(
            get: { settingsStore.settings[keyPath: keyPath] },
            set: { newValue in settingsStore.update { $0[keyPath: keyPath] = newValue } }
        )
    }

    private func stringBinding(_ keyPath: WritableKeyPath<ClockSettings, String>) -> Binding<String> {
        Binding(
            get: { settingsStore.settings[keyPath: keyPath] },
            set: { newValue in settingsStore.update { $0[keyPath: keyPath] = newValue } }
        )
    }
}
