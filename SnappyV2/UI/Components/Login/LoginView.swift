//
//  LoginView.swift
//  SnappyV2
//
//  Created by David Bage on 08/03/2022.
//

import SwiftUI

struct LoginView: View {
    typealias LoginStrings = Strings.General.Login
    typealias CustomLoginStrings = Strings.General.Login.Customisable
    
    @Environment(\.presentationMode) var presentation
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.colorScheme) var colorScheme
    
    // MARK: - Constants
    struct Constants {
        struct Buttons {
            static let size: CGFloat = 15
            static let vPadding: CGFloat = 3
        }
        
        struct BackgroundImage {
            static let yOffset: CGFloat = -100
        }
        
        struct LoginStack { 
            static let topPadding: CGFloat = 50
            static let largeDeviceTopPadding: CGFloat = 200
            static let hPadding: CGFloat = 16
        }
    }
    
    @StateObject var viewModel: LoginViewModel
    @StateObject var socialLoginViewModel: SocialMediaLoginViewModel
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    init(loginViewModel: LoginViewModel, socialLoginViewModel: SocialMediaLoginViewModel) {
        self._viewModel = .init(wrappedValue: loginViewModel)
        self._socialLoginViewModel = .init(wrappedValue: socialLoginViewModel)
    }
    
    var body: some View {
        if viewModel.isInCheckout {
            mainView
                .dismissableNavBar(presentation: presentation, color: colorPalette.primaryBlue, title: Strings.CheckoutView.Payment.secureCheckout.localized, navigationDismissType: .back, backButtonAction: nil)
        } else {
            mainView
                .onAppear {
                    viewModel.onAppearSendEvent()
                }
        }
    }
    
    @ViewBuilder private var mainView: some View {
        ZStack(alignment: .top) {
            if viewModel.isInCheckout == false {
                Image.Branding.StockPhotos.deliveryMan
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .offset(y: Constants.BackgroundImage.yOffset)
            }
            
            ScrollView(showsIndicators: false) {
                if viewModel.isInCheckout, let orderTotal = viewModel.orderTotal {
                    VStack {
                        CheckoutOrderSummaryBanner(container: viewModel.container, orderTotal: orderTotal, progressState: .details)
                    }
                }
                
                if viewModel.isInCheckout {
                    VStack {
                        loginView
                            .padding()
                            .background(colorPalette.secondaryWhite)
                            .standardCardFormat()
                    }
                    .padding()
                } else {
                    VStack {
                        loginView
                    }
                    .cardOnImageFormat()
                }
            }
            if viewModel.isLoading || socialLoginViewModel.isLoading {
                LoadingView()
            }
        }
        .onAppear {
            viewModel.onAppearSendEvent()
        }
    }
    
    private var loginView: some View {
        VStack {
            LoginHomeView(viewModel: viewModel, socialLoginViewModel: socialLoginViewModel)
            
            NavigationLink("", isActive: $viewModel.showCreateAccountView) {
                CreateAccountView(viewModel: .init(container: viewModel.container), socialLoginViewModel: .init(container: viewModel.container))
                    .onAppear {
                        viewModel.onCreateAccountAppearSendEvent()
                    }
            }
        }
    }
}

#if DEBUG
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(loginViewModel: .init(container: .preview), socialLoginViewModel: .init(container: .preview))
    }
}
#endif
