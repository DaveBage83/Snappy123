//
//  ForgotPasswordView.swift
//  SnappyV2
//
//  Created by David Bage on 15/03/2022.
//

import SwiftUI
import Combine

class ForgotPasswordViewModel: ObservableObject {
    @Published var email = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    @Published var emailHasError = false
    @Published var isLoading = false
    @Published var emailSent = false
        
    let container: DIContainer
    
    init(container: DIContainer) {
        self.container = container
    }
    
    private func resetPassword() {
        container.services.userService.resetPasswordRequest(email: email)
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                #warning("Add error handling")
                print(completion)
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
    typealias LoginStrings = Strings.General.Login
    
    struct Constants {
        static let padding: CGFloat = 30
        static let cornerRadius: CGFloat = 15
        static let vSpacing: CGFloat = 15
        
        struct Success {
            static let cornerRadius: CGFloat = 5
        }
    }
    
    @StateObject var viewModel: ForgotPasswordViewModel
    
    var body: some View {
        ZStack {
            VStack {
                VStack {
                    title
                    
                    emailFieldAndButton
                }
                .padding()
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
                .snappyShadow()
            }
            .padding()
            if viewModel.isLoading {
                LoadingView()
            }
        }
    }
    
    var emailFieldAndButton: some View {
        VStack(spacing: Constants.vSpacing) {
            TextFieldFloatingWithBorder(LoginStrings.emailAddress.localized, text: $viewModel.email, hasWarning: $viewModel.emailHasError, disableAnimations: true, keyboardType: .emailAddress)
                .autocapitalization(.none)
                .disabled(viewModel.emailSent)
            
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
        Text("A password reset email has been sent to \(viewModel.email)")
            .frame(maxWidth: .infinity)
            .font(.snappyBody2)
            .foregroundColor(.white)
            .padding()
            .background(Color.snappyTeal)
            .clipShape(RoundedRectangle(cornerRadius: Constants.Success.cornerRadius))
    }
    
    var title: some View {
        VStack {
            VStack {
                Text(Strings.ResetPassword.title.localized)
                    .font(.snappyTitle2)
                    .foregroundColor(.snappyBlue)
                    .fontWeight(.bold)
                    .padding()
                
                Text(Strings.ResetPassword.subtitle.localized)
                    .font(.snappyCaption)
                    .foregroundColor(.snappyTextGrey1)
                    .padding()
            }
        }
    }
}

struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView(viewModel: .init(container: .preview))
    }
}
