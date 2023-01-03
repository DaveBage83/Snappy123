//
//  Modifiers.swift
//  SnappyV2
//
//  Created by David Bage on 07/05/2022.
//

import SwiftUI
import Combine

struct StandardCardFormat: ViewModifier {
    @Binding var isDisabled: Bool
    let corners: UIRectCorner
    
    init(isDisabled: Binding<Bool>, corners: UIRectCorner) {
        self._isDisabled = isDisabled
        self.corners = corners
    }

    func body(content: Content) -> some View {
        content
            .cornerRadius(8, corners: corners)
            .shadow(color: isDisabled ? .clear : .cardShadow, radius: 9, x: 0, y: 0) // When in disabled state we do not want to apply shadow
    }
}

struct StandardPillFormat: ViewModifier {
    let outlineColor: Color?
    
    init(outlineColor: Color?) {
        self.outlineColor = outlineColor
    }
    
    func body(content: Content) -> some View {
        content
            .cornerRadius(34)
            .shadow(color: .cardShadow, radius: 9, x: 0, y: 0)
            .overlay(
                RoundedRectangle(cornerRadius: 34)
                    .stroke(outlineColor ?? .clear, lineWidth: outlineColor != nil ? 0.5 : 0)
            )
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

enum ToastType {
    case error
    case success
}

class StandardAlertToastViewModel: ObservableObject {
    let container: DIContainer
    @Published var showAlert = false
    @Published var alertText = ""
    
    private var cancellables = Set<AnyCancellable>()
    let viewID: UUID
    let toastType: ToastType
    
    init(container: DIContainer, toastType: ToastType, viewID: UUID) {
        self.container = container
        self.viewID = viewID
        self.toastType = toastType
        let appState = container.appState
        
        if toastType == .error {
            setupBindToLatestError(with: appState)
        }
        
        if toastType == .success {
            setupBindToLatestSuccess(with: appState)
        }
    }
    
    private func setupBindToLatestError(with appState: Store<AppState>) {
        appState
            .map(\.errors.first)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                guard let self else { return }
                self.configureAlert()
            }
            .store(in: &cancellables)
    }
    
    private func setupBindToLatestSuccess(with appState: Store<AppState>) {
        appState
            .map(\.successToasts.first)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                guard let self else { return }
                self.configureAlert()
            }
            .store(in: &cancellables)
    }
    
    private func configureAlert() {
        switch toastType {
        case .error:
            let toastString = container.appState.value.errors.first?.localizedDescription
            handleToast(toastString: toastString)
        case .success:
            let toastString = container.appState.value.successToasts.first?.subtitle
            handleToast(toastString: toastString)
        }
    }
    
    private func handleToast(toastString: String?) {
        if let toastString, toastString.isEmpty == false {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                guard let self else { return }
                self.alertText = toastString
                self.showAlert = true
            }
            
        } else {
            self.alertText = ""
            self.showAlert = false
        }
    }
}

struct StandardAlertToast: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: StandardAlertToastViewModel
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    func body(content: Content) -> some View {
        content
            .toast(
                container: viewModel.container,
                isPresenting: $viewModel.showAlert,
                subtitle: $viewModel.alertText, alert: { subtitle, tapToDismiss  in
                AlertToast(
                    displayMode: .banner(.slide),
                    type: .regular,
                    title: viewModel.toastType == .error ? GeneralStrings.oops.localized : GeneralStrings.success.localized,
                    subTitle: .constant(subtitle),
                    style: .style(
                        backgroundColor: viewModel.toastType == .error ? colorPalette.alertWarning : colorPalette.alertSuccess,
                        titleColor: .white,
                        subTitleColor: .white,
                        titleFont: .Body1.semiBold(),
                        subTitleFont: .Body1.regular()),
                    tapToDismiss: tapToDismiss
                )
            })
    }
}

