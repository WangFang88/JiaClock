# 小嘉时钟 JiaClock

美学桌面时钟 iOS App（三轮完整版：基础架构 + 透明时钟 + Widget）。

## 打开方式

Xcode 16+ → 打开 `JiaClock.xcodeproj` → 选择模拟器或真机 → `Cmd + R`

## 已实现

- **第一轮**：首页、全屏/翻页时钟、设置、主题、五语言、核心模型
- **第二轮**：透明时钟（AVFoundation 后置摄像头、权限、玻璃拟态 UI）
- **第三轮**：Widget 小/中/大 + App Group 设置共享
- **CI**：`codemagic.yaml`（模拟器构建 + TestFlight）

## Bundle ID

- App: `com.jiaclock.app`
- Widget: `com.jiaclock.app.widget`
- App Group: `group.com.jiaclock.app`

## Windows 开发者

无法本地编译 iOS，请 push 到 GitHub 后用 [Codemagic](https://codemagic.io) 云端构建，或 TestFlight 真机测试。
