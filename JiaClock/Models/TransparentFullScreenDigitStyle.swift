import SwiftUI

/// 全屏透明翻页数字视觉样式（无数字背景色）。
enum TransparentFullScreenDigitStyle: String, Codable, CaseIterable, Identifiable {
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
            Color(red: 1.0, green: 0.82, blue: 0.92).opacity(0.90)
        case .pureWhite:
            Color.white.opacity(0.92)
        case .jiaOrange:
            Color(red: 1.0, green: 0.62, blue: 0.30).opacity(0.95)
        case .iceBlue:
            Color(red: 0.82, green: 0.94, blue: 1.0).opacity(0.90)
        }
    }

    var lineColor: Color {
        switch self {
        case .softPinkWhite, .pureWhite, .iceBlue:
            Color.black.opacity(0.42)
        case .jiaOrange:
            Color.black.opacity(0.38)
        }
    }

    var shadowColor: Color {
        Color.black.opacity(0.38)
    }

    var glowColor: Color {
        switch self {
        case .softPinkWhite:
            Color.white.opacity(0.24)
        case .pureWhite:
            Color.white.opacity(0.20)
        case .jiaOrange:
            Color(red: 1.0, green: 0.62, blue: 0.32).opacity(0.38)
        case .iceBlue:
            Color(red: 0.62, green: 0.84, blue: 1.0).opacity(0.30)
        }
    }

    var highlightColor: Color {
        switch self {
        case .softPinkWhite, .pureWhite, .iceBlue:
            Color.white.opacity(0.30)
        case .jiaOrange:
            Color(red: 1.0, green: 0.88, blue: 0.62).opacity(0.34)
        }
    }

    var strokeColor: Color {
        digitColor.opacity(0.35)
    }
}

typealias TransparentBigDigitStyle = TransparentFullScreenDigitStyle
