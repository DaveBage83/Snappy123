//
//  CheckoutSuccessView.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 28/01/2022.
//

import SwiftUI

class CheckoutSuccessViewModel: ObservableObject {
    let container: DIContainer
    
    init(container: DIContainer) {
        self.container = container
    }
}

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
            CheckoutProgressView(viewModel: .init(container: viewModel.container, progressState: .completeSuccess))
                .padding(.horizontal, Constants.Main.hPadding)

            ScrollView {
                successBanner()
                    .padding([.top, .leading, .trailing])

                OrderSummaryCard(container: viewModel.container, order: TestPastOrder.order)
                    .padding()
                
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
            .dismissableNavBar(
                presentation: nil,
                color: colorPalette.typefacePrimary,
                title: PaymentStrings.secureCheckout.localized)
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
