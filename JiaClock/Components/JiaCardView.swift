import SwiftUI

struct JiaCardView<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    var cornerRadius: CGFloat = 20
    var padding: CGFloat = 16
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(padding)
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .strokeBorder(Color.white.opacity(colorScheme == .dark ? 0.12 : 0.22), lineWidth: 1)
                    }
                    .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.35 : 0.12), radius: 18, x: 0, y: 10)
            }
    }
}
