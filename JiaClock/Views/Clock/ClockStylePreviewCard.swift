import SwiftUI

struct ClockStylePreviewCard: View {
    let style: ClockDisplayStyle
    let isSelected: Bool
    let isLocked: Bool
    let accent: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                ZStack(alignment: .topTrailing) {
                    ClockStyleMiniPreview(style: style)
                        .frame(height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .strokeBorder(
                                    isSelected ? accent.opacity(0.95) : Color.white.opacity(0.10),
                                    lineWidth: isSelected ? 2 : 1
                                )
                        }

                    HStack(spacing: 6) {
                        if style.isProStyle {
                            ProBadgeView(compact: true)
                        }
                        if isLocked {
                            Image(systemName: "lock.fill")
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(.white.opacity(0.75))
                                .padding(6)
                                .background(Circle().fill(Color.black.opacity(0.35)))
                        }
                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.body)
                                .foregroundStyle(accent)
                                .shadow(color: accent.opacity(0.4), radius: 4, x: 0, y: 0)
                        }
                    }
                    .padding(8)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(style.title)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    Text(style.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    if style.showsCameraBadge {
                        Label(L10n.ClockStyleCenter.cameraBadge, systemImage: "camera.fill")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(accent.opacity(0.92))
                    }
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.primary.opacity(0.04))
                    .overlay {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .strokeBorder(
                                isSelected ? accent.opacity(0.35) : Color.primary.opacity(0.06),
                                lineWidth: 1
                            )
                    }
            }
            .shadow(color: Color.black.opacity(isSelected ? 0.12 : 0.06), radius: isSelected ? 14 : 8, x: 0, y: 6)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 迷你预览

struct ClockStyleMiniPreview: View {
    let style: ClockDisplayStyle

    var body: some View {
        switch style {
        case .digital:
            digitalPreview
        case .flip:
            flipPreview
        case .transparentFlip:
            transparentFlipPreview
        case .stackedFlip:
            stackedFlipPreview
        case .retroCalendar:
            retroPreview
        case .dayHourglass:
            hourglassPreview
        case .minimalFloating:
            minimalPreview
        }
    }

    private var digitalPreview: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.12, green: 0.14, blue: 0.22), Color(red: 0.06, green: 0.08, blue: 0.14)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Text("10:28")
                .font(.system(size: 34, weight: .ultraLight, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.white.opacity(0.92))
        }
    }

    private var flipPreview: some View {
        ZStack {
            Color(red: 0.10, green: 0.12, blue: 0.18)
            HStack(spacing: 8) {
                miniFlipDigit("1")
                miniFlipDigit("0")
                Text(":").font(.title3.weight(.light)).foregroundStyle(.white.opacity(0.55))
                miniFlipDigit("2")
                miniFlipDigit("8")
            }
        }
    }

    private var transparentFlipPreview: some View {
        ZStack {
            LinearGradient(colors: [.gray.opacity(0.35), .gray.opacity(0.55)], startPoint: .top, endPoint: .bottom)
            HStack(spacing: 5) {
                miniGlassFlip("1", opacity: 0.55)
                miniGlassFlip("0", opacity: 0.55)
                Text(":").font(.caption.weight(.light)).foregroundStyle(.white.opacity(0.7))
                miniGlassFlip("2", opacity: 0.55)
                miniGlassFlip("8", opacity: 0.55)
            }
        }
    }

    private var stackedFlipPreview: some View {
        ZStack {
            Color(red: 0.08, green: 0.08, blue: 0.12)
            StackedFlipThemePreview(theme: StackedFlipThemeLibrary.orangeClassic)
                .scaleEffect(0.78)
        }
    }

    private var retroPreview: some View {
        ZStack {
            Color(red: 0.10, green: 0.10, blue: 0.14)
            RetroCalendarClockPreview(theme: RetroCalendarClockThemeLibrary.classicYellow)
                .scaleEffect(0.82)
        }
    }

    private var hourglassPreview: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.04, green: 0.04, blue: 0.06), Color(red: 0.10, green: 0.08, blue: 0.12)],
                startPoint: .top,
                endPoint: .bottom
            )
            DayHourglassView(
                date: Date.now,
                theme: DayHourglassThemeLibrary.goldenNight,
                size: CGSize(width: 56, height: 88)
            )
        }
    }

    private var minimalPreview: some View {
        ZStack {
            LinearGradient(colors: [.gray.opacity(0.4), .gray.opacity(0.6)], startPoint: .top, endPoint: .bottom)
            VStack(spacing: 6) {
                Text("10:28")
                    .font(.system(size: 28, weight: .thin, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.white)
                Rectangle()
                    .fill(Color.white.opacity(0.35))
                    .frame(width: 48, height: 1)
            }
        }
    }

    private func miniFlipDigit(_ digit: String) -> some View {
        Text(digit)
            .font(.system(size: 20, weight: .light, design: .rounded))
            .foregroundStyle(.white)
            .frame(width: 26, height: 32)
            .background(RoundedRectangle(cornerRadius: 5).fill(Color.white.opacity(0.12)))
    }

    private func miniGlassFlip(_ digit: String, opacity: Double) -> some View {
        Text(digit)
            .font(.system(size: 16, weight: .light, design: .rounded))
            .foregroundStyle(.white)
            .frame(width: 22, height: 28)
            .background(RoundedRectangle(cornerRadius: 5).fill(Color.white.opacity(opacity)))
            .overlay(RoundedRectangle(cornerRadius: 5).strokeBorder(Color.white.opacity(0.25), lineWidth: 0.5))
    }
}
