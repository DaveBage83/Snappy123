//
//  ForgotPasswordView.swift
//  SnappyV2
//
//  Created by David Bage on 15/03/2022.
//

import SwiftUI
import Combine
import OSLog

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
        
        struct Button {
            static let bottomPadding: CGFloat = 30
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
                        text: Strings.ForgotPassword.subtitle.localized,
                        altText: Strings.ForgotPassword.subtitleShort.localized,
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
                
                SnappyButton(
                    container: viewModel.container,
                    type: .primary,
                    size: .large,
                    title: GeneralStrings.send.localized,
                    largeTextTitle: nil,
                    icon: nil) {
                        Task {
                            await viewModel.submitTapped()
                        }
                    }
                    .padding(.bottom, Constants.Button.bottomPadding)
            }
            .padding()
            .background(colorPalette.backgroundMain)

            if viewModel.isLoading {
                LoadingView()
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .background(colorPalette.backgroundMain)
        .frame(width: UIScreen.screenWidth * (sizeClass == .compact ? 1 : Constants.General.largeScreenWidthMultiplier))
        .displayError(viewModel.error)
        
        .dismissableNavBar(presentation: presentation, color: colorPalette.primaryBlue, title: GeneralStrings.Login.forgotShortened.localized, navigationDismissType: .close)
		.onAppear {
            viewModel.onAppearSendEvent()
        }
    }
}

#if DEBUG
struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView(viewModel: .init(container: .preview, dismissHandler: { _ in }))
    }
}
#endif
