//
//  LoginView.swift
//  SnappyV2
//
//  Created by David Bage on 08/03/2022.
//

import SwiftUI

struct LoginView: View {
    @Environment(\.presentationMode) var presentation
    @Environment(\.colorScheme) var colorScheme
    
    // MARK: - Constants
    struct Constants {
        struct LoginStack {
            static let blurred: CGFloat = 20
            static let notBlurred: CGFloat = 0
        }
    }
    
    @StateObject var viewModel: LoginViewModel
    @StateObject var socialLoginViewModel: SocialMediaLoginViewModel
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    private let alertViewXPosition = UIScreen.screenWidth / 2
    private let alertViewYPosition = UIScreen.screenHeight / 2

    init(loginViewModel: LoginViewModel, socialLoginViewModel: SocialMediaLoginViewModel) {
        self._viewModel = .init(wrappedValue: loginViewModel)
        self._socialLoginViewModel = .init(wrappedValue: socialLoginViewModel)
    }
    
    var body: some View {
        if viewModel.isFromInitialView {
            mainView
                .navigationBarItems(trailing: SettingsButton(viewModel: .init(container: viewModel.container)))
                .toolbar(content: {
                    ToolbarItem(placement: .principal) {
                        SnappyLogo()
                    }
                })
                .dismissableNavBar(presentation: presentation, color: colorPalette.primaryBlue)
                .onAppear {
                    viewModel.onAppearSendEvent()
                }
                .edgesIgnoringSafeArea(.bottom)
        } else {
            mainView
                .edgesIgnoringSafeArea(.bottom)
        }
    }
    
    @ViewBuilder private var mainView: some View {
        ZStack(alignment: .top) {
            if viewModel.isInCheckout {
                VStack(spacing: 0) {
                    ScrollView {
                        loginView
                            .padding()
                            .background(colorPalette.secondaryWhite)
                            .standardCardFormat(container: viewModel.container)
                    }
                }
                .padding()
                .background(colorPalette.backgroundMain)
                .blur(radius: (viewModel.isLoading || socialLoginViewModel.isLoading) ? Constants.LoginStack.blurred : Constants.LoginStack.notBlurred)
            } else {
                CardOnBackgroundImageViewContainer(
                    container: viewModel.container,
                    image: Image.Branding.StockPhotos.deliveryMan) {
                        loginView
                    }
                    .blur(radius: (viewModel.isLoading || socialLoginViewModel.isLoading) ? Constants.LoginStack.blurred : Constants.LoginStack.notBlurred)
            }
            
            if viewModel.isLoading || socialLoginViewModel.isLoading {
                AnimatedLoadingView(message: Strings.AnimatedLoadingView.loggingIn.localized)
                    .position(x: alertViewXPosition,
                              y: alertViewYPosition)
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
                CreateAccountView(viewModel: .init(container: viewModel.container), socialLoginViewModel: .init(container: viewModel.container, isInCheckout: viewModel.isInCheckout))
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
        LoginView(loginViewModel: .init(container: .preview), socialLoginViewModel: .init(container: .preview, isInCheckout: false))
    }
}
#endif
