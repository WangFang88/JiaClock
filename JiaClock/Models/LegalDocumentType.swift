import Foundation

enum LegalDocumentType: String, CaseIterable, Identifiable {
    case termsOfService
    case privacyPolicy

    var id: String { rawValue }

    var title: String {
        switch self {
        case .termsOfService: L10n.Legal.termsOfService
        case .privacyPolicy: L10n.Legal.privacyPolicy
        }
    }
}
