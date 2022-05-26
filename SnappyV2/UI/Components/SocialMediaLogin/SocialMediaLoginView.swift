//
//  SocialMediaLoginView.swift
//  SnappyV2
//
//  Created by David Bage on 26/05/2022.
//

import SwiftUI
import AuthenticationServices

struct SocialMediaLoginView: View {
    // MARK: - Environment objects
    @ScaledMetric var scale: CGFloat = 1 // Used to scale icon for accessibility options
    
    // MARK: - State objects
    @StateObject var viewModel: SocialMediaLoginViewModel
    
    // MARK: - Constants
    struct Constants {
        static let spacing: CGFloat = 13
        
        struct AppleButton {
            static let height: CGFloat = 40
            static let cornerRadius: CGFloat = 10
        }
    }

    // MARK: - Main body
    var body: some View {
        VStack(spacing: Constants.spacing) {
            signinWithAppleButton
            
            SocialButton(
                container: viewModel.container,
                platform: .facebookLogin,
                size: .small) {
                    Task {
                        await viewModel.loginWithFacebook()
                    }
                }
            
            SocialButton(
                container: viewModel.container,
                platform: .googleLogin,
                size: .small) {
                    viewModel.googleSignInTapped()
                }
        }
    }
    
    // MARK: - Apple button
    private var signinWithAppleButton: some View {
        SignInWithAppleButton(.signIn, onRequest: { request in
            request.requestedScopes = [.fullName, .email]
        }, onCompletion: { result in
            viewModel.handleAppleLoginResult(result: result)
        })
        .frame(height: Constants.AppleButton.height * scale)
        .cornerRadius(Constants.AppleButton.cornerRadius)
    }
}

struct SocialMediaLoginView_Previews: PreviewProvider {
    static var previews: some View {
        SocialMediaLoginView(viewModel: .init(container: .preview))
    }
}
