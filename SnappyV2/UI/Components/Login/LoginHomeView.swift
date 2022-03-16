//
//  LoginHomeView.swift
//  SnappyV2
//
//  Created by David Bage on 11/03/2022.
//

import SwiftUI
import AuthenticationServices

struct LoginHomeView: View {
    typealias LoginStrings = Strings.General.Login
    typealias CustomLoginStrings = Strings.General.Login.Customisable
    
    // MARK: - Constants
    struct Constants {
        struct General {
            static let cornerRadius: CGFloat = 15
        }
        
        struct AppleButton {
            static let height: CGFloat = 40
        }
    }
    
    @ObservedObject var loginViewModel: LoginViewModel
    @ObservedObject var facebookLoginViewModel: LoginWithFacebookViewModel
    
    var body: some View {
        VStack {
            VStack {
                signInFields
                
                signinWithAppleButton
                
                LoginWithFacebookButton(viewModel: facebookLoginViewModel)
                    .padding(.bottom)
                
                forgotPasswordButton
            }
            .padding()
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: Constants.General.cornerRadius))
            .snappyShadow()
            
            CreateAccountCard(viewModel: loginViewModel)
        }
    }
    
    var loginView: some View {
        VStack {
            VStack {
                signInFields
                
                signinWithAppleButton
                
                LoginWithFacebookButton(viewModel: facebookLoginViewModel)
                    .padding(.bottom)
                
                forgotPasswordButton
            }
            .padding()
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: Constants.General.cornerRadius))
            .snappyShadow()
            
            CreateAccountCard(viewModel: loginViewModel)
        }
    }

    // MARK: - Sign in fields & button
    private var signInFields: some View {
        VStack {
            TextFieldFloatingWithBorder(LoginStrings.emailAddress.localized, text: $loginViewModel.email, hasWarning: .constant(loginViewModel.emailHasError), keyboardType: .emailAddress)
                .autocapitalization(.none)
            
            TextFieldFloatingWithBorder(LoginStrings.password.localized, text: $loginViewModel.password, hasWarning: .constant(loginViewModel.passwordHasError), isSecureField: true)
                .padding(.bottom)
            
            LoginButton(action: loginViewModel.loginTapped, text: LoginStrings.login.localized, icon: Image.Login.User.standard)
                .buttonStyle(SnappyPrimaryButtonStyle())
        }
    }
    
    // MARK: - Sign in with Apple button
    private var signinWithAppleButton: some View {
        SignInWithAppleButton(.signIn, onRequest: { request in
            request.requestedScopes = [.fullName, .email]
        }, onCompletion: { result in
            switch result {
            case let .success(authResults):
                loginViewModel.appleLoginTapped(auth: authResults)
                
            case .failure(let error):
                #warning("Error handling required")
                print("Authorization failed: " + error.localizedDescription)
            }
        })
            .frame(height: Constants.AppleButton.height)
    }
    
    // MARK: - Forgot password button
    private var forgotPasswordButton: some View {
        NavigationLink("Forgot password?") {
            ForgotPasswordView(viewModel: .init(container: loginViewModel.container))
        }
        .font(.snappyBody2)
        .foregroundColor(.snappyTextGrey2)
    }
}

struct LoginHomeView_Previews: PreviewProvider {
    static var previews: some View {
        LoginHomeView(loginViewModel: .init(container: .preview), facebookLoginViewModel: .init(container: .preview))
    }
}
