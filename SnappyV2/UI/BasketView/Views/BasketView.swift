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
                        listCouponEntry(text: coupon.name, amount: "- " + coupon.deductCost.toCurrencyString())
                        Divider()
                    }
                    
                    // Savings
                    if let savings = viewModel.basket?.savings {
                        ForEach(savings, id: \.self) { saving in
                            listEntry(text: saving.name, amount: saving.amount.toCurrencyString())
                            Divider()
                        }
                    }
                    
                    // Sub-total
                    if let subTotal = viewModel.basket?.orderSubtotal {
                        listEntry(text: "Order Sub-Total", amount: subTotal.toCurrencyString())
                        Divider()
                    }
                    
                    // Fees
                    if let fees = viewModel.basket?.fees {
                        ForEach(fees, id: \.self) { fee in
                            listEntry(text: fee.title, amount: fee.amount.toCurrencyString())
                            Divider()
                        }
                    }
                    
                    // Total
                    if let total = viewModel.basket?.orderTotal {
                        orderTotal(totalAmount: total.toCurrencyString())
                        Divider()
                    }
                }
                
                coupon
                
                Button(action: { viewModel.checkOutTapped() }) {
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
    
    @ViewBuilder var coupon: some View {
        // Keyboard submit only on iOS 15 at the moment
        if #available(iOS 15.0, *) {
            TextField("Got a coupon code?", text: $viewModel.couponCode)
                .font(.snappyBody)
                .textFieldStyle(.roundedBorder)
                .padding(.top)
                .submitLabel(.done)
                .onSubmit {
                    viewModel.submitCoupon()
                }
        } else {
            #warning("Add keyboard submit or inline button for iOS 14")
            TextField("Got a coupon code?", text: $viewModel.couponCode)
                .font(.snappyBody)
                .textFieldStyle(.roundedBorder)
                .padding(.top)
        }
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
                
                Text(item.menuItem.price.price.toCurrencyString() + " - \(item.menuItem.name)")
                    .font(.snappyCaption)
                TextField("4", text: $quantity)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.snappyBody)
                    .scaledToFit()
                Text(item.totalPrice.toCurrencyString())
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
    
    func listCouponEntry(text: String, amount: String) -> some View {
        HStack {
            Text(text)
                .font(.snappyCaption)
            Spacer()
            Button(action: { viewModel.removeCoupon() }) {
                Image(systemName: "x.circle")
                    .foregroundColor(.black)
            }
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
