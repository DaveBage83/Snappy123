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
    
    // MARK: - Environment
    @Environment(\.colorScheme) var colorScheme
    
    private struct Constants {
        struct MinSpendWarning {
            static let spacing: CGFloat = 16
            static let iconHeight: CGFloat = 16
            static let fontPadding: CGFloat = 12
            static let externalPadding: CGFloat = 32
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
            static let height: CGFloat = 12
        }
        
        struct SubItemStack {
            static let spacing: CGFloat = 32
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
            VStack {
                if viewModel.basketIsEmpty {
                    emptyBasket
                        .padding()
                        .navigationTitle(BasketViewStrings.title.localized)
                        .navigationBarTitleDisplayMode(.inline)
                        .background(colorPalette.backgroundMain)
                } else {
                    ScrollView {
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
                                
                                couponInput
                                
                                mentionMe
                                
                                mainButton
                            }
                        }
                        .frame(maxHeight: .infinity)
                        .padding([.top, .leading, .trailing])
                        .onAppear {
                            viewModel.onBasketViewSendEvent()
                        }
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
                    }
                    .background(colorPalette.backgroundMain)
                    .navigationTitle(BasketViewStrings.title.localized)
                    .navigationBarTitleDisplayMode(.inline)
                    .onTapGesture {
                        hideKeyboard()
                    }
                }
                // MARK: NavigationLinks
                NavigationLink("", isActive: $viewModel.isContinueToCheckoutTapped) {
                    CheckoutRootView(viewModel: .init(container: viewModel.container, keepCheckoutFlowAlive: $viewModel.isContinueToCheckoutTapped))
                }
            }
        }
        .withStandardAlert(
            container: viewModel.container,
            isPresenting: $viewModel.showMinSpendWarning,
            type: .error,
            title: BasketViewStrings.minSpendAlertTitle.localized,
            subtitle: BasketViewStrings.minSpendAlertSubTitle.localized)
        .withStandardAlert(
            container: viewModel.container,
            isPresenting: $viewModel.couponAppliedUnsuccessfully,
            type: .error,
            title: Strings.BasketView.Coupon.couponErrorTitle.localized,
            subtitle: Strings.BasketView.Coupon.couponErrorSubtitle.localized)
        .toast(isPresenting: $viewModel.showingServiceFeeAlert, tapToDismiss: true, disableAutoDismiss: true, alert: {
            AlertToast(
                displayMode: .alert,
                type: .regular,
                title: viewModel.serviceFeeDescription?.title ?? "", // should never end up empty as we unwrap the text before setting alert to true
                subTitle: viewModel.serviceFeeDescription?.description ?? "", // should never end up empty as we unwrap the text before setting,
                style: .style(
                    backgroundColor: colorPalette.alertHighlight,
                    titleColor: colorPalette.secondaryWhite,
                    subTitleColor: colorPalette.secondaryWhite,
                    titleFont: .Body1.semiBold(),
                    subTitleFont: .Body1.regular())
            )
        })
        .sheet(isPresented: $viewModel.showMentionMeWebView) {
            MentionMeWebView(
                viewModel: MentionMeWebViewModel(
                    container: viewModel.container,
                    mentionMeRequestResult: viewModel.mentionMeRefereeRequestResult,
                    dismissWebViewHandler: { couponAction in
                        viewModel.mentionMeWebViewDismissed(with: couponAction)
                    }
                )
            )
        }
        .displayError(viewModel.error)
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
                Text(" \((viewModel.basket?.fulfilmentMethod.minSpend ?? 0).toCurrencyString())")
                    .font(.subheadline.bold()) +
                Text(BasketViewStrings.proceed.localized)
                
                Image.Icons.CircleCheck.filled
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
            hasError: .constant(viewModel.couponAppliedUnsuccessfully),
            isLoading: $viewModel.applyingCoupon,
            labelText: BasketViewStrings.Coupon.codeTitle.localized,
            largeLabelText: nil,
            mainButton: (BasketViewStrings.Coupon.alertApplyShort.localized, {
                Task {
                    await viewModel.submitCoupon()
                }
            })
        )
    }
    
    @ViewBuilder private var mainButton: some View {
        if viewModel.basketIsEmpty {
            SnappyButton(
                container: viewModel.container,
                type: .primary,
                size: .large,
                title: BasketViewStrings.startShopping.localized,
                largeTextTitle: nil,
                icon: nil) {
                    viewModel.startShoppingPressed()
                }
        } else {
            VStack(spacing: Constants.MainButtonStack.spacing) {
                if viewModel.isSlotExpired == false {
                    SnappyButton(
                        container: viewModel.container,
                        type: .success,
                        size: .large,
                        title: Strings.BasketView.checkout.localized,
                        largeTextTitle: nil,
                        icon: nil) {
                            viewModel.checkoutTapped()
                        }
                }
                
                SnappyButton(
                    container: viewModel.container,
                    type: .outline,
                    size: .large,
                    title: BasketViewStrings.continueShopping.localized,
                    largeTextTitle: nil,
                    icon: nil) {
                        viewModel.startShoppingPressed()
                    }
            }
        }
    }

    private var emptyBasket: some View {
        VStack {
            FulfilmentInfoCard(viewModel: .init(container: viewModel.container))
                .padding(.bottom, Constants.EmptyBasketView.bottomPadding)
            
            Text(BasketViewStrings.noItems.localized)
                .font(.Body1.semiBold())
                .foregroundColor(colorPalette.typefacePrimary)
            
            Spacer()
            
            mainButton
        }
    }
    
    private func basketItems() -> some View {
        LazyVStack {
            // Items
            if let items = viewModel.basket?.items {
                VStack(spacing: Constants.BasketItems.spacing) {
                    ForEach(items, id: \.self) { item in
                        
                        BasketListItemView(viewModel: .init(container: viewModel.container, item: item) { basketItem, newQuantity in
                            Task {
                                await viewModel.updateBasketItem(basketItem: basketItem ,quantity: newQuantity)
                            }
                        })
                    }
                }
                .padding(.bottom, Constants.BasketItems.bottomPadding)
            }
            
            // Coupon
            if let coupon = viewModel.basket?.coupon {
                listCouponEntry(text: coupon.name, amount: "- " + coupon.deductCost.toCurrencyString())
                
                Divider()
            }
            
            #warning("To re-implement once designs updated")
            // Savings
//            if let savings = viewModel.basket?.savings {
//                ForEach(savings, id: \.self) { saving in
//                    listEntry(text: saving.name, amount: saving.amount.toCurrencyString(), feeDescription: nil)
//
//                    Divider()
//                }
//            }
            
            // Sub-total
            if let subTotal = viewModel.basket?.orderSubtotal {
                listEntry(text: Strings.BasketView.subtotal.localized, amount: subTotal.toCurrencyString(), feeDescription: nil)
                    .foregroundColor(viewModel.minimumSpendReached ? colorPalette.typefacePrimary : colorPalette.primaryRed)
                
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
            }
        }
    }
    
    private func listEntry(text: String, amount: String, feeDescription: String?) -> some View {
        HStack {
            Text(text)
                .font(.Body2.regular())
            if let description = feeDescription {
                Button(action: { viewModel.showServiceFeeAlert(title: text, description: description) }) {
                    Image.Icons.Info.standard
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: Constants.ListEntry.height)
                        .foregroundColor(colorPalette.typefacePrimary)
                }
            }
            
            Spacer()
            
            Text(amount)
                .font(.Body2.regular())
        }
    }
    
    private func driverTipListEntry(text: String, amount: String) -> some View {
        HStack {
            Text(text)
            
            Spacer()
            
            DriverTipsButton(viewModel: viewModel, size: .standard)
                .padding(.trailing)
            
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
                    .foregroundColor(.black)
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
