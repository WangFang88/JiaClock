import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const xcPath = path.join(__dirname, "../JiaClock/Resources/Localizable.xcstrings");
const raw = fs.readFileSync(xcPath, "utf8").replace(/^\uFEFF/, "");
const data = JSON.parse(raw);
const strings = data.strings;

function loc(en, zh, zht, ja, ko) {
  return {
    localizations: {
      en: { stringUnit: { state: "translated", value: en } },
      "zh-Hans": { stringUnit: { state: "translated", value: zh } },
      "zh-Hant": { stringUnit: { state: "translated", value: zht } },
      ja: { stringUnit: { state: "translated", value: ja } },
      ko: { stringUnit: { state: "translated", value: ko } },
    },
  };
}

const entries = {
  "legal.privacy.effective_date": loc(
    "Last updated: June 2025",
    "最后更新：2025 年 6 月",
    "最後更新：2025 年 6 月",
    "最終更新：2025年6月",
    "최종 업데이트: 2025년 6월"
  ),
  "legal.privacy.intro": loc(
    "Jia Clock (「小嘉时钟」) is an aesthetic desk clock app. This Privacy Policy explains what the app accesses and how that information is used. We describe our practices clearly and accurately, without overstating protections.",
    "小嘉时钟是一款美学桌面时钟 App。本隐私政策说明 App 会访问哪些信息、以及如何使用这些信息。我们力求清楚、真实地描述相关做法，不夸大保护范围。",
    "小嘉時鐘是一款美學桌面時鐘 App。本隱私政策說明 App 會存取哪些資訊、以及如何使用這些資訊。我們力求清楚、真實地描述相關做法，不誇大保護範圍。",
    "小嘉クロックは美学デスク時計アプリです。本プライバシーポリシーは、アプリがアクセスする情報とその利用方法を説明します。過大な表現を避け、事実に基づいて記載します。",
    "Jia Clock(小嘉时钟)은 미학 데스크 시계 앱입니다. 본 개인정보 처리방침은 앱이 접근하는 정보와 사용 방식을 설명합니다. 과장 없이 사실에 근거해 기술합니다."
  ),
  "legal.privacy.section.camera.title": loc(
    "Camera (Transparent Clock only)",
    "摄像头（仅透明时钟）",
    "相機（僅透明時鐘）",
    "カメラ（透明時計のみ）",
    "카메라(투명 시계 전용)"
  ),
  "legal.privacy.section.camera.body": loc(
    "• Jia Clock requests camera access only when you actively choose to enable Transparent Clock.\n• The camera feed is used solely for live on-device preview as the clock background.\n• The app does not record camera footage.\n• The app does not save camera footage.\n• The app does not upload camera footage.\n• The app does not use camera footage for face recognition, identity detection, or content analysis.\n• The camera stops when you close Transparent Clock, leave that screen, send the app to the background, or lock your device. The camera does not run in the background.",
    "• 小嘉时钟仅在你主动开启透明时钟时，才会请求摄像头权限。\n• 摄像头画面仅用于本机实时预览，作为时钟背景显示。\n• App 不会录制摄像头画面。\n• App 不会保存摄像头画面。\n• App 不会上传摄像头画面。\n• App 不会使用摄像头画面进行人脸识别、身份识别或内容分析。\n• 当你关闭透明时钟、离开该页面、App 进入后台或设备锁屏时，摄像头会停止工作，不会在后台继续运行。",
    "• 小嘉時鐘僅在你主動開啟透明時鐘時，才會請求相機權限。\n• 相機畫面僅用於本機即時預覽，作為時鐘背景顯示。\n• App 不會錄製相機畫面。\n• App 不會保存相機畫面。\n• App 不會上傳相機畫面。\n• App 不會使用相機畫面進行人臉識別、身份識別或內容分析。\n• 當你關閉透明時鐘、離開該頁面、App 進入背景或裝置鎖屏時，相機會停止工作，不會在背景繼續運行。",
    "• 透明時計を有効にするときのみ、カメラ権限をリクエストします。\n• カメラ映像は端末内のリアルタイムプレビュー（時計背景）のみに使用します。\n• 録画・保存・アップロードは行いません。\n• 顔認識、本人確認、コンテンツ分析には使用しません。\n• 透明時計を閉じる、画面を離れる、バックグラウンド移行、端末ロック時にカメラは停止し、バックグラウンドでは動作しません。",
    "• 투명 시계를 직접 켤 때만 카메라 권한을 요청합니다.\n• 카메라 화면은 기기 내 실시간 미리보기(시계 배경)에만 사용됩니다.\n• 녹화·저장·업로드하지 않습니다.\n• 얼굴 인식, 신원 확인, 콘텐츠 분석에 사용하지 않습니다.\n• 투명 시계 종료, 화면 이탈, 백그라운드 전환, 기기 잠금 시 카메라가 중지되며 백그라운드에서 실행되지 않습니다."
  ),
  "legal.privacy.section.widget.title": loc(
    "Widget",
    "小组件",
    "小組件",
    "ウィジェット",
    "위젯"
  ),
  "legal.privacy.section.widget.body": loc(
    "Home screen widgets display time and your chosen clock settings only. Widgets do not access or use the camera.",
    "主屏幕小组件仅显示时间与你在 App 中选择的时钟设置，不会访问或使用摄像头。",
    "主畫面小組件僅顯示時間與你在 App 中選擇的時鐘設定，不會存取或使用相機。",
    "ホーム画面ウィジェットは時刻と設定した時計表示のみを行い、カメラにはアクセスしません。",
    "홈 화면 위젯은 시간과 선택한 시계 설정만 표시하며 카메라에 접근하지 않습니다."
  ),
  "legal.privacy.section.purchases.title": loc(
    "Purchases and Subscriptions",
    "购买与订阅",
    "購買與訂閱",
    "購入とサブスクリプション",
    "구매 및 구독"
  ),
  "legal.privacy.section.purchases.body": loc(
    "In-app purchases and subscriptions are processed by Apple through StoreKit. We do not receive or store your payment card details. Apple's terms and privacy practices apply to payment processing.",
    "App 内购买与订阅由 Apple 通过 StoreKit 处理。我们不会接收或保存你的支付卡信息。支付处理适用 Apple 的相关条款与隐私政策。",
    "App 內購買與訂閱由 Apple 透過 StoreKit 處理。我們不會接收或保存你的支付卡資訊。支付處理適用 Apple 的相關條款與隱私政策。",
    "アプリ内課金とサブスクリプションは Apple の StoreKit により処理されます。当方はカード情報を受け取らず保存もしません。",
    "앱 내 구매와 구독은 Apple StoreKit으로 처리됩니다. 당사는 결제 카드 정보를 받거나 저장하지 않습니다."
  ),
  "legal.privacy.section.storage.title": loc(
    "Information Stored on Your Device",
    "保存在你设备上的信息",
    "保存在你裝置上的資訊",
    "端末に保存される情報",
    "기기에 저장되는 정보"
  ),
  "legal.privacy.section.storage.body": loc(
    "Jia Clock may save your preferences locally on your device, such as theme, custom tagline, and time display options.\n\nIf App Group storage is used, it is only to share these clock settings between the main app and the widget extension. Camera data is never shared through App Group.",
    "小嘉时钟可能在本机保存你的偏好设置，例如主题、自定义标语、时间显示格式等。\n\n如使用 App Group，其用途仅限于在主 App 与 Widget 扩展之间共享上述时钟设置，不会通过 App Group 共享任何摄像头数据。",
    "小嘉時鐘可能在本機保存你的偏好設定，例如主題、自訂標語、時間顯示格式等。\n\n如使用 App Group，其用途僅限於在主 App 與 Widget 擴展之間共享上述時鐘設定，不會透過 App Group 共享任何相機資料。",
    "テーマ、标语、時刻表示形式などの設定を端末内に保存することがあります。\n\nApp Group を使用する場合も、メインアプリとウィジェット間でこれらの設定を共有する目的に限り、カメラデータは共有しません。",
    "테마, 사용자 슬로건, 시간 표시 형식 등 설정을 기기에 저장할 수 있습니다.\n\nApp Group은 앱과 위젯 간 시계 설정 공유에만 사용되며 카메라 데이터는 공유하지 않습니다."
  ),
  "legal.privacy.section.changes.title": loc(
    "Changes to This Policy",
    "政策变更",
    "政策變更",
    "本ポリシーの変更",
    "정책 변경"
  ),
  "legal.privacy.section.changes.body": loc(
    "We may update this Privacy Policy from time to time. Continued use of the app after changes take effect constitutes acceptance of the updated policy.",
    "我们可能不时更新本隐私政策。更新生效后你继续使用 App，即视为接受更新后的政策。",
    "我們可能不時更新本隱私政策。更新生效後你繼續使用 App，即視為接受更新後的政策。",
    "本ポリシーは随時更新される場合があります。更新後も利用を続ける場合、更新内容に同意したものとみなします。",
    "본 방침은 수시로 업데이트될 수 있습니다. 변경 후에도 앱을 계속 사용하면 업데이트된 방침에 동의한 것으로 봅니다."
  ),
  "legal.privacy.section.contact.title": loc(
    "Contact",
    "联系我们",
    "聯絡我們",
    "お問い合わせ",
    "문의"
  ),
  "legal.privacy.section.contact.body": loc(
    "If you have questions about this Privacy Policy, please contact us at: douzq@jdarray.com",
    "如对本隐私政策有疑问，请联系：douzq@jdarray.com",
    "如對本隱私政策有疑問，請聯絡：douzq@jdarray.com",
    "本ポリシーに関するお問い合わせ：douzq@jdarray.com",
    "본 방침 관련 문의: douzq@jdarray.com"
  ),

  "legal.terms.effective_date": loc(
    "Last updated: June 2025",
    "最后更新：2025 年 6 月",
    "最後更新：2025 年 6 月",
    "最終更新：2025年6月",
    "최종 업데이트: 2025년 6월"
  ),
  "legal.terms.intro": loc(
    "These Terms of Service (「Terms」) govern your use of Jia Clock (「小嘉时钟」, the 「App」). By using the App, you agree to these Terms.",
    "本用户协议（「协议」）适用于你对小嘉时钟（「App」）的使用。使用 App 即表示你同意本协议。",
    "本使用者協議（「協議」）適用於你對小嘉時鐘（「App」）的使用。使用 App 即表示你同意本協議。",
    "本利用規約（「規約」）は、小嘉クロック（「本アプリ」）の利用条件を定めます。利用により規約に同意したものとみなします。",
    "본 이용약관(「약관」)은 Jia Clock(小嘉时钟) 앱 이용에 적용됩니다. 앱을 사용하면 본 약관에 동의한 것으로 봅니다."
  ),
  "legal.terms.section.service.title": loc(
    "Service Description",
    "服务说明",
    "服務說明",
    "サービス内容",
    "서비스 설명"
  ),
  "legal.terms.section.service.body": loc(
    "Jia Clock provides aesthetic clock displays, including full-screen clock, flip clock, transparent clock (camera preview background), and home screen widgets. Features may vary by device, system version, and subscription status.",
    "小嘉时钟提供美学时钟显示功能，包括全屏时钟、翻页时钟、透明时钟（摄像头预览背景）及主屏幕小组件。具体功能可能因设备、系统版本及订阅状态而有所不同。",
    "小嘉時鐘提供美學時鐘顯示功能，包括全屏時鐘、翻頁時鐘、透明時鐘（相機預覽背景）及主畫面小組件。具體功能可能因裝置、系統版本及訂閱狀態而有所不同。",
    "小嘉クロックは、全画面時計、フリップ時計、透明時計（カメラプレビュー背景）、ホーム画面ウィジェットなどを提供します。機能は端末、OS、サブスクリプション状態により異なる場合があります。",
    "Jia Clock은 전체 화면 시계, 플립 시계, 투명 시계(카메라 미리보기 배경), 홈 화면 위젯 등을 제공합니다. 기능은 기기, OS, 구독 상태에 따라 달라질 수 있습니다."
  ),
  "legal.terms.section.rules.title": loc(
    "User Conduct",
    "用户使用规则",
    "使用者規則",
    "利用上の注意",
    "이용 규칙"
  ),
  "legal.terms.section.rules.body": loc(
    "You agree to use the App lawfully and not to misuse, reverse engineer, interfere with, or attempt unauthorized access to the App or related services. You are responsible for your device, network, and Apple ID security.",
    "你应合法使用 App，不得滥用、逆向工程、干扰或试图未经授权访问 App 或相关服务。你需自行负责设备、网络及 Apple ID 的安全。",
    "你應合法使用 App，不得濫用、逆向工程、干擾或試圖未經授權存取 App 或相關服務。你需自行負責裝置、網路及 Apple ID 的安全。",
    "法令に従って利用し、不正利用、リバースエンジニアリング、妨害、不正アクセスを行わないことに同意します。端末、ネットワーク、Apple ID の管理は利用者の責任です。",
    "앱을 합법적으로 사용해야 하며, 남용·리버스 엔지니어링·방해·무단 접근을 해서는 안 됩니다. 기기, 네트워크, Apple ID 보안은 사용자 책임입니다."
  ),
  "legal.terms.section.pro.title": loc(
    "Pro Features",
    "Pro 功能说明",
    "Pro 功能說明",
    "Pro 機能",
    "Pro 기능"
  ),
  "legal.terms.section.pro.body": loc(
    "Certain features are available through Jia Clock Pro, such as premium themes and other advanced options marked in the app. Pro access requires an active subscription or lifetime purchase. Free features remain available without Pro.",
    "部分功能属于小嘉时钟 Pro，例如高级主题及 App 内标注的其他高级选项。Pro 需有效订阅或永久买断后方可使用。未解锁 Pro 时，免费功能仍可正常使用。",
    "部分功能屬於小嘉時鐘 Pro，例如進階主題及 App 內標註的其他進階選項。Pro 需有效訂閱或永久買斷後方可使用。未解鎖 Pro 時，免費功能仍可正常使用。",
    "プレミアムテーマなど、一部機能は Pro で提供されます。Pro 利用には有効なサブスクリプションまたは買い切りが必要です。無料機能は Pro なしでも利用できます。",
    "프리미엄 테마 등 일부 기능은 Pro에서 제공됩니다. Pro는 유효한 구독 또는 평생 구매가 필요합니다. 무료 기능은 Pro 없이도 이용할 수 있습니다."
  ),
  "legal.terms.section.subscriptions.title": loc(
    "Subscriptions and Lifetime Purchase",
    "订阅与永久买断",
    "訂閱與永久買斷",
    "サブスクリプションと買い切り",
    "구독 및 평생 구매"
  ),
  "legal.terms.section.subscriptions.body": loc(
    "Pro may be offered as monthly subscription, yearly subscription, or one-time lifetime purchase. Prices are shown in the app as returned by the App Store and may vary by region. Subscriptions automatically renew unless cancelled at least 24 hours before the end of the current billing period. You can manage or cancel subscriptions in your App Store account settings. Restore Purchases is available in the app.",
    "Pro 可能以月度订阅、年度订阅或一次性永久买断形式提供。价格以 App Store 在 App 内返回的显示为准，可能因地区而异。订阅会在当前计费周期结束前至少 24 小时未取消的情况下自动续期。你可在 App Store 账户设置中管理或取消订阅。App 内提供「恢复购买」功能。",
    "Pro 可能以月度訂閱、年度訂閱或一次性永久買斷形式提供。價格以 App Store 在 App 內返回的顯示為準，可能因地區而異。訂閱會在當前計費週期結束前至少 24 小時未取消的情況下自動續期。你可在 App Store 帳戶設定中管理或取消訂閱。App 內提供「恢復購買」功能。",
    "Pro は月額・年額サブスクリプションまたは買い切りで提供される場合があります。価格は App Store の表示に従います。サブスクリプションは期間終了24時間前までにキャンセルしない限り自動更新されます。App Store 設定で管理でき、アプリ内で購入復元が可能です。",
    "Pro는 월간·연간 구독 또는 평생 일회성 구매로 제공될 수 있습니다. 가격은 App Store 표시를 따르며 지역별로 다를 수 있습니다. 구독은 현재 기간 종료 24시간 전까지 취소하지 않으면 자동 갱신됩니다. App Store 설정에서 관리할 수 있으며 앱에서 구매 복원이 가능합니다."
  ),
  "legal.terms.section.refunds.title": loc(
    "Refunds",
    "退款说明",
    "退款說明",
    "返金",
    "환불"
  ),
  "legal.terms.section.refunds.body": loc(
    "All purchases are processed by Apple. Refund requests must be submitted to Apple in accordance with Apple's policies. We cannot issue refunds directly.",
    "所有购买均由 Apple 处理。退款申请须按 Apple 政策向 Apple 提交，我们无法直接为你办理退款。",
    "所有購買均由 Apple 處理。退款申請須按 Apple 政策向 Apple 提交，我們無法直接為你辦理退款。",
    "購入は Apple が処理します。返金は Apple のポリシーに従い Apple に申請してください。当方から直接返金することはできません。",
    "모든 구매는 Apple이 처리합니다. 환불은 Apple 정책에 따라 Apple에 요청해야 하며, 당사가 직접 환불할 수 없습니다."
  ),
  "legal.terms.section.limitations.title": loc(
    "Feature Availability and Limitations",
    "功能限制说明",
    "功能限制說明",
    "機能の制限",
    "기능 제한"
  ),
  "legal.terms.section.limitations.body": loc(
    "The App is provided on an 「as is」 and 「as available」 basis. We do not guarantee uninterrupted operation on all devices. Transparent Clock requires a compatible camera and user permission. Simulator or restricted devices may have limited functionality.",
    "App 按「现状」及「可用性」提供，我们不保证在所有设备上持续无中断运行。透明时钟需要兼容的摄像头及用户授权；模拟器或受限制设备可能功能受限。",
    "App 按「現狀」及「可用性」提供，我們不保證在所有裝置上持續無中斷運行。透明時鐘需要相容的相機及使用者授權；模擬器或受限制裝置可能功能受限。",
    "本アプリは「現状有姿」で提供されます。全端末での無停止動作を保証しません。透明時計には対応カメラと許可が必要で、シミュレータ等では制限がある場合があります。",
    "앱은 「있는 그대로」 제공됩니다. 모든 기기에서 중단 없는 동작을 보장하지 않습니다. 투명 시계는 호환 카메라와 사용자 권한이 필요하며, 시뮬레이터 등에서는 기능이 제한될 수 있습니다."
  ),
  "legal.terms.section.camera.title": loc(
    "Transparent Clock and Camera",
    "透明时钟与摄像头",
    "透明時鐘與相機",
    "透明時計とカメラ",
    "투명 시계와 카메라"
  ),
  "legal.terms.section.camera.body": loc(
    "Transparent Clock uses the device camera for live on-device preview only when you enable the feature. By enabling it, you confirm you have the right to use the camera in your environment. See the Privacy Policy for detailed camera practices.",
    "透明时钟仅在你主动开启时使用设备摄像头进行本机实时预览。开启即表示你确认在当前环境中有权使用摄像头。摄像头相关细节请参阅隐私政策。",
    "透明時鐘僅在你主動開啟時使用裝置相機進行本機即時預覽。開啟即表示你確認在當前環境中有權使用相機。相機相關細節請參閱隱私政策。",
    "透明時計は、有効化した場合に端末カメラを端末内プレビューのみに使用します。有効化により、利用環境でカメラ使用が適切であることを確認したものとみなします。詳細はプライバシーポリシーを参照してください。",
    "투명 시계는 사용자가 켠 경우에만 기기 카메라를 기기 내 실시간 미리보기에 사용합니다. 활성화하면 해당 환경에서 카메라 사용 권리가 있음을 확인한 것으로 봅니다. 자세한 내용은 개인정보 처리방침을 참고하세요."
  ),
  "legal.terms.section.disclaimer.title": loc(
    "Disclaimer",
    "免责声明",
    "免責聲明",
    "免責事項",
    "면책 조항"
  ),
  "legal.terms.section.disclaimer.body": loc(
    "To the maximum extent permitted by law, we are not liable for indirect, incidental, or consequential damages arising from your use of the App. The App is a display tool and does not provide professional, medical, or emergency services.",
    "在法律允许的最大范围内，我们不对因使用 App 产生的间接、附带或后果性损害承担责任。App 为显示工具，不提供专业、医疗或紧急服务。",
    "在法律允許的最大範圍內，我們不對因使用 App 產生的間接、附帶或後果性損害承擔責任。App 為顯示工具，不提供專業、醫療或緊急服務。",
    "法令で許される最大限の範囲で、間接的・付随的・結果的損害について責任を負いません。本アプリは表示ツールであり、専門・医療・緊急サービスを提供しません。",
    "법이 허용하는 최대 범위 내에서 간접·부수·결과적 손해에 대해 책임지지 않습니다. 앱은 표시 도구이며 전문·의료·긴급 서비스를 제공하지 않습니다."
  ),
  "legal.terms.section.updates.title": loc(
    "Changes to These Terms",
    "协议更新",
    "協議更新",
    "規約の変更",
    "약관 변경"
  ),
  "legal.terms.section.updates.body": loc(
    "We may update these Terms from time to time. Material changes will be reflected in the app or App Store listing. Continued use after updates constitutes acceptance.",
    "我们可能不时更新本协议。重要变更会在 App 或 App Store 页面中体现。更新后继续使用即视为接受。",
    "我們可能不時更新本協議。重要變更會在 App 或 App Store 頁面中體現。更新後繼續使用即視為接受。",
    "本規約は随時更新される場合があります。重要な変更はアプリまたは App Store 掲載情報に反映されます。更新後の利用は同意とみなします。",
    "본 약관은 수시로 업데이트될 수 있습니다. 중요 변경은 앱 또는 App Store 페이지에 반영됩니다. 변경 후 계속 사용하면 동의한 것으로 봅니다."
  ),
  "legal.terms.section.contact.title": loc(
    "Contact",
    "联系方式",
    "聯絡方式",
    "お問い合わせ",
    "문의"
  ),
  "legal.terms.section.contact.body": loc(
    "For questions about these Terms, contact: douzq@jdarray.com",
    "如对本协议有疑问，请联系：douzq@jdarray.com",
    "如對本協議有疑問，請聯絡：douzq@jdarray.com",
    "本規約に関するお問い合わせ：douzq@jdarray.com",
    "약관 관련 문의: douzq@jdarray.com"
  ),

  "transparent.privacy_title": loc(
    "How the camera is used",
    "摄像头如何使用",
    "相機如何使用",
    "カメラの利用方法",
    "카메라 사용 방식"
  ),
  "transparent.privacy_body": loc(
    "Camera access is requested only when you enable Transparent Clock. The feed is used for on-device live preview only — not recorded, saved, uploaded, or analyzed. Widgets do not use the camera.",
    "仅在你开启透明时钟时请求摄像头权限。画面仅用于本机实时预览，不会录制、保存、上传或分析。小组件不使用摄像头。",
    "僅在你開啟透明時鐘時請求相機權限。畫面僅用於本機即時預覽，不會錄製、保存、上傳或分析。小組件不使用相機。",
    "透明時計を有効にした場合のみカメラ権限を求めます。映像は端末内プレビューのみに使用し、録画・保存・アップロード・分析は行いません。ウィジェットはカメラを使用しません。",
    "투명 시계를 켤 때만 카메라 권한을 요청합니다. 화면은 기기 내 실시간 미리보기에만 사용되며 녹화·저장·업로드·분석하지 않습니다. 위젯은 카메라를 사용하지 않습니다."
  ),
  "pro.subscription_disclosure": loc(
    "Payment is charged to your Apple ID account. Monthly and yearly subscriptions auto-renew unless cancelled at least 24 hours before the end of the current period. Lifetime purchase is a one-time charge. Prices are shown as returned by the App Store. You can manage or cancel subscriptions in App Store settings. Restore Purchases is available in Settings.",
    "付款将从你的 Apple ID 账户扣款。月度与年度订阅会在当前周期结束前至少 24 小时未取消时自动续期。永久买断为一次性扣款。价格以 App Store 返回显示为准。可在 App Store 设置中管理或取消订阅。可在设置中恢复购买。",
    "付款將從你的 Apple ID 帳戶扣款。月度與年度訂閱會在當前週期結束前至少 24 小時未取消時自動續期。永久買斷為一次性扣款。價格以 App Store 返回顯示為準。可在 App Store 設定中管理或取消訂閱。可在設定中恢復購買。",
    "お支払いは Apple ID に請求されます。月額・年額は期間終了24時間前までにキャンセルしない限り自動更新されます。買い切りは一度きりの課金です。価格は App Store の表示に従います。App Store 設定で管理でき、設定から購入復元が可能です。",
    "결제는 Apple ID 계정으로 청구됩니다. 월간·연간 구독은 현재 기간 종료 24시간 전까지 취소하지 않으면 자동 갱신됩니다. 평생 구매는 일회성 결제입니다. 가격은 App Store 표시를 따릅니다. App Store 설정에서 관리할 수 있으며 설정에서 구매 복원이 가능합니다."
  ),
};

for (const [key, value] of Object.entries(entries)) {
  strings[key] = value;
}

delete strings["legal.placeholder_body"];

fs.writeFileSync(xcPath, JSON.stringify(data, null, 2) + "\n", "utf8");
console.log("Patched", Object.keys(entries).length, "keys");
