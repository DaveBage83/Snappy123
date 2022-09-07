//
//  Modifiers.swift
//  SnappyV2
//
//  Created by David Bage on 07/05/2022.
//

import SwiftUI

struct LoadingModifier: ViewModifier {
    @Binding var isLoading: Bool
    let color: Color
    
    func body(content: Content) -> some View {
        
        content
            .overlay(Group { // We need to wrap in a group as <iOS15 has no way of directly including conditions in overlays
                if isLoading {
                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: color))
                }
            }, alignment: .center)
    }
}

struct StandardCardFormat: ViewModifier {
    @Binding var isDisabled: Bool

    func body(content: Content) -> some View {
        content
            .cornerRadius(8)
            .shadow(color: isDisabled ? .clear : .cardShadow, radius: 9, x: 0, y: 0) // When in disabled state we do not want to apply shadow
    }
}

struct StandardPillFormat: ViewModifier {
    func body(content: Content) -> some View {
        content
            .cornerRadius(34)
            .shadow(color: .cardShadow, radius: 9, x: 0, y: 0)
    }
}

struct StandardPillCornerRadius: ViewModifier {
    func body(content: Content) -> some View {
        content
            .cornerRadius(24)
    }
}

struct SizePreferenceKey: PreferenceKey {
  static var defaultValue: CGSize = .zero

  static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
    value = nextValue()
  }
}

struct MeasureSizeModifier: ViewModifier {
  func body(content: Content) -> some View {
    content.background(GeometryReader { geometry in
      Color.clear.preference(key: SizePreferenceKey.self,
                             value: geometry.size)
    })
  }
}

struct CardOnImageViewModifier: ViewModifier {
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.presentationMode) var presentation
    let colorPalette: ColorPalette
    let includeDismissableNavigation: Bool
    
    struct Constants {
        struct Frame {
            static let largeDeviceWidth: CGFloat = UIScreen.screenWidth * 0.7
        }
        
        struct InternalPadding {
            static let standard: CGFloat = 16
            static let largeDevice: CGFloat = 32
        }
        
        struct ExternalPadding {
            static let standard: CGFloat = UIScreen.screenHeight * 0.05
            static let largeDevice: CGFloat = UIScreen.screenHeight * 0.2
        }
    }
    
    private var externalPadding: CGFloat {
        sizeClass == .compact ? Constants.ExternalPadding.standard : Constants.ExternalPadding.largeDevice
    }
    
    func body(content: Content) -> some View {
        if includeDismissableNavigation {
            mainContent(content: content)
                .dismissableNavBar(presentation: presentation, color: .white)
        } else {
            mainContent(content: content)
        }
    }
    
    func mainContent(content: Content) -> some View {
        content
            .frame(maxWidth: sizeClass == .compact ? .infinity : Constants.Frame.largeDeviceWidth)
            .padding(sizeClass == .compact ? Constants.InternalPadding.standard : Constants.InternalPadding.largeDevice)
            .background(colorPalette.secondaryWhite)
            .standardCardFormat()
            .padding(.top, externalPadding)
            .padding(.horizontal)
    }
}

struct StandardAlert: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    let container: DIContainer
    
    enum StandardAlertType {
        case error
        case info
        case success
    }
    
    @Binding var isPresenting: Bool
    let type: StandardAlertType
    let title: String
    let subtitle: String
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: container, colorScheme: colorScheme)
    }
    
    private var backgroundColor: Color {
        switch type {
        case .error:
            return colorPalette.alertWarning
        case .info:
            return colorPalette.primaryBlue.withOpacity(.ten)
        case .success:
            return colorPalette.alertSuccess
        }
    }
    
    private var textColor: Color {
        switch type {
        case .error:
            return .white
        case .info:
            return colorPalette.typefacePrimary
        case .success:
            return .white
        }
    }
    
    func body(content: Content) -> some View {
        content
            .toast(isPresenting: $isPresenting, alert: {
                AlertToast(
                    displayMode: .banner(.slide),
                    type: .regular,
                    title: title,
                    subTitle: subtitle,
                    style: .style(
                        backgroundColor: backgroundColor,
                        titleColor: textColor,
                        subTitleColor: textColor,
                        titleFont: .Body1.semiBold(),
                        subTitleFont: .Body1.regular())
                )
            })
    }
}

