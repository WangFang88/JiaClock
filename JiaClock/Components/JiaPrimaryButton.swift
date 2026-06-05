import SwiftUI

struct JiaPrimaryButton: View {
    let title: String
    var systemImage: String? = nil
    var isFullWidth: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let systemImage {
                    Image(systemName: systemImage).font(.body.weight(.semibold))
                }
                Text(title).font(.body.weight(.semibold))
            }
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background {
                Capsule(style: .continuous)
                    .fill(LinearGradient(
                        colors: [Color.white.opacity(0.95), Color.white.opacity(0.82)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ))
            }
            .foregroundStyle(Color(red: 0.12, green: 0.12, blue: 0.16))
        }
        .buttonStyle(.plain)
    }
}
