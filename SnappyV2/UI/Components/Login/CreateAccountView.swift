//
//  CreateAccountView.swift
//  SnappyV2
//
//  Created by David Bage on 11/03/2022.
//

import SwiftUI

struct CreateAccountView: View {
    // MARK: - Environment objects
    @Environment(\.colorScheme) var colorScheme
    @ScaledMetric var scale: CGFloat = 1 // Used to scale icon for accessibility options
    @Environment(\.sizeCategory) var sizeCategory: ContentSizeCategory
    
    // MARK: - String helpers
    typealias LoginStrings = Strings.General.Login
    typealias CreateAccountStrings = Strings.CreateAccount
    typealias TermsStrings = Strings.Terms
    
    // MARK: - State objects
    @StateObject var viewModel: CreateAccountViewModel
    @StateObject var socialLoginViewModel: SocialMediaLoginViewModel
    
    // MARK: - Constants
    struct Constants {
        struct InternalStack {
            static let maxSpacing: CGFloat = 20
            static let minSpacing: CGFloat = 8
        }
        
        struct BackgroundImage {
            static let yOffset: CGFloat = -100
        }
        
        struct DividerText {
            static let padding: CGFloat = 9
        }
        
        struct Checkbox {
            static let width: CGFloat = 24
        }
        
        struct General {
            static let minimalDisplayThreshold: Int = 7
            static let maxTextThreshold: Int = 10
        }
    }

    // MARK: - Computed variables
    private var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    // Used to control when to switch to minimal mode for larger text sizes
    private var minimalDisplayView: Bool {
        sizeCategory.size > Constants.General.minimalDisplayThreshold
    }
    
