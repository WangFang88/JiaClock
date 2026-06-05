import Foundation

enum LegalContent {
    static func body(for type: LegalDocumentType) -> String {
        switch type {
        case .termsOfService:
            L10n.Legal.placeholderBody + "\n\n" + type.title
        case .privacyPolicy:
            L10n.Legal.placeholderBody + "\n\n" + type.title
        }
    }
}
