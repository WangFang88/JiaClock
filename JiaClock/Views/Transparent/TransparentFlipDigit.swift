import SwiftUI

/// 单个透明翻页数字：无背景，中间横线，数字变化时执行真实上下片翻转。
struct TransparentFlipDigit: View, Equatable {
    let digit: Character
    let fontSize: CGFloat
    let style: TransparentFullScreenDigitStyle

    @State private var displayedDigit: Character
    @State private var isFlipping = false
    @State private var topFlipAngle: Double = 0
    @State private var bottomFlipAngle: Double = 90
    @State private var flipFromDigit: Character = "0"
    @State private var flipToDigit: Character = "0"

    init(digit: Character, fontSize: CGFloat, style: TransparentFullScreenDigitStyle) {
        self.digit = digit
        self.fontSize = fontSize
        self.style = style
        _displayedDigit = State(initialValue: digit)
        _flipFromDigit = State(initialValue: digit)
        _flipToDigit = State(initialValue: digit)
    }

    static func == (lhs: TransparentFlipDigit, rhs: TransparentFlipDigit) -> Bool {
        lhs.digit == rhs.digit
            && lhs.fontSize == rhs.fontSize
            && lhs.style == rhs.style
    }

    private var metrics: TransparentFlipDigitMetrics {
        TransparentFlipDigitMetrics(fontSize: fontSize)
    }

    var body: some View {
        ZStack {
            TransparentFlipDigitLayer(
                digit: isFlipping ? flipFromDigit : displayedDigit,
                half: .bottom,
                fontSize: fontSize,
                style: style
            )

            TransparentFlipDigitLayer(
                digit: isFlipping ? flipToDigit : displayedDigit,
                half: .top,
                fontSize: fontSize,
                style: style
            )

            if isFlipping {
                TransparentFlipDigitLayer(
                    digit: flipFromDigit,
                    half: .top,
                    fontSize: fontSize,
                    style: style
                )
                .rotation3DEffect(
                    .degrees(topFlipAngle),
                    axis: (x: 1, y: 0, z: 0),
                    anchor: .bottom,
                    perspective: 0.45
                )
                .zIndex(2)

                TransparentFlipDigitLayer(
                    digit: flipToDigit,
                    half: .bottom,
                    fontSize: fontSize,
                    style: style
                )
                .rotation3DEffect(
                    .degrees(bottomFlipAngle),
                    axis: (x: 1, y: 0, z: 0),
                    anchor: .top,
                    perspective: 0.45
                )
                .zIndex(1)
            }

            Rectangle()
                .fill(style.lineColor)
                .frame(width: metrics.width * 1.04, height: max(1.5, fontSize * 0.013))
                .zIndex(3)
        }
        .frame(width: metrics.width, height: metrics.height)
        .animation(nil, value: style)
        .animation(nil, value: fontSize)
        .onChange(of: digit) { _, newValue in
            guard newValue != displayedDigit else { return }
            if isFlipping {
                finishFlipImmediately(to: newValue)
            } else {
                startFlip(to: newValue)
            }
        }
    }

    private func startFlip(to newDigit: Character) {
        flipFromDigit = displayedDigit
        flipToDigit = newDigit
        isFlipping = true
        topFlipAngle = 0
        bottomFlipAngle = 90

        withAnimation(.easeIn(duration: 0.16)) {
            topFlipAngle = -90
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
            withAnimation(.easeOut(duration: 0.16)) {
                bottomFlipAngle = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
                displayedDigit = newDigit
                isFlipping = false
                topFlipAngle = 0
                bottomFlipAngle = 90
                flipFromDigit = newDigit
                flipToDigit = newDigit
            }
        }
    }

    private func finishFlipImmediately(to newDigit: Character) {
        displayedDigit = newDigit
        flipFromDigit = newDigit
        flipToDigit = newDigit
        isFlipping = false
        topFlipAngle = 0
        bottomFlipAngle = 90
    }
}
