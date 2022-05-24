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
    
    @StateObject var loginViewModel: LoginViewModel
    @StateObject var facebookButtonViewModel: LoginWithFacebookViewModel
    
    init(loginViewModel: LoginViewModel, facebookButtonViewModel: LoginWithFacebookViewModel) {
        self._loginViewModel = .init(wrappedValue: loginViewModel)
        self._facebookButtonViewModel = .init(wrappedValue: facebookButtonViewModel)
        
        // Configure clear navbar
        let coloredAppearance = UINavigationBarAppearance()
        coloredAppearance.configureWithTransparentBackground()
        
        UINavigationBar.appearance().standardAppearance = coloredAppearance
        UINavigationBar.appearance().compactAppearance = coloredAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
        UINavigationBar.appearance().tintColor = UIColor(.white)
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Image.Branding.StockPhotos.deliveryMan
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity)
                .offset(x: 0, y: Constants.BackgroundImage.yOffset)
            VStack {
                LoginHomeView(loginViewModel: loginViewModel, facebookLoginViewModel: facebookButtonViewModel)
                
                NavigationLink("", isActive: $loginViewModel.showCreateAccountView) {
                    CreateAccountView(viewModel: .init(container: loginViewModel.container), facebookButtonViewModel: facebookButtonViewModel)
                }
            }
            .padding(.top, sizeClass == .compact ? Constants.LoginStack.topPadding : Constants.LoginStack.largeDeviceTopPadding)
            .padding(.horizontal, Constants.LoginStack.hPadding)
            
            if facebookButtonViewModel.isLoading || loginViewModel.isLoading {
                LoadingView()
            }
        }
        .ignoresSafeArea()
        .displayError(loginViewModel.error)
        .simpleBackButton(presentation: presentation)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(loginViewModel: .init(container: .preview), facebookButtonViewModel: .init(container: .preview))
    }
}
