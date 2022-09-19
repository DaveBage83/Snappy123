//
//  InitialView.swift
//  SnappyV2Study
//
//  Created by Henrik Gustavii on 21/06/2021.
//

import SwiftUI

// 3rd party
import DriverInterface

struct InitialView: View {
    // MARK: - Environment objects
    
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.scenePhase) var scenePhase
    @ScaledMetric var scale: CGFloat = 1 // Used to scale icon for accessibility options
    @Environment(\.sizeCategory) var sizeCategory: ContentSizeCategory
    @Environment(\.mainWindowSize) var mainWindowSize
    
    typealias ViewStrings = Strings.InitialView
    
    // MARK: - Food item enum -> used for food item images
        
    private enum FoodItem {
        case tomato
        case orange
        case crisps
        case milk
        case pizza
        case chocolate
        case bread
        
        var image: Image {
            switch self {
            case .tomato:
                return Image.InitialViewItems.tomato
            case .orange:
                return Image.InitialViewItems.orange
            case .crisps:
                return Image.InitialViewItems.crisps
            case .milk:
                return Image.InitialViewItems.milk
            case .pizza:
                return Image.InitialViewItems.pizza
            case .chocolate:
                return Image.InitialViewItems.chocolate
            case .bread:
                return Image.InitialViewItems.bread
            }
        }
        
        // Size of food items
        func width(windowWidth: CGFloat) -> CGFloat {
            switch self {
            case .tomato:
                return (windowWidth / 5)
            case .orange:
                return (windowWidth / 5.2)
            case .crisps:
                return (windowWidth / 3.5)
            case .milk:
                return (windowWidth / 3)
            case .pizza:
                return (windowWidth / 3)
            case .chocolate:
                return (windowWidth / 3.5)
            case .bread:
                return(windowWidth / 4)
            }
        }
        
        // Offset of food item images
        func position(windowWidth: CGFloat) -> CGSize {
            switch self {
            case .tomato:
                return CGSize(width: -(windowWidth / 2) * 0.85, height: -(Constants.Background.ovalHeight / 2) * 0.7)
            case .orange:
                return CGSize(width: -(windowWidth / 2) * 0.29, height: -(Constants.Background.ovalHeight / 2) * 0.9)
            case .crisps:
                return CGSize(width: (windowWidth / 2) * 0.4, height: -(Constants.Background.ovalHeight / 2))
            case .milk:
                return CGSize(width: (windowWidth / 2) * 1.05, height: -(Constants.Background.ovalHeight / 2) * 0.95)
            case .pizza:
                return CGSize(width: (windowWidth / 2) * 1.05, height: (Constants.Background.ovalHeight / 2) * 0.7)
            case .chocolate:
                return CGSize(width: (windowWidth / 2) * 0.1, height: (Constants.Background.ovalHeight / 2) * 0.86)
            case .bread:
                return CGSize(width: -(windowWidth / 2) * 0.7, height: (Constants.Background.ovalHeight / 2) * 0.85)
            }
        }
    }
    
    // MARK: - Constants
    
    struct Constants {
        struct PostcodeSearch {
            static let cornerRadius: CGFloat = 8
            static let vSpacing: CGFloat = 8
            static let largeDeviceWidth: CGFloat = UIScreen.screenWidth / 2
            static let buttonIconWidth: CGFloat = 24
            static let hPadding: CGFloat = 5
        }
        
        struct SearchButton {
            static let width: CGFloat = 300
            static let height: CGFloat = 55
            static let cornerRadius: CGFloat = 15
        }
        
        struct Background {
            static let animation = Animation.linear(duration: 0.3).delay(0.5)
            static let ovalHeight: CGFloat = UIScreen.screenHeight * 0.65
        }
        
        struct General {
            static let largeDeviceImageMultiplier: CGFloat = 1.5
            static let minimalDisplayThreshold: Int = 7
        }
        
        struct Logo {
            static let width: CGFloat = UIScreen.screenWidth / 2.5
            static let largeDeviceSnappyLogoMultiplier: CGFloat = 2
        }
        
        struct Tagline {
            static let bottomPadding: CGFloat = 8
        }
        
        struct SubTagline {
            static let paddingDenominator: CGFloat = 3
        }
        
        struct TitleStack {
            static let heightAdjustment: CGFloat = 0.05
        }
        
        struct FoodItem {
            static let animationRotation: CGFloat = 360
            static let maxScale: CGFloat = 1
        }
    }
    
    // MARK: - State objects / properties
    
    @StateObject var viewModel: InitialViewModel

    @State var isRotated = false // Controls when to rotate food items for animation
    @State var foodItemScale: CGFloat = 0.0 // Controls scale of food item animation
    
    // MARK: - Computed variables

    // Postcode search bar height needs to be relative to screen height
    private var postcodeSearchBarViewHeight: CGFloat {
        mainWindowSize.height / 15
    }
    
    private var logoBottomPadding: CGFloat {
        mainWindowSize.height / 20
    }
    
    private var imageSizeMultiplier: CGFloat {
        sizeClass == .compact ? 1 : Constants.General.largeDeviceImageMultiplier
    }
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    private var foodItems: [FoodItem] {
        [.tomato, .orange, .crisps, .milk, .pizza, .chocolate, .bread]
    }
    
    // MARK: - Main body
    
    var body: some View {
        NavigationView {
            ZStack {
                navigationLinks
                backgroundView
                
                if viewModel.businessProfileIsLoaded {
                    
                    VStack {
                        
                        Image.Branding.Logo.white
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: Constants.Logo.width)
                            .padding(.bottom, logoBottomPadding)
                        
                        if sizeCategory.size < Constants.General.minimalDisplayThreshold || sizeClass != .compact {
                            Text(ViewStrings.tagline.localized)
                                .font(.heading2)
                                .foregroundColor(.white)
                                .padding(.bottom, Constants.Tagline.bottomPadding)
                            
                            Text(ViewStrings.subTagline.localized)
                                .font(.Body1.regular())
                                .foregroundColor(.white)
                                .padding(.bottom, postcodeSearchBarViewHeight / Constants.SubTagline.paddingDenominator)
                        }
                        
                        postcodeSearchBarView()
                    }
                        .offset(x: 0, y: -Constants.Background.ovalHeight * Constants.TitleStack.heightAdjustment)
                        .toast(isPresenting: $viewModel.isRestoring) {
                            AlertToast(displayMode: .alert, type: .loading)
                        }

                } else {
                    
                    Text("").toast(isPresenting: $viewModel.businessProfileIsLoading) {
                        AlertToast(displayMode: .alert, type: .loading)
                    }
                    
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if viewModel.showDriverStartShift {
                        StartDriverShiftButton(container: viewModel.container) {
                            Task {
                                await viewModel.startDriverShiftTapped()
                            }
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.businessProfileIsLoaded {
                        AccountButton(container: viewModel.container) {
                            viewModel.viewState = .memberDashboard
                        }
                    }
                }
            }
            .onAppear {
                AppDelegate.orientationLock = .portrait
                viewModel.onAppearSendEvent()
            }
            .onChange(of: scenePhase) { newPhase in
                if scenePhase == .background {
                    viewModel.dismissLocationAlertTapped()
                }
            }
            .withAlertToast(container: viewModel.container, error: $viewModel.error)
            .withAlertToast(container: viewModel.container, error: $viewModel.locationManager.error)
            .toast(isPresenting: .constant(viewModel.isLoading || viewModel.driverSettingsLoading), alert: {
                AlertToast(displayMode: .alert, type: .loading)
            })

            .alert(item: $viewModel.showAlert) { alert in
                switch alert.id {
                case .locationServicesDenied:
                    return Alert(
                        title: Text(Strings.Alerts.Location.deniedLocationTitle.localized),
                        message: Text(Strings.Alerts.Location.deniedLocationMessage.localized),
                        primaryButton:
                                .default(Text(Strings.General.settings.localized), action: {
                                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                                }),
                        secondaryButton:
                                .cancel(Text(Strings.General.cancel.localized), action: {
                                    viewModel.dismissLocationAlertTapped()
                                })
                        )
                case .errorLoadingBusinessProfile:
                    return Alert(
                        title:Text(Strings.InitialView.businessProfileAlertTitle.localized),
                        message: Text(Strings.InitialView.businessProfileAlertMessage.localized + "\n----\n" + (viewModel.businessProfileLoadingError?.localizedDescription ?? "")),
                        dismissButton: .default(Text(Strings.General.retry.localized), action: {
                                Task {
                                    await viewModel.loadBusinessProfile()
                                }
                            })
                        )
                }
            }
            .fullScreenCover(
                item: $viewModel.driverDependencies,
                content: { driverDependencies in
                    DriverInterfaceView(driverDependencies: driverDependencies)
                }
            )
            .onAppear {
                AppDelegate.orientationLock = .portrait
            }
        }
        .navigationViewStyle(.stack)
    }
    
    // MARK: - Food item factory
    
    private func foodItem(_ item: FoodItem) -> some View {
        item.image
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: item.width(windowWidth: mainWindowSize.width))
            .scaleEffect(foodItemScale)
            .rotationEffect(Angle.degrees(isRotated ? Constants.FoodItem.animationRotation : 0))
            .offset(item.position(windowWidth: mainWindowSize.width))
            .animation(Constants.Background.animation, value: foodItemScale)
    }
    
    // MARK: - Background view
    
    private var backgroundView: some View {
        ZStack {
            Image.InitialViewItems.oval
                .resizable()
                .frame(width: mainWindowSize.width)
                .frame(height: Constants.Background.ovalHeight)
            
            ForEach(foodItems, id: \.self) { item in
                foodItem(item)
            }
        }

        .onAppear {
            foodItemScale = Constants.FoodItem.maxScale
            isRotated = true
        }
        .onDisappear {
            viewModel.dismissLocationAlertTapped()
        }
    }
    
    // MARK: - Navigation links
    
    private var navigationLinks: some View {
        HStack {
            NavigationLink(destination: LoginView(loginViewModel: .init(container: viewModel.container), socialLoginViewModel: .init(container: viewModel.container)), tag: InitialViewModel.NavigationDestination.login, selection: $viewModel.viewState) { EmptyView() }

            NavigationLink(destination: CreateAccountView(viewModel: .init(container: viewModel.container), socialLoginViewModel: .init(container: viewModel.container)), tag: InitialViewModel.NavigationDestination.create, selection: $viewModel.viewState) { EmptyView() }
            
            NavigationLink(destination: MemberDashboardView(viewModel: .init(container: viewModel.container)), tag: InitialViewModel.NavigationDestination.memberDashboard, selection: $viewModel.viewState) { EmptyView() }
        }
    }
    
    // MARK: - Postcode search bar
    
    private func postcodeSearchBarView() -> some View {
        HStack {
            Spacer()
            VStack(spacing: Constants.PostcodeSearch.vSpacing) {
                TextField(ViewStrings.postcodeSearch.localized, text: $viewModel.postcode)
                    .frame(height: postcodeSearchBarViewHeight)
                    .frame(maxWidth: sizeClass == .compact ? .infinity : Constants.PostcodeSearch.largeDeviceWidth)
                    .font(.Body1.regular())
                    .multilineTextAlignment(.center)
                    .textFieldStyle(PlainTextFieldStyle())
                    .background(colorScheme == .dark ? Color.black : Color.white)
                    .cornerRadius(Constants.PostcodeSearch.cornerRadius)
                    .autocapitalization(.allCharacters)
                    .disableAutocorrection(true)
                    .overlay(
                        HStack {
                            
                            Button(action: { Task { await viewModel.searchViaLocationTapped() } }) {
                                Image.Icons.LocationCrosshairs.standard
                                    .renderingMode(.template)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: Constants.PostcodeSearch.buttonIconWidth * scale)
                                    .foregroundColor(colorPalette.typefacePrimary)
                            }
                            .foregroundColor(.black)
                            .padding()
                            .disabled(viewModel.isLoading)
                            Spacer()
                        }
                    )
                    .disabled(viewModel.isLoading || viewModel.locationIsLoading)
                
                SnappyButton(
                    container: viewModel.container,
                    type: .secondary,
                    size: .large,
                    title: ViewStrings.storeSearch.localized,
                    largeTextTitle: "Search",
                    icon: Image.Icons.MagnifyingGlass.heavy, isLoading: .constant(viewModel.isLoading)) {
                        Task { await viewModel.tapLoadRetailStores() }
                    }
                    .disabled(viewModel.postcode.isEmpty || viewModel.isLoading || viewModel.locationIsLoading)
                    .frame(maxWidth: sizeClass == .compact ? .infinity : Constants.PostcodeSearch.largeDeviceWidth)
            }
            .padding(.horizontal, Constants.PostcodeSearch.hPadding)
            Spacer()
        }
    }
}

#if DEBUG
struct InitialView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            InitialView(viewModel: .init(container: .preview))
                .previewDevice(PreviewDevice(rawValue: "iPhone 13 Pro Max"))
            
            InitialView(viewModel: .init(container: .preview))
                .previewDevice(PreviewDevice(rawValue: "iPhone 13 mini"))
            
            InitialView(viewModel: .init(container: .preview))
                .previewDevice(PreviewDevice(rawValue: "iPhone 8"))
            
            InitialView(viewModel: .init(container: .preview))
                .previewDevice(PreviewDevice(rawValue: "iPad Pro (9.7-inch)"))
        }
    }
}
#endif
