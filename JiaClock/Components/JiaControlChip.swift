import SwiftUI

struct JiaControlChip: View {
    let icon: String
    let title: String
    var action: (() -> Void)?

    var body: some View {
        Group {
            if let action {
                Button(action: action) { label }.buttonStyle(.plain)
            } else {
                label
            }
        }
    }

    private var label: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
            Text(title)
        }
        .font(.subheadline.weight(.semibold))
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay {
            Capsule().strokeBorder(Color.white.opacity(0.22), lineWidth: 1)
        }
    }
}
