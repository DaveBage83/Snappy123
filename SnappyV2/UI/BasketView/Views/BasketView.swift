//
//  BasketView.swift
//  SnappyV2Study
//
//  Created by Henrik Gustavii on 12/07/2021.
//

import SwiftUI

struct BasketView: View {
    typealias DeliveryStrings = Strings.BasketView.DeliveryBanner
    typealias CouponStrings = Strings.BasketView.Coupon
    
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: BasketViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    FulfilmentInfoCard(viewModel: .init(container: viewModel.container))
                        .padding(.bottom)
                    
                    if viewModel.showBasketItems {
                        basketItems()
                    }
                    
                    coupon()
                    
                    #warning("Reinstate one button once member sign in is handled elsewhere")
                    Button(action: { viewModel.checkoutTapped() }) {
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
                    
                    
                    // MARK: NavigationLinks
                    NavigationLink("", isActive: $viewModel.isContinueToCheckoutTapped) {
                        navigationDestination()
                    }
                }
                .padding([.top, .leading, .trailing])
                .alert(isPresented: $viewModel.showCouponAlert) {
                    Alert(
                        title: Text(CouponStrings.alertTitle.localized),
                        message: Text(CouponStrings.alertMessage.localized),
                        primaryButton:
                                .default(Text(CouponStrings.alertApply.localized), action: { Task { await viewModel.submitCoupon() } }),
                        secondaryButton:
                                .destructive(Text(CouponStrings.alertRemove.localized), action: { viewModel.clearCouponAndContinue() })
                    )
                }
                
                ProductCarouselView()
            }
        }
        .navigationViewStyle(.stack)
    }
    
    @ViewBuilder func navigationDestination() -> some View {
        if viewModel.isMemberSignedIn {
            CheckoutDetailsView(container: viewModel.container)
        } else {
            CheckoutView(viewModel: .init(container: viewModel.container))
        }
    }
    
    func basketItems() -> some View {
        LazyVStack {
            // Items
            if let items = viewModel.basket?.items {
                ForEach(items, id: \.self) { item in
                    
                    BasketListItemView(viewModel: .init(container: viewModel.container, item: item) { itemId, newQuantity, basketLineId in
                        Task {
                            await viewModel.updateBasketItem(itemId: itemId ,quantity: newQuantity, basketLineId: basketLineId)
                        }
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
            
            // Driver tips
            if viewModel.showDriverTips {
                driverTipListEntry(text: Strings.BasketView.drivertips.localized, amount: viewModel.driverTip.toCurrencyString())
                
                Divider()
            }
            
            // Total
            if let total = viewModel.basket?.orderTotal {
                orderTotal(totalAmount: total.toCurrencyString())
                
                Divider()
            }
        }
    }
    
    @ViewBuilder func coupon() -> some View {
        ZStack {
            TextField(Strings.BasketView.Coupon.code.localized, text: $viewModel.couponCode)
                .font(.snappyBody)
                .textFieldStyle(.roundedBorder)
            
            HStack {
                Spacer()
                Button(action: { Task { await viewModel.submitCoupon() } }) {
                    Text("Add")
                }
                .buttonStyle(SnappyPrimaryButtonStyle())
                .padding(.trailing, 6)
            }
            
        }
        .padding(.top)
        
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
                    Alert(title: Text(Strings.BasketView.ListEntry.chargeInfo.localized),
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
    
    func driverTipListEntry(text: String, amount: String) -> some View {
        HStack {
            Text(text)
                .font(.snappyCaption)
            
            Spacer()
            
            DriverTipsButton(viewModel: viewModel, size: .standard)
            
            Text(amount)
                .font(.snappyCaption)
        }
    }
    
    func listCouponEntry(text: String, amount: String) -> some View {
        HStack {
            Text(text)
                .font(.snappyCaption)
            
            Spacer()
            
            Button(action: { Task { await viewModel.removeCoupon() } }) {
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

extension BasketViewModel.TipLevel {
    var image: Image {
        switch self {
        case .unhappy:
            return Image.Icons.Tips.level1
        case .neutral:
            return Image.Icons.Tips.level2
        case .happy:
            return Image.Icons.Tips.level3
        case .veryHappy:
            return Image.Icons.Tips.level4
        case .insanelyHappy:
            return Image.Icons.Tips.level5
        }
    }
}

struct BasketView_Previews: PreviewProvider {
    static var previews: some View {
        BasketView(viewModel: .init(container: .preview))
            .previewCases()
    }
}
