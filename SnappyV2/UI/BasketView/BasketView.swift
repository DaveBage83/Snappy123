//
//  BasketView.swift
//  SnappyV2Study
//
//  Created by Henrik Gustavii on 12/07/2021.
//

import SwiftUI

class BasketViewModel: ObservableObject {
    @Published var productDetail: RetailStoreMenuItem?
}

struct BasketView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel = BasketViewModel()
    
    let basketItems: [RetailStoreMenuItem]
    
    @State var quantity = ""
    @State var couponCode = ""
    
    var body: some View {
        ScrollView {
            VStack {
                deliveryBanner()
                    .padding(.bottom)
                
                LazyVStack {
                    Group {
                        basketListItem()
                        Divider()
                        basketListItem()
                        Divider()
                        basketListItem()
                        Divider()
                        basketListItem()
                        Divider()
                    }
                    Group {
                        listEntry(text: "Meal Deal Saving", amount: "- £1.50")
                        Divider()
                        listEntry(text: "Order Sub-Total", amount: "£29.95")
                        Divider()
                        listEntry(text: "Delivery Fee", amount: "£2.95")
                        Divider()
                        listEntry(text: "Snappy Service Fee", amount: "£2.50", snappyServiceFee: true)
                        Divider()
                        orderTotal(totalAmount: "£33.90")
                        Divider()
                    }
                }
                
                TextField("Got a coupon code?", text: $couponCode)
                    .font(.snappyBody)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.top)
                
                Button(action: {}) {
                    Text("Checkout")
                        .font(.snappyTitle2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(10)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.snappySuccess)
                        )
                }
                .padding(.vertical)
                
                
            }
            .padding([.top, .leading, .trailing])
            
            ProductCarouselView()
        }
    }
    
    func deliveryBanner() -> some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "car")
                    Text("Delivery")
                    Text("Slot Expires in 45 mins")
                        .font(.snappyCaption2)
                        .fontWeight(.bold)
                        .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                        .background(Capsule().fill(Color.snappyRed))
                }
                
                Text("12 March | 17:30 - 18:25").bold()
            }
            
            Button(action: {}) {
                Text("Change")
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke()
                            .foregroundColor(.white)
                    )
            }
        }
        .font(.snappySubheadline)
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .foregroundColor(.white)
        .background(Color.snappyDark)
        .cornerRadius(6)
    }
    
    func basketListItem(offer: Bool = Bool.random()) -> some View {
        VStack {
            HStack {
                Image("whiskey2")
                    .resizable()
                    .scaledToFit()
                Text("£24.90 - Some whiskey or other that possibly is not Scottish")
                    .font(.snappyCaption)
                TextField("4", text: $quantity)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.snappyBody)
                    .scaledToFit()
                Text("£24.99")
                    .font(.snappyBody)
            }
            
            .background(
                Rectangle().fill(Color.white).opacity(0.84)
                    .padding([.top, .horizontal], -3)
            )
            .frame(height: 40)
            
            if offer {
                Text("3 for 2 offer missed - take advantage and don't miss this deal")
                    .font(.snappyCaption2).bold()
                    .foregroundColor(.white)
                
                Spacer()
            }
            
        }
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(Bool.random() ? Color.snappyOfferBasket : Color.snappyAmberBasket)
                .padding([.top, .horizontal], -3)
                .opacity(offer ? 1 : 0)
        )
        
    }
    
    func listEntry(text: String, amount: String, snappyServiceFee: Bool = false) -> some View {
        HStack {
            Text(text)
                .font(.snappyCaption)
            if snappyServiceFee {
                Image(systemName: "info.circle")
            }
            Spacer()
            Text("\(amount)").bold()
                .font(.snappyCaption)
        }
    }
    
    func orderTotal(totalAmount: String) -> some View {
        HStack {
            Text("Order Total")
                .font(.snappyCaption)
                .fontWeight(.heavy)
            Spacer()
            Text("\(totalAmount)").bold()
                .font(.snappyCaption)
                .fontWeight(.heavy)
            
        }

    }
}

struct BasketView_Previews: PreviewProvider {
    static var previews: some View {
        let price = RetailStoreMenuItemPrice(price: 20.90, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: 20.90)
        BasketView(basketItems: [RetailStoreMenuItem(id: 123, name: "Some whiskey or other that possibly is not Scottish", eposCode: nil, outOfStock: false, ageRestriction: 18, description: nil, quickAdd: true, price: price, images: nil, menuItemSizes: nil, menuItemOptions: nil)])
            .previewLayout(.sizeThatFits)
//            .padding()
            .previewCases()
    }
}
