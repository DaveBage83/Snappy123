//
//  CheckoutSuccessView.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 28/01/2022.
//

import SwiftUI
import UIKit
import StoreKit

struct CheckoutSuccessView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.mainWindowSize) var mainWindowSize
    @Environment(\.tabViewHeight) var tabViewHeight
    
    typealias PaymentStrings = Strings.CheckoutView.Payment
    
    struct Constants {
        struct HelpStack {
            static let spacing: CGFloat = 16
            static let textWidthMultiplier: CGFloat = 0.7
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
                    Text(.init(Strings.CheckoutView.PaymentCustom.callStore.localizedFormat(phone, AppV2Constants.Business.faqURL)))
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
                CreateAccountCard(viewModel: .init(container: viewModel.container, isInCheckout: true))
                    .padding(.bottom, tabViewHeight)
                    .padding(.horizontal)
            }
        }
        .background(colorPalette.backgroundMain)
        .snappyBottomSheet(container: viewModel.container, item: $viewModel.triggerBottomSheet, windowSize: mainWindowSize, content: {_ in
            ToastableViewContainer(content: {
                mentionMe
            }, viewModel: .init(container: viewModel.container, isModal: true))
        })
        .snappySheet(container: viewModel.container, isPresented: $viewModel.showMentionMeWebView,
                     sheetContent: MentionMeWebView(
                        viewModel: MentionMeWebViewModel(
                            container: viewModel.container,
                            mentionMeRequestResult: viewModel.mentionMeOfferRequestResult,
                            dismissWebViewHandler: { _ in
                                viewModel.mentionMeWebViewDismissed()
                            }
                        )
                     ))
        .onChange(of: viewModel.webViewURL) { url in
            if let url = url {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        .onChange(of: viewModel.faqURL) { url in
            if let url = url {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }.onChange(of: viewModel.appStoreReviewScene) { appStoreReviewScene in
            if let appStoreReviewScene = appStoreReviewScene {
                // Show review dialog - this will not neccessarily show the App Store review prompt
                // as Apple has additional logic to prevent users being spammed with prompts. Apple
                // also does not allow developers to determine whether the prompt was shown or ratings
                // left because they do not want developers to have different behaviour towards
                // user leaving or not leaving reviews
                guaranteeMainThread {
                    SKStoreReviewController.requestReview(in: appStoreReviewScene)
                }
            }
        }
        .onChange(of: viewModel.storeNumberURL) { url in
            if let url = url {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        .onDisappear {
            // Clear temp basket
            viewModel.clearSuccessCheckoutBasket()
        }
        .alert(isPresented: $viewModel.showOSUpdateAlert) {
            Alert(title: Text(Strings.VersionUpateAlert.title.localized), message: Text(viewModel.osUpdateText), dismissButton: .default(Text(GeneralStrings.understood.localized)))
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
}

#if DEBUG
struct CheckoutSuccessView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutSuccessView(viewModel: .init(container: .preview))
    }
}
#endif
