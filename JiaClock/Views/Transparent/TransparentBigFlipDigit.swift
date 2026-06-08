import SwiftUI

/// 单个超大透明翻页数字：无底色，中间横线穿过数字。
struct TransparentBigFlipDigit: View {
    let digit: Character
    let fontSize: CGFloat
    let style: TransparentBigDigitStyle

    var body: some View {
        Text(String(digit))
            .font(.system(size: fontSize, weight: .black, design: .rounded))
            .monospacedDigit()
            .foregroundStyle(style.digitColor)
            .shadow(color: style.shadowColor, radius: 8, x: 0, y: 3)
            .shadow(color: style.glowColor, radius: 4, x: 0, y: 0)
            .overlay(alignment: .top) {
                LinearGradient(
                    colors: [style.highlightColor, .clear],
                    startPoint: .top,
                    endPoint: .center
                )
                .blendMode(.overlay)
                .allowsHitTesting(false)
            }
            .overlay(alignment: .center) {
                Rectangle()
                    .fill(style.lineColor)
                    .frame(height: max(1.5, fontSize * 0.014))
            }
            .fixedSize()
    }
}
