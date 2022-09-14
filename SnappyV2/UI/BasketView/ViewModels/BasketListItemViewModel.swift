//
//  BasketListItemViewModel.swift
//  SnappyV2
//
//  Created by David Bage on 17/01/2022.
//

import Foundation
import Combine
import OSLog

@MainActor
final class BasketListItemViewModel: ObservableObject {
    let container: DIContainer
    let basket: Basket?
    let item: BasketItem
    @Published var quantity: String = ""
    var changeQuantity: (_ basketItem: BasketItem, _ quantity: Int) -> Void
    var hasMissedPromotions = false
    var latestMissedPromotion: BasketItemMissedPromotion?
    var selectionOptionsDict: [Int: [Int]]?
    @Published var bannerDetails = [BannerDetails]()
    @Published var missedPromoShown: BasketItemMissedPromotion?
    @Published var complexItemShown: RetailStoreMenuItem?
    @Published var error: Error?
    
    var priceString: String {
        item.menuItem.price.price.toCurrencyString(using: container.appState.value.userData.selectedStore.value?.currency ?? AppV2Constants.Business.defaultStoreCurrency)
    }
    
    var totalPriceString: String {
        item.totalPrice.toCurrencyString(using: container.appState.value.userData.selectedStore.value?.currency ?? AppV2Constants.Business.defaultStoreCurrency)
    }

    init(container: DIContainer, item: BasketItem, changeQuantity: @escaping (BasketItem, Int) -> Void) {
        self.item = item
        self.changeQuantity = changeQuantity
        self.container = container
        
        self.basket = container.appState.value.userData.basket
        
        convertOptionIds(selectedOptions: item.selectedOptions)
        convertAndAddViewSelectionBanner(selectedOptions: item.selectedOptions, size: item.size)
        if let missedPromos = item.missedPromotions {
            self.setupMissedPromotions(promos: missedPromos)
        }
    }
    
    func onSubmit() {
        changeQuantity(item, Int(quantity) ?? 0)
        quantity = ""
    }
    
    func showMissed(promo: BasketItemMissedPromotion) {
        missedPromoShown = promo
    }
    
    private func setupMissedPromotions(promos: [BasketItemMissedPromotion]) {
        self.hasMissedPromotions = true
        for promo in promos {
            bannerDetails.append(BannerDetails(type: .missedOffer, text: promo.name, action: { [weak self] in
                guard let self = self else { return }
                self.showPromoTapped(promo: promo)
            }))
        }
    }
    
    func filterQuantityToStringNumber(stringValue: String) {
        let filtered = stringValue.filter { $0.isNumber }
        
        if quantity != filtered {
            quantity = filtered
        }
    }
    
    func showPromoTapped(promo: BasketItemMissedPromotion) {
        missedPromoShown = promo
    }
    
    func dismissTapped() {
        missedPromoShown = nil
    }
    
    private func convertAndAddViewSelectionBanner(selectedOptions: [BasketItemSelectedOption]?, size: BasketItemSelectedSize?) {
        if selectedOptions != nil || size != nil {
            bannerDetails.append(BannerDetails(type: .viewSelection, text: Strings.BasketView.viewSelection.localized, action: { [weak self] in
                guard let self = self else { return }
                self.viewSelectionTapped()
                }))
        }
    }
    
    private func convertOptionIds(selectedOptions: [BasketItemSelectedOption]?) {
        if let selectedOptions = selectedOptions {
            var optionsDict = [Int: [Int]]()
            for selectedOption in selectedOptions {
                var optionArray = [Int]()
                for selectedValues in selectedOption.selectedValues {
                    optionArray.append(selectedValues)
                }
                optionsDict[selectedOption.id] = optionArray
            }
            selectionOptionsDict = optionsDict
        }
    }
    
    func viewSelectionTapped() {
        complexItemShown = item.menuItem
    }
}