struct HighlightedItem: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    struct Constants {
        static let cornerRadius: CGFloat = 8
        static let bottomPadding: CGFloat = 5
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
                .padding(.bottom, bannerHeight) // Adjust by height of banner
                .padding(.bottom, Constants.bottomPadding) // Add additional standard bottom padding
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

struct LoadingToast: ViewModifier {
    let container: DIContainer
    @Binding var loading: Bool

    init(container: DIContainer, loading: Binding<Bool>) {
        self._loading = loading
        self.container = container
    }
    
    func body(content: Content) -> some View {
        content
            .toast(container: container, isPresenting: $loading, subtitle: .constant(""), alert: { _, _  in
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
    func withLoadingToast(container: DIContainer, loading: Binding<Bool>) -> some View {
        modifier(LoadingToast(container: container, loading: loading))
    }
}

extension View {
    func withAlertToast(container: DIContainer, toastType: ToastType, viewID: UUID) -> some View {
        modifier(StandardAlertToast(viewModel: .init(
            container: container,
            toastType: toastType,
            viewID: viewID)))
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
    func standardCardFormat(isDisabled: Binding<Bool> = .constant(false), corners: UIRectCorner = .allCorners) -> some View {
        modifier(StandardCardFormat(isDisabled: isDisabled, corners: corners))
    }
}

extension View {
    func standardPillFormat(outlineColor: Color? = nil) -> some View {
        modifier(StandardPillFormat(outlineColor: outlineColor))
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

struct DeliveryTierInfo: Identifiable, Equatable {
    let id = UUID()
    let orderMethod: RetailStoreOrderMethod?
    let currency: RetailStoreCurrency?
}

struct DeliveryOfferBanner: ViewModifier {
    @Environment(\.mainWindowSize) var mainWindowSize

    @Environment(\.colorScheme) var colorScheme
    
    @StateObject var viewModel: DeliveryOfferBannerViewModel
                
    init(viewModel: DeliveryOfferBannerViewModel) {
        self._viewModel = .init(wrappedValue: viewModel)
    }

    func body(content: Content) -> some View {
        if viewModel.showDeliveryBanner {
            content
                .highlightedItem(container: viewModel.container, banners: [.init(type: viewModel.bannerType, text: viewModel.deliveryBannerText?.firstLetterCapitalized ?? "", action: {
                if viewModel.isDisabled == false, let orderMethod = viewModel.deliveryTierInfo.orderMethod {
                    viewModel.setOrderMethod(orderMethod)
                }
            })])
            .disabled(viewModel.isDisabled)
            .snappyBottomSheet(
                container: viewModel.container,
                item: $viewModel.selectedDeliveryTierInfo,
                windowSize: mainWindowSize,
                content: { orderMethod in
                    RetailStoreDeliveryTiers(viewModel: .init(
                        container: viewModel.container,
                        deliveryOrderMethod: viewModel.selectedDeliveryTierInfo?.orderMethod,
                        currency: viewModel.deliveryTierInfo.currency))
                })
        } else {
            content
        }
    }
}

extension View {
    func withDeliveryOffer(container: DIContainer, deliveryTierInfo: DeliveryTierInfo, currency: RetailStoreCurrency?, fromBasket: Bool) -> some View {
        modifier(DeliveryOfferBanner(viewModel: .init(container: container, deliveryTierInfo: deliveryTierInfo, currency: currency, fromBasket: fromBasket)))
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

struct CustomAlert: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    let container: DIContainer
    let frameWidth: CGFloat = 300
    let cornerRadius: CGFloat = 20
    
    private var colorPalette: ColorPalette {
        .init(container: container, colorScheme: colorScheme)
    }
    
    func body(content: Content) -> some View {
        content
            .frame(width: frameWidth)
            .background(colorPalette.secondaryWhite)
            .cornerRadius(cornerRadius)
    }
}

extension View {
    func customAlert(container: DIContainer) -> some View {
        modifier(CustomAlert(container: container))
    }
}

struct WithSearchHistory: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.mainWindowSize) var mainWindowSize
    // MARK: - Constants
    let spacing: CGFloat = 10
    let hPadding: CGFloat = 16
    let vPadding: CGFloat = 6
    let width: CGFloat = 250
    let clockIconHeight: CGFloat = 15
    let topPadding: CGFloat = 10
    let xOffset: CGFloat = 5
    let yOffset: CGFloat = 1
    let container: DIContainer
    let textfieldTextSetter: (String) -> Void
    
    // MARK: - View model
    
    @Binding var searchResults: [String]
    
    var showPostcodeDropDown: Bool {
        searchResults.isEmpty == false
    }
    
    private var colorPalette: ColorPalette {
        .init(container: container, colorScheme: colorScheme)
    }
    
    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            content
            
            Rectangle() // Used to attach the overlay beneath the textfield
                .frame(height: 0)
                .overlay(
                    searchHistoryDropdown,
                    alignment: .topLeading)
        }
    }
    
    @ViewBuilder private var searchHistoryDropdown: some View {
        if showPostcodeDropDown {
            VStack(alignment: .leading, spacing: spacing) {
                ForEach($searchResults, id: \.self) { searchTerm in
                    Button {
                        textfieldTextSetter(searchTerm.wrappedValue)
                        searchResults = []
                    } label: {
                        HStack {
                            Text(searchTerm.wrappedValue)
                                .font(.Body2.semiBold())
                                .foregroundColor(colorPalette.typefacePrimary)
                            Spacer()
                            Image.Icons.Clock.heavy
                                .renderingMode(.template)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: clockIconHeight)
                                .foregroundColor(colorPalette.textGrey2)
                            
                        }.frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal, hPadding)
                    .padding(.vertical, vPadding)
                    
                    Divider()
                }
            }
            .padding(.top, topPadding)
            .frame(width: width)
            .background(colorPalette.typefaceInvert)
            .standardCardFormat(corners: [.bottomLeft, .bottomRight])
            .offset(x: xOffset, y: yOffset)
        }
    }
}

extension View {
    func withSearchHistory(container: DIContainer, searchResults: Binding<[String]>, textfieldTextSetter: @escaping (String) -> Void) -> some View {
        modifier(WithSearchHistory(container: container, textfieldTextSetter: textfieldTextSetter, searchResults: searchResults))
    }
}

enum BannerType: Int {
    case missedOffer = 1
    case viewSelection
    case substitutedItem
    case rejectedItem
    case itemQuantityChange
    case deliveryOfferMain
    case deliveryOfferWithTiersMain
    case deliveryOffer
    case deliveryOfferWithTiers
    
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
        case .deliveryOfferMain, .deliveryOfferWithTiersMain, .deliveryOffer, .deliveryOfferWithTiers:
            return colorPalette.alertSuccess
        }
    }
    
    var leadingIcon: Image? {
        switch self {
        case .deliveryOfferMain, .deliveryOfferWithTiersMain:
            return Image.Icons.Tag.filled
        default:
            return nil
        }
    }

    func textColor(colorPalette: ColorPalette) -> Color {
        switch self {
        case .missedOffer:
            return colorPalette.typefacePrimary
        default:
            return .white
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
        case .deliveryOfferMain, .deliveryOfferWithTiersMain:
            return .clear
        case .deliveryOffer, .deliveryOfferWithTiers:
            return colorPalette.alertSuccess.withOpacity(.twenty)
        }
    }
    
    var icon: Image? {
        switch self {
        case .viewSelection, .deliveryOfferWithTiersMain, .deliveryOfferWithTiers:
            return Image.Icons.Eye.filled
        case .missedOffer:
            return Image.Icons.Plus.medium
        case .substitutedItem, .rejectedItem, .itemQuantityChange, .deliveryOfferMain, .deliveryOffer:
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