struct StandardAlertToast: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.tabViewHeight) var tabViewHeight

    @Binding var error: Swift.Error?
    @State var showAlert = false
    
    var text: String {
        guard let error = error else { return "" }
        if let error = error as? APIErrorResult {
            return error.errorDisplay
        } else {
            return error.localizedDescription
        }
    }
    
    let container: DIContainer

    init(container: DIContainer, error: Binding<Swift.Error?>) {
        self._error = error
        self.container = container
    }
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: container, colorScheme: colorScheme)
    }
    
    func body(content: Content) -> some View {
        content
            .toast(isPresenting: $showAlert, alert: {
                AlertToast(
                    displayMode: .banner(.slide),
                    type: .regular,
                    title: GeneralStrings.oops.localized,
                    subTitle: text,
                    style: .style(
                        backgroundColor: colorPalette.alertWarning,
                        titleColor: .white,
                        subTitleColor: .white,
                        titleFont: .Body1.semiBold(),
                        subTitleFont: .Body1.regular())
                )
            })
            .padding(.bottom, showAlert ? tabViewHeight : 0)
            .onChange(of: error?.localizedDescription) { err in
                if err?.isEmpty == false {
                    showAlert = true
                }
            }
            .onChange(of: showAlert) { newValue in
                if newValue == false {
                    error = nil
                }
            }
    }
}

struct HighlightedItem: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    struct Constants {
        static let cornerRadius: CGFloat = 8
        static let itemPadding: CGFloat = 8
    }
    
    let container: DIContainer
    let banners: [BannerDetails]

    @State var bannerHeight: CGFloat = 0.0
    
    var backgroundColor: Color {
        let selectedBanner = banners.min(by: { $0.type.rawValue < $1.type.rawValue })
        return selectedBanner?.type.associatedMainBgColor(colorPalette: colorPalette) ?? .clear
    }
    
    var bottomBannerId: UUID? {
        banners.last?.id
    }
    
    init(container: DIContainer, banners: [BannerDetails]) {
        self.container = container
        self.banners = banners.sorted { $0.type.rawValue > $1.type.rawValue }
    }
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: container, colorScheme: colorScheme)
    }
    
    func body(content: Content) -> some View {
        ZStack(alignment: .bottom) {
            content
                .padding([.top, .horizontal], Constants.itemPadding)
                .padding(.bottom, bannerHeight) // Adjust by height of banner
                .padding(.bottom) // Add additional standard bottom padding
                .background(backgroundColor)
                .cornerRadius(Constants.cornerRadius)
            VStack(spacing: 0) {
                ForEach(banners, id: \.id) { banner in
                    BasketAndPastOrderItemBanner(
                        viewModel: .init(
                            container: container,
                            banner: banner,
                            isBottomBanner: banner.id == bottomBannerId))
                        .frame(maxWidth: .infinity)
                        .overlay(GeometryReader { geo in
                            Text("")
                                .onAppear {
                                    self.bannerHeight = geo.size.height * CGFloat(banners.count)
                                }
                        })
                }
            }
        }
    }
}

struct BasketAndPastOrderImage: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    struct Constants {
        static let size: CGFloat = 56
        static let cornerRadius: CGFloat = 8
        static let lineWidth: CGFloat = 1
        static let padding: CGFloat = 4
    }
    
    let container: DIContainer
    
    init(container: DIContainer) {
        self.container = container
    }
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: container, colorScheme: colorScheme)
    }
    
    func body(content: Content) -> some View {
        content
            .scaledToFit()
            .frame(width: Constants.size, height: Constants.size)
            .padding(Constants.padding)
            .background(colorPalette.secondaryWhite)
            .cornerRadius(Constants.cornerRadius)

    }
}

