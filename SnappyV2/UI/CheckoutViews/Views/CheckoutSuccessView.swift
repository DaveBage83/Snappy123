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
    }
    
    @StateObject var viewModel: CheckoutSuccessViewModel
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    var body: some View {
        VStack {
            ScrollView {

                OrderSummaryCard(container: viewModel.container, order: TestPastOrder.order)
                    .padding()
                
                mentionMe
                
                VStack(spacing: Constants.HelpStack.spacing) {
                    Text(PaymentStrings.needHelp.localized)
                        .font(.Body1.semiBold())
                        .foregroundColor(colorPalette.typefacePrimary)
                    
                    Text(PaymentStrings.callDirect.localized)
                        .font(.hyperlink1())
                        .frame(width: UIScreen.screenWidth * Constants.HelpStack.textWidthMultiplier)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: Constants.Button.spacing) {
                    SnappyButton(
                        container: viewModel.container,
                        type: .outline,
                        size: .large,
                        title: GeneralStrings.callStore.localized,
                        largeTextTitle: GeneralStrings.callStoreShort.localized,
                        icon: Image.Icons.Phone.filled) {
                            #warning("Functionality yet to be implemented")
                            print("Call")
                        }
                }
                .padding()
            }
            .background(colorPalette.backgroundMain)
        }.sheet(isPresented: $viewModel.showMentionMeWebView) {
            MentionMeWebView(
                viewModel: MentionMeWebViewModel(
                    container: viewModel.container,
                    mentionMeRequestResult: viewModel.mentionMeOfferRequestResult,
                    dismissWebViewHandler: { _ in
                        viewModel.mentionMeWebViewDismissed()
                    }
                )
            )
        }.onChange(of: viewModel.webViewURL) { url in
            if let url = url {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }

    @ViewBuilder private var mentionMe: some View {
        if viewModel.showMentionMeLoading {
            ProgressView()
        } else if let mentionMeButtonText = viewModel.mentionMeButtonText {
            SnappyButton(
                container: viewModel.container,
                type: .primary,
                size: .large,
                title: mentionMeButtonText,
                largeTextTitle: nil,
                icon: nil) {
                    viewModel.showMentionMeOffer()
                }
        } else {
            EmptyView()
        }
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
