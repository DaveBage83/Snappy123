//
//  BasketView.swift
//  SnappyV2Study
//
//  Created by Henrik Gustavii on 12/07/2021.
//

import SwiftUI

struct BasketView: View {
    // MARK: - Typealiases
    typealias CouponStrings = Strings.BasketView.Coupon
    typealias BasketViewStrings = Strings.BasketView
    @Environment(\.mainWindowSize) var mainWindowSize

    // MARK: - Environment
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.tabViewHeight) var tabViewHeight
    
    private struct Constants {
        struct MinSpendWarning {
            static let spacing: CGFloat = 16
            static let iconHeight: CGFloat = 16
            static let fontPadding: CGFloat = 12
            static let lineLimit = 5
        }
        
        struct VerifiedAccountRequiredWarning {
            static let iconHeight: CGFloat = 16
            static let fontPadding: CGFloat = 12
            static let lineLimit = 5
        }
        
        struct MainButtonStack {
            static let spacing: CGFloat = 16
        }
        
        struct EmptyBasketView {
            static let bottomPadding: CGFloat = 56
        }
        
        struct BasketItems {
            static let spacing: CGFloat = 16
            static let bottomPadding: CGFloat = 24
        }
        
        struct ListEntry {
            static let maxPadding: CGFloat = 8
        }
        
        struct SubItemStack {
            static let spacing: CGFloat = 32
        }
        
        struct DeliveryBanner {
            static let widthAdjustment: CGFloat = 16
        }
        
        struct MentionMe {
            static let bottomPadding: CGFloat = 20
        }
    }
    
    // MARK: - View model
    @StateObject var viewModel: BasketViewModel
    
    // MARK: - Computed
    private var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    // MARK: - Main view
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                VStack(spacing: 0) {
                    
                    Divider()
                    
                    if viewModel.basketIsEmpty {
                        emptyBasket
                            .padding([.top, .horizontal])
                            .padding(.bottom, tabViewHeight)
                            .navigationTitle(BasketViewStrings.title.localized)
                            .navigationBarTitleDisplayMode(.inline)
                            .background(colorPalette.backgroundMain)
                    } else {
                        ScrollView(showsIndicators: false) {
                            VStack {
                                FulfilmentInfoCard(viewModel: .init(container: viewModel.container))
                                    .padding(.bottom)
                                
                                if viewModel.showBasketItems {
                                    basketItems()
                                        .padding(.bottom, Constants.BasketItems.bottomPadding)
                                }
                                
                                if viewModel.basketIsEmpty {
                                    Text(BasketViewStrings.noItems.localized)
                                        .font(.Body1.semiBold())
                                        .foregroundColor(colorPalette.typefacePrimary)
                                }
                                
                                VStack(spacing: Constants.SubItemStack.spacing) {
                                    minSpendWarning
                                    
                                    verifiedAccountRequiredWarning
                                    
                                    couponInput
                                    
                                    mentionMe
                                        .padding(.bottom, Constants.MentionMe.bottomPadding)
                                }
                            }
                            .padding([.top, .leading, .trailing])
                            .frame(maxHeight: .infinity)
                            .onAppear {
                                viewModel.onBasketViewSendEvent()
                            }
                            .padding(.bottom, tabViewHeight)
                            .padding(.bottom)
                        }
                        .background(colorPalette.backgroundMain)
                        .navigationTitle(BasketViewStrings.title.localized)
                        .navigationBarTitleDisplayMode(.inline)
                        Text("")
                            .alert(isPresented: $viewModel.showCouponAlert) {
                                Alert(
                                    title: Text(CouponStrings.alertTitle.localized),
                                    message: Text(CouponStrings.alertMessage.localized),
                                    primaryButton:
                                            .default(Text(CouponStrings.alertApply.localized), action: { Task { await viewModel.submitCoupon() } }),
                                    secondaryButton:
                                            .destructive(Text(CouponStrings.alertRemove.localized), action: { Task { await viewModel.clearCouponAndContinue() } })
                                )
                            }
                    }
                    // MARK: NavigationLinks
                    // There is a bug in iOS < 15 whereby when there are exactly 2 NavigationLinks in any given view, the link
                    // will pop back automatically when presented. As a workaround, we need to add an empty link in. This does
                    // produce a console warning "Unable to present. Please file a bug.".
                    if #available(iOS 15.0, *) {
                        NavigationLink("", isActive: $viewModel.isContinueToCheckoutTapped) {
                            CheckoutRootView(viewModel: .init(container: viewModel.container), dismissCheckoutRootView: {
                                viewModel.dismissView()
                            })
                        }
                    } else {
                        NavigationLink("", isActive: $viewModel.isContinueToCheckoutTapped) {
                            CheckoutRootView(viewModel: .init(container: viewModel.container), dismissCheckoutRootView: {
                                viewModel.dismissView()
                            })
                        }
                        
                        NavigationLink(destination: EmptyView(), label: {})
                    }
                }
                .background(colorPalette.backgroundMain)

                mainButton
                    .padding(.horizontal)
                    .background(colorPalette.backgroundMain.withOpacity(.eighty))
            }
            .edgesIgnoringSafeArea(.bottom)
        }
        .snappySheet(container: viewModel.container, isPresented: $viewModel.showMentionMeWebView,
                     sheetContent: MentionMeWebView(
                        viewModel: MentionMeWebViewModel(
                            container: viewModel.container,
                            mentionMeRequestResult: viewModel.mentionMeRefereeRequestResult,
                            dismissWebViewHandler: { couponAction in
                                viewModel.mentionMeWebViewDismissed(with: couponAction)
                            }
                        )
                     ))
        .navigationViewStyle(.stack)
    }
    
    @ViewBuilder private var minSpendWarning: some View {
        if viewModel.minimumSpendReached == false {
            HStack(alignment: .top, spacing: Constants.MinSpendWarning.spacing) {
                Text(BasketViewStrings.subtotalShort.localized)
                    .font(.subheadline.bold()) +
                Text(BasketViewStrings.notReached.localized) +
                Text(BasketViewStrings.minSpend.localized)
                    .font(.subheadline.bold()) +
                Text(BasketViewStrings.valueOf.localized) +
                Text(" " + viewModel.fulfilmentMethodMinSpendPriceString)
                    .font(.subheadline.bold()) +
                Text(BasketViewStrings.proceed.localized)
                
                Image.Icons.Triangle.filled
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: Constants.MinSpendWarning.iconHeight)
                    .foregroundColor(colorPalette.primaryRed)
            }
            .fixedSize(horizontal: false, vertical: true)
            .lineLimit(Constants.MinSpendWarning.lineLimit)
            .font(.subheadline)
            .foregroundColor(colorPalette.primaryRed)
            .padding(Constants.MinSpendWarning.fontPadding)
            .background(colorPalette.secondaryWhite)
            .standardCardFormat()
        }
    }
    
    @ViewBuilder private var verifiedAccountRequiredWarning: some View {
        if let verifiedAccountRequired = viewModel.unmetCouponMemberAccountRequirement {
            HStack(alignment: .top, spacing: Constants.MinSpendWarning.spacing) {
                Text(verifiedAccountRequired.localizedDescription)
                
                Image.Icons.Triangle.filled
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: Constants.VerifiedAccountRequiredWarning.iconHeight)
                    .foregroundColor(colorPalette.primaryRed)
            }
            .fixedSize(horizontal: false, vertical: true)
            .lineLimit(Constants.VerifiedAccountRequiredWarning.lineLimit)
            .font(.subheadline)
            .foregroundColor(colorPalette.primaryRed)
            .padding(Constants.VerifiedAccountRequiredWarning.fontPadding)
            .background(colorPalette.secondaryWhite)
            .standardCardFormat()
        }
    }
    
    @ViewBuilder private var mentionMe: some View {
        if viewModel.showMentionMeLoading {
            ProgressView()
        } else if let mentionMeButtonText = viewModel.mentionMeButtonText {
            Button {
                viewModel.showMentionMeReferral()
            } label: {
                Text(mentionMeButtonText)
                    .underline()
                    .font(.hyperlink1())
                    .foregroundColor(colorPalette.primaryBlue)
            }
        } else {
            EmptyView()
        }
    }
    
    private var couponInput: some View {
        SnappyTextFieldWithButton(
            container: viewModel.container,
            text: $viewModel.couponCode,
            hasError: .constant(viewModel.couponFieldHasError),
            isLoading: $viewModel.applyingCoupon,
            showInvalidFieldWarning: .constant(false),
            labelText: BasketViewStrings.Coupon.codeTitle.localized,
            largeLabelText: nil,
            warningText: nil,
            keyboardType: nil,
            mainButton: (BasketViewStrings.Coupon.alertApplyShort.localized, {
                Task {
                    await viewModel.submitCoupon()
                }
            }))
    }
    
    @ViewBuilder private var mainButton: some View {
        HStack(spacing: Constants.MainButtonStack.spacing) {
            SnappyButton(
                container: viewModel.container,
                type: viewModel.basketIsEmpty ? .primary : .outline,
                size: .large,
                title: viewModel.shopButtonText,
                largeTextTitle: nil,
                icon: nil) {
                    viewModel.startShoppingPressed()
                }
            
            if viewModel.showCheckoutButton {
                SnappyButton(
                    container: viewModel.container,
                    type: .success,
                    size: .large,
                    title: Strings.BasketView.checkout.localized,
                    largeTextTitle: nil,
                    icon: nil) {
                        Task {
                            await viewModel.checkoutTapped()
                        }
                    }
            }
        }
        .padding(.bottom, tabViewHeight)
        .padding(.top)
    }

    private var emptyBasket: some View {
        VStack {
            FulfilmentInfoCard(viewModel: .init(container: viewModel.container))
                .padding(.bottom, Constants.EmptyBasketView.bottomPadding)
            
            Text(BasketViewStrings.noItems.localized)
                .font(.Body1.semiBold())
                .foregroundColor(colorPalette.typefacePrimary)
            
            Spacer()            
        }
    }
    
    private func basketItems() -> some View {
        LazyVStack {
            // Items
            if let items = viewModel.basket?.items {
                VStack(spacing: Constants.BasketItems.spacing) {
                    ForEach(items, id: \.basketLineId) { item in
                        BasketListItemView(viewModel: .init(container: viewModel.container, item: item) { basketItem, newQuantity in
                            Task {
                                await viewModel.updateBasketItem(basketItem: basketItem, quantity: newQuantity)
                            }
                        })
                    }
                }
                .padding(.bottom, Constants.BasketItems.bottomPadding)
            }
            
            // Sub-total
            if let orderSubtotalPriceString = viewModel.orderSubtotalPriceString {
                listEntry(text: Strings.BasketView.subtotal.localized, amount: orderSubtotalPriceString, feeDescription: nil)
                    .foregroundColor(viewModel.minimumSpendReached ? colorPalette.typefacePrimary : colorPalette.primaryRed)
                
                Divider()
            }
            
            // Savings
            if let savings = viewModel.basket?.savings {
                ForEach(savings, id: \.self) { saving in
                    listEntry(text: saving.name, amount: "-\(saving.amount.toCurrencyString(using: viewModel.currency))", feeDescription: nil)

                    Divider()
                }
            }
            
            // Coupon
            if
                let deductCostPriceString = viewModel.deductCostPriceString,
                let coupon = viewModel.basket?.coupon
            {
                listCouponEntry(text: coupon.name + " (\(coupon.code))", amount: "- " + deductCostPriceString)
                Divider()
            }
            
            // Fees
            if let fees = viewModel.displayableFees {
                ForEach(fees) { fee in
                    if fee.text.lowercased() == "delivery" {
                            listEntry(text: fee.text, amount: fee.amount, feeDescription: fee.description)
                            .frame(width: mainWindowSize.width - Constants.DeliveryBanner.widthAdjustment)
                            #warning("Designs have changed for delivery fees now. Current implementation causing an issue with animation of driver tips so disabling this for now.")
//                            .withDeliveryOffer(container: viewModel.container, deliveryTierInfo: .init(orderMethod: viewModel.orderDeliveryMethod, currency: viewModel.currency), currency: viewModel.currency, fromBasket: true)
                    } else {
                        listEntry(text: fee.text, amount: fee.amount, feeDescription: fee.description)
                    }
                    
                    Divider()
                }
            }
            
            // Driver tips
            if let driverTipPriceString = viewModel.driverTipPriceString {
                driverTipListEntry(text: Strings.BasketView.drivertips.localized, amount: driverTipPriceString)
                
                Divider()
            }
            
            // Total
            if let totalPriceString = viewModel.orderTotalPriceString {
                orderTotal(totalAmount: totalPriceString)
            }
        }
    }
    
    private func listEntry(text: String, amount: String, feeDescription: String?) -> some View {
        HStack {
            if let feeDescription = feeDescription {
                Text(text)
                    .font(.Body2.regular())
                    .withInfoButtonAndText(container: viewModel.container, text: feeDescription)
            } else {
                Text(text)
                    .font(.Body2.regular())
            }
            
            Spacer()
            
            Text(amount)
                .font(.Body2.regular())
        }
        .padding([.horizontal, .top], text.lowercased() == "delivery" ? Constants.ListEntry.maxPadding : 0)
    }
    
    private func driverTipListEntry(text: String, amount: String) -> some View {
        HStack {
            Text(text)
            
            Spacer()
            
            VStack {
                DriverTipsButton(viewModel: viewModel, size: .standard)
                    .padding(.trailing)
            }
            
            
            Text(amount)
        }
        .font(.Body2.regular())
    }
    
    private func listCouponEntry(text: String, amount: String) -> some View {
        HStack {
            Text(text)
                .font(.snappyCaption)
            
            Spacer()
            
            Button(action: { Task { await viewModel.removeCoupon() } }) {
                Image.Actions.Close.xCircle
                    .renderingMode(.template)
                    .foregroundColor(colorPalette.typefacePrimary)
            }
            
            Text("\(amount)")
                .font(.snappyCaption)
        }
    }
    
    private func orderTotal(totalAmount: String) -> some View {
        HStack {
            Text(Strings.BasketView.total.localized)
            
            Spacer()
            
            Text("\(totalAmount)").bold()
        }
        .font(.Body1.semiBold())
        .foregroundColor(colorPalette.typefacePrimary)
        
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

#if DEBUG
struct BasketView_Previews: PreviewProvider {
    static var previews: some View {
        BasketView(viewModel: .init(container: .preview))
            .previewCases()
    }
}
#endif
