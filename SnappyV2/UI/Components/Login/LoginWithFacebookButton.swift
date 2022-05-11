//
//  LoginWithFacebookButton.swift
//  SnappyV2
//
//  Created by David Bage on 14/03/2022.
//

import SwiftUI
import Combine
import OSLog

@MainActor
class LoginWithFacebookViewModel: ObservableObject {
        
    let container: DIContainer
    @Published private(set) var error: Error?
    private var cancellables = Set<AnyCancellable>()
    
    init(container: DIContainer) {
        self.container = container
    }
    
    @Published var isLoading = false
    
    func loginWithFacebook() async {
        isLoading = true
        do {
            try await container.services.userService.loginWithFacebook(registeringFromScreen: .startScreen)
            self.isLoading = false
        } catch {
            self.error = error
            Logger.member.error("Failed to log in with Facebook: \(error.localizedDescription)")
            self.isLoading = false
        }
    }
}

struct LoginWithFacebookButton: View {
    typealias LoginStrings = Strings.General.Login
    typealias CustomLoginStrings = Strings.General.Login.Customisable
    
    @StateObject var viewModel: LoginWithFacebookViewModel
    
    var body: some View {
        LoginButton(action: {
            Task {
                await viewModel.loginWithFacebook()
            }
        }, text: CustomLoginStrings.loginWith.localizedFormat(LoginStrings.facebook.localized), icon: Image.Login.Methods.facebook)
        .buttonStyle(SnappySecondaryButtonStyle())
    }
}

struct LoginWithFacebookButton_Previews: PreviewProvider {
    static var previews: some View {
        LoginWithFacebookButton(viewModel: .init(container: .preview))
    }
}
