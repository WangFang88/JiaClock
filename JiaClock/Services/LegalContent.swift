import Foundation

enum LegalContent {
    struct Section: Identifiable {
        let id: String
        let title: String?
        let body: String
    }

    static func sections(for type: LegalDocumentType) -> [Section] {
        switch type {
        case .privacyPolicy: privacySections()
        case .termsOfService: termsSections()
        }
    }

    static func body(for type: LegalDocumentType) -> String {
        sections(for: type).map { section in
            if let title = section.title {
                return "\(title)\n\(section.body)"
            }
            return section.body
        }.joined(separator: "\n\n")
    }

    private static func privacySections() -> [Section] {
        [
            Section(id: "effective", title: nil, body: L10n.Legal.privacyEffectiveDate),
            Section(id: "intro", title: nil, body: L10n.Legal.privacyIntro),
            Section(id: "camera", title: L10n.Legal.privacyCameraTitle, body: L10n.Legal.privacyCameraBody),
            Section(id: "widget", title: L10n.Legal.privacyWidgetTitle, body: L10n.Legal.privacyWidgetBody),
            Section(id: "purchases", title: L10n.Legal.privacyPurchasesTitle, body: L10n.Legal.privacyPurchasesBody),
            Section(id: "storage", title: L10n.Legal.privacyStorageTitle, body: L10n.Legal.privacyStorageBody),
            Section(id: "changes", title: L10n.Legal.privacyChangesTitle, body: L10n.Legal.privacyChangesBody),
            Section(id: "contact", title: L10n.Legal.privacyContactTitle, body: L10n.Legal.privacyContactBody),
        ]
    }

    private static func termsSections() -> [Section] {
        [
            Section(id: "effective", title: nil, body: L10n.Legal.termsEffectiveDate),
            Section(id: "intro", title: nil, body: L10n.Legal.termsIntro),
            Section(id: "service", title: L10n.Legal.termsServiceTitle, body: L10n.Legal.termsServiceBody),
            Section(id: "rules", title: L10n.Legal.termsRulesTitle, body: L10n.Legal.termsRulesBody),
            Section(id: "pro", title: L10n.Legal.termsProTitle, body: L10n.Legal.termsProBody),
            Section(id: "subscriptions", title: L10n.Legal.termsSubscriptionsTitle, body: L10n.Legal.termsSubscriptionsBody),
            Section(id: "refunds", title: L10n.Legal.termsRefundsTitle, body: L10n.Legal.termsRefundsBody),
            Section(id: "limitations", title: L10n.Legal.termsLimitationsTitle, body: L10n.Legal.termsLimitationsBody),
            Section(id: "camera", title: L10n.Legal.termsCameraTitle, body: L10n.Legal.termsCameraBody),
            Section(id: "disclaimer", title: L10n.Legal.termsDisclaimerTitle, body: L10n.Legal.termsDisclaimerBody),
            Section(id: "updates", title: L10n.Legal.termsUpdatesTitle, body: L10n.Legal.termsUpdatesBody),
            Section(id: "contact", title: L10n.Legal.termsContactTitle, body: L10n.Legal.termsContactBody),
        ]
    }
}
