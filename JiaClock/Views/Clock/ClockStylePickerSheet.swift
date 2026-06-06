import SwiftUI

/// 兼容旧入口：内嵌统一样式中心。
struct ClockStylePickerSheet: View {
    var body: some View {
        ClockStyleCenterView(mode: .sheet)
    }
}
