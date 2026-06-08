import SwiftUI

/// 绘制单个翻页数字的上半或下半区，用于翻页动画分层。
struct TransparentFlipDigitLayer: View {
    enum Half {
        case top
        case bottom
    }

    let digit: Character
    let half: Half
    let fontSize: CGFloat
    let style: TransparentFullScreenDigitStyle

    private var metrics: TransparentFlipDigitMetrics {
        TransparentFlipDigitMetrics(fontSize: fontSize)
    }

    var body: some View {
        flipDigitText(String(digit))
            .frame(width: metrics.width, height: metrics.height, alignment: .center)
            .mask(alignment: half == .top ? .top : .bottom) {
                Rectangle()
                    .frame(height: metrics.halfHeight)
            }
    }

    @ViewBuilder
    private func flipDigitText(_ text: String) -> some View {
        Text(text)
            .font(.system(size: fontSize, weight: .black, design: .rounded))
            .monospacedDigit()
            .fontWidth(.expanded)
            .scaleEffect(x: 1.10, y: 1.0)
            .foregroundStyle(style.digitColor)
            .shadow(color: style.shadowColor, radius: fontSize * 0.06, x: 0, y: fontSize * 0.025)
            .shadow(color: style.glowColor, radius: fontSize * 0.03, x: 0, y: 0)
            .overlay {
                Text(text)
                    .font(.system(size: fontSize, weight: .black, design: .rounded))
                    .monospacedDigit()
                    .fontWidth(.expanded)
                    .scaleEffect(x: 1.10, y: 1.0)
                    .foregroundStyle(.clear)
                    .shadow(color: style.strokeColor, radius: 0, x: 0, y: 1)
            }
            .overlay(alignment: .top) {
                LinearGradient(
                    colors: [style.highlightColor, .clear],
                    startPoint: .top,
                    endPoint: .center
                )
                .blendMode(.overlay)
                .allowsHitTesting(false)
            }
    }
}

struct TransparentFlipDigitMetrics {
    let fontSize: CGFloat
    let width: CGFloat
    let height: CGFloat
    let halfHeight: CGFloat

    init(fontSize: CGFloat) {
        self.fontSize = fontSize
        width = fontSize * 0.68
        height = fontSize * 1.12
        halfHeight = height * 0.5
    }
}
