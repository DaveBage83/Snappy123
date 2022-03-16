//
//  LoginWithFacebookButton.swift
//  SnappyV2
//
//  Created by David Bage on 14/03/2022.
//

import SwiftUI
import Combine
import OSLog

class LoginWithFacebookViewModel: ObservableObject {
        
    let container: DIContainer
    private var cancellables = Set<AnyCancellable>()
    
    init(container: DIContainer) {
        self.container = container
    }
    
    @Published var isLoading = false

    private func loginWithFacebook() {
        container.services.userService.loginWithFacebook(registeringFromScreen: .startScreen)
            .receive(on: RunLoop.main)
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    Logger.member.log("Successfully logged member in using Facebook")
                    self.isLoading = false
                case .failure(let err):
                    #warning("Error handling required here")
                    Logger.member.error("Unable to log in using Facebook \(err.localizedDescription)")
                    self.isLoading = false
                }
            }
            .store(in: &cancellables)
    }
    
    func loginWithFacebookTapped() {
        isLoading = true
        loginWithFacebook()
    }
}

struct LoginWithFacebookButton: View {
    typealias LoginStrings = Strings.General.Login
    typealias CustomLoginStrings = Strings.General.Login.Customisable
    
    @StateObject var viewModel: LoginWithFacebookViewModel
    
    var body: some View {
        LoginButton(action: {
            viewModel.loginWithFacebookTapped()
        }, text: CustomLoginStrings.loginWith.localizedFormat(LoginStrings.facebook.localized), icon: Image.Login.Methods.facebook)
            .buttonStyle(SnappySecondaryButtonStyle())
    }
}

struct LoginWithFacebookButton_Previews: PreviewProvider {
    static var previews: some View {
        LoginWithFacebookButton(viewModel: .init(container: .preview))
    }
}