struct StandardSuccessToast: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
        
    @Binding var toastText: String?
    @State var showAlert = false
    
    let container: DIContainer

    init(container: DIContainer, toastText: Binding<String?>) {
        self._toastText = toastText
        self.container = container
    }
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: container, colorScheme: colorScheme)
    }
    
    func body(content: Content) -> some View {
        content
            .toast(isPresenting: $showAlert, alert: {
                AlertToast(
                    displayMode: .banner(.slide),
                    type: .regular,
                    title: GeneralStrings.success.localized,
                    subTitle: toastText,
                    style: .style(
                        backgroundColor: colorPalette.alertSuccess,
                        titleColor: .white,
                        subTitleColor: .white,
                        titleFont: .Body1.semiBold(),
                        subTitleFont: .Body1.regular())
                )
            })
            .onChange(of: toastText) { toastText in
                if toastText?.isEmpty == false {
                    showAlert = true
                }
            }
            .onChange(of: showAlert) { newValue in
                if newValue == false {
                    toastText = nil
                }
            }
    }
}

struct WithInfoButtonAndText: ViewModifier {
    @State var elementWidth: CGFloat = 0
    
    let container: DIContainer
    let infoText: String
    
    func body(content: Content) -> some View {
        content
            .overlay(GeometryReader { geo in
                Text("")
                    .onAppear {
                        elementWidth = geo.size.width
                    }
            })
            .overlay(InfoButtonWithText(container: container, text: infoText)
                .offset(x: (elementWidth / 2) + 16)
            )
    }
}

struct WithNavigationAnimation: ViewModifier {
    @State var navigationDirection: NavigationDirection
    
    func body(content: Content) -> some View {
        content
            .transition(AnyTransition.asymmetric(
                insertion:.move(edge: navigationDirection == .back ? .leading : .trailing),
                removal: .move(edge: navigationDirection == .back ? .trailing : .leading))
            )
            .animation(.default)
    }
}

struct HighlightedItem: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    struct Constants {
        static let cornerRadius: CGFloat = 8
        static let itemPadding: CGFloat = 8
    }
    
    let container: DIContainer
    let banners: [BannerDetails]

    @State var bannerHeight: CGFloat = 0.0
    
    var backgroundColor: Color {
        let selectedBanner = banners.min(by: { $0.type.rawValue < $1.type.rawValue })
        return selectedBanner?.type.associatedMainBgColor(colorPalette: colorPalette) ?? .clear
    }
    
    var bottomBannerId: UUID? {
        banners.last?.id
    }
    
    init(container: DIContainer, banners: [BannerDetails]) {
        self.container = container
        self.banners = banners.sorted { $0.type.rawValue > $1.type.rawValue }
    }
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: container, colorScheme: colorScheme)
    }
    
    func body(content: Content) -> some View {
        ZStack(alignment: .bottom) {
            content
                .padding([.top, .horizontal], Constants.itemPadding)
                .padding(.bottom, bannerHeight) // Adjust by height of banner
                .padding(.bottom) // Add additional standard bottom padding
                .background(backgroundColor)
                .cornerRadius(Constants.cornerRadius)
            VStack(spacing: 0) {
                ForEach(banners, id: \.id) { banner in
                    BasketAndPastOrderItemBanner(
                        viewModel: .init(
                            container: container,
                            banner: banner,
                            isBottomBanner: banner.id == bottomBannerId))
                        .frame(maxWidth: .infinity)
                        .overlay(GeometryReader { geo in
                            Text("")
                                .onAppear {
                                    self.bannerHeight = geo.size.height * CGFloat(banners.count)
                                }
                        })
                }
            }
        }
    }
}

struct BasketAndPastOrderImage: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    struct Constants {
        static let size: CGFloat = 56
        static let cornerRadius: CGFloat = 8
        static let lineWidth: CGFloat = 1
        static let padding: CGFloat = 4
    }
    
    let container: DIContainer
    
    init(container: DIContainer) {
        self.container = container
    }
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: container, colorScheme: colorScheme)
    }
    
    func body(content: Content) -> some View {
        content
            .scaledToFit()
            .frame(width: Constants.size, height: Constants.size)
            .padding(Constants.padding)
            .background(colorPalette.secondaryWhite)
            .cornerRadius(Constants.cornerRadius)

    }
}

