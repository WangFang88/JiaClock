import SwiftUI

struct LegalDocumentView: View {
    let type: LegalDocumentType
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                Text(LegalContent.body(for: type)).padding(20).frame(maxWidth: .infinity, alignment: .leading)
            }
            .navigationTitle(type.title)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button(L10n.Common.done) { dismiss() } } }
        }
    }
}
