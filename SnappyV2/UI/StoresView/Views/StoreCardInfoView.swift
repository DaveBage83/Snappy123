//
//  StoreCardInfoView.swift
//  SnappyV2Study
//
//  Created by Henrik Gustavii on 14/06/2021.
//

import SwiftUI

struct StoreCardInfoView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject var viewModel: StoreCardInfoViewModel
    
    init(storeDetails: RetailStore) {
        self._viewModel = StateObject(wrappedValue: StoreCardInfoViewModel(storeDetails: storeDetails))
    }
    
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                if let storeLogo = viewModel.storeDetails.storeLogo?["xhdpi_2x"]?.absoluteString {
                    RemoteImage(url: storeLogo) // Temporary: To be removed for more suitable image loading
                        .frame(width: 100, height: 100)
                        .scaledToFit()
                        .cornerRadius(10)
                } else {
                    Image("coop-logo")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .scaledToFit()
                        .cornerRadius(10)
                }
                
                VStack(alignment: .leading) {
                    Text("\(viewModel.storeDetails.storeName)")
                        .font(.snappyBody)
                    
                    HStack(alignment: .top) {
                        VStack(alignment: .leading) {
                            Text("Delivery Time")
                                .font(.snappyCaption)
                                .foregroundColor(.secondary)
                            Text("Unknown delivery time")
                                .font(.snappyBody)
                                .fontWeight(.bold)
                        }
                        Spacer()
                        VStack(alignment: .leading) {
                            Text("From you")
                                .font(.snappyCaption)
                                .foregroundColor(.secondary)
                            Text("\(viewModel.distance) miles")
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
                        .foregroundColor(.snappyHighlight)
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

//struct StoreCardInfoView_Previews: PreviewProvider {
//    static var previews: some View {
//        StoreCardInfoView(storeDetails: StoreCardDetails(name: "Coop", logo: "coop-logo", address: "Newhaven Road", deliveryTime: "20-30 mins", distaceToDeliver: 1.3, deliveryCharge: nil, isNewStore: true))
//            .previewLayout(.sizeThatFits)
//            .padding()
//
//        StoreCardInfoView(storeDetails: StoreCardDetails(name: "Keystore", logo: "keystore-logo", address: "Newhaven Road", deliveryTime: "20-30 mins", distaceToDeliver: 5.4, deliveryCharge: 3.5, isNewStore: true))
//            .preferredColorScheme(.dark)
//            .previewLayout(.sizeThatFits)
//            .padding()
//    }
//}


