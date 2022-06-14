//
//  ForgotPasswordView.swift
//  SnappyV2
//
//  Created by David Bage on 15/03/2022.
//

import SwiftUI
import Combine
import OSLog

class ForgotPasswordViewModel: ObservableObject {
    
    @Published var email = ""
    @Published var emailHasError = false
    @Published var isLoading = false
    @Published var emailSent = false
    @Published private(set) var error: Error?
        
    let container: DIContainer
    private var cancellables = Set<AnyCancellable>()
    
    init(container: DIContainer) {
        self.container = container
    }
    
    private func resetPassword() {
        container.services.userService.resetPasswordRequest(email: email)
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                
                switch completion {
                case .failure(let error):
                    self.error = error
                    Logger.member.error("Failed to send password reset message")
                case .finished:
                    Logger.member.log("Email sent to reset password")
                }
                
                self.isLoading = false
            } receiveValue: { [weak self] _ in
                guard let self = self else { return }
                self.isLoading = false
                self.emailSent = true
            }
            .store(in: &cancellables)
    }
    
    func submitTapped() {
        emailHasError = email.isEmpty
        isLoading = true
        resetPassword()
    }
}

struct ForgotPasswordView: View {
    @Environment(\.presentationMode) var presentation
    @Environment(\.colorScheme) var colorScheme
    @ScaledMetric var scale: CGFloat = 1 // Used to scale icon for accessibility options
    @Environment(\.horizontalSizeClass) var sizeClass
    
    @StateObject var viewModel: ForgotPasswordViewModel

    typealias LoginStrings = Strings.General.Login
    
    struct Constants {
        static let padding: CGFloat = 30
        static let cornerRadius: CGFloat = 15
        static let vSpacing: CGFloat = 15
        
        struct Success {
            static let cornerRadius: CGFloat = 5
        }
        
        struct EmailStack {
            static let emailStackHeight: CGFloat = 150
        }
        
        struct General {
            static let sizeThreshold = 7
            static let largeScreenWidthMultiplier: CGFloat = 0.6
        }
    }
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    var body: some View {
        ZStack {
            VStack {
                VStack {
                    AdaptableText(
                        text: Strings.ResetPassword.subtitle.localized,
                        altText: Strings.ResetPassword.subtitleShort.localized,
                        threshold: Constants.General.sizeThreshold)
                    .multilineTextAlignment(.center)
                    .font(.Body1.regular())
                    .foregroundColor(colorPalette.typefacePrimary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding()
                    
                    SnappyTextfield(
                        container: viewModel.container,
                    text: $viewModel.email,
                    hasError: $viewModel.emailHasError,
                    labelText: LoginStrings.emailAddress.localized,
                        largeTextLabelText: LoginStrings.email.localized.capitalized)
                    .keyboardType(.emailAddress)
                }
                .frame(height: Constants.EmailStack.emailStackHeight * scale)
                
                if sizeClass == .compact {
                    Spacer()
                }
                
                if viewModel.emailSent {
                    successView
                } else {
                    SnappyButton(
                        container: viewModel.container,
                        type: .primary,
                        size: .large,
                        title: GeneralStrings.send.localized,
                        largeTextTitle: nil,
                        icon: nil) {
                            viewModel.submitTapped()
                        }
                }
            }
            .padding()
            
            if viewModel.isLoading {
                LoadingView()
            }
        }
        .frame(width: UIScreen.screenWidth * (sizeClass == .compact ? 1 : Constants.General.largeScreenWidthMultiplier))
        .displayError(viewModel.error)
        .simpleBackButtonNavigation(presentation: presentation, color: colorPalette.primaryBlue, title: GeneralStrings.Login.forgotShortened.localized)
    }
    
    var emailFieldAndButton: some View {
        VStack(spacing: Constants.vSpacing) {
            SnappyTextfield(
                container: viewModel.container,
                text: $viewModel.email,
                hasError: $viewModel.emailHasError,
                labelText: LoginStrings.emailAddress.localized,
                largeTextLabelText: nil)
            
            if viewModel.emailSent {
                successView
            } else {
                LoginButton(action: {
                    viewModel.submitTapped()
                }, text: GeneralStrings.cont.localized, icon: nil)
                    .buttonStyle(SnappyPrimaryButtonStyle())
            }
        }
    }
    
    var successView: some View {
        Text(Strings.ResetPasswordCustom.confirmation.localizedFormat(viewModel.email))
            .frame(maxWidth: .infinity)
            .font(.snappyBody2)
            .foregroundColor(.white)
            .padding()
            .background(Color.snappyTeal)
            .clipShape(RoundedRectangle(cornerRadius: Constants.Success.cornerRadius))
    }
}

#if DEBUG
struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView(viewModel: .init(container: .preview))
    }
}
#endif
