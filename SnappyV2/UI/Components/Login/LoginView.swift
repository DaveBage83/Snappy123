//
//  LoginView.swift
//  SnappyV2
//
//  Created by David Bage on 08/03/2022.
//

import SwiftUI

struct LoginView: View {
    typealias LoginStrings = Strings.General.Login
    typealias CustomLoginStrings = Strings.General.Login.Customisable
    
    // MARK: - Constants
    struct Constants {
        struct Buttons {
            static let size: CGFloat = 15
            static let vPadding: CGFloat = 3
        }
    }
    
    @StateObject var loginViewModel: LoginViewModel
    @StateObject var facebookButtonViewModel: LoginWithFacebookViewModel
    
    var body: some View {
        ScrollView {
            ZStack {
                VStack {
                    Text(LoginStrings.title.localized)
                        .font(.snappyTitle2)
                        .foregroundColor(.snappyBlue)
                        .fontWeight(.bold)
                        .padding()
                    
                    Text(LoginStrings.subtitle.localized)
                        .font(.snappyCaption)
                        .foregroundColor(.snappyTextGrey1)
                        .padding()
                    
                    LoginHomeView(loginViewModel: loginViewModel, facebookLoginViewModel: facebookButtonViewModel)
                    
                    NavigationLink("", isActive: $loginViewModel.showCreateAccountView) {
                        CreateAccountView(viewModel: .init(container: loginViewModel.container), facebookButtonViewModel: facebookButtonViewModel)
                    }
                }
                .navigationViewStyle(.stack)
                .navigationBarTitleDisplayMode(.inline)
                .background(Color.white)
                .padding()
                if facebookButtonViewModel.isLoading || loginViewModel.isLoading {
                   LoadingView()
                }
            }
        }
        .displayError(loginViewModel.error)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(loginViewModel: .init(container: .preview), facebookButtonViewModel: .init(container: .preview))
    }
}
