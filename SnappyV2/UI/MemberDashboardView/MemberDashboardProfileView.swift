//
//  MemberDashboardProfileView.swift
//  SnappyV2
//
//  Created by David Bage on 25/03/2022.
//

import SwiftUI
import Combine

struct MemberDashboardProfileView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.tabViewHeight) var tabViewHeight

    typealias ProfileStrings = Strings.MemberDashboard.Profile
    
    // MARK: - Constants
    
    struct Constants {
        struct MarketingPreferences {
            static let spacing: CGFloat = 10
        }
        
        struct SubViewStacks {
            static let spacing: CGFloat = 20
        }
        
        struct General {
            static let stackSpacing: CGFloat = 30
            static let topPadding: CGFloat = 28
        }
        
        struct Buttons {
            static let height: CGFloat = 30
        }
        
        struct DetailFields {
            static let spacing: CGFloat = 25
        }
        
        struct ChangePasswordFields {
            static let spacing: CGFloat = 25
        }
        
        struct ChangePasswordView {
            static let padding: CGFloat = 20
        }
    }
    
    // MARK: - View Models
    
    @StateObject var viewModel: MemberDashboardProfileViewModel
    let didSetError: (Swift.Error) -> ()
    let didSucceed: (String) -> ()
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    // MARK: - Main body
    
    var body: some View {
        updateProfileDetailsView
            .padding(.top, Constants.General.topPadding)
            .padding(.bottom, tabViewHeight)
            .sheet(isPresented: $viewModel.showPasswordResetView, content: {
                NavigationView {
                    VStack(spacing: 0) {
                        Divider()
                        changePasswordView
                            .dismissableNavBar(
                                presentation: nil,
                                color: colorPalette.primaryBlue,
                                title: Strings.MemberDashboard.Profile.updatePassword.localized,
                                navigationDismissType: .close,
                                backButtonAction: {
                                    viewModel.dismissPasswordResetView()
                                })
                    }
                    .withAlertToast(container: viewModel.container, error: $viewModel.resetPasswordError)
                }
            })
    }
    
    // MARK: - Update details view
    
    var updateProfileDetailsView: some View {
        VStack(alignment: .leading, spacing: Constants.General.stackSpacing) {
            detailFields
            updateProfileButtons
        }
        .onAppear {
            viewModel.onAppearSendEvent()
        }
    }
    
    // MARK: - Subview : Update details view buttons
    
    var updateProfileButtons: some View {
        VStack {
            SnappyButton(
                container: viewModel.container,
                type: .primary,
                size: .large,
                title: ProfileStrings.update.localized,
                largeTextTitle: nil,
                icon: nil,
                isLoading: $viewModel.profileIsUpdating) {
                    Task {
                        await viewModel.updateMemberDetails(didSetError: didSetError, didSucceed: didSucceed)
                    }
                }

            SnappyButton(
                container: viewModel.container,
                type: .outline,
                size: .large,
                title: ProfileStrings.changePassword.localized,
                largeTextTitle: nil,
                icon: nil) {
                    viewModel.changePasswordScreenRequested()
                }
        }
    }

    // MARK: - Subview : Update profile view fields
    
    var detailFields: some View {
        VStack(alignment: .leading, spacing: Constants.SubViewStacks.spacing) {
            header(ProfileStrings.yourDetails.localized)
            
            VStack(spacing: Constants.DetailFields.spacing) {
                SnappyTextfield(
                    container: viewModel.container,
                    text: $viewModel.firstName,
                    hasError: $viewModel.firstNameHasError,
                    labelText: GeneralStrings.firstName.localized,
                    largeTextLabelText: nil)
                
                SnappyTextfield(
                    container: viewModel.container,
                    text: $viewModel.lastName,
                    hasError: $viewModel.lastNameHasError,
                    labelText: GeneralStrings.lastName.localized,
                    largeTextLabelText: nil)

                SnappyTextfield(
                    container: viewModel.container,
                    text: $viewModel.phoneNumber,
                    hasError: $viewModel.phoneHasError,
                    labelText: GeneralStrings.phone.localized,
                    largeTextLabelText: nil,
                    keyboardType: .phonePad)
                .onReceive(Just(viewModel.phoneNumber)) { newValue in
                    viewModel.filterPhoneNumber(newValue: newValue)
                }
            }
            .redacted(reason: viewModel.profileIsUpdating ? .placeholder : [])
        }
    }
    
    // MARK: - Change password view
    
    var changePasswordView: some View {
        VStack(alignment: .leading, spacing: Constants.General.stackSpacing) {
            
            changePasswordFields
                .padding(.top, Constants.ChangePasswordView.padding)
            
            Spacer()
            
            changePasswordButton
                .padding(.bottom, Constants.ChangePasswordView.padding)
        }
        .padding()
        .background(colorPalette.backgroundMain)
        .edgesIgnoringSafeArea(.bottom)
    }
    
    // MARK: - Subview : change password fields
    
    var changePasswordFields: some View {
        VStack(spacing: Constants.ChangePasswordFields.spacing) {
            SnappyTextfield(
                container: viewModel.container,
                text: $viewModel.currentPassword,
                hasError: $viewModel.currentPasswordHasError,
                labelText: ProfileStrings.currentPassword.localized,
                largeTextLabelText: nil)
            
            
            SnappyTextfield(
                container: viewModel.container,
                text: $viewModel.newPassword,
                hasError: $viewModel.newPasswordHasError,
                labelText: ProfileStrings.newPassword.localized,
                largeTextLabelText: nil,
                fieldType: .secureTextfield)
            
            SnappyTextfield(
                container: viewModel.container,
                text: $viewModel.verifyNewPassword,
                hasError: $viewModel.verifyNewPasswordHasError,
                labelText: ProfileStrings.verifyPassword.localized,
                largeTextLabelText: nil,
                fieldType: .secureTextfield)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
    
    // MARK: - Subview : change password buttons
    
    var changePasswordButton: some View {
        SnappyButton(
            container: viewModel.container,
            type: .primary,
            size: .large,
            title: Strings.MemberDashboard.Profile.updatePassword.localized,
            largeTextTitle: nil,
            icon: nil,
            isLoading: $viewModel.changePasswordLoading) {
                Task {
                    await viewModel.changePassword(didResetPassword: didSucceed)
                }
            }
    }
    
    // MARK: - Section header factory
    
    func header(_ title: String) -> some View {
        Text(title)
            .font(.heading4())
            .foregroundColor(colorPalette.primaryBlue)
    }
}

#if DEBUG
struct MemberDashboardProfileView_Previews: PreviewProvider {
    static var previews: some View {
        MemberDashboardProfileView(viewModel: .init(container: .preview), didSetError: { _ in }, didSucceed: { _ in })
    }
}
#endif
