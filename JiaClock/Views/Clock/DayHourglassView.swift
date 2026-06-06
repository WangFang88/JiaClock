import SwiftUI

// MARK: - 全屏一日沙漏

struct DayHourglassScreenView: View {
    @EnvironmentObject private var settingsStore: ClockSettingsStore
    @EnvironmentObject private var entitlements: EntitlementManager
    @EnvironmentObject private var storeKit: StoreKitService
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @State private var showControls = true
    @State private var showStyleCenter = false
    @State private var showThemePicker = false
    @Environment(\.clockStyleLaunch) private var clockStyleLaunch

    private var theme: DayHourglassTheme {
        DayHourglassThemeLibrary.theme(id: settingsStore.settings.dayHourglassThemeID)
    }

    private var settings: ClockSettings { settingsStore.settings }

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 20.0, paused: false)) { timeline in
            let now = timeline.date
            GeometryReader { geo in
                let isLandscape = geo.size.width > geo.size.height
                let isPad = horizontalSizeClass == .regular

                ZStack {
                    backgroundLayer
                    VStack(spacing: 0) {
                        Spacer(minLength: geo.safeAreaInsets.top + 8)
                        if showControls {
                            controlsBar
                        } else {
                            Color.clear.frame(height: 52)
                        }
                        Group {
                            if isLandscape {
                                landscapeLayout(now: now, geo: geo, isPad: isPad)
                            } else {
                                portraitLayout(now: now, geo: geo, isPad: isPad)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture { withAnimation(.easeInOut(duration: 0.2)) { showControls.toggle() } }
                }
            }
        }
        .ignoresSafeArea()
        .onAppear {
            settingsStore.enforceAccessibleDayHourglassTheme(isPro: entitlements.isPro)
        }
        .onChange(of: entitlements.isPro) { _, isPro in
            settingsStore.enforceAccessibleDayHourglassTheme(isPro: isPro)
        }
        .statusBarHidden(!showControls)
        .sheet(isPresented: $showThemePicker) {
            DayHourglassThemePickerSheet()
                .environmentObject(settingsStore)
                .environmentObject(entitlements)
                .environmentObject(storeKit)
        }
        .sheet(isPresented: $showStyleCenter) {
            ClockStyleCenterView(mode: .sheet, onLaunch: { destination in
                showStyleCenter = false
                if destination != .fullscreenContainer {
                    dismiss()
                    clockStyleLaunch?.onLaunch(destination)
                }
            })
        }
    }

    private var backgroundLayer: some View {
        LinearGradient(
            colors: theme.backgroundColors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private func portraitLayout(now: Date, geo: GeometryProxy, isPad: Bool) -> some View {
        let hourglassHeight = min(geo.size.height * (isPad ? 0.48 : 0.42), isPad ? 420 : 340)
        let hourglassWidth = hourglassHeight * 0.52

        return VStack(spacing: isPad ? 28 : 22) {
            Spacer(minLength: 16)
            DayHourglassView(
                date: now,
                theme: theme,
                size: CGSize(width: hourglassWidth, height: hourglassHeight)
            )
            if !settings.dayHourglassPureMode {
                infoPanel(now: now, isPad: isPad, alignment: .center)
            } else {
                pureTimeLabel(now: now, isPad: isPad)
            }
            Spacer(minLength: 24)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 24)
    }

    private func landscapeLayout(now: Date, geo: GeometryProxy, isPad: Bool) -> some View {
        let hourglassHeight = min(geo.size.height * 0.72, isPad ? 480 : 300)
        let hourglassWidth = hourglassHeight * 0.52

        return HStack(spacing: isPad ? 48 : 32) {
            Spacer(minLength: 0)
            DayHourglassView(
                date: now,
                theme: theme,
                size: CGSize(width: hourglassWidth, height: hourglassHeight)
            )
            if settings.dayHourglassPureMode {
                pureTimeLabel(now: now, isPad: isPad)
                    .frame(maxWidth: isPad ? 320 : 220, alignment: .leading)
            } else {
                infoPanel(now: now, isPad: isPad, alignment: .leading)
                    .frame(maxWidth: isPad ? 360 : 260, alignment: .leading)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, isPad ? 48 : 28)
        .padding(.vertical, 20)
    }

    @ViewBuilder
    private func infoPanel(now: Date, isPad: Bool, alignment: HorizontalAlignment) -> some View {
        VStack(alignment: alignment, spacing: isPad ? 14 : 10) {
            Text(ClockTimeFormatter.timeString(from: now, settings: settings))
                .font(.system(size: isPad ? 52 : 40, weight: .ultraLight, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(theme.textPrimary)
                .shadow(color: theme.glowColor.opacity(0.35), radius: 12, x: 0, y: 0)

            if settings.dayHourglassShowPercent {
                Text(L10n.Hourglass.todayPassed(DayProgressCalculator.percentPassed(for: now)))
                    .font(.system(size: isPad ? 20 : 17, weight: .medium, design: .rounded))
                    .foregroundStyle(theme.textSecondary)
            }

            if settings.dayHourglassShowRemainingTime {
                Text(L10n.Hourglass.untilDayEnds(DayProgressCalculator.formattedRemainingTime(for: now)))
                    .font(.system(size: isPad ? 18 : 15, weight: .regular, design: .rounded))
                    .foregroundStyle(theme.textSecondary.opacity(0.88))
                    .monospacedDigit()
            }

            if !settingsStore.effectiveTagline.isEmpty {
                Text(settingsStore.effectiveTagline)
                    .font(.system(size: isPad ? 17 : 15, weight: .medium, design: .rounded))
                    .foregroundStyle(theme.accentColor.opacity(0.92))
                    .multilineTextAlignment(alignment == .center ? .center : .leading)
                    .padding(.top, 4)
            }
        }
        .allowsHitTesting(false)
    }

    private func pureTimeLabel(now: Date, isPad: Bool) -> some View {
        Text(ClockTimeFormatter.timeString(from: now, settings: settings))
            .font(.system(size: isPad ? 44 : 36, weight: .ultraLight, design: .rounded))
            .monospacedDigit()
            .foregroundStyle(theme.textPrimary)
            .shadow(color: theme.glowColor.opacity(0.3), radius: 10, x: 0, y: 0)
            .allowsHitTesting(false)
    }

    private var controlsBar: some View {
        HStack(spacing: 10) {
            JiaControlChip(icon: "xmark", title: L10n.Common.close) { dismiss() }
            Spacer(minLength: 8)
            JiaControlChip(icon: "paintpalette.fill", title: L10n.Hourglass.themeButton) {
                showThemePicker = true
            }
            JiaControlChip(icon: "square.grid.2x2", title: L10n.ClockStyleCenter.entryButton) {
                showStyleCenter = true
            }
            Menu {
                Toggle(L10n.Hourglass.showPercent, isOn: binding(\.dayHourglassShowPercent))
                Toggle(L10n.Hourglass.showRemaining, isOn: binding(\.dayHourglassShowRemainingTime))
                Toggle(L10n.Hourglass.pureMode, isOn: binding(\.dayHourglassPureMode))
            } label: {
                JiaControlChip(icon: "slider.horizontal.3", title: L10n.Transparent.adjust, action: nil)
            }
        }
        .padding(.horizontal, 16)
        .transition(.opacity)
    }

    private func binding(_ keyPath: WritableKeyPath<ClockSettings, Bool>) -> Binding<Bool> {
        Binding(
            get: { settingsStore.settings[keyPath: keyPath] },
            set: { newValue in settingsStore.update { $0[keyPath: keyPath] = newValue } }
        )
    }
}

// MARK: - 沙漏 Canvas

struct DayHourglassView: View {
    let date: Date
    let theme: DayHourglassTheme
    let size: CGSize

    var body: some View {
        let progress = DayProgressCalculator.dayProgress(for: date)
        TimelineView(.animation(minimumInterval: 1.0 / 20.0)) { timeline in
            Canvas { context, canvasSize in
                let phase = timeline.date.timeIntervalSinceReferenceDate
                let geo = HourglassGeometry(size: canvasSize)
                let breath = 0.82 + 0.18 * sin(phase * 1.1)

                drawStarDust(context: &context, geo: geo, phase: phase)
                drawGlow(context: &context, geo: geo, breath: breath)
                drawTopSand(context: &context, geo: geo, progress: progress, phase: phase)
                drawBottomSand(context: &context, geo: geo, progress: progress, phase: phase)
                drawSandStream(context: &context, geo: geo, phase: phase, progress: progress)
                drawGlassOutline(context: &context, geo: geo, breath: breath)
                drawParticles(context: &context, geo: geo, phase: phase)
            }
        }
        .frame(width: size.width, height: size.height)
    }

    private func drawStarDust(context: inout GraphicsContext, geo: HourglassGeometry, phase: Double) {
        for i in 0..<24 {
            let seed = Double(i) * 2.399963
            let x = geo.rect.minX + geo.rect.width * (0.12 + 0.76 * fract(sin(seed) * 43758.5453))
            let y = geo.rect.minY + geo.rect.height * (0.08 + 0.84 * fract(cos(seed * 1.3) * 23421.631))
            let twinkle = 0.15 + 0.35 * abs(sin(phase * 0.6 + seed))
            let r: CGFloat = i % 3 == 0 ? 1.2 : 0.7
            let rect = CGRect(x: x, y: y + sin(phase * 0.15 + seed) * 3, width: r, height: r)
            context.fill(Path(ellipseIn: rect), with: .color(theme.particleColor.opacity(twinkle * 0.35)))
        }
    }

    private func drawGlow(context: inout GraphicsContext, geo: HourglassGeometry, breath: Double) {
        let center = CGPoint(x: geo.rect.midX, y: geo.rect.midY)
        let radius = geo.rect.width * 0.55
        let glowRect = CGRect(
            x: center.x - radius,
            y: center.y - radius * 0.9,
            width: radius * 2,
            height: radius * 1.8
        )
        context.fill(
            Path(ellipseIn: glowRect),
            with: .color(theme.glowColor.opacity(0.08 * breath))
        )
    }

    private func drawTopSand(context: inout GraphicsContext, geo: HourglassGeometry, progress: Double, phase: Double) {
        let topAmount = max(0, 1 - progress)
        guard topAmount > 0.002 else { return }

        var clip = context
        clip.clip(to: geo.topChamberPath())

        let chamberTop = geo.topBulbTop
        let chamberBottom = geo.waistY
        let chamberHeight = chamberBottom - chamberTop
        let sandTop = chamberBottom - chamberHeight * CGFloat(topAmount)

        var sandPath = Path()
        let leftBottom = geo.pointOnTopChamberLeft(y: chamberBottom)
        let rightBottom = geo.pointOnTopChamberRight(y: chamberBottom)
        sandPath.move(to: leftBottom)
        sandPath.addLine(to: rightBottom)

        let waveSteps = 12
        for step in stride(from: waveSteps, through: 0, by: -1) {
            let t = CGFloat(step) / CGFloat(waveSteps)
            let y = sandTop + (chamberBottom - sandTop) * (1 - t) * 0.02
            let wave = sin(phase * 2.5 + Double(t) * 4) * geo.rect.width * 0.012
            let x = geo.rect.midX + (geo.halfWidth(atY: y, inTop: true) - geo.rect.width * 0.04) * (t * 2 - 1) + wave
            sandPath.addLine(to: CGPoint(x: x, y: y))
        }

        let leftTop = geo.pointOnTopChamberLeft(y: sandTop)
        sandPath.addLine(to: leftTop)
        sandPath.closeSubpath()

        clip.fill(sandPath, with: .linearGradient(
            Gradient(colors: [theme.sandHighlight, theme.sandColor]),
            startPoint: CGPoint(x: geo.rect.midX, y: sandTop),
            endPoint: CGPoint(x: geo.rect.midX, y: chamberBottom)
        ))
    }

    private func drawBottomSand(context: inout GraphicsContext, geo: HourglassGeometry, progress: Double, phase: Double) {
        let bottomAmount = min(1, max(0, progress))
        guard bottomAmount > 0.002 else { return }

        var clip = context
        clip.clip(to: geo.bottomChamberPath())

        let chamberTop = geo.waistY
        let chamberBottom = geo.bottomBulbBottom
        let chamberHeight = chamberBottom - chamberTop
        let sandTop = chamberBottom - chamberHeight * CGFloat(bottomAmount)

        var sandPath = Path()
        let leftBottom = geo.pointOnBottomChamberLeft(y: chamberBottom)
        let rightBottom = geo.pointOnBottomChamberRight(y: chamberBottom)
        sandPath.move(to: leftBottom)
        sandPath.addLine(to: rightBottom)

        let moundSteps = 14
        for step in 0...moundSteps {
            let t = CGFloat(step) / CGFloat(moundSteps)
            let x = leftBottom.x + (rightBottom.x - leftBottom.x) * t
            let mound = pow(sin(.pi * t), 1.6) * geo.rect.width * 0.06
            let wave = sin(phase * 1.8 + Double(t) * 5) * 1.5
            let y = sandTop - mound + wave
            sandPath.addLine(to: CGPoint(x: x, y: y))
        }

        let leftTop = geo.pointOnBottomChamberLeft(y: sandTop)
        sandPath.addLine(to: leftTop)
        sandPath.closeSubpath()

        clip.fill(sandPath, with: .linearGradient(
            Gradient(colors: [theme.sandColor, theme.sandHighlight.opacity(0.85)]),
            startPoint: CGPoint(x: geo.rect.midX, y: sandTop),
            endPoint: CGPoint(x: geo.rect.midX, y: chamberBottom)
        ))
    }

    private func drawSandStream(context: inout GraphicsContext, geo: HourglassGeometry, phase: Double, progress: Double) {
        guard progress > 0.01, progress < 0.99 else { return }

        let streamTop = geo.waistY - geo.rect.height * 0.01
        let streamBottom = geo.waistY + geo.rect.height * 0.08
        let streamWidth = geo.rect.width * 0.018

        for i in 0..<6 {
            let offset = (phase * 80 + Double(i) * 18).truncatingRemainder(dividingBy: Double(streamBottom - streamTop))
            let y = streamTop + CGFloat(offset)
            let wobble = sin(phase * 4 + Double(i)) * streamWidth * 0.3
            let rect = CGRect(
                x: geo.rect.midX - streamWidth / 2 + wobble,
                y: y,
                width: streamWidth,
                height: streamWidth * 1.8
            )
            let alpha = 0.35 + 0.25 * sin(phase * 5 + Double(i))
            context.fill(Path(ellipseIn: rect), with: .color(theme.sandHighlight.opacity(alpha)))
        }

        let linePath = Path { path in
            path.move(to: CGPoint(x: geo.rect.midX, y: streamTop))
            path.addLine(to: CGPoint(x: geo.rect.midX, y: streamBottom))
        }
        context.stroke(
            linePath,
            with: .color(theme.sandColor.opacity(0.45 + 0.15 * sin(phase * 3))),
            style: StrokeStyle(lineWidth: streamWidth * 0.6, lineCap: .round, dash: [3, 5], dashPhase: phase * 12)
        )
    }

    private func drawGlassOutline(context: inout GraphicsContext, geo: HourglassGeometry, breath: Double) {
        let outline = geo.glassOutlinePath()
        context.stroke(
            outline,
            with: .color(theme.glassStroke.opacity(0.35 * breath)),
            style: StrokeStyle(lineWidth: geo.rect.width * 0.028, lineCap: .round, lineJoin: .round)
        )
        context.stroke(
            outline,
            with: .color(theme.glassStroke.opacity(0.85)),
            style: StrokeStyle(lineWidth: geo.rect.width * 0.008, lineCap: .round, lineJoin: .round)
        )
    }

    private func drawParticles(context: inout GraphicsContext, geo: HourglassGeometry, phase: Double) {
        for i in 0..<10 {
            let seed = Double(i) * 1.731
            let baseY = geo.waistY + geo.rect.height * 0.02
            let drift = sin(phase * 0.8 + seed) * geo.rect.width * 0.08
            let x = geo.rect.midX + drift
            let y = baseY + CGFloat(i) * 6 + sin(phase * 1.2 + seed * 2) * 8
            let alpha = 0.2 + 0.3 * abs(sin(phase * 2 + seed))
            let r: CGFloat = 1.0 + CGFloat(i % 2)
            context.fill(
                Path(ellipseIn: CGRect(x: x, y: y, width: r, height: r)),
                with: .color(theme.particleColor.opacity(alpha))
            )
        }
    }

    private func fract(_ value: Double) -> Double {
        value - floor(value)
    }
}

// MARK: - 几何

private struct HourglassGeometry {
    let rect: CGRect

    init(size: CGSize) {
        rect = CGRect(origin: .zero, size: size)
    }

    var topBulbTop: CGFloat { rect.minY + rect.height * 0.05 }
    var waistY: CGFloat { rect.midY }
    var bottomBulbBottom: CGFloat { rect.maxY - rect.height * 0.05 }

    func halfWidth(atY y: CGFloat, inTop: Bool) -> CGFloat {
        if inTop {
            let t = (y - topBulbTop) / (waistY - topBulbTop)
            return lerp(rect.width * 0.38, rect.width * 0.055, t)
        }
        let t = (y - waistY) / (bottomBulbBottom - waistY)
        return lerp(rect.width * 0.055, rect.width * 0.38, t)
    }

    func pointOnTopChamberLeft(y: CGFloat) -> CGPoint {
        CGPoint(x: rect.midX - halfWidth(atY: y, inTop: true), y: y)
    }

    func pointOnTopChamberRight(y: CGFloat) -> CGPoint {
        CGPoint(x: rect.midX + halfWidth(atY: y, inTop: true), y: y)
    }

    func pointOnBottomChamberLeft(y: CGFloat) -> CGPoint {
        CGPoint(x: rect.midX - halfWidth(atY: y, inTop: false), y: y)
    }

    func pointOnBottomChamberRight(y: CGFloat) -> CGPoint {
        CGPoint(x: rect.midX + halfWidth(atY: y, inTop: false), y: y)
    }

    func topChamberPath() -> Path {
        var path = Path()
        path.move(to: pointOnTopChamberLeft(y: topBulbTop))
        path.addQuadCurve(
            to: pointOnTopChamberRight(y: topBulbTop),
            control: CGPoint(x: rect.midX, y: topBulbTop - rect.height * 0.04)
        )
        path.addLine(to: pointOnTopChamberRight(y: waistY))
        path.addLine(to: pointOnTopChamberLeft(y: waistY))
        path.closeSubpath()
        return path
    }

    func bottomChamberPath() -> Path {
        var path = Path()
        path.move(to: pointOnBottomChamberLeft(y: waistY))
        path.addLine(to: pointOnBottomChamberRight(y: waistY))
        path.addLine(to: pointOnBottomChamberRight(y: bottomBulbBottom))
        path.addQuadCurve(
            to: pointOnBottomChamberLeft(y: bottomBulbBottom),
            control: CGPoint(x: rect.midX, y: bottomBulbBottom + rect.height * 0.04)
        )
        path.closeSubpath()
        return path
    }

    func glassOutlinePath() -> Path {
        var path = Path()
        path.move(to: pointOnTopChamberLeft(y: topBulbTop))
        path.addQuadCurve(
            to: pointOnTopChamberRight(y: topBulbTop),
            control: CGPoint(x: rect.midX, y: topBulbTop - rect.height * 0.045)
        )
        path.addLine(to: pointOnTopChamberRight(y: waistY))
        path.addLine(to: pointOnBottomChamberRight(y: waistY))
        path.addLine(to: pointOnBottomChamberRight(y: bottomBulbBottom))
        path.addQuadCurve(
            to: pointOnBottomChamberLeft(y: bottomBulbBottom),
            control: CGPoint(x: rect.midX, y: bottomBulbBottom + rect.height * 0.045)
        )
        path.addLine(to: pointOnBottomChamberLeft(y: waistY))
        path.addLine(to: pointOnTopChamberLeft(y: waistY))
        path.closeSubpath()
        return path
    }

    private func lerp(_ a: CGFloat, _ b: CGFloat, _ t: CGFloat) -> CGFloat {
        a + (b - a) * min(1, max(0, t))
    }
}

// MARK: - 主题选择 Sheet

struct DayHourglassThemePickerSheet: View {
    @EnvironmentObject private var settingsStore: ClockSettingsStore
    @EnvironmentObject private var entitlements: EntitlementManager
    @EnvironmentObject private var storeKit: StoreKitService
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @State private var showPaywall = false

    private var selectedID: String { settingsStore.settings.dayHourglassThemeID }

    var body: some View {
        NavigationStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(DayHourglassThemeLibrary.all) { theme in
                        themeCard(theme)
                    }
                }
                .padding(20)
            }
            .background(Color(red: 0.08, green: 0.08, blue: 0.10))
            .navigationTitle(L10n.Hourglass.themeSheetTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(L10n.Common.done) { dismiss() }
                }
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView(highlightFeature: .premiumThemes)
                    .environmentObject(storeKit)
                    .environmentObject(entitlements)
            }
        }
        .presentationDetents([.height(horizontalSizeClass == .regular ? 220 : 200)])
        .presentationDragIndicator(.visible)
    }

    private func themeCard(_ theme: DayHourglassTheme) -> some View {
        let isSelected = selectedID == theme.id
        let locked = theme.isPro && !entitlements.isPro
        let cardWidth: CGFloat = horizontalSizeClass == .regular ? 160 : 140

        return Button {
            if theme.isPro, !entitlements.isPro {
                showPaywall = true
                return
            }
            settingsStore.update { $0.dayHourglassThemeID = theme.id }
        } label: {
            VStack(spacing: 10) {
                ZStack {
                    LinearGradient(
                        colors: theme.backgroundColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    DayHourglassView(
                        date: Date.now,
                        theme: theme,
                        size: CGSize(width: cardWidth * 0.45, height: cardWidth * 0.72)
                    )
                }
                .frame(width: cardWidth, height: cardWidth * 0.85)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(isSelected ? theme.accentColor : Color.white.opacity(0.12), lineWidth: isSelected ? 2 : 1)
                }

                HStack(spacing: 4) {
                    Text(theme.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.92))
                    if theme.isPro { ProBadgeView(compact: true) }
                    if locked {
                        Image(systemName: "lock.fill")
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }
            }
            .frame(width: cardWidth)
        }
        .buttonStyle(.plain)
    }
}
