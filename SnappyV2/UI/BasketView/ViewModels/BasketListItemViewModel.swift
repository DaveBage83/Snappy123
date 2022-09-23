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
    @Published var basket: Basket?
    @Published var item: BasketItem
    @Published var quantity: String = ""
    var changeQuantity: (_ basketItem: BasketItem, _ quantity: Int) -> Void
    @Published var hasMissedPromotions = false
    var latestMissedPromotion: BasketItemMissedPromotion?
    @Published var selectionOptionsDict: [Int: [Int]]?
    @Published var bannerDetails = [BannerDetails]()
    @Published var missedPromoShown: BasketItemMissedPromotion?
    @Published var complexItemShown: RetailStoreMenuItem?
    @Published var error: Error?
    @Published var optionTexts =  [OptionText]()
    private var cancellables = Set<AnyCancellable>()
    
    var priceString: String {
        item.menuItem.price.price.toCurrencyString(using: container.appState.value.userData.selectedStore.value?.currency ?? AppV2Constants.Business.defaultStoreCurrency)
    }
    
    var totalPriceString: String {
        item.totalPrice.toCurrencyString(using: container.appState.value.userData.selectedStore.value?.currency ?? AppV2Constants.Business.defaultStoreCurrency)
    }
    
    var sizeText: String {
        if let name = item.size?.name {
            return " (\(name))"
        } else {
            return ""
        }
    }

    init(container: DIContainer, item: BasketItem, changeQuantity: @escaping (BasketItem, Int) -> Void) {
        self.item = item
        self.changeQuantity = changeQuantity
        self.container = container
        
        self._basket = .init(initialValue: container.appState.value.userData.basket)
        
        setupBasket(appState: container.appState)
        setupOptionTexts()
    }
    
    private func setupBasket(appState: Store<AppState>) {
        appState
            .map(\.userData.basket)
            .receive(on: RunLoop.main)
            .assignWeak(to: \.basket, on: self)
            .store(in: &cancellables)
    }
    
    enum OptionTextType: String {
        case option
        case optionValue
        case singleValueOption
    }
    
    struct OptionText: Identifiable {
        let id = UUID()
        let title: String
        let type: OptionTextType
        let value: String?
    }
    
    func setupOptionTexts() {
        $basket
            .receive(on: RunLoop.main)
            .sink { [weak self] basket in
                guard let self else { return }
                if let basketItem = basket?.items.first(where: { $0.basketLineId == self.item.basketLineId }) {
                    self.item = basketItem
                    self.optionTexts = self.assignOptionTexts(
                        selectedOptions: basketItem.selectedOptions,
                        availableOptions: basketItem.menuItem.menuItemOptions
                    )
                    
                    // Setting up view selection and missed promo banners
                    self.bannerDetails = []
                    self.convertAndAddViewSelectionBanner(basketItem: basketItem)
                    if let missedPromos = basketItem.missedPromotions {
                        self.setupMissedPromotions(promos: missedPromos)
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    private func assignOptionTexts(selectedOptions: [BasketItemSelectedOption]?, availableOptions: [RetailStoreMenuItemOption]?) -> [OptionText] {
        if let selectedOptions, let availableOptions {
            var optionTextArray = [OptionText]()
            for option in selectedOptions {
                for availableOption in availableOptions {
                    if option.id == availableOption.id {
                        if availableOption.instances != 1 {
                            optionTextArray.append(OptionText(title: availableOption.name, type: .option, value: nil))
                        }
                        if let values = availableOption.values {
                            for availableValue in values {
                                for id in option.selectedValues where id == availableValue.id {
                                    if availableOption.instances == 1 {
                                        optionTextArray.append(OptionText(title: availableOption.name, type: .singleValueOption, value: availableValue.name))
                                    } else {
                                        optionTextArray.append(OptionText(title: availableValue.name, type: .optionValue, value: nil))
                                    }
                                }
                            }
                        }
                    }
                }
            }
            return optionTextArray
        }
        return []
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
            bannerDetails.append(BannerDetails(type: .missedOffer, text: Strings.BasketView.ListEntry.missed.localized + promo.name, action: { [weak self] in
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
    
    private func convertAndAddViewSelectionBanner(basketItem:  BasketItem) {
        if basketItem.menuItem.menuItemSizes != nil || basketItem.menuItem.menuItemOptions != nil {
            bannerDetails.append(BannerDetails(type: .viewSelection, text: Strings.BasketView.viewSelection.localized, action: { [weak self] in
                guard let self = self else { return }
                self.viewSelectionTapped()
                }))
        }
    }
    
    func viewSelectionTapped() {
        complexItemShown = item.menuItem
    }
}
