//
//  CheckoutSuccessView.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 28/01/2022.
//

import SwiftUI
import UIKit

struct CheckoutSuccessView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.mainWindowSize) var mainWindowSize
    @Environment(\.tabViewHeight) var tabViewHeight

    typealias ProgressStrings = Strings.CheckoutView.Progress
    typealias PaymentStrings = Strings.CheckoutView.Payment
    
    struct Constants {
        struct Main {
            static let hPadding: CGFloat = 30
        }
        
        struct HelpStack {
            static let spacing: CGFloat = 16
            static let textWidthMultiplier: CGFloat = 0.7
        }
        
        struct Button {
            static let spacing: CGFloat = 16
        }
        
        struct SuccessBanner {
            static let spacing: CGFloat = 16
            static let height: CGFloat = 75
        }
        
        struct SuccessImage {
            static let width: CGFloat = 75
            static let hSpacing: CGFloat = 16
        }
        
        struct MentionMe {
            static let spacing: CGFloat = 20
            static let bottomPadding: CGFloat = 34
            static let hPadding: CGFloat = 40.5
        }
    }
    
    @StateObject var viewModel: CheckoutSuccessViewModel
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    var body: some View {
            ScrollView {
                HStack(spacing: Constants.SuccessImage.hSpacing) {
                    Image.CheckoutView.success
                        .resizable()
                        .scaledToFit()
                        .frame(width: Constants.SuccessImage.width)
                    
                    Text(Strings.CheckoutView.Payment.paymentSuccess.localized)
                        .font(.heading2.bold())
                        .foregroundColor(colorPalette.alertSuccess)
                }
                .padding()

                if let basket = viewModel.basket {
                    OrderSummaryCard(container: viewModel.container, order: nil, basket: basket)
                        .padding()
                }
                
                // Only show call store button if a store number is present
                if viewModel.showCallStoreButton {
                    SnappyButton(
                        container: viewModel.container,
                        type: .outline,
                        size: .large,
                        title: GeneralStrings.callStore.localized,
                        largeTextTitle: GeneralStrings.callStoreShort.localized,
                        icon: Image.Icons.Phone.filled) {
                            viewModel.callStoreTapped()
                        }
                        .padding()
                }
                
                VStack(spacing: Constants.HelpStack.spacing) {
                    Text(PaymentStrings.needHelp.localized)
                        .font(.Body1.semiBold())
                        .foregroundColor(colorPalette.typefacePrimary)
                    
                    // For some reason, hyperlinks here only work when using .init with text. This means we have to keep this logic in the view
                    if let phone = viewModel.storeNumber {
                        Text(.init(Strings.CheckoutView.PaymentCustom.callStore.localizedFormat(phone)))
                            .font(.hyperlink1())
                            .frame(width: UIScreen.screenWidth * Constants.HelpStack.textWidthMultiplier)
                            .multilineTextAlignment(.center)
                    } else {
                        Text(.init(Strings.CheckoutView.Payment.getHelp.localized))
                            .font(.hyperlink1())
                            .frame(width: UIScreen.screenWidth * Constants.HelpStack.textWidthMultiplier)
                            .multilineTextAlignment(.center)
                    }
                }
                
                if viewModel.showCreateAccountCard {
                    CreateAccountCard(viewModel: .init(container: viewModel.container))
                        .padding(.bottom, tabViewHeight)
                        .padding(.horizontal)
                }
            }
            .background(colorPalette.backgroundMain)
        .bottomSheet(container: viewModel.container, item: $viewModel.triggerBottomSheet, title: nil, windowSize: mainWindowSize, content: {_ in
            mentionMe
        })
        .sheet(isPresented: $viewModel.showMentionMeWebView) {
            MentionMeWebView(
                viewModel: MentionMeWebViewModel(
                    container: viewModel.container,
                    mentionMeRequestResult: viewModel.mentionMeOfferRequestResult,
                    dismissWebViewHandler: { _ in
                        viewModel.mentionMeWebViewDismissed()
                    }
                )
            )
        }
        .onChange(of: viewModel.webViewURL) { url in
            if let url = url {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        .onChange(of: viewModel.faqURL) { url in
            if let url = url {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        .onDisappear {
            // Clear temp basket
            viewModel.clearSuccessCheckoutBasket()
        }
    }
    
    @ViewBuilder private var mentionMe: some View {
        VStack(spacing: Constants.MentionMe.spacing) {
            VStack {
                Text(viewModel.mentionMeButtonText ?? Strings.MentionMe.Main.referForDiscount.localized)
                    .font(.heading2.bold())
                    .foregroundColor(colorPalette.primaryBlue)
                
                Text(Strings.MentionMe.Main.tellFriends.localized)
                    .font(.Body1.regular())
                    .foregroundColor(colorPalette.primaryBlue)
            }
            
            SnappyButton(
                container: viewModel.container,
                type: .primary,
                size: .large,
                title: Strings.MentionMe.Main.learnHow.localized,
                largeTextTitle: nil,
                icon: nil) {
                    viewModel.showMentionMeOffer()
                }
        }
        .padding(.bottom, Constants.MentionMe.bottomPadding)
        .padding(.top)
        .padding(.horizontal, Constants.MentionMe.hPadding)
    }
    
    func successBanner() -> some View {
        HStack(spacing: Constants.SuccessBanner.spacing) {
            Image.CheckoutView.success
                .resizable()
                .scaledToFit()
                .frame(height: Constants.SuccessBanner.height)
            
            Text(PaymentStrings.paymentSuccess.localized)
                .font(.heading2)
                .foregroundColor(colorPalette.alertSuccess)
                .multilineTextAlignment(.center)
        }
    }
}

#if DEBUG
struct CheckoutSuccessView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutSuccessView(viewModel: .init(container: .preview))
            .environmentObject(CheckoutViewModel(container: .preview))
    }
}
#endif
