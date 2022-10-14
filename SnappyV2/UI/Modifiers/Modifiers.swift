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

struct StandardAlertToast: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.tabViewHeight) var tabViewHeight
    
    @Binding var error: Swift.Error?
    @State var showAlert = false
    let container: DIContainer
    let viewID: UUID
    
    var text: String {
        guard let error = container.appState.value.latestError else { return "" }
        if let err = error as? APIErrorResult {
            return err.errorDisplay
        }
        return error.localizedDescription
    }
    
    @State var errorText = ""
    
    let tapToDismissOverride: Bool
    
    init(container: DIContainer, tapToDismissOverride: Bool, error: Binding<Swift.Error?>, viewID: UUID) {
        self._error = error
        self.tapToDismissOverride = tapToDismissOverride
        self.container = container
        self.viewID = viewID
    }
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: container, colorScheme: colorScheme)
    }
    
    func body(content: Content) -> some View {
        content
            .toast(isPresenting: $showAlert, subtitle: $errorText, tapToDismissOverride: tapToDismissOverride, alert: { subtitle, tapToDismiss  in
                AlertToast(
                    displayMode: .banner(.slide),
                    type: .regular,
                    title: GeneralStrings.oops.localized,
                    subTitle: $errorText,
                    style: .style(
                        backgroundColor: .red,
                        titleColor: .white,
                        subTitleColor: .white,
                        titleFont: .Body1.semiBold(),
                        subTitleFont: .Body1.regular()),
                    tapToDismiss: tapToDismiss
                )
            })
            .padding(.bottom)
            .onChange(of: container.appState.value.latestError?.localizedDescription) { errText in
                if errText != nil && showAlert == false && container.appState.value.latestViewID == viewID {

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        
                        if let err = container.appState.value.latestError as? APIErrorResult {
                            self.errorText = err.errorDisplay
                            showAlert = true
                            self.errorText = err.errorDisplay
                        } else {
                            self.errorText = container.appState.value.latestError?.localizedDescription ?? ""
                            showAlert = true
                            self.errorText = container.appState.value.latestError?.localizedDescription ?? ""
                        }
                        

                    }
                }
            }
            .onChange(of: showAlert) { newValue in
                if newValue == false && container.appState.value.latestViewID == viewID {
                    container.appState.value.errors.removeAll(where: { $0.localizedDescription == error?.localizedDescription })
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
        static let size: CGFloat = 40
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
    @Environment(\.tabViewHeight) var tabViewHeight
    
    @Binding var toastText: String?
    @State var showAlert = false
    @State var successText = ""
    
    let container: DIContainer
    let viewID: UUID

    init(container: DIContainer, viewID: UUID, toastText: Binding<String?>) {
        self._toastText = toastText
        self.container = container
        self.viewID = viewID
    }
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: container, colorScheme: colorScheme)
    }
    
    func body(content: Content) -> some View {
        content
            .toast(isPresenting: $showAlert, subtitle: .constant(successText), tapToDismissOverride: false, alert: { subtitle, tapToDismiss in
                AlertToast(
                    displayMode: .banner(.slide),
                    type: .regular,
                    title: GeneralStrings.success.localized,
                    subTitle: $successText,
                    style: .style(
                        backgroundColor: colorPalette.alertSuccess,
                        titleColor: .white,
                        subTitleColor: .white,
                        titleFont: .Body1.semiBold(),
                        subTitleFont: .Body1.regular()),
                    tapToDismiss: false // success toast should not be tap to dismiss
                )
            })
            .padding(.bottom, showAlert ? tabViewHeight : 0)
            .onChange(of: container.appState.value.latestSuccessToast) { toastText in
                if toastText?.isEmpty == false && container.appState.value.latestViewID == viewID {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.successText = container.appState.value.latestSuccessToast ?? ""

                        showAlert = true
                    }
                }
            }
            .onChange(of: showAlert) { newValue in
                if newValue == false {
                    container.appState.value.successToastStrings.removeAll(where: { $0 == toastText })
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

struct LoadingToast: ViewModifier {
    @Binding var loading: Bool

    init(loading: Binding<Bool>) {
        self._loading = loading
    }
    
    func body(content: Content) -> some View {
        content
            .toast(isPresenting: $loading, subtitle: .constant(""), tapToDismissOverride: true, alert: { _, _  in
                AlertToast(
                    displayMode: .alert,
                    type: .loading,
                    subtitle: .constant(""),
                    tapToDismiss: false
                )
            })
    }
}

extension View {
    func withLoadingToast(loading: Binding<Bool>) -> some View {
        modifier(LoadingToast(loading: loading))
    }
}

extension View {
    func withAlertToast(container: DIContainer, tapToDismissOverride: Bool = false, error: Binding<Swift.Error?>, viewID: UUID) -> some View {
        modifier(StandardAlertToast(container: container, tapToDismissOverride: tapToDismissOverride, error: error, viewID: viewID))

    }
}

extension View {
    func withSuccessToast(container: DIContainer, viewID: UUID, toastText: Binding<String?>) -> some View {
        modifier(StandardSuccessToast(container: container, viewID: viewID, toastText: toastText))
    }
}

#warning("Still using in a few places but need to deprecate.")
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

extension View {
    func snappySheet(container: DIContainer, isPresented: Binding<Bool>, sheetContent: some View) -> some View {
        self
            .sheet(isPresented: isPresented) {
                ToastableViewContainer(content: {
                    sheetContent
                }, viewModel: .init(container: container, isModal: true))
            }
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
