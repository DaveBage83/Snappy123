//
//  LoginHomeView.swift
//  SnappyV2
//
//  Created by David Bage on 11/03/2022.
//

import SwiftUI
import AuthenticationServices

struct LoginHomeView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.horizontalSizeClass) var sizeClass
    
    typealias LoginStrings = Strings.General.Login
    typealias CustomLoginStrings = Strings.General.Login.Customisable
    
    // MARK: - Constants
    struct Constants {
        struct General {
            static let cornerRadius: CGFloat = 15
            static let largeDeviceStackWidth: CGFloat = 500
        }
        
        struct AppleButton {
            static let height: CGFloat = 40
            static let cornerRadius: CGFloat = 10
        }
        
        struct Title {
            static let vSpacing: CGFloat = 8
            static let bottomPadding: CGFloat = 30
        }
        
        struct ButtonStack {
            static let spacing: CGFloat = 13
            static let bottomPadding: CGFloat = 28
        }
        
        struct SignInFields {
            static let padding: CGFloat = 10
            static let spacing: CGFloat = 16.5
        }
        
        struct ForgotPasswordButton {
            static let bottomPadding: CGFloat = 16
        }
    }
    
    var colorPalette: ColorPalette {
        ColorPalette(container: loginViewModel.container, colorScheme: colorScheme)
    }
    
    @ObservedObject var loginViewModel: LoginViewModel
    @ObservedObject var facebookLoginViewModel: LoginWithFacebookViewModel
    
    var body: some View {
        VStack {
            VStack(spacing: Constants.Title.vSpacing) {
                Text(LoginStrings.title.localized)
                    .foregroundColor(colorPalette.primaryBlue)
                    .font(.heading2)
                
                Text(LoginStrings.subtitle.localized)
                    .foregroundColor(colorPalette.typefacePrimary)
                    .font(.Body1.regular())
            }
            .padding(.bottom, Constants.Title.bottomPadding)
            
            VStack(spacing: Constants.ButtonStack.spacing) {
                signinWithAppleButton
                
                SocialButton(
                    container: loginViewModel.container,
                    platform: .facebookLogin,
                    size: .small) {
                        Task {
                            await facebookLoginViewModel.loginWithFacebook()
                        }
                    }
                
                SocialButton(
                    container: loginViewModel.container,
                    platform: .googleLogin,
                    size: .small) {
                        loginViewModel.googleSignInTapped()
                    }
            }
            .padding(.bottom, Constants.ButtonStack.bottomPadding)
            
            signInFields
                .padding(.bottom, Constants.SignInFields.padding)
            
            forgotPasswordButton
                .padding(.bottom, Constants.ForgotPasswordButton.bottomPadding)
            
            Text(GeneralStrings.Login.noAccount.localized)
                .font(.Body1.semiBold())
                .foregroundColor(colorPalette.primaryBlue)
            
            SnappyButton(
                container: loginViewModel.container,
                type: .primary,
                size: .large,
                title: GeneralStrings.Login.register.localized,
                icon: nil) {
                    loginViewModel.createAccountTapped()
                }
        }
        .frame(maxWidth: sizeClass == .compact ? .infinity : Constants.General.largeDeviceStackWidth)
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: Constants.General.cornerRadius))
        .standardCardFormat()
    }
    
    // MARK: - Sign in fields & button
    private var signInFields: some View {
        VStack(spacing: Constants.SignInFields.spacing) {
            SnappyTextfield(
                container: loginViewModel.container,
                text: $loginViewModel.email,
                isDisabled: .constant(false),
                hasError: .constant(loginViewModel.emailHasError),
                labelText: LoginStrings.emailAddress.localized, keyboardType: .emailAddress)
            
            SnappyTextfield(
                container: loginViewModel.container,
                text: $loginViewModel.password,
                isDisabled: .constant(false),
                hasError: .constant(loginViewModel.passwordHasError),
                labelText: LoginStrings.password.localized,
                fieldType: .secureTextfield)
            
            SnappyButton(
                container: loginViewModel.container,
                type: .primary,
                size: .large,
                title: LoginStrings.continueWithEmail.localized,
                icon: nil,
                action: loginViewModel.loginTapped)
        }
    }
    
    // MARK: - Sign in with Apple button
    private var signinWithAppleButton: some View {
        SignInWithAppleButton(.signIn, onRequest: { request in
            request.requestedScopes = [.fullName, .email]
        }, onCompletion: { result in
            loginViewModel.handleAppleLoginResult(result: result)
        })
        .frame(height: Constants.AppleButton.height)
        .cornerRadius(Constants.AppleButton.cornerRadius)
    }
    
    // MARK: - Forgot password button
    private var forgotPasswordButton: some View {
        NavigationLink {
            ForgotPasswordView(viewModel: .init(container: loginViewModel.container))
        } label: {
            Text(Strings.ResetPassword.title.localized)
                .underline()
                .font(.hyperlink1())
                .foregroundColor(colorPalette.typefacePrimary.withOpacity(.eighty))
        }
    }
}

struct LoginHomeView_Previews: PreviewProvider {
    static var previews: some View {
        LoginHomeView(loginViewModel: .init(container: .preview), facebookLoginViewModel: .init(container: .preview))
    }
}
