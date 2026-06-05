import SwiftUI

struct LegalDocumentView: View {
    let type: LegalDocumentType
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    ForEach(LegalContent.sections(for: type)) { section in
                        VStack(alignment: .leading, spacing: 8) {
                            if let title = section.title {
                                Text(title)
                                    .font(.headline.weight(.semibold))
                            }
                            Text(section.body)
                                .font(.subheadline)
                                .foregroundStyle(.primary.opacity(0.88))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .navigationTitle(type.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button(L10n.Common.done) { dismiss() } } }
        }
    }
}
