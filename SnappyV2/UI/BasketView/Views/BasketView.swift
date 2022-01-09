//
//  BasketView.swift
//  SnappyV2Study
//
//  Created by Henrik Gustavii on 12/07/2021.
//

import SwiftUI

struct BasketView: View {
    typealias DeliveryStrings = Strings.BasketView.DeliveryBanner
    
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: BasketViewModel
    
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
                            BasketListItemView(viewModel: .init(item: item) { itemId, newQuantity, basketLineId in
                                viewModel.updateBasketItem(itemId: itemId ,quantity: newQuantity, basketLineId: basketLineId)
                            })
                            .redacted(reason: viewModel.isUpdatingItem ? .placeholder : [])
                            
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
                            listEntry(text: saving.name, amount: saving.amount.toCurrencyString(), feeDescription: nil)
                            
                            Divider()
                        }
                    }
                    
                    // Sub-total
                    if let subTotal = viewModel.basket?.orderSubtotal {
                        listEntry(text: Strings.BasketView.subtotal.localized, amount: subTotal.toCurrencyString(), feeDescription: nil)
                        
                        Divider()
                    }
                    
                    // Fees
                    if let fees = viewModel.basket?.fees {
                        ForEach(fees, id: \.self) { fee in
                            listEntry(text: fee.title, amount: fee.amount.toCurrencyString(), feeDescription: fee.description)
                            
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
                    Text(Strings.BasketView.checkout.localized)
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
                    Image.Checkout.car
                    
                    Text(GeneralStrings.delivery.localized)
                    
                    #warning("Replace expiry time with actual expiry time")
                    Text(DeliveryStrings.Customisable.expires.localizedFormat("45"))
                        .font(.snappyCaption2)
                        .fontWeight(.bold)
                        .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                        .background(Capsule().fill(Color.snappyRed))
                }
                
                Text(DeliveryStrings.Customisable.deliverySlot.localizedFormat("12 March", "17:30", "18:25"))
                    .bold()
            }
            
            Button(action: {}) {
                Text(DeliveryStrings.change.localized)
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
            TextField(Strings.BasketView.Coupon.code.localized, text: $viewModel.couponCode)
                .font(.snappyBody)
                .textFieldStyle(.roundedBorder)
                .padding(.top)
                .submitLabel(.done)
                .onSubmit {
                    viewModel.submitCoupon()
                }
        } else {
            #warning("Add keyboard submit or inline button for iOS 14")
            TextField(Strings.BasketView.Coupon.code.localized, text: $viewModel.couponCode)
                .font(.snappyBody)
                .textFieldStyle(.roundedBorder)
                .padding(.top)
        }
        
        if viewModel.couponAppliedSuccessfully || viewModel.couponAppliedUnsuccessfully {
            HStack {
                Spacer()
                
                Text(viewModel.couponAppliedUnsuccessfully ? Strings.BasketView.Coupon.failure.localized : Strings.BasketView.Coupon.success.localized)
                    .font(.snappyCaption)
                    .fontWeight(.semibold)
                    .foregroundColor(viewModel.couponAppliedUnsuccessfully ? .snappyRed : .snappySuccess)
                
                Spacer()
            }
            .background(viewModel.couponAppliedUnsuccessfully ? Color.snappyRed.opacity(0.2) : Color.snappySuccess.opacity(0.2))
            .animation(.easeOut)
            .transition(AnyTransition.move(edge: .top))
            .padding(.top, -8)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation {
                        self.viewModel.couponAppliedSuccessfully = false
                        self.viewModel.couponAppliedUnsuccessfully = false
                    }
                }
            }
        }
    }
    
    func listEntry(text: String, amount: String, feeDescription: String?) -> some View {
        HStack {
            Text(text)
                .font(.snappyCaption)
            if let description = feeDescription {
                Button(action: { viewModel.showServiceFeeAlert() }) {
                    Image.General.Info.circle
                        .foregroundColor(.black)
                }
                .alert(isPresented: $viewModel.showingServiceFeeAlert) {
                    #warning("Add localised alert labels")
                    return Alert(title: Text(Strings.BasketView.ListEntry.changeInfo.localized),
                                 message: Text(description),
                                 dismissButton: .default(Text(Strings.BasketView.ListEntry.gotIt.localized),
                                                         action: { viewModel.dismissAlert()}))
                }
            }
            
            Spacer()
            
            Text(amount)
                .font(.snappyCaption)
        }
    }
    
    func listCouponEntry(text: String, amount: String) -> some View {
        HStack {
            Text(text)
                .font(.snappyCaption)
            
            Spacer()
            
            Button(action: { viewModel.removeCoupon() }) {
                Image.Actions.Close.xCircle
                    .foregroundColor(.black)
            }
            
            Text("\(amount)")
                .font(.snappyCaption)
        }
        .background(Color.snappySuccess.opacity(0.2))
    }
    
    func orderTotal(totalAmount: String) -> some View {
        HStack {
            Text(Strings.BasketView.total.localized)
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
