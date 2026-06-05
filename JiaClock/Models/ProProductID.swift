import Foundation

/// App Store Connect 商品 ID 集中管理（禁止在 View 中硬编码）。
enum ProProductID {
    static let monthly = "jia.clock.pro.monthly"
    static let yearly = "jia.clock.pro.yearly"
    static let lifetime = "jia.clock.pro.lifetime"

    static let all: [String] = [monthly, yearly, lifetime]
    static let subscriptionIDs: Set<String> = [monthly, yearly]
    static let lifetimeIDs: Set<String> = [lifetime]

    static func kind(for productID: String) -> Kind {
        if lifetimeIDs.contains(productID) { return .lifetime }
        if subscriptionIDs.contains(productID) { return .subscription }
        return .unknown
    }

    enum Kind {
        case subscription
        case lifetime
        case unknown
    }
}
