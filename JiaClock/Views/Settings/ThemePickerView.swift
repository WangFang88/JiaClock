import SwiftUI

struct ThemePickerView: View {
    @EnvironmentObject private var settingsStore: ClockSettingsStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                JiaBackgroundView(theme: settingsStore.theme)
                ScrollView {
                    VStack(spacing: 14) {
                        ForEach(ClockTheme.allCases) { item in
                            Button { settingsStore.theme = item } label: { themeRow(item) }.buttonStyle(.plain)
                        }
                    }.padding(20)
                }
            }
            .navigationTitle(L10n.Theme.pickerTitle)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button(L10n.Common.done) { dismiss() } } }
        }
    }

    private func themeRow(_ item: ClockTheme) -> some View {
        JiaCardView {
            HStack(spacing: 14) {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(LinearGradient(colors: item.gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 64, height: 64)
                HStack(spacing: 8) {
                    Text(item.title).font(.headline.weight(.semibold))
                    if item.requiresPro { ProBadgeView(compact: true) }
                }
                Spacer()
                if settingsStore.theme == item {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(item.accentColor)
                }
            }
        }
    }
}
