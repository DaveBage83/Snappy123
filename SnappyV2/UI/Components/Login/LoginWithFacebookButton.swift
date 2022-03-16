//
//  LoginWithFacebookButton.swift
//  SnappyV2
//
//  Created by David Bage on 14/03/2022.
//

import SwiftUI
import Combine

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
                    self.isLoading = false
                case let .failure(error):
                    #warning("Error handling required here")
                    print("Facebook Login Error: \(error)")
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
