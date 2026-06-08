import SwiftUI

/// 两位数字组（如 10、15、48），无背景。
struct TransparentFlipNumberGroup: View, Equatable {
    let tens: Character
    let ones: Character
    let fontSize: CGFloat
    let pairSpacing: CGFloat
    let style: TransparentFullScreenDigitStyle

    static func == (lhs: TransparentFlipNumberGroup, rhs: TransparentFlipNumberGroup) -> Bool {
        lhs.tens == rhs.tens
            && lhs.ones == rhs.ones
            && lhs.fontSize == rhs.fontSize
            && lhs.pairSpacing == rhs.pairSpacing
            && lhs.style == rhs.style
    }

    var body: some View {
        HStack(spacing: pairSpacing) {
            TransparentFlipDigit(digit: tens, fontSize: fontSize, style: style)
            TransparentFlipDigit(digit: ones, fontSize: fontSize, style: style)
        }
    }
}
