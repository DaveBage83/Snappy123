//
//  FulfilmentInfoCard.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 15/02/2022.
//

import SwiftUI

struct FulfilmentInfoCard: View {
    typealias DeliveryStrings = Strings.BasketView.DeliveryBanner
    
    @StateObject var viewModel: FulfilmentInfoCardViewModel
    var isInCheckout: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Image.Checkout.car
                    
                    Text(viewModel.fulfilmentTypeString)
                }
                
                Text(viewModel.fulfilmentTimeString)
                    .bold()
            }
            
            Button(action: { viewModel.showFulfilmentSelectView() }) {
                Text(DeliveryStrings.change.localized)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke()
                            .foregroundColor(.white)
                    )
            }
            
            // Fulfilment slot selection
            NavigationLink("", isActive: $viewModel.isFulfilmentSlotSelectShown) {
                FulfilmentTimeSlotSelectionView(viewModel: .init(container: viewModel.container, isInCheckout: isInCheckout))
            }
            .font(.snappySubheadline)
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .foregroundColor(.black)
            .background(Color.snappyDark)
            .cornerRadius(6)
        }
    }
}

struct DeliveryInfoCard_Previews: PreviewProvider {
    static var previews: some View {
        FulfilmentInfoCard(viewModel: .init(container: .preview), isInCheckout: false)
            .previewLayout(.sizeThatFits)
            .padding()
            .previewCases()
    }
}
