//
//  FulfilmentInfoCard.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 15/02/2022.
//

import SwiftUI

struct FulfilmentInfoCard: View {
    @Environment(\.colorScheme) var colorScheme
    
    struct Constants {
        static let paddingVertical: CGFloat = 6
        static let paddingHorizontal: CGFloat = 10
        static let cornerRadius: CGFloat = 6
        
        struct Logo {
            static let size: CGFloat = 56
            static let cornerRadius: CGFloat = 8
        }
    }
    
    typealias DeliveryStrings = Strings.BasketView.DeliveryBanner
    
    @StateObject var viewModel: FulfilmentInfoCardViewModel
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    private var fulfilmentIcon: Image {
        if viewModel.basket?.fulfilmentMethod.type == .delivery {
            return Image.Icons.Truck.standard
        } else {
            return Image.Icons.BagShopping.standard
        }
    }
    
    var body: some View {
        HStack {
            
            AsyncImage(urlString: viewModel.selectedStore?.storeLogo?[AppV2Constants.API.imageScaleFactor]?.absoluteString, placeholder: {
                Image.Placeholders.productPlaceholder
                    .resizable()
                    .frame(width: Constants.Logo.size, height: Constants.Logo.size)
                    .scaledToFill()
                    .cornerRadius(Constants.Logo.cornerRadius)
            })
            .frame(width: Constants.Logo.size, height: Constants.Logo.size)
            .scaledToFit()
            .cornerRadius(Constants.Logo.cornerRadius)
            
            VStack(alignment: .leading) {
                Text(viewModel.selectedStore?.nameWithAddress1 ?? "")
                    .font(.Body2.semiBold())
                    .foregroundColor(colorPalette.typefacePrimary)
                
                HStack {
                    fulfilmentIcon
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 16)
                        .foregroundColor(colorPalette.primaryBlue)
                    
                    Text(viewModel.fulfilmentTimeString)
                        .font(.Body2.semiBold())
                        .foregroundColor(colorPalette.primaryBlue)
                }
            }
            
//            Button(action: { viewModel.showFulfilmentSelectView() }) {
//                Text(DeliveryStrings.change.localized)
//                    .padding(.vertical, Constants.paddingVertical)
//                    .padding(.horizontal, Constants.paddingHorizontal)
//                    .background(
//                        RoundedRectangle(cornerRadius: Constants.cornerRadius)
//                            .stroke()
//                            .foregroundColor(.white)
//                    )
//            }
            
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
