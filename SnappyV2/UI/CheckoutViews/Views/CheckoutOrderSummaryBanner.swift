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
    
    let container: DIContainer
    let orderTotal: Double?
    
    // If progressState is included, we show the progress bar
    @Binding var progressState: CheckoutProgressViewModel.ProgressState
        
    init(container: DIContainer, orderTotal: Double?, progressState: Binding<CheckoutProgressViewModel.ProgressState> = .constant(.notStarted)) {
        self.container = container
        self.orderTotal = orderTotal
        
        self._progressState = progressState
    }
    
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: container, colorScheme: colorScheme)
    }

    var body: some View {
        VStack {
            Divider()

            if let progressState = progressState {
                CheckoutProgressView(viewModel: .init(container: container, progressState: progressState))
                    .padding(.horizontal, Constants.ProgressView.hPadding)
                    .padding(.vertical, Constants.ProgressView.vPadding)
                Divider()
            }
            
            if let orderTotal = orderTotal {
                HStack(spacing: Constants.hSpacing) {
                    Text(Strings.CheckoutView.Progress.orderTotal.localized.capitalizingFirstLetterOnly())
                    Text("|")
                    Text(orderTotal.toCurrencyString())
                }
                .font(.button2())
                .foregroundColor(colorPalette.primaryBlue)
                .padding(Constants.padding)
                .frame(maxWidth: .infinity)
                Divider()
            }
        }
    }
}

struct CheckoutOrderSummaryBanner_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutOrderSummaryBanner(container: .preview, orderTotal: 11.2, progressState: .constant(.payment))
    }
}
