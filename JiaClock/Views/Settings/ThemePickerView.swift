import SwiftUI

struct ThemePickerView: View {
    @EnvironmentObject private var settingsStore: ClockSettingsStore
    @EnvironmentObject private var entitlements: EntitlementManager
    @EnvironmentObject private var storeKit: StoreKitService
    @Environment(\.dismiss) private var dismiss
    @State private var showPaywall = false

    var body: some View {
        NavigationStack {
            ZStack {
                JiaBackgroundView(theme: settingsStore.theme)
                ScrollView {
                    VStack(spacing: 14) {
                        ForEach(ClockTheme.allCases) { item in
                            Button { selectTheme(item) } label: { themeRow(item) }.buttonStyle(.plain)
                        }
                    }.padding(20)
                }
            }
            .navigationTitle(L10n.Theme.pickerTitle)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button(L10n.Common.done) { dismiss() } } }
            .sheet(isPresented: $showPaywall) {
                PaywallView(highlightFeature: .premiumThemes)
                    .environmentObject(storeKit)
                    .environmentObject(entitlements)
            }
            .onChange(of: showPaywall) { _, isShowing in
                if !isShowing {
                    Task { await entitlements.refreshEntitlements() }
                }
            }
        }
    }

    private func selectTheme(_ item: ClockTheme) {
        if item.requiresPro, !entitlements.hasAccess(to: .premiumThemes) {
            showPaywall = true
            return
        }
        settingsStore.theme = item
    }

    private func themeRow(_ item: ClockTheme) -> some View {
        JiaCardView {
            HStack(spacing: 14) {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(LinearGradient(colors: item.gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .overlay { ThemePreviewPatternOverlay(theme: item) }
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .frame(width: 64, height: 64)
                HStack(spacing: 8) {
                    Text(item.title).font(.headline.weight(.semibold))
                    if item.requiresPro { ProBadgeView(compact: true) }
                }
                Spacer()
                if settingsStore.theme == item {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(item.accentColor)
                } else if item.requiresPro, !entitlements.hasAccess(to: .premiumThemes) {
                    Image(systemName: "lock.fill").font(.subheadline).foregroundStyle(.secondary)
                }
            }
        }
    }
}

/// 仅用于主题选择页 64×64 预览区；原有 4 主题无图案叠加。
private struct ThemePreviewPatternOverlay: View {
    let theme: ClockTheme

    var body: some View {
        switch theme {
        case .aurora: AuroraPreviewPattern()
        case .sakura: SakuraPreviewPattern()
        case .ember: EmberPreviewPattern()
        case .jadeRealm: JadeRealmPreviewPattern()
        case .purpleDusk: PurpleDuskPreviewPattern()
        case .candyFantasy: CandyFantasyPreviewPattern()
        default: EmptyView()
        }
    }
}

private struct AuroraPreviewPattern: View {
    var body: some View {
        Canvas { context, size in
            let bands: [(y: CGFloat, controlY: CGFloat, opacity: Double)] = [
                (0.55, 0.08, 0.22),
                (0.72, 0.22, 0.16),
                (0.38, 0.18, 0.14),
            ]
            for band in bands {
                var path = Path()
                path.move(to: CGPoint(x: -4, y: size.height * band.y))
                path.addQuadCurve(
                    to: CGPoint(x: size.width + 4, y: size.height * (band.y - 0.18)),
                    control: CGPoint(x: size.width * 0.52, y: size.height * band.controlY)
                )
                context.stroke(
                    path,
                    with: .color(Color(red: 0.62, green: 0.98, blue: 0.88).opacity(band.opacity)),
                    style: StrokeStyle(lineWidth: 2.2, lineCap: .round)
                )
            }
        }
        .allowsHitTesting(false)
    }
}

private struct SakuraPreviewPattern: View {
    private let petals: [(x: CGFloat, y: CGFloat, r: CGFloat, o: Double)] = [
        (0.14, 0.18, 2.2, 0.20), (0.38, 0.12, 1.8, 0.16), (0.62, 0.22, 2.4, 0.18),
        (0.82, 0.14, 1.6, 0.14), (0.24, 0.42, 2.0, 0.17), (0.52, 0.48, 2.6, 0.20),
        (0.76, 0.40, 1.9, 0.15), (0.18, 0.68, 2.2, 0.16), (0.46, 0.72, 1.7, 0.14),
        (0.70, 0.66, 2.3, 0.18), (0.88, 0.78, 1.5, 0.12), (0.32, 0.84, 2.0, 0.15),
    ]

    var body: some View {
        GeometryReader { geo in
            ForEach(Array(petals.enumerated()), id: \.offset) { _, petal in
                Circle()
                    .fill(Color(red: 1.0, green: 0.82, blue: 0.88).opacity(petal.o))
                    .frame(width: petal.r * 2, height: petal.r * 2)
                    .position(x: geo.size.width * petal.x, y: geo.size.height * petal.y)
            }
        }
        .allowsHitTesting(false)
    }
}

private struct EmberPreviewPattern: View {
    private let sparks: [(x: CGFloat, y: CGFloat, r: CGFloat, o: Double)] = [
        (0.20, 0.24, 1.6, 0.22), (0.44, 0.16, 1.2, 0.16), (0.68, 0.28, 1.8, 0.20),
        (0.84, 0.18, 1.0, 0.14), (0.30, 0.52, 1.4, 0.18), (0.58, 0.46, 1.7, 0.21),
        (0.76, 0.58, 1.1, 0.15), (0.16, 0.72, 1.5, 0.17), (0.48, 0.78, 1.3, 0.16),
        (0.72, 0.82, 1.6, 0.19),
    ]

    var body: some View {
        GeometryReader { geo in
            ForEach(Array(sparks.enumerated()), id: \.offset) { _, spark in
                Circle()
                    .fill(Color(red: 1.0, green: 0.88, blue: 0.45).opacity(spark.o))
                    .frame(width: spark.r * 2, height: spark.r * 2)
                    .position(x: geo.size.width * spark.x, y: geo.size.height * spark.y)
            }
        }
        .allowsHitTesting(false)
    }
}

private struct JadeRealmPreviewPattern: View {
    var body: some View {
        Canvas { context, size in
            let leafColor = Color(red: 0.72, green: 0.96, blue: 0.78).opacity(0.18)
            let leaves: [(x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat, angle: Double)] = [
                (0.22, 0.30, 10, 16, -35), (0.58, 0.22, 11, 17, 28),
                (0.78, 0.48, 9, 15, -18), (0.34, 0.62, 12, 18, 42),
                (0.62, 0.72, 10, 16, -25),
            ]
            for leaf in leaves {
                let center = CGPoint(x: size.width * leaf.x, y: size.height * leaf.y)
                var path = Path(ellipseIn: CGRect(x: -leaf.w / 2, y: -leaf.h / 2, width: leaf.w, height: leaf.h))
                let transform = CGAffineTransform(translationX: center.x, y: center.y)
                    .rotated(by: leaf.angle * .pi / 180)
                path = path.applying(transform)
                context.fill(path, with: .color(leafColor))
            }
        }
        .allowsHitTesting(false)
    }
}

private struct PurpleDuskPreviewPattern: View {
    private let stars: [(x: CGFloat, y: CGFloat, s: CGFloat, o: Double)] = [
        (0.18, 0.20, 4, 0.20), (0.42, 0.14, 3, 0.16), (0.66, 0.24, 4.5, 0.18),
        (0.84, 0.16, 3, 0.14), (0.28, 0.46, 3.5, 0.17), (0.54, 0.52, 4, 0.20),
        (0.76, 0.44, 3, 0.15), (0.22, 0.74, 4, 0.18), (0.50, 0.80, 3.5, 0.16),
        (0.74, 0.70, 4, 0.19),
    ]

    var body: some View {
        GeometryReader { geo in
            ForEach(Array(stars.enumerated()), id: \.offset) { _, star in
                StarPreviewShape()
                    .stroke(Color(red: 0.92, green: 0.86, blue: 1.0).opacity(star.o), lineWidth: 0.9)
                    .frame(width: star.s * 2, height: star.s * 2)
                    .position(x: geo.size.width * star.x, y: geo.size.height * star.y)
            }
        }
        .allowsHitTesting(false)
    }
}

private struct StarPreviewShape: Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let arm = min(rect.width, rect.height) * 0.42
        var path = Path()
        path.move(to: CGPoint(x: center.x, y: center.y - arm))
        path.addLine(to: CGPoint(x: center.x, y: center.y + arm))
        path.move(to: CGPoint(x: center.x - arm, y: center.y))
        path.addLine(to: CGPoint(x: center.x + arm, y: center.y))
        path.move(to: CGPoint(x: center.x - arm * 0.65, y: center.y - arm * 0.65))
        path.addLine(to: CGPoint(x: center.x + arm * 0.65, y: center.y + arm * 0.65))
        path.move(to: CGPoint(x: center.x + arm * 0.65, y: center.y - arm * 0.65))
        path.addLine(to: CGPoint(x: center.x - arm * 0.65, y: center.y + arm * 0.65))
        return path
    }
}

private struct CandyFantasyPreviewPattern: View {
    var body: some View {
        Canvas { context, size in
            let spacing: CGFloat = 11
            let radius: CGFloat = 2.2
            let colors: [Color] = [
                Color(red: 1.0, green: 0.78, blue: 0.88).opacity(0.20),
                Color(red: 1.0, green: 0.92, blue: 0.62).opacity(0.18),
                Color(red: 0.72, green: 0.86, blue: 1.0).opacity(0.18),
            ]
            var row = 0
            var y = spacing * 0.6
            while y < size.height + spacing {
                let offsetX = row.isMultiple(of: 2) ? 0 : spacing * 0.5
                var x = offsetX + spacing * 0.4
                var col = 0
                while x < size.width + spacing {
                    let dot = CGRect(x: x - radius, y: y - radius, width: radius * 2, height: radius * 2)
                    context.fill(Path(ellipseIn: dot), with: .color(colors[col % colors.count]))
                    x += spacing
                    col += 1
                }
                y += spacing
                row += 1
            }
        }
        .allowsHitTesting(false)
    }
}