    // MARK: - Main body
    var body: some View {
        ZStack(alignment: .top) {
            Image.Branding.StockPhotos.phoneInHand
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity)
                .offset(x: 0, y: Constants.BackgroundImage.yOffset)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: Constants.InternalStack.minSpacing) {
                    heading
                        .padding(.bottom, Constants.InternalStack.minSpacing)
                        .multilineTextAlignment(.center)
                    
                    VStack(spacing: Constants.InternalStack.maxSpacing) {
                        SocialMediaLoginView(viewModel: socialLoginViewModel)
                        divider
                        createAccountDetailsFields
                        referralCode
                        accountPasswordView
                    }
                    .padding(.bottom, Constants.InternalStack.minSpacing)
                    
                    termsAndConditionsView
                        .padding(.bottom, Constants.InternalStack.maxSpacing)
                    
                    createAccountButton
                }
                .cardOnImageFormat()
            }
            
            if viewModel.isLoading || socialLoginViewModel.isLoading {
                LoadingView()
            }
        }
        .displayError(viewModel.error)
    }
    
    // MARK: - Title and subtitle
    private var heading: some View {
        VStack(spacing: Constants.InternalStack.minSpacing) {
            AdaptableText(text: CreateAccountStrings.title.localized, altText: CreateAccountStrings.titleShort.localized, threshold: Constants.General.maxTextThreshold)
                .font(.heading2)
                .foregroundColor(colorPalette.primaryBlue)
            
            if minimalDisplayView == false {
                Text(CreateAccountStrings.subtitle.localized)
                    .font(.Body1.regular())
                    .foregroundColor(colorPalette.typefacePrimary)
            }
        }
    }
    
    // MARK: - Divider separating social sign ins and input fields
    private var divider: some View {
        ZStack {
            Divider()
            Text(GeneralStrings.or.localized)
                .font(.button1())
                .foregroundColor(colorPalette.typefacePrimary)
                .padding(.horizontal, Constants.DividerText.padding)
                .background(colorPalette.typefaceInvert)
        }
    }
    
    // MARK: - Create account details fields
    private var createAccountDetailsFields: some View {
        VStack(spacing: Constants.InternalStack.maxSpacing) {
            
            AdaptableText(text: CreateAccountStrings.addDetails.localized, altText: CreateAccountStrings.addDetailsShort.localized, threshold: Constants.General.maxTextThreshold)
                .font(.heading4())
                .foregroundColor(colorPalette.primaryBlue)
            
                SnappyTextfield(
                    container: viewModel.container,
                    text: $viewModel.firstName,
                    hasError: .constant(viewModel.firstNameHasError),
                    labelText: GeneralStrings.firstName.localized,
                    largeTextLabelText: nil)
                
                SnappyTextfield(
                    container: viewModel.container,
                    text: $viewModel.lastName,
                    hasError: .constant(viewModel.lastNameHasError),
                    labelText: GeneralStrings.lastName.localized,
                    largeTextLabelText: nil)
                
                SnappyTextfield(
                    container: viewModel.container,
                    text: $viewModel.email,
                    hasError: .constant(viewModel.emailHasError),
                    labelText: LoginStrings.emailAddress.localized,
                    largeTextLabelText: LoginStrings.email.localized.capitalizingFirstLetter())
                
                SnappyTextfield(
                    container: viewModel.container,
                    text: $viewModel.phone,
                    hasError: .constant(viewModel.phoneHasError),
                    labelText: GeneralStrings.phone.localized,
                    largeTextLabelText: GeneralStrings.phoneShort.localized)
        }
    }

    // MARK: - Password view
    private var accountPasswordView: some View {
        VStack(spacing: Constants.InternalStack.maxSpacing) {
            Text(CreateAccountStrings.createPassword.localized)
                .font(.heading4())
                .foregroundColor(colorPalette.primaryBlue)
                .multilineTextAlignment(.center)
            
            SnappyTextfield(
                container: viewModel.container,
                text: $viewModel.password,
                hasError: .constant(viewModel.passwordHasError),
                labelText: LoginStrings.password.localized,
                largeTextLabelText: LoginStrings.passwordShort.localized,
                fieldType: .secureTextfield)
        }
    }

    // MARK: - Submit button
    var createAccountButton: some View {
        SnappyButton(
            container: viewModel.container,
            type: .primary,
            size: .large,
            title: CreateAccountStrings.title.localized,
            largeTextTitle: CreateAccountStrings.titleShort.localized,
            icon: nil) {
                Task {
                    try await viewModel.createAccountTapped()
                }
            }
    }
    
    // MARK: - Terms and conditions
    private var termsAndConditionsView: some View {
        HStack {
            Button {
                viewModel.termsAgreedTapped()
            } label: {
                (viewModel.termsAgreed ? Image.Icons.CircleCheck.filled : Image.Icons.Circle.standard)
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: Constants.Checkbox.width * scale)
                    .foregroundColor(viewModel.termsAndConditionsHasError ? colorPalette.primaryRed : colorPalette.primaryBlue)
            }
            
            Text("\(TermsStrings.agreeTo.localized) [\(TermsStrings.terms.localized)](https://app-dev.snappyshopper.co.uk/terms-and-conditions) \(TermsStrings.and.localized) [\(TermsStrings.privacy.localized)](https://app-dev.snappyshopper.co.uk/privacy-policy).")
            
                .font(.hyperlink2())
                .foregroundColor(viewModel.termsAndConditionsHasError ? .snappyRed : .snappyTextGrey2)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Referral code
    private var referralCode: some View {
        VStack(spacing: Constants.InternalStack.minSpacing) {
            AdaptableText(text: CreateAccountStrings.referralTitle.localized, altText: CreateAccountStrings.referralTitleShort.localized, threshold: Constants.General.maxTextThreshold)
                .font(.heading4())
                .foregroundColor(colorPalette.primaryBlue)
                .multilineTextAlignment(.center)
            
            VStack(spacing: Constants.InternalStack.maxSpacing) {
                Text(CreateAccountStrings.referralBody.localized)
                    .font(.Body2.regular())
                    .foregroundColor(colorPalette.typefacePrimary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                
                SnappyTextfield(
                    container: viewModel.container,
                    text: $viewModel.referralCode,
                    isDisabled: .constant(false),
                    hasError: .constant(false),
                    labelText: CreateAccountStrings.referralPlaceholderShort.localized,
                    largeTextLabelText: nil)
            }
        }
    }
}

struct CreateAccountView_Previews: PreviewProvider {
    static var previews: some View {
        CreateAccountView(viewModel: .init(container: .preview), socialLoginViewModel: .init(container: .preview))
    }
}
