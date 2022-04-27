//
//  MemberDashboardProfileView.swift
//  SnappyV2
//
//  Created by David Bage on 25/03/2022.
//

import SwiftUI

struct MemberDashboardProfileView: View {
    typealias ProfileStrings = Strings.MemberDashboard.Profile
    
    // MARK: - Constants
    
    struct Constants {
        struct MarketingPreferences {
            static let spacing: CGFloat = 10
        }
        
        struct SubViewStacks {
            static let spacing: CGFloat = 15
        }
        
        struct General {
            static let stackSpacing: CGFloat = 30
        }
        
        struct Buttons {
            static let height: CGFloat = 30
        }
    }
    
    // MARK: - View Models
    
    @StateObject var viewModel: MemberDashboardProfileViewModel
    @StateObject var marketingPreferencesViewModel: MarketingPreferencesViewModel
    
    init(container: DIContainer) {
        self._viewModel = .init(wrappedValue: .init(container: container))
        self._marketingPreferencesViewModel = .init(wrappedValue: .init(container: container, isCheckout: false))
    }
    
    // MARK: - Main body
    
    var body: some View {
        switch viewModel.viewState {
        case .updateProfile:
            updateProfileDetailsView
        case .changePassword:
            changePasswordView
        }
    }
    
    // MARK: - Update details view
    
    var updateProfileDetailsView: some View {
        VStack(alignment: .leading, spacing: Constants.General.stackSpacing) {
            detailFields
            marketingPreferencSelectionView
            updateProfileButtons
        }
        .padding()
    }
    
    // MARK: - Subview : Update details view buttons
    
    var updateProfileButtons: some View {
        VStack {
            Button {
                #warning("As we have to trigger these 2 separately, we should add UI tests at some point to ensure both are triggered")
                Task {
                    await marketingPreferencesViewModel.updateMarketingPreferences()
                    viewModel.updateProfileTapped()
                }
            } label: {
                if viewModel.profileIsUpdating {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .frame(maxWidth: .infinity)
                        .frame(height: Constants.Buttons.height)
                } else {
                    Text(ProfileStrings.update.localized)
                        .frame(maxWidth: .infinity)
                        .frame(height: Constants.Buttons.height)
                }
            }
            .buttonStyle(SnappyPrimaryButtonStyle())
            
            Button {
                viewModel.changePasswordScreenRequested()
            } label: {
                Text(ProfileStrings.changePassword.localized)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .frame(height: Constants.Buttons.height)
            }
            .buttonStyle(SnappySecondaryButtonStyle())
        }
    }
    
    // MARK: - Subview : Marketing preferences
    
    var marketingPreferencSelectionView: some View {
        VStack(alignment: .leading, spacing: Constants.SubViewStacks.spacing) {
            header(Strings.CheckoutDetails.MarketingPreferences.title.localized)
            
            VStack(alignment: .leading, spacing: Constants.MarketingPreferences.spacing) {
                
                
                Text(Strings.CheckoutDetails.MarketingPreferences.prompt.localized)
                    .font(.snappyCaption)
                
                MarketingPreferencesView(viewModel: marketingPreferencesViewModel)
            }
        }
    }
    
    // MARK: - Subview : Update profile view fields
    
    var detailFields: some View {
        VStack(alignment: .leading, spacing: Constants.SubViewStacks.spacing) {
            header(ProfileStrings.yourDetails.localized)
            
            VStack {
                TextFieldFloatingWithBorder(GeneralStrings.firstName.localized, text: $viewModel.firstName, hasWarning: .constant(viewModel.firstNameHasError))
                
                TextFieldFloatingWithBorder(GeneralStrings.lastName.localized, text: $viewModel.lastName, hasWarning: .constant(viewModel.lastNameHasError))

                TextFieldFloatingWithBorder(GeneralStrings.phone.localized, text: $viewModel.phoneNumber, hasWarning: .constant(viewModel.phoneNumberHasError), keyboardType: .numberPad)
            }
            .redacted(reason: viewModel.profileIsUpdating ? .placeholder : [])
        }
    }
    
    // MARK: - Change password view
    
    var changePasswordView: some View {
        ZStack {
            VStack(alignment: .leading, spacing: Constants.General.stackSpacing) {
                Text(ProfileStrings.changePassword.localized)
                    .font(.snappyBody)
                    .fontWeight(.bold)
                
                changePasswordFields
                
                changePasswordButtons
                
                Spacer()
            }
            .padding()
            
            if viewModel.changePasswordLoading {
                LoadingView()
            }
        }
    }
    
    // MARK: - Subview : change password fields
    
    var changePasswordFields: some View {
        VStack {
            TextFieldFloatingWithBorder(ProfileStrings.currentPassword.localized, text: $viewModel.currentPassword, hasWarning:.constant(viewModel.currentPasswordHasError), isSecureField: true)
            TextFieldFloatingWithBorder(ProfileStrings.newPassword.localized, text: $viewModel.newPassword, hasWarning: .constant(viewModel.newPasswordHasError), isSecureField: true)
            TextFieldFloatingWithBorder(ProfileStrings.verifyPassword.localized, text: $viewModel.verifyNewPassword, hasWarning: .constant(viewModel.verifyNewPasswordHasError), isSecureField: true)
        }
    }
    
    // MARK: - Subview : change password buttons
    
    var changePasswordButtons: some View {
        VStack {
            Button {
                Task {
                    try await viewModel.changePasswordTapped()
                }
                
            } label: {
                Text(ProfileStrings.changePassword.localized)
                    .frame(maxWidth: .infinity)
                    .frame(height: Constants.Buttons.height)
            }
            .buttonStyle(SnappyPrimaryButtonStyle())
            
            Button {
                viewModel.backToUpdateViewTapped()
            } label: {
                Text(ProfileStrings.backToUpdate.localized)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .frame(height: Constants.Buttons.height)
            }
            .buttonStyle(SnappySecondaryButtonStyle())
        }
    }
    
    // MARK: - Section header factory
    
    func header(_ title: String) -> some View {
        Text(title)
            .font(.snappyBody)
            .fontWeight(.bold)
    }
}

struct MemberDashboardProfileView_Previews: PreviewProvider {
    static var previews: some View {
        MemberDashboardProfileView(container: .preview)
    }
}
