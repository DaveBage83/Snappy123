//
//  CreateAccountView.swift
//  SnappyV2
//
//  Created by David Bage on 11/03/2022.
//

import SwiftUI

struct CreateAccountView: View {
    typealias LoginStrings = Strings.General.Login
    typealias CreateAccountStrings = Strings.CreateAccount
    typealias TermsStrings = Strings.Terms
 
    struct Constants {
        struct Main {
            static let stackSpaing: CGFloat = 30
        }
        
        struct General {
            static let vSpacing: CGFloat = 10
        }
        
        struct Heading {
            static let padding: CGFloat = 2
        }
        
        struct SubmitButton {
            static let padding: CGFloat = 5
        }
    }
    
    @StateObject var viewModel: CreateAccountViewModel
    @StateObject var facebookButtonViewModel: LoginWithFacebookViewModel
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            ZStack {
                VStack(spacing: Constants.Main.stackSpaing) {
                    heading
                    
                    LoginWithFacebookButton(viewModel: facebookButtonViewModel)
                    
                    createAccountDetailsFields
                    
                    accountPasswordView
                    
                    marketingPreferences
                    
                    referralCode
                    
                    termsAndConditionsView
                    
                    createAccountButton
                }
                if viewModel.isLoading || facebookButtonViewModel.isLoading {
                    LoadingView()
                }
            }
        }
        .padding(.horizontal, Constants.Main.stackSpaing)
    }
    
    // MARK: - Title and subtitle
    var heading: some View {
        VStack {
            Text(CreateAccountStrings.title.localized)
                .font(.snappyTitle2)
                .foregroundColor(.snappyBlue)
                .fontWeight(.bold)
                .padding(Constants.Heading.padding)
            
            Text(CreateAccountStrings.subtitle.localized)
                .font(.snappyCaption)
                .foregroundColor(.snappyTextGrey1)
        }
    }
    
    // MARK: - Create account details fields
    var createAccountDetailsFields: some View {
        VStack(spacing: Constants.General.vSpacing) {
            caption(CreateAccountStrings.addDetails.localized)
            
            VStack {
                TextFieldFloatingWithBorder(GeneralStrings.firstName.localized, text: $viewModel.firstName, hasWarning: .constant(viewModel.firstNameHasError))
                
                TextFieldFloatingWithBorder(GeneralStrings.lastName.localized, text: $viewModel.lastName, hasWarning: .constant(viewModel.lastNameHasError))
                
                TextFieldFloatingWithBorder(LoginStrings.emailAddress.localized, text: $viewModel.email, hasWarning: .constant(viewModel.emailHasError), keyboardType: .emailAddress)
                    .autocapitalization(.none)
                
                TextFieldFloatingWithBorder(GeneralStrings.phone.localized, text: $viewModel.phone, hasWarning: .constant(viewModel.phoneHasError), keyboardType: .numberPad)
                    .autocapitalization(.none)
            }
        }
    }
    
    // MARK: - Password view
    var accountPasswordView: some View {
        VStack(spacing: Constants.General.vSpacing) {
            caption("Create secure password")
            
            TextFieldFloatingWithBorder(LoginStrings.password.localized, text: $viewModel.password, hasWarning: .constant(viewModel.passwordHasError), isSecureField: true)
                .padding(.bottom)
        }
    }
    
    // MARK: - Marketing preferences
    var marketingPreferences: some View {
        VStack(spacing: Constants.General.vSpacing) {
            caption(Strings.MarketingPreferences.title.localized)
            
            MarketingPreferencesView(
                preferencesAreLoading: .constant(false),
                emailMarketingEnabled: $viewModel.emailMarketingEnabled,
                directMailMarketingEnabled: $viewModel.directMailMarketingEnabled,
                notificationMarketingEnabled: $viewModel.notificationMarketingEnabled,
                smsMarketingEnabled: $viewModel.smsMarketingEnabled,
                telephoneMarketingEnabled: $viewModel.telephoneMarketingEnabled,
                labelFont: .snappyBody2,
                fontColor: .snappyTextGrey2
            )
        }
    }
    
    // MARK: - Submit button
    var createAccountButton: some View {
        LoginButton(action: {
            viewModel.createAccountTapped()
        }, text: CreateAccountStrings.title.localized, icon: nil)
            .buttonStyle(SnappyPrimaryButtonStyle())
    }
    
    // MARK: - Terms and conditions
    var termsAndConditionsView: some View {
        HStack {
            Button {
                viewModel.termsAgreedTapped()
            } label: {
                (viewModel.termsAgreed ? Image.General.Checkbox.checked : Image.General.Checkbox.unChecked)
                    .font(.snappyTitle2)
                    .foregroundColor(viewModel.termsAndConditionsHasError ? .snappyRed : .snappyBlue)
            }

            Text("\(TermsStrings.agreeTo.localized) [\(TermsStrings.terms.localized)](https://app-dev.snappyshopper.co.uk/terms-and-conditions) \(TermsStrings.and.localized) [\(TermsStrings.privacy.localized)](https://app-dev.snappyshopper.co.uk/privacy-policy).")
            
                .font(.snappyCaption)
                .foregroundColor(viewModel.termsAndConditionsHasError ? .snappyRed : .snappyTextGrey2)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Referral code
    var referralCode: some View {
        VStack(spacing: Constants.General.vSpacing) {
            caption(CreateAccountStrings.referralTitle.localized)
            
            VStack {
                Text(CreateAccountStrings.referralBody.localized)
                    .font(.snappyCaption)
                    .foregroundColor(.snappyTextGrey2)
                
                TextFieldFloatingWithBorder(CreateAccountStrings.referralPlaceholder.localized, text: $viewModel.referralCode)
                    .padding(.bottom)
            }
        }
    }
    
    // MARK: - Caption
    func caption(_ text: String) -> some View {
        Text(text)
            .font(.snappyBody)
            .fontWeight(.bold)
            .foregroundColor(.snappyBlue)
    }
}

struct CreateAccountView_Previews: PreviewProvider {
    static var previews: some View {
        CreateAccountView(viewModel: .init(container: .preview), facebookButtonViewModel: .init(container: .preview))
    }
}
