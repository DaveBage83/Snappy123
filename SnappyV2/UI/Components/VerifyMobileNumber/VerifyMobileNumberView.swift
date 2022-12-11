//
//  VerifyMobileNumberView.swift
//  SnappyV2
//
//  Created by Kevin Palser on 21/09/2022.
//

import SwiftUI
import Combine

struct VerifyMobileNumberView: View {
    
    // MARK: - Typealiases
    typealias VerifyMobileNumberStrings = Strings.VerifyMobileNumber
    
    // MARK: - Environment objects
    @Environment(\.colorScheme) private var colorScheme
    
    // MARK: - Constants
    struct Constants {
        struct VerifyMobileNumberAlert {
            static let frameWidth: CGFloat = 300
            static let cornerRadius: CGFloat = 20
            static let vStackSpacing: CGFloat = 11
            static let opacity: CGFloat = 0.2
        }
    }
    
    // MARK: - View model
    @StateObject var viewModel: VerifyMobileNumberViewModel
    
    // MARK: - Colors
    private var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    // MARK: - Main content
    var body: some View {

        ZStack {
            Color.black.opacity(Constants.VerifyMobileNumberAlert.opacity)
                .ignoresSafeArea()
            
            VStack(spacing: Constants.VerifyMobileNumberAlert.vStackSpacing) {
                Text(VerifyMobileNumberStrings.EnterCodeViewStaticText.title.localized)
                    .bold()
                    .padding(.top)
                    .frame(maxWidth: .infinity)
                
                Text(viewModel.instructions)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                TextField(VerifyMobileNumberStrings.EnterCodeViewStaticText.codeField.localized, text: $viewModel.verifyCode)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.allCharacters)
                    .textContentType(.oneTimeCode)
                    .multilineTextAlignment(.center)
                    .padding([.leading, .trailing])
                    .onReceive(Just(viewModel.verifyCode)) { newValue in
                        viewModel.filteredVerifyCode(newValue: newValue)
                    }
                
                Divider()
                
                Button(action: {
                    Task {
                        await viewModel.submitCodeTapped()
                    }
                }) {
                    Text(Strings.General.send.localized).bold()
                }.disabled(viewModel.submitDisabled)
                
                Divider()
                
                Button(action: {
                    Task {
                        await viewModel.resendCodeTapped()
                    }
                }) {
                    Text(VerifyMobileNumberStrings.EnterCodeViewStaticText.resendButton.localized).bold()
                }
                
                Divider()
                
                Button(action: {
                    viewModel.cancelTapped()
                }) {
                    Text(Strings.General.cancel.localized).bold()
                }.padding(.bottom)
            }
                .frame(width: Constants.VerifyMobileNumberAlert.frameWidth)
                .background(colorPalette.secondaryWhite)
                .cornerRadius(Constants.VerifyMobileNumberAlert.cornerRadius)
                .withLoadingToast(loading: $viewModel.isRequestingOrSendingVerificationCode)
        }
            .font(.body)
    }
}

#if DEBUG
struct VerifyMobileNumberView_Previews: PreviewProvider {
    static var previews: some View {
        VerifyMobileNumberView(viewModel: .init(container: .preview, dismissViewHandler: { _, _ in }))
    }
}
#endif

