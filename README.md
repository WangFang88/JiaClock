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

- App: `jdarray.JiaClock`
- Widget: `jdarray.JiaClock.JiaClockWidget`
- App Group: `group.jdarray.JiaClock`
- Team ID: `CR7GXH4RAJ`

## Windows 开发者

无法本地编译 iOS，请 push 到 GitHub 后用 [Codemagic](https://codemagic.io) 云端构建，或 TestFlight 真机测试。

---

## Codemagic 配置（分步指南）

仓库已包含 `codemagic.yaml`，含两个 workflow：

| Workflow | 用途 | 触发方式 |
|----------|------|----------|
| `jiaclock-ios-simulator` | 模拟器编译冒烟测试 | push 任意分支自动 |
| `jiaclock-testflight` | 签名 + TestFlight | **默认手动**（签名配好后可改 yaml） |

### 第一步：连接仓库（约 2 分钟）

1. 打开 [codemagic.io](https://codemagic.io) 并登录（可用 GitHub 账号）
2. **Applications** → **Add application** → 选 **GitHub** → `WangFang88/JiaClock`
3. 构建配置选 **codemagic.yaml**（不要选 Flutter/React Native 向导）
4. 保存后应能看到 `jiaclock-ios-simulator` 和 `jiaclock-testflight` 两个 workflow

### 第二步：跑通模拟器构建（无需 Apple 账号）

1. 进入应用 → 选 **jiaclock-ios-simulator**
2. 点 **Start new build** → 分支 `main` → **Start build**
3. 成功即表示 Xcode 工程与 Swift 代码在 CI 上可编译

> 每次 push 到 GitHub 也会自动触发此 workflow。

### 第三步：Apple Developer 准备（TestFlight 前必做）

在 [Apple Developer](https://developer.apple.com/account) 完成：

1. **Identifiers → App Groups** → 新建 `group.jdarray.JiaClock`
2. **Identifiers → App IDs** → 新建两个 App ID，均勾选 **App Groups** 并关联上述 Group：
   - `jdarray.JiaClock`（主 App，需 Camera 能力若上架审核）
   - `jdarray.JiaClock.JiaClockWidget`（Widget Extension）
3. [App Store Connect](https://appstoreconnect.apple.com) → **My Apps** → **+** → 新建 App：
   - 名称：小嘉时钟
   - Bundle ID：`jdarray.JiaClock`
   - 记下 **Apple ID**（纯数字，例如 `6740123456`）—— 不是 Bundle ID

### 第四步：Codemagic 集成与签名

#### 4.1 App Store Connect API Key

1. Codemagic → **Team settings** → **Integrations** → **App Store Connect**
2. 在 Apple 侧创建 API Key（App Store Connect → Users and Access → Integrations → App Store Connect API）
3. 上传 `.p8`、填 Key ID、Issuer ID，集成名称设为 **`codemagic`**（与 yaml 一致）

#### 4.2 Apple Developer Portal（自动描述文件）

1. Codemagic → **Team settings** → **Integrations** → **Developer Portal**
2. 连接 Apple Developer 账号（推荐 App Store Connect API Key 同一套凭证）
3. Codemagic 会为 `jdarray.JiaClock` 与 `jdarray.JiaClock.JiaClockWidget` 自动生成 App Store 描述文件（含 App Group）

#### 4.3 环境变量

1. Codemagic → 进入 **JiaClock** 应用 → **Environment variables**
2. 新建组 **`jiaclock_secrets`**，添加：
   - `APP_STORE_APPLE_ID` = 第三步记下的数字 Apple ID
3. 勾选 **Secure**（推荐）

### 第五步：TestFlight 构建

1. 选 workflow **`jiaclock-testflight`**
2. **Start new build** → 分支 `main`
3. 成功后 ipa 上传 TestFlight；在 App Store Connect → TestFlight 添加内测成员
4. iPhone 安装 **TestFlight** App，接受邀请后安装 **小嘉时钟**

### 可选：push 自动打 TestFlight 包

签名与 `APP_STORE_APPLE_ID` 都验证通过后，编辑 `codemagic.yaml` 中 `jiaclock-testflight` 的 `triggering`：

```yaml
triggering:
  events:
    - push
  branch_patterns:
    - pattern: main
      include: true
  cancel_previous_builds: true
```

### 常见问题

| 问题 | 处理 |
|------|------|
| 模拟器 build 失败 | 查看日志中 Swift 编译错误；确认 scheme 为 `JiaClock` |
| `APP_STORE_APPLE_ID` 报错 | 在 `jiaclock_secrets` 组填写 App Store Connect 里的数字 ID |
| 签名 / App Group 失败 | 确认 Developer Portal 两个 Bundle ID 都已启用同一 App Group |
| Widget 未出现在添加小组件列表 | 需真机/TestFlight 安装完整 App；模拟器 CI 包不含可安装 ipa |
| 集成名不匹配 | yaml 里 `app_store_connect: codemagic` 须与 Codemagic 集成名称一致 |

### 相关链接

- 仓库：<https://github.com/WangFang88/JiaClock>
- Codemagic iOS 文档：<https://docs.codemagic.io/yaml-quick-start/building-a-native-ios-app/>
