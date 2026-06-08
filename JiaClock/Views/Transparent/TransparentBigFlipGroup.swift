import SwiftUI

/// 两位数字组，例如 10、15、48。
struct TransparentBigFlipGroup: View {
    let tens: Character
    let ones: Character
    let fontSize: CGFloat
    let pairSpacing: CGFloat
    let style: TransparentBigDigitStyle

    var body: some View {
        HStack(spacing: pairSpacing) {
            TransparentBigFlipDigit(digit: tens, fontSize: fontSize, style: style)
            TransparentBigFlipDigit(digit: ones, fontSize: fontSize, style: style)
        }
    }
}
