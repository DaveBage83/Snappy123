//
//  StoreCardInfoView.swift
//  SnappyV2Study
//
//  Created by Henrik Gustavii on 14/06/2021.
//

import SwiftUI

struct StoreCardInfoView: View {
    typealias DeliveryStrings = Strings.StoreInfo.Delivery
    
    struct Constants {
        struct StoreLogo {
            static let size: CGFloat = 100
            static let cornerRadius: CGFloat = 10
        }
    }
    
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject var viewModel: StoreCardInfoViewModel
    
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                if let storeLogo = viewModel.storeDetails.storeLogo?[AppV2Constants.API.imageScaleFactor]?.absoluteString,
                let imageURL = URL(string: storeLogo) {
                    AsyncImage(url: imageURL, placeholder: {
                        Image.Placeholders.productPlaceholder
                            .resizable()
                            .frame(width: Constants.StoreLogo.size, height: Constants.StoreLogo.size)
                            .scaledToFit()
                            .cornerRadius(Constants.StoreLogo.cornerRadius)
                    })
                    .frame(width: Constants.StoreLogo.size, height: Constants.StoreLogo.size)
                    .scaledToFit()
                    .cornerRadius(Constants.StoreLogo.cornerRadius)
                    
                } else {
                    Image.Placeholders.productPlaceholder
                        .resizable()
                        .frame(width: Constants.StoreLogo.size, height: Constants.StoreLogo.size)
                        .scaledToFit()
                        .cornerRadius(Constants.StoreLogo.cornerRadius)
                }
                
                
                VStack(alignment: .leading) {
                    Text(viewModel.storeDetails.storeName)
                        .font(.snappyBody)
                    
                    HStack(alignment: .top) {
                        VStack(alignment: .leading) {
                            Text(GeneralStrings.deliveryTime.localized)
                                .font(.snappyCaption)
                                .foregroundColor(.secondary)
                            
                            Text(viewModel.storeDetails.orderMethods?["delivery"]?.earliestTime ?? "-")
                                .font(.snappyBody)
                                .fontWeight(.bold)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .leading) {
                            Text(DeliveryStrings.fromYou.localized)
                                .font(.snappyCaption)
                                .foregroundColor(.secondary)
                            
                            Text(DeliveryStrings.Customisable.distance.localizedFormat(viewModel.distance))
                                .font(.snappyBody)
                                .fontWeight(.bold)
                        }
                        
                    }
                    .font(.snappyFootnote)
                    .padding(.bottom, 1)
                    .padding(.top, 1)
                    
                    Text(viewModel.deliveryChargeString)
                        .font(.snappyFootnote)
                        .fontWeight(.bold)
                        .foregroundColor(.snappyBlue)
                }
                
            }
            .padding()
            .cornerRadius(15)
        }
        .frame(width: 350)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(colorScheme == .dark ? Color.black : Color.white)
                .shadow(color: .gray, radius: 2)
                .padding(4)
        )
//        .overlay(
//            VStack {
//                HStack {
//                    if viewModel.storeDetails.isNewStore {
//                        Text("New Store")
//                            .font(.snappyCaption)
//                            .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
//                            .foregroundColor(.white)
//                            .background(Capsule().fill(Color.snappyHighlight))
//                            .offset(x: 4, y: 4)
//                    }
//                    Spacer()
//                }
//                Spacer()
//            }
//        )
    }
}

struct StoreCardInfoView_Previews: PreviewProvider {
    static var previews: some View {
        StoreCardInfoView(viewModel: StoreCardInfoViewModel(container: .preview, storeDetails: RetailStore(id: 123, storeName: "Coop", distance: 1.4, storeLogo: nil, storeProductTypes: nil, orderMethods: ["delivery": RetailStoreOrderMethod.init(name: .delivery, earliestTime: "20-30 mins", status: .open, cost: nil, fulfilmentIn: nil)], ratings: nil)))
            .previewLayout(.sizeThatFits)
            .padding()
        
        StoreCardInfoView(viewModel: StoreCardInfoViewModel(container: .preview, storeDetails: RetailStore(id: 123, storeName: "Keystore", distance: 5.4, storeLogo: nil, storeProductTypes: nil, orderMethods: ["delivery": RetailStoreOrderMethod.init(name: .delivery, earliestTime: "20-30 mins", status: .open, cost: 3.5, fulfilmentIn: nil)], ratings: nil)))
            .previewLayout(.sizeThatFits)
            .padding()
        
        StoreCardInfoView(viewModel: StoreCardInfoViewModel(container: .preview, storeDetails: RetailStore(id: 123, storeName: "Coop", distance: 1.4, storeLogo: nil, storeProductTypes: nil, orderMethods: ["delivery": RetailStoreOrderMethod.init(name: .delivery, earliestTime: "20-30 mins", status: .open, cost: nil, fulfilmentIn: nil)], ratings: nil)))
            .previewLayout(.sizeThatFits)
            .padding()
        
        StoreCardInfoView(viewModel: StoreCardInfoViewModel(container: .preview, storeDetails: RetailStore(id: 123, storeName: "Keystore", distance: 5.4, storeLogo: nil, storeProductTypes: nil, orderMethods: ["delivery": RetailStoreOrderMethod.init(name: .delivery, earliestTime: "20-30 mins", status: .open, cost: 3.5, fulfilmentIn: nil)], ratings: nil)))
            .previewLayout(.sizeThatFits)
            .padding()
    }
}


