import SwiftUI

enum TransparentBigDigitStyle: String, Codable, CaseIterable, Identifiable {
    case softPinkWhite
    case pureWhite
    case jiaOrange
    case iceBlue

    var id: String { rawValue }

    var title: String {
        switch self {
        case .softPinkWhite: L10n.Transparent.bigDigitSoftPinkWhite
        case .pureWhite: L10n.Transparent.bigDigitPureWhite
        case .jiaOrange: L10n.Transparent.bigDigitJiaOrange
        case .iceBlue: L10n.Transparent.bigDigitIceBlue
        }
    }

    var digitColor: Color {
        switch self {
        case .softPinkWhite:
            Color(red: 1.0, green: 0.86, blue: 0.95).opacity(0.90)
        case .pureWhite:
            Color.white.opacity(0.92)
        case .jiaOrange:
            Color(red: 1.0, green: 0.72, blue: 0.42).opacity(0.92)
        case .iceBlue:
            Color(red: 0.82, green: 0.94, blue: 1.0).opacity(0.90)
        }
    }

    var lineColor: Color {
        switch self {
        case .softPinkWhite, .pureWhite, .iceBlue:
            Color.black.opacity(0.45)
        case .jiaOrange:
            Color.black.opacity(0.38)
        }
    }

    var shadowColor: Color {
        Color.black.opacity(0.35)
    }

    var glowColor: Color {
        switch self {
        case .softPinkWhite:
            Color.white.opacity(0.22)
        case .pureWhite:
            Color.white.opacity(0.18)
        case .jiaOrange:
            Color(red: 1.0, green: 0.62, blue: 0.32).opacity(0.35)
        case .iceBlue:
            Color(red: 0.62, green: 0.84, blue: 1.0).opacity(0.28)
        }
    }

    var highlightColor: Color {
        switch self {
        case .softPinkWhite, .pureWhite, .iceBlue:
            Color.white.opacity(0.28)
        case .jiaOrange:
            Color(red: 1.0, green: 0.88, blue: 0.62).opacity(0.32)
        }
    }
}
