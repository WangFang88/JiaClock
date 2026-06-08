import SwiftUI

/// 透明时钟其他样式共用的翻页动画引擎（参数与全屏透明翻页一致）。
struct TransparentClockFlipAnimatingDigit<Content: View>: View {
    let digit: Character
    let contentSize: CGSize
    let showCenterLine: Bool
    let centerLineColor: Color
    let centerLineHeight: CGFloat
    @ViewBuilder let digitContent: (Character) -> Content

    @State private var displayedDigit: Character
    @State private var isFlipping = false
    @State private var topFlipAngle: Double = 0
    @State private var bottomFlipAngle: Double = 90
    @State private var flipFromDigit: Character = "0"
    @State private var flipToDigit: Character = "0"

    init(
        digit: Character,
        contentSize: CGSize,
        showCenterLine: Bool = false,
        centerLineColor: Color = .clear,
        centerLineHeight: CGFloat = 1,
        @ViewBuilder digitContent: @escaping (Character) -> Content
    ) {
        self.digit = digit
        self.contentSize = contentSize
        self.showCenterLine = showCenterLine
        self.centerLineColor = centerLineColor
        self.centerLineHeight = centerLineHeight
        self.digitContent = digitContent
        _displayedDigit = State(initialValue: digit)
        _flipFromDigit = State(initialValue: digit)
        _flipToDigit = State(initialValue: digit)
    }

    private var halfHeight: CGFloat {
        contentSize.height * 0.5
    }

    var body: some View {
        ZStack {
            halfLayer(digit: isFlipping ? flipFromDigit : displayedDigit, half: .bottom)
            halfLayer(digit: isFlipping ? flipToDigit : displayedDigit, half: .top)

            if isFlipping {
                halfLayer(digit: flipFromDigit, half: .top)
                    .rotation3DEffect(
                        .degrees(topFlipAngle),
                        axis: (x: 1, y: 0, z: 0),
                        anchor: .bottom,
                        perspective: 0.45
                    )
                    .zIndex(2)

                halfLayer(digit: flipToDigit, half: .bottom)
                    .rotation3DEffect(
                        .degrees(bottomFlipAngle),
                        axis: (x: 1, y: 0, z: 0),
                        anchor: .top,
                        perspective: 0.45
                    )
                    .zIndex(1)
            }

            if showCenterLine {
                Rectangle()
                    .fill(centerLineColor)
                    .frame(width: contentSize.width, height: centerLineHeight)
                    .zIndex(3)
            }
        }
        .frame(width: contentSize.width, height: contentSize.height)
        .onChange(of: digit) { _, newValue in
            guard newValue != displayedDigit else { return }
            if isFlipping {
                finishFlipImmediately(to: newValue)
            } else {
                startFlip(to: newValue)
            }
        }
    }

    private enum Half {
        case top
        case bottom
    }

    private func halfLayer(digit: Character, half: Half) -> some View {
        digitContent(digit)
            .frame(width: contentSize.width, height: contentSize.height, alignment: .center)
            .mask(alignment: half == .top ? .top : .bottom) {
                Rectangle()
                    .frame(height: halfHeight)
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

/// 极简悬浮样式的逐位翻页时间行。
struct MinimalFloatingFlipTimeRow: View {
    let timeString: String
    let useLightText: Bool

    private var textColor: Color {
        useLightText ? .white : Color(red: 0.12, green: 0.12, blue: 0.16)
    }

    private let digitSize = CGSize(width: 34, height: 60)

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(timeString.enumerated()), id: \.offset) { _, char in
                if char.isNumber {
                    TransparentClockFlipAnimatingDigit(
                        digit: char,
                        contentSize: digitSize
                    ) { value in
                        Text(String(value))
                            .font(.system(size: 56, weight: .thin, design: .rounded))
                            .monospacedDigit()
                            .foregroundStyle(textColor)
                            .shadow(color: .black.opacity(0.45), radius: 10, x: 0, y: 3)
                    }
                } else {
                    Text(String(char))
                        .font(.system(size: 56, weight: .thin, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(textColor)
                        .shadow(color: .black.opacity(0.45), radius: 10, x: 0, y: 3)
                }
            }
        }
        .minimumScaleFactor(0.6)
        .lineLimit(1)
    }
}
