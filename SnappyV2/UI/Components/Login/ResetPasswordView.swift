//
//  ResetPasswordView.swift
//  SnappyV2
//
//  Created by Kevin Palser on 26/09/2022.
//

import SwiftUI
import Combine
import OSLog

struct ResetPasswordView: View {
    
    // MARK: - Typealiases
    typealias ResetPasswordStrings = Strings.ResetPassword
    
    @Environment(\.presentationMode) var presentation
    @Environment(\.colorScheme) var colorScheme
    @ScaledMetric var scale: CGFloat = 1 // Used to scale icon for accessibility options
    @Environment(\.horizontalSizeClass) var sizeClass
    
    @StateObject var viewModel: ResetPasswordViewModel
    
    struct Constants {
        struct PasswordsStack {
            static let passwordStackHeight: CGFloat = 174
        }
        
        struct General {
            static let sizeThreshold = 7
            static let largeScreenWidthMultiplier: CGFloat = 0.6
            static let vSpacing: CGFloat = 15
        }
        
        struct Warning {
            static let spacing: CGFloat = 16
            static let iconHeight: CGFloat = 16
            static let fontPadding: CGFloat = 12
            static let lineLimit = 5
        }
    }
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    var body: some View {
        ZStack {
            VStack {
                if viewModel.noMemberFound {
                    VStack {
                        AdaptableText(
                            text: ResetPasswordStrings.subtitle.localized,
                            altText: ResetPasswordStrings.subtitleShort.localized,
                            threshold: Constants.General.sizeThreshold)
                        .multilineTextAlignment(.center)
                        .font(.Body1.regular())
                        .foregroundColor(colorPalette.typefacePrimary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding()
                        
                        SnappyTextfield(
                            container: viewModel.container,
                            text: $viewModel.newPassword,
                            isDisabled: .constant(false),
                            hasError: .constant(viewModel.newPasswordHasError),
                            labelText: ResetPasswordStrings.newPasswordField.localized,
                            largeTextLabelText: nil,
                            fieldType: .secureTextfield)
                        
                        SnappyTextfield(
                            container: viewModel.container,
                            text: $viewModel.confirmationPassword,
                            isDisabled: .constant(false),
                            hasError: .constant(viewModel.confirmationPasswordHasError),
                            labelText: ResetPasswordStrings.confirmPasswordField.localized,
                            largeTextLabelText: nil,
                            fieldType: .secureTextfield)
                        
                    }
                    .frame(height: Constants.PasswordsStack.passwordStackHeight * scale)
                    
                    confirmationNotMatchingWarning
                    
                } else {
                    
                    memberAlreadySignedInWarning
                    
                }
                
                SnappyButton(
                    container: viewModel.container,
                    type: .primary,
                    size: .large,
                    title: viewModel.noMemberFound ? ResetPasswordStrings.submit.localized : Strings.General.close.localized,
                    largeTextTitle: nil,
                    icon: nil) {
                        hideKeyboard()
                        Task {
                            await viewModel.submitTapped()
                        }
                    }
                    .padding(.top, Constants.General.vSpacing)
                
                Spacer()
            }
            .padding()
            
            if viewModel.isLoading {
                LoadingView()
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .background(colorPalette.backgroundMain)
        .dismissableNavBar(presentation: presentation, color: colorPalette.primaryBlue, title: ResetPasswordStrings.title.localized, navigationDismissType: .close)
        .onChange(of: viewModel.dismiss, perform: { dismiss in
            if dismiss {
                presentation.wrappedValue.dismiss()
            }
        })
    }
    
    @ViewBuilder private var confirmationNotMatchingWarning: some View {
        if viewModel.confirmationPasswordDifferent {
            HStack(alignment: .top, spacing: Constants.Warning.spacing) {
                Text(ResetPasswordStrings.nonMatchingPasswords.localized)
                
                Image.Icons.Triangle.filled
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: Constants.Warning.iconHeight)
                    .foregroundColor(colorPalette.primaryRed)
            }
            .fixedSize(horizontal: false, vertical: true)
            .lineLimit(Constants.Warning.lineLimit)
            .font(.subheadline)
            .foregroundColor(colorPalette.primaryRed)
            .padding(Constants.Warning.fontPadding)
            .background(colorPalette.secondaryWhite)
            .standardCardFormat(container: viewModel.container)
        }
    }
    
    @ViewBuilder private var memberAlreadySignedInWarning: some View {
        HStack(alignment: .top, spacing: Constants.Warning.spacing) {
            Text(ResetPasswordStrings.memberAlreadySignedIn.localized)
            
            Image.Icons.Triangle.filled
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: Constants.Warning.iconHeight)
                .foregroundColor(colorPalette.primaryRed)
        }
        .fixedSize(horizontal: false, vertical: true)
        .lineLimit(Constants.Warning.lineLimit)
        .font(.subheadline)
        .foregroundColor(colorPalette.primaryRed)
        .padding(Constants.Warning.fontPadding)
        .background(colorPalette.secondaryWhite)
        .standardCardFormat(container: viewModel.container)
    }

}

#if DEBUG
struct ResetPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ResetPasswordView(viewModel: .init(container: .preview, isInCheckout: false, resetToken: "p6rGf6KLBD", dismissHandler: { _ in }))
    }
}
#endif
