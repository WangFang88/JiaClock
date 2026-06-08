import SwiftUI

/// 小时 / 分钟 / 秒组之间的间距（无冒号）。
struct TransparentFlipTimeSeparator: View {
    let width: CGFloat

    var body: some View {
        Color.clear
            .frame(width: width)
            .accessibilityHidden(true)
    }
}