extension View {
    func withStandardAlert(container: DIContainer, isPresenting: Binding<Bool>, type: StandardAlert.StandardAlertType, title: String, subtitle: String) -> some View {
        modifier(StandardAlert(
            container: container,
            isPresenting: isPresenting,
            type: type,
            title: title,
            subtitle: subtitle))
    }
}

extension View {
    func withAlertToast(container: DIContainer, error: Binding<Swift.Error?>) -> some View {
        modifier(StandardAlertToast(container: container, error: error))
    }
}

extension View {
    func withSuccessToast(container: DIContainer, toastText: Binding<String?>) -> some View {
        modifier(StandardSuccessToast(container: container, toastText: toastText))
    }
}

extension View {
    func withLoadingView(isLoading: Binding<Bool>, color: Color) -> some View {
        modifier(LoadingModifier(isLoading: isLoading, color: color))
    }
}

extension View {
    func standardPillCornerRadius() -> some View {
        modifier(StandardPillCornerRadius())
    }
}

extension View {
    func standardCardFormat(isDisabled: Binding<Bool> = .constant(false)) -> some View {
        modifier(StandardCardFormat(isDisabled: isDisabled))
    }
}

extension View {
    func standardPillFormat() -> some View {
        modifier(StandardPillFormat())
    }
}

extension View {
  func measureSize(perform action: @escaping (CGSize) -> Void) -> some View {
    self.modifier(MeasureSizeModifier())
      .onPreferenceChange(SizePreferenceKey.self, perform: action)
  }
}

extension View {
    func cardOnImageFormat(colorPalette: ColorPalette, includeDismissableNavigation: Bool) -> some View {
        modifier(CardOnImageViewModifier(colorPalette: colorPalette, includeDismissableNavigation: includeDismissableNavigation))
    }
}

extension View {
    func withNavigationAnimation(direction: NavigationDirection) -> some View {
        modifier(WithNavigationAnimation(navigationDirection: direction))
    }
}

extension View {
    func basketAndPastOrderImage(container: DIContainer) -> some View {
        modifier(BasketAndPastOrderImage(container: container))
    }
}

enum NavigationDirection {
    case back
    case forward
}

extension View {
    func highlightedItem(container: DIContainer, banners: [BannerDetails]) -> some View {
        modifier(HighlightedItem(container: container, banners: banners))
    }
}

extension View {
    func withInfoButtonAndText(container: DIContainer, text: String) -> some View {
        modifier(WithInfoButtonAndText(container: container, infoText: text))
    }
}

enum BannerType: Int {
    case missedOffer = 1
    case viewSelection
    case substitutedItem
    case rejectedItem
    case itemQuantityChange
    
    func bgColor(colorPalette: ColorPalette) -> Color {
        switch self {
        case .viewSelection, .itemQuantityChange:
            return colorPalette.primaryBlue
        case .missedOffer:
            return colorPalette.offer
        case .substitutedItem:
            return colorPalette.alertOfferBasket
        case .rejectedItem:
            return colorPalette.primaryRed
        }
    }

    func textColor(colorPalette: ColorPalette) -> Color {
        switch self {
        case .viewSelection, .substitutedItem, .rejectedItem, .itemQuantityChange:
            return .white
        case .missedOffer:
            return colorPalette.typefacePrimary
        }
    }
    
    func associatedMainBgColor(colorPalette: ColorPalette) -> Color {
        switch self {
        case .viewSelection, .itemQuantityChange:
            return colorPalette.primaryBlue.withOpacity(.ten)
        case .missedOffer:
            return colorPalette.offer.withOpacity(.ten)
        case .rejectedItem:
            return colorPalette.primaryRed.withOpacity(.ten)
        case .substitutedItem:
            return colorPalette.alertOfferBasket.withOpacity(.ten)
        }
    }
    
    var icon: Image? {
        switch self {
        case .viewSelection:
            return Image.Icons.Eye.filled
        case .missedOffer:
            return Image.Icons.Plus.medium
        case .substitutedItem, .rejectedItem, .itemQuantityChange:
            return nil
        }
    }
}

struct BannerDetails: Identifiable {
    let id = UUID()
    let type: BannerType
    let text: String
    let action: (() -> Void)?
}
