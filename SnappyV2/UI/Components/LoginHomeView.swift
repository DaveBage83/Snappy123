//
//  LoginHomeView.swift
//  SnappyV2
//
//  Created by David Bage on 11/03/2022.
//

import SwiftUI

struct LoginHomeView: View {
    // MARK: - Environment objects
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.sizeCategory) var sizeCategory: ContentSizeCategory    
    // MARK: - State objects
    @ObservedObject var viewModel: LoginViewModel
    @ObservedObject var socialLoginViewModel: SocialMediaLoginViewModel
    
    typealias LoginStrings = Strings.General.Login
    
    // MARK: - Constants
    struct Constants {
        struct General {
            static let largeTextThreshold = 8
        }
        
        struct Title {
            static let vSpacing: CGFloat = 8
        }
        
        struct ButtonStack {
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
    
    // MARK: - Computed properties
    
    // Colour palette
    var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    // Controls when we switch to minimalised view for large font selection
    private var minimalisedView: Bool {
        sizeCategory.size > Constants.General.largeTextThreshold
    }
    
    private var titleBottomPadding: CGFloat {
        UIScreen.screenHeight * 0.03
    }
    
    // MARK: - Main body
    var body: some View {
        VStack {
            VStack(spacing: Constants.Title.vSpacing) {
                AdaptableText(
                    text: LoginStrings.title.localized,
                    altText: LoginStrings.titleShortened.localized,
                    threshold: Constants.General.largeTextThreshold)
                .foregroundColor(colorPalette.primaryBlue)
                .font(.heading2)
                .multilineTextAlignment(.center)
                
                if minimalisedView == false {
                    Text(LoginStrings.subtitle.localized)
                        .foregroundColor(colorPalette.typefacePrimary)
                        .font(.Body1.regular())
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.bottom, titleBottomPadding)
            
            SocialMediaLoginView(viewModel: socialLoginViewModel)
                .padding(.bottom, Constants.ButtonStack.bottomPadding)
            
            signInFields
                .padding(.bottom, Constants.SignInFields.padding)
            
            forgotPasswordButton
                .padding(.bottom, Constants.ForgotPasswordButton.bottomPadding)
            
            AdaptableText(
                text: GeneralStrings.Login.noAccount.localized,
                altText: GeneralStrings.Login.noAccountShortened.localized,
                threshold: Constants.General.largeTextThreshold)
            .font(.Body1.semiBold())
            .foregroundColor(colorPalette.primaryBlue)
            
            SnappyButton(
                container: viewModel.container,
                type: .primary,
                size: .large,
                title: GeneralStrings.Login.register.localized,
                largeTextTitle: nil,
                icon: nil) {
                    viewModel.createAccountTapped()
                }
        }
        .snappySheet(container: viewModel.container, isPresented: $viewModel.showForgotPassword, sheetContent: NavigationView {
            ForgotPasswordView(
                viewModel: .init(container: viewModel.container,
                dismissHandler: { email in
                    viewModel.forgotPasswordDismissed(sendingEmail: email)
                })
            )
        })
    }
    
    // MARK: - Sign in fields & button
    private var signInFields: some View {
        VStack(spacing: Constants.SignInFields.spacing) {
            ValidatableField(
                container: viewModel.container,
                labelText: LoginStrings.emailAddress.localized,
                largeLabelText: LoginStrings.email.localized.capitalizingFirstLetter(),
                warningText: Strings.CheckoutDetails.ContactDetails.emailInvalid.localized,
                keyboardType: .emailAddress,
                fieldText: $viewModel.email,
                hasError: $viewModel.emailHasError,
                showInvalidFieldWarning: $viewModel.showInvalidEmailError)
            
            SnappyTextfield(
                container: viewModel.container,
                text: $viewModel.password,
                isDisabled: .constant(false),
                hasError: .constant(viewModel.passwordHasError),
                labelText: LoginStrings.password.localized,
                largeTextLabelText: LoginStrings.passwordShort.localized,
                fieldType: .secureTextfield)
            
            SnappyButton(
                container: viewModel.container,
                type: .primary,
                size: .large,
                title: LoginStrings.continueWithEmail.localized,
                largeTextTitle: GeneralStrings.cont.localized,
                icon: nil,
                isLoading: $viewModel.isLoading,
                action: { Task { await viewModel.loginTapped() } })
        }
    }
    
    // MARK: - Forgot password button
    private var forgotPasswordButton: some View {
        Button {
            viewModel.showForgotPasswordTapped()
        } label: {
            Text(minimalisedView ? LoginStrings.forgotShortened.localized : Strings.ResetPassword.title.localized)
                .underline()
                .font(.hyperlink1())
                .foregroundColor(colorPalette.typefacePrimary.withOpacity(.eighty))
        }
    }
}

#if DEBUG
struct LoginHomeView_Previews: PreviewProvider {
    static var previews: some View {
        LoginHomeView(viewModel: .init(container: .preview), socialLoginViewModel: .init(container: .preview, isInCheckout: false))
    }
}
#endif
