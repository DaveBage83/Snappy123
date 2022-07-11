//
//  CheckoutFulfilmentInfoView.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 28/01/2022.
//

import SwiftUI

struct CheckoutFulfilmentInfoView: View {
    @Environment(\.colorScheme) var colorScheme
    
    struct Constants {
        static let cornerRadius: CGFloat = 6
        static let progressViewScale: Double = 2
        static let vSpacing: CGFloat = 16
        static let vPadding: CGFloat = 24
    }
    
    typealias DeliveryStrings = Strings.BasketView.DeliveryBanner
    typealias CheckoutStrings = Strings.CheckoutView
    
    @StateObject var viewModel:  CheckoutFulfilmentInfoViewModel
    @ObservedObject var checkoutRootViewModel: CheckoutRootViewModel
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    var body: some View {
        ScrollView {
            VStack {
                VStack(spacing: Constants.vSpacing) {
                    if viewModel.showPayByCard {
                        Button(action: {
                            checkoutRootViewModel.payByCardTapped()
                        }) {
                            PaymentCard(container: viewModel.container, paymentMethod: .card)
                        }
                    }
                    
                    if viewModel.showPayByApple {
                        Button(action: { viewModel.payByAppleTapped() }) {
                            PaymentCard(container: viewModel.container, paymentMethod: .apple)
                        }
                    }
                    
                    if viewModel.showPayByCash {
                        Button(action: { Task { await viewModel.payByCashTapped() }}) {
                            PaymentCard(container: viewModel.container, paymentMethod: .cash)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, Constants.vPadding)
            }
            .background(colorPalette.secondaryWhite)
            .standardCardFormat()
            .padding()
        }
        .background(colorPalette.backgroundMain)
    }
}

#if DEBUG
struct CheckoutDeliveryAddressView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutFulfilmentInfoView(viewModel: .init(container: .preview), checkoutRootViewModel: .init(container: .preview))
            .environmentObject(CheckoutViewModel(container: .preview))
    }
}
#endif
