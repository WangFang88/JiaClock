import StoreKit
import SwiftUI

struct PaywallView: View {
    @EnvironmentObject private var storeKit: StoreKitService
    @EnvironmentObject private var entitlements: EntitlementManager
    @Environment(\.dismiss) private var dismiss

    var highlightFeature: ProFeature? = nil
    @State private var selectedLegal: LegalDocumentType?

    private let brandTheme = ClockTheme.jiaWarmGlow

    var body: some View {
        NavigationStack {
            ZStack {
                JiaBackgroundView(theme: brandTheme)
                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        heroSection
                        valueSection
                        featureSection
                        productSection
                        legalSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 24)
                    .frame(maxWidth: 560)
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(L10n.Common.close) { dismiss() }
                }
            }
            .onAppear { storeKit.recoverFromStalePurchaseStateIfNeeded() }
            .task { await storeKit.loadProducts() }
            .alert(L10n.Pro.alertTitle, isPresented: alertBinding) {
                Button(L10n.Common.done, role: .cancel) {}
            } message: {
                Text(storeKit.alertMessage ?? "")
            }
            .sheet(item: $selectedLegal) { LegalDocumentView(type: $0) }
            .onChange(of: storeKit.purchaseState) { _, newValue in
                if case .succeeded = newValue {
                    dismiss()
                    storeKit.resetPurchaseState()
                }
            }
        }
    }

    private var alertBinding: Binding<Bool> {
        Binding(
            get: { storeKit.alertMessage != nil },
            set: { if !$0 { storeKit.alertMessage = nil } }
        )
    }

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                ProBadgeView()
                if entitlements.isPro {
                    Text(L10n.Pro.alreadyUnlocked)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.green)
                }
            }
            Text(L10n.Pro.paywallTitle)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text(L10n.Pro.paywallSubtitle)
                .font(.body)
                .foregroundStyle(.white.opacity(0.82))
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var valueSection: some View {
        JiaCardView {
            VStack(alignment: .leading, spacing: 10) {
                Text(L10n.Pro.paywallValueHeadline)
                    .font(.headline.weight(.semibold))
                Text(L10n.Pro.paywallValueBody)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                if let highlightFeature {
                    Label(highlightFeature.title, systemImage: highlightFeature.systemImage)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(brandTheme.accentColor)
                        .padding(.top, 4)
                }
            }
        }
    }

    private var featureSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.Pro.paywallFeaturesTitle)
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white)
            ForEach(ProFeature.paywallHighlights) { feature in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: feature.systemImage)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(brandTheme.accentColor)
                        .frame(width: 24)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(feature.title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.94))
                        Text(feature.subtitle)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.78))
                    }
                    Spacer(minLength: 0)
                }
                .padding(12)
                .background {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.white.opacity(0.08))
                }
            }
        }
    }

    @ViewBuilder
    private var productSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.Pro.paywallPlansTitle)
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white)

            if storeKit.isLoadingProducts {
                ProgressView(L10n.Pro.loadingProducts)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
            } else if storeKit.products.isEmpty {
                Text(L10n.Pro.productsUnavailable)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            } else {
                if let yearly = storeKit.yearlyProduct {
                    productCard(product: yearly, style: .recommended)
                }
                if let lifetime = storeKit.lifetimeProduct {
                    productCard(product: lifetime, style: .lifetime)
                }
                if let monthly = storeKit.monthlyProduct {
                    productCard(product: monthly, style: .standard)
                }
            }

            Button {
                storeKit.requestRestorePurchases()
            } label: {
                HStack(spacing: 8) {
                    if storeKit.isRestoring { ProgressView().controlSize(.small) }
                    Text(L10n.Pro.restorePurchases)
                }
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.white.opacity(0.88))
            .disabled(storeKit.isRestoring)

            Text(L10n.Pro.subscriptionDisclosure)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.55))
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var legalSection: some View {
        HStack(spacing: 16) {
            Button(L10n.Legal.termsOfService) { selectedLegal = .termsOfService }
            Button(L10n.Legal.privacyPolicy) { selectedLegal = .privacyPolicy }
        }
        .font(.caption)
        .foregroundStyle(.white.opacity(0.7))
        .frame(maxWidth: .infinity)
    }

    private func isProcessing(product: Product) -> Bool {
        storeKit.purchasingProductID == product.id && storeKit.isPurchaseInProgress
    }

    private enum ProductCardStyle {
        case standard, recommended, lifetime
    }

    @ViewBuilder
    private func productCard(product: Product, style: ProductCardStyle) -> some View {
        Button {
            storeKit.requestPurchase(product)
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(planTitle(for: product, style: style))
                        .font(.headline.weight(.bold))
                    Spacer(minLength: 8)
                    if isProcessing(product: product) {
                        HStack(spacing: 6) {
                            ProgressView().controlSize(.small)
                            Text(L10n.Pro.processing)
                                .font(.caption.weight(.semibold))
                        }
                    } else if style == .recommended {
                        Text(L10n.Pro.recommendedBadge)
                            .font(.caption2.weight(.bold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(brandTheme.accentColor))
                            .foregroundStyle(Color(red: 0.18, green: 0.10, blue: 0.04))
                    } else if style == .lifetime {
                        Text(L10n.Pro.lifetimeBadge)
                            .font(.caption2.weight(.bold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(Color.white.opacity(0.92)))
                            .foregroundStyle(Color(red: 0.18, green: 0.10, blue: 0.04))
                    }
                }
                Text(storeKit.productDisplayName(product))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(storeKit.productDisplayPrice(product))
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                    if let period = storeKit.subscriptionPeriodDescription(for: product) {
                        Text(period).font(.caption).foregroundStyle(.secondary)
                    }
                }
                if style == .lifetime {
                    Text(L10n.Pro.lifetimeHint)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(cardFill(for: style))
                    .overlay {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .strokeBorder(cardStroke(for: style), lineWidth: style == .standard ? 1 : 1.5)
                    }
            }
            .foregroundStyle(Color(red: 0.12, green: 0.12, blue: 0.16))
        }
        .buttonStyle(.plain)
        .disabled(entitlements.isPro)
        .opacity(entitlements.isPro ? 0.55 : 1)
    }

    private func planTitle(for product: Product, style: ProductCardStyle) -> String {
        switch product.id {
        case ProProductID.monthly: return L10n.Pro.planMonthly
        case ProProductID.yearly: return L10n.Pro.planYearly
        case ProProductID.lifetime: return L10n.Pro.planLifetime
        default: return product.displayName
        }
    }

    private func cardFill(for style: ProductCardStyle) -> AnyShapeStyle {
        switch style {
        case .standard: AnyShapeStyle(Color.white.opacity(0.88))
        case .recommended: AnyShapeStyle(LinearGradient(
            colors: [Color.white.opacity(0.96), Color(red: 1, green: 0.94, blue: 0.86)],
            startPoint: .topLeading, endPoint: .bottomTrailing
        ))
        case .lifetime: AnyShapeStyle(LinearGradient(
            colors: [Color(red: 0.98, green: 0.88, blue: 0.62), Color.white.opacity(0.94)],
            startPoint: .topLeading, endPoint: .bottomTrailing
        ))
        }
    }

    private func cardStroke(for style: ProductCardStyle) -> Color {
        switch style {
        case .standard: Color.white.opacity(0.25)
        case .recommended: brandTheme.accentColor.opacity(0.65)
        case .lifetime: Color(red: 0.92, green: 0.58, blue: 0.24).opacity(0.75)
        }
    }
}
