//
//  FulfilmentInfoCard.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 15/02/2022.
//

import SwiftUI

struct FulfilmentInfoCard: View {
    struct Constants {
        static let paddingVertical: CGFloat = 6
        static let paddingHorizontal: CGFloat = 10
        static let cornerRadius: CGFloat = 6
    }
    
    typealias DeliveryStrings = Strings.BasketView.DeliveryBanner
    
    @StateObject var viewModel: FulfilmentInfoCardViewModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Image.Checkout.delivery
                    
                    Text(viewModel.fulfilmentTypeString)
                }
                
                Text(viewModel.fulfilmentTimeString)
                    .bold()
            }
            
            Button(action: { viewModel.showFulfilmentSelectView() }) {
                Text(DeliveryStrings.change.localized)
                    .padding(.vertical, Constants.paddingVertical)
                    .padding(.horizontal, Constants.paddingHorizontal)
                    .background(
                        RoundedRectangle(cornerRadius: Constants.cornerRadius)
                            .stroke()
                            .foregroundColor(.white)
                    )
            }
            
            // Fulfilment slot selection
            NavigationLink("", isActive: $viewModel.isFulfilmentSlotSelectShown) {
                FulfilmentTimeSlotSelectionView(viewModel: .init(container: viewModel.container, isInCheckout: viewModel.isInCheckout))
            }
            .font(.snappySubheadline)
            .padding(.vertical, Constants.paddingVertical)
            .padding(.horizontal, Constants.paddingHorizontal)
            .foregroundColor(.black)
            .background(Color.snappyDark)
            .cornerRadius(Constants.cornerRadius)
        }
    }
}

#if DEBUG
struct DeliveryInfoCard_Previews: PreviewProvider {
    static var previews: some View {
        FulfilmentInfoCard(viewModel: .init(container: .preview))
            .previewLayout(.sizeThatFits)
            .padding()
            .previewCases()
    }
}
#endif
