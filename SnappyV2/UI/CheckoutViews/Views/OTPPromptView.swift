//
//  OTPPromptView.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 14/07/2022.
//

import SwiftUI

struct OTPPromptView: View {
    typealias OTPStrings = Strings.CheckoutView.OTP
    
    struct Constants {
        struct OTPAlert {
            static let frameWidth: CGFloat = 300
            static let cornerRadius: CGFloat = 20
            static let vStackSpacing: CGFloat = 11
            static let opacity: CGFloat = 0.2
            static let buttonPadding: CGFloat = -10
            static let dividerHeight: CGFloat = 50
        }
    }
    
    @StateObject var viewModel: OTPPromptViewModel
    
    var body: some View {
        VStack {
            if viewModel.showOTPCodePrompt {
                enterOTPPrompt()
            } else {
                requestOTPPrompt()
            }
        }
        .withAlertToast(container: viewModel.container, error: $viewModel.error)
        
        // MARK: NavigationLinks
        NavigationLink("", isActive: $viewModel.showLoginView) {
            LoginView(loginViewModel: .init(container: viewModel.container), socialLoginViewModel: .init(container: viewModel.container))
        }
    }
    
    func requestOTPPrompt() -> some View {
        ZStack {
            Color.black.opacity(Constants.OTPAlert.opacity)
                .ignoresSafeArea()
            
            VStack(spacing: Constants.OTPAlert.vStackSpacing) {
                Text(OTPStrings.promptTitle.localized)
                    .bold()
                    .padding(.top)
                
                    .frame(maxWidth: .infinity)
                Text(viewModel.email + OTPStrings.promptText.localized)
                    .multilineTextAlignment(.center)
                    .padding([.leading, .trailing])
                
                    Divider()
                    
                    Button(action: {
                        Task { await viewModel.sendOTP(via: .email) }
                    }) {
                        Text(OTPStrings.emailOTP.localized)
                    }
                    
                    Divider()
                    
                    if viewModel.showOTPTelephone {
                        Button(action: {
                            Task { await viewModel.sendOTP(via: .sms) }
                        }) {
                            Text(OTPStrings.textOTP.localized + viewModel.otpTelephone)
                        }

                        Divider()
                    }
                    
                    Button(action: {
                        viewModel.login()
                    }) {
                        Text(Strings.General.Login.login.localized)
                    }
                    
                    Divider()
                    
                    Button(action: {
                        viewModel.dismissOTPPrompt()
                    }) {
                        Text(Strings.General.cancel.localized)
                            .bold()
                    }
                    .padding(.bottom)
            }
            .frame(width: Constants.OTPAlert.frameWidth)
            .background(Color.white)
            .cornerRadius(Constants.OTPAlert.cornerRadius)
            .toast(isPresenting: $viewModel.isSendingOTPRequest, alert: {
                AlertToast(displayMode: .alert, type: .loading)
            })
        }
    }
    
    func enterOTPPrompt() -> some View {
        ZStack {
            Color.black.opacity(Constants.OTPAlert.opacity)
                .ignoresSafeArea()
            
            VStack(spacing: Constants.OTPAlert.vStackSpacing) {
                Text(OTPStrings.otpSentTitle.localized)
                    .bold()
                    .padding(.top)
                
                    .frame(maxWidth: .infinity)
                Text(viewModel.otpType == .email ? OTPStrings.Customisable.otpSentEmailText.localizedFormat(viewModel.optCodeSendDestination) : OTPStrings.Customisable.otpSentMobileText.localizedFormat(viewModel.optCodeSendDestination))
                    .multilineTextAlignment(.center)
                    .padding([.leading, .trailing])
                
                TextField(OTPStrings.enterPassword.localized, text: $viewModel.otpCode)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.allCharacters)
                    .textContentType(.oneTimeCode)
                    .multilineTextAlignment(.center)
                    .padding([.leading, .trailing])
                
                Divider()
                
                HStack(alignment: .center) {
                    Spacer()
                    
                    Button(action: {
                        viewModel.dismissOTPPrompt()
                    }) {
                        Text(Strings.General.cancel.localized)
                            .bold()
                    }
                    .padding(.top, Constants.OTPAlert.buttonPadding)
                    
                    Spacer()
                    
                    Divider()
                        .frame(height: Constants.OTPAlert.dividerHeight)
                        .padding(.top, Constants.OTPAlert.buttonPadding)
                    
                    Spacer()
                    
                    Button(action: {
                        Task { await viewModel.loginWithOTP() }
                    }) {
                        Text(Strings.General.Login.login.localized)
                            .bold()
                    }
                    .padding(.top, Constants.OTPAlert.buttonPadding)
                    .disabled(viewModel.disableLogin)
                    
                    Spacer()
                }
            }
            .frame(width: Constants.OTPAlert.frameWidth)
            .background(Color.white)
            .cornerRadius(Constants.OTPAlert.cornerRadius)
            .toast(isPresenting: $viewModel.isSendingOTPCode, alert: {
                AlertToast(displayMode: .alert, type: .loading)
            })
        }
    }
}

#if DEBUG
struct OTPPromptView_Previews: PreviewProvider {
    static var previews: some View {
        OTPPromptView(viewModel: .init(container: .preview, email: "email@domain.com", otpTelephone: "0987654321", dismiss: {}))
    }
}
#endif
