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
    
    @StateObject var viewModel: CheckoutSuccessViewModel
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    var body: some View {
        VStack {
            CheckoutProgressView(viewModel: .init(container: viewModel.container, progressState: .completeSuccess))
                .padding(.horizontal, 30)

            ScrollView {
                successBanner()
                    .padding([.top, .leading, .trailing])

                OrderSummaryCard(container: viewModel.container, order: TestPastOrder.order)
                    .padding()
                
                VStack(spacing: 16) {
                    Text("Need help with your order?")
                        .font(.Body1.semiBold())
                        .foregroundColor(colorPalette.typefacePrimary)
                    
                    Text("Call the store direct or check out our FAQs section for more information.")
                        .font(.hyperlink1())
                        .frame(width: UIScreen.screenWidth * 0.7)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 16) {
                    SnappyButton(
                        container: viewModel.container,
                        type: .outline,
                        size: .large,
                        title: "Call store",
                        largeTextTitle: "Call",
                        icon: Image.Icons.Phone.filled) {
                            print("Call")
                        }
                }
                .padding()
            }
            .background(colorPalette.backgroundMain)
            .dismissableNavBar(
                presentation: nil,
                color: colorPalette.typefacePrimary,
                title: "Secure Checkout")
        }
    }

    
    func successBanner() -> some View {
        HStack(spacing: 16) {
            Image.CheckoutView.success
                .resizable()
                .scaledToFit()
                .frame(height: 75)
            
            Text("Your order is successful")
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
