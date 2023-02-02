//
//  CheckoutOrderSummaryBanner.swift
//  SnappyV2
//
//  Created by David Bage on 05/07/2022.
//

import SwiftUI

struct CheckoutOrderSummaryBanner: View {
    @Environment(\.colorScheme) var colorScheme
    
    struct Constants {
        static let padding: CGFloat = 5
        static let hSpacing: CGFloat = 5
        
        struct ProgressView {
            static let hPadding: CGFloat = 30
            static let vPadding: CGFloat = 3
        }
    }
    
    @ObservedObject var checkoutRootViewModel: CheckoutRootViewModel

    private var colorPalette: ColorPalette {
        ColorPalette(container: checkoutRootViewModel.container, colorScheme: colorScheme)
    }

    var body: some View {
        VStack {
            Divider()
            
            CheckoutProgressView(viewModel: checkoutRootViewModel)
                .padding(.horizontal, Constants.ProgressView.hPadding)
                .padding(.vertical, Constants.ProgressView.vPadding)
            Divider()
            
            if let orderTotalPriceString = checkoutRootViewModel.orderTotalPriceString {
                HStack {
                    HStack(spacing: Constants.hSpacing) {
                        Text(Strings.CheckoutView.Progress.orderTotal.localized.capitalizingFirstLetterOnly())
                        Text("|")
                        Text(orderTotalPriceString)
                    }
                    
                #warning("Not using this component for now.")
//                    CheckoutSlotExpiryView(viewModel: .init(
//                        container: checkoutRootViewModel.container))
                }
                .font(.button2())
                .foregroundColor(colorPalette.primaryBlue)
                .padding(.horizontal)
                .frame(maxWidth: .infinity)
                Divider()
            }
        }
    }
}

#if DEBUG
struct CheckoutOrderSummaryBanner_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutOrderSummaryBanner(checkoutRootViewModel: .init(container: .preview))
    }
}
#endif
