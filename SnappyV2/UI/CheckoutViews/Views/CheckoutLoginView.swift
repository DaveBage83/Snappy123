//
//  CheckoutLoginView.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 27/01/2022.
//

import SwiftUI

class CheckoutLoginViewModel: ObservableObject {
    enum LoginType {
        case manualLogin
        case appleLogin
        case facebookLogin
    }
    
    let container: DIContainer
    @Published var email = ""
    @Published var password = ""
    @Published var loginType: LoginType?
    
    var emailAndPassswordFilled: Bool {
        email.isEmpty == false && password.isEmpty == false
    }
    
    init(container: DIContainer) {
        self.container = container
    }
    
    func loginTapped() {
//        container.appState.value.userData.memberSignedIn = true
        loginType = .manualLogin
    }
}

struct CheckoutLoginView: View {
    typealias ProgressStrings = Strings.CheckoutView.Progress
    typealias LoginStrings = Strings.General.Login
    
    @StateObject var viewModel: CheckoutLoginViewModel
    
    var body: some View {
        ScrollView {
            checkoutProgress()
                .background(Color.white)
            
            loginDetails()
                .padding([.top, .leading, .trailing])
            
            Button(action: { viewModel.loginTapped() }) {
                loginButton()
                    .padding([.top, .leading, .trailing])
            }
            .disabled(!viewModel.emailAndPassswordFilled)
            
            createAccountLink
                .padding([.top, .leading, .trailing])
            
            Button(action: { viewModel.loginTapped() }) {
                signInWithAppleCard()
                    .padding([.top, .leading, .trailing])
            }
            
            Button(action: { viewModel.loginTapped() }) {
                loginWithFacebookCard()
                    .padding([.top, .leading, .trailing])
            }
            
            
            // MARK: NavigationLinks
            NavigationLink(
                destination:
                    CheckoutDetailsView(viewModel: .init(container: viewModel.container)),
                tag: CheckoutLoginViewModel.LoginType.manualLogin,
                selection: $viewModel.loginType) { EmptyView() }
        }
    }
    
    // MARK: View Components
    func checkoutProgress() -> some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                Image.Checkout.delivery
                    .font(.title2)
                    .foregroundColor(.snappyBlue)
                    .padding()
                
                VStack(alignment: .leading) {
                    Text(ProgressStrings.time.localized)
                        .font(.snappyCaption)
                        .foregroundColor(.gray)
                    
                    #warning("To replace with actual order time")
                    Text("Sun, 15 October, 10:30").bold()
                        .font(.snappyCaption)
                        .foregroundColor(.snappyBlue)
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text(ProgressStrings.orderTotal.localized)
                        .foregroundColor(.gray)
                    
                    HStack {
                    #warning("To replace with actual order value")
                        Text("£8.95")
                            .fontWeight(.semibold)
                            .foregroundColor(.snappyBlue)
                        
                        Image.General.bulletList
                            .foregroundColor(.snappyBlue)
                    }
                }
                .font(.snappyCaption)
                
            }
            .padding(.horizontal)
            
            ProgressBarView(value: 1, maxValue: 4, backgroundColor: .snappyBGFields1, foregroundColor: .snappyBlue)
                .frame(height: 6)
                .padding(.horizontal, -3)
        }
    }
    
    func loginDetails() -> some View {
        VStack(alignment: .leading) {
            Text("Login to your account")
                .font(.snappyHeadline)
            
            TextFieldFloatingWithBorder("Email Address", text: $viewModel.email, background: Color.snappyBGMain)
                
                TextFieldFloatingWithBorder("Password", text: $viewModel.password, background: Color.snappyBGMain)
        }
    }
    
    var createAccountLink: some View {
        HStack {
            Button(action: {}) {
                Text("Forgot your password?")
            }
        }
    }
    
    func loginButton() -> some View {
        Text("Login")
            .font(.snappyTitle2)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(10)
            .padding(.horizontal)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(viewModel.emailAndPassswordFilled ? Color.snappyTeal : Color.gray)
            )
    }
    
    func signInWithAppleCard() -> some View {
        HStack {
            Image.Login.Methods.apple
                .font(.title2)
                .foregroundColor(.snappyBlue)
            
            Spacer()
            
            VStack(alignment: .leading) {
                Text(LoginStrings.Customisable.signInWith.localizedFormat(LoginStrings.apple.localized))
                    .font(.snappyHeadline)
            }
            
            Spacer()
            
            Image.Navigation.chevronRight
        }
        .padding()
        .background(Color.white)
        .cornerRadius(6)
        .snappyShadow()
    }
    
    func loginWithFacebookCard() -> some View {
        HStack {
            Image.General.Number.filledCircle
                .font(.title2)
                .foregroundColor(.snappyBlue)
            
            Spacer()
            
            VStack(alignment: .leading) {
                Text(LoginStrings.Customisable.loginWith.localizedFormat(LoginStrings.facebook.localized))
                    .font(.snappyHeadline)
            }
            
            Spacer()
            
            Image.Navigation.chevronRight
        }
        .padding()
        .background(Color.white)
        .cornerRadius(6)
        .snappyShadow()
    }
}

struct CheckoutLoginView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutLoginView(viewModel: .init(container: .preview))
            .environmentObject(CheckoutViewModel(container: .preview))
    }
}
