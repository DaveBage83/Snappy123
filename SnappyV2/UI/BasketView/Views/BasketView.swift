//
//  BasketView.swift
//  SnappyV2Study
//
//  Created by Henrik Gustavii on 12/07/2021.
//

import SwiftUI

struct BasketView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel = BasketViewModel(container: .preview)
    
    @State var quantity = ""
    @State var couponCode = ""
    
    var body: some View {
        ScrollView {
            VStack {
                deliveryBanner()
                    .padding(.bottom)
                
                LazyVStack {
                    // Items
                    if let items = viewModel.basket?.items {
                    ForEach(items, id: \.self) { item in
                            basketListItem(item: item)
                            Divider()
                        }
                    }
                    
                    // Coupon
                    if let coupon = viewModel.basket?.coupon {
                        listEntry(text: coupon.name, amount: "\(coupon.deductCost)")
                        Divider()
                    }
                    
                    // Savings
                    if let savings = viewModel.basket?.savings {
                        ForEach(savings, id: \.self) { saving in
                            listEntry(text: saving.name, amount: "\(saving.amount)")
                            Divider()
                        }
                    }
                    
                    // Sub-total
                    if let subTotal = viewModel.basket?.orderSubtotal {
                        listEntry(text: "Order Sub-Total", amount: "\(subTotal)")
                        Divider()
                    }
                    
                    // Fees
                    if let fees = viewModel.basket?.fees {
                        ForEach(fees, id: \.self) { fee in
                            listEntry(text: fee.title, amount: "\(fee.amount)")
                            Divider()
                        }
                    }
                    
                    // Total
                    if let total = viewModel.basket?.orderTotal {
                        orderTotal(totalAmount: "\(total)")
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
    
    func basketListItem(item: BasketItem) -> some View {
        VStack {
            HStack {
                if let image = item.menuItem.images?.first?["xhdpi_2x"]?.absoluteString {
                    RemoteImage(url: image)
                        .scaledToFit()
                } else {
                    Image("whiskey")
                        .resizable()
                        .scaledToFit()
                }
                
                Text("\(item.menuItem.price.price) - \(item.menuItem.name)")
                    .font(.snappyCaption)
                TextField("4", text: $quantity)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.snappyBody)
                    .scaledToFit()
                Text("\(item.totalPrice)")
                    .font(.snappyBody)
            }
            .background(
                Rectangle().fill(Color.white).opacity(0.84)
                    .padding([.top, .horizontal], -3)
            )
            .frame(height: 40)
            
//            if false {
//                Text("3 for 2 offer missed - take advantage and don't miss this deal")
//                    .font(.snappyCaption2).bold()
//                    .foregroundColor(.white)
//
//                Spacer()
//            }
        }
        .background(
            RoundedRectangle(cornerRadius: 4)
//                .fill(Bool.random() ? Color.snappyOfferBasket : Color.snappyAmberBasket)
                .padding([.top, .horizontal], -3)
//                .opacity(false ? 1 : 0)
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
        BasketView(viewModel: .init(container: .preview))
//            .padding()
            .previewCases()
    }
}
