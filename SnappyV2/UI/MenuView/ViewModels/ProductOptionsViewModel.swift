//
//  ProductOptionsViewModel.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 12/08/2021.
//

import Foundation
import Combine
import OSLog

enum OptionValueType {
    case manyMore
    case radio
    case checkbox
    case stepper
}

class OptionController: ObservableObject {
    
    // [optionID: [ValueID]] Includes all selected values, regardless of dependencies
    @Published var selectedOptionAndValueIDs = [Int: [Int]]()
    
    // Selected values to be sent back to server
    @Published var actualSelectedOptionsAndValueIDs = [Int: [Int]]()
    
    @Published var selectedSizeID: Int?
    
    // collection of all minimumReached results reached in all options
    @Published var allMinimumReached = [Int: Bool]()
}

@MainActor
final class ProductOptionsViewModel: ObservableObject {
    let container: DIContainer
    let optionController = OptionController()
    @Published var item: RetailStoreMenuItem
    var availableOptions = [RetailStoreMenuItemOption]()
    @Published var filteredOptions = [RetailStoreMenuItemOption]()
    @Published var totalPrice: String = ""
    @Published var isAddingToBasket = false
    @Published var viewDismissed: Bool = false
    @Published var criteriaMet: Bool = false
    @Published var scrollToOptionId: Int?
    let basketItem: BasketItem?
    var itemDetails = [ItemDetails]()
        
    private var cancellables = Set<AnyCancellable>()
    
    var showUpdateButtonText: Bool { basketItem != nil }
    
    var showExpandedDescription: Bool { item.quickAdd == false && item.menuItemSizes == nil && item.menuItemOptions == nil }
    
    var showItemDetails: Bool { itemDetails.isEmpty == false }
    
    init(container: DIContainer, item: RetailStoreMenuItem, basketItem: BasketItem? = nil) {
        self.container = container
        self.item = item
        self.basketItem = basketItem
        if let itemDetails = item.itemDetails {
            self.itemDetails = itemDetails
        }
        
        initAvailableOptions()
        setupFilteredOptions()
        setupActualSelectedOptionsAndValueIDs()
        setupTotalPrice()
        setupAllMinimumReached()
        
        // if basketItem, apply basket items options and size, else apply defaults
        if let basketItem = basketItem {
            if let sizeId = basketItem.size?.id {
                self.optionController.selectedSizeID = sizeId
            }
            if let selectedOptions = basketItem.selectedOptions {
                self.convertOptionIds(selectedOptions: selectedOptions)
            }
        } else {
            checkForAndApplyDefaults()
            applySizeDefault()
        }
    }
    
    func initAvailableOptions() {
        if let options = item.menuItemOptions {
            availableOptions = options
        }
    }
    
    private func setupFilteredOptions() {
        optionController.$selectedOptionAndValueIDs
            .receive(on: RunLoop.main)
            .map { dict in
                dict.values.flatMap { $0 }
            }
            .map { [weak self] valueIDs in
                guard let self = self else { return [] }
                var array = [RetailStoreMenuItemOption]()
                
                for option in self.availableOptions {
                    guard array.contains(option) == false else { continue }
                    guard option.dependencies.isEmpty == false else { array.append(option); continue }
                    
                    if (option.dependencies.contains {
                        return valueIDs.contains($0)
                    }) {
                        array.append(option)
                    }
                }
                
                return array
            }
            .assignWeak(to: \.filteredOptions, on: self)
            .store(in: &cancellables)
    }
    
    private func setupTotalPrice() {
        Publishers.CombineLatest(optionController.$selectedOptionAndValueIDs, optionController.$selectedSizeID)
            .receive(on: RunLoop.main)
            .map { dict, size in
                return (dict.values.flatMap { $0 }, size)
            }
            .map { [weak self] valueIDs, sizeid -> [Double] in
                guard let self = self else { return [] }
                var prices = [Double]()
                
                if let sizeid = sizeid, let sizes = self.item.menuItemSizes {
                    for size in sizes {
                        if size.id == sizeid {
                            prices.append(size.price.price)
                        }
                    }
                } else {
                    prices.append(self.item.price.price)
                }
                
                for option in self.filteredOptions {
                    if let values = option.values {
                        for value in values {
                            for valueID in valueIDs {
                                if valueID == value.id {
                                    if let sizeExtraCosts = value.sizeExtraCost {
                                        for sizeExtraCost in sizeExtraCosts {
                                            if sizeid == sizeExtraCost.sizeId {
                                                prices.append(sizeExtraCost.extraCost)
                                            }
                                        }
                                    } else {
                                        prices.append(value.extraCost)
                                    }
                                }
                            }
                        }
                    }
                }
                
                return prices
            }
            .map { [weak self] pricesArray in
                guard let self = self else { return "" }
                let sum = pricesArray.reduce(0, +)
                
                return sum.toCurrencyString(
                    using: self.container.appState.value.userData.selectedStore.value?.currency ?? AppV2Constants.Business.defaultStoreCurrency
                )
            }
            .assignWeak(to: \.totalPrice, on: self)
            .store(in: &cancellables)
    }
    
    private func setupActualSelectedOptionsAndValueIDs() {
        $filteredOptions
            .receive(on: RunLoop.main)
            .map { options -> [Int] in
                return options.map { $0.id }
            }
            .map { [weak self] optionIDs in
                guard let self = self else { return [:] }
                var dict = [Int: [Int]]()
                
                for item in self.optionController.selectedOptionAndValueIDs {
                    if optionIDs.contains(item.key) && item.value.isEmpty == false {
                        dict[item.key] = item.value
                    }
                }
                
                return dict
            }
            .assignWeak(to: \.actualSelectedOptionsAndValueIDs, on: optionController)
            .store(in: &cancellables)
    }
    
    private func setupAllMinimumReached() {
        optionController.$allMinimumReached
            .receive(on: RunLoop.main)
            .sink { [weak self] minArray in
                guard let self = self else { return }
                self.criteriaMet =  minArray.allSatisfy { $0.value == true }
            }
            .store(in: &cancellables)
    }
    
    func scrollToFirstMissingOption() {
        scrollToOptionId = optionController.allMinimumReached.first(where: { $0.value == false })?.key
    }
    
    private func convertOptionIds(selectedOptions: [BasketItemSelectedOption]) {
        var optionsDict = [Int: [Int]]()
        for selectedOption in selectedOptions {
            var optionArray = [Int]()
            for selectedValues in selectedOption.selectedValues {
                optionArray.append(selectedValues)
            }
            optionsDict[selectedOption.id] = optionArray
        }
        optionController.selectedOptionAndValueIDs = optionsDict
    }

    func actionButtonTapped() async {
        guard criteriaMet else {
            scrollToFirstMissingOption()
            return
        }
        
        self.isAddingToBasket = true
        var itemsOptionArray: [BasketItemRequestOption] = []
        for optionValue in optionController.actualSelectedOptionsAndValueIDs {
            let basketOptionValues = BasketItemRequestOption(id: optionValue.key, values: optionValue.value, type: .item)
            itemsOptionArray.append(basketOptionValues)
        }
        
        do {
            if let basketItem = basketItem {
                let basketRequest = BasketItemRequest(menuItemId: self.item.id, quantity: basketItem.quantity, sizeId: optionController.selectedSizeID ?? 0, bannerAdvertId: 0, options: itemsOptionArray, instructions: nil)
                try await self.container.services.basketService.updateItem(basketItemRequest: basketRequest, basketItem: basketItem)
                Logger.product.info("Updating item \(String(describing: self.item.name)) with options in basket")
            } else {
                let basketRequest = BasketItemRequest(menuItemId: self.item.id, quantity: 1, sizeId: optionController.selectedSizeID ?? 0, bannerAdvertId: 0, options: itemsOptionArray, instructions: nil)
                try await self.container.services.basketService.addItem(basketItemRequest: basketRequest, item: self.item)
                Logger.product.info("Added item \(String(describing: self.item.name)) with options to basket")
            }
            
            self.isAddingToBasket = false
            self.dismissView()
        } catch {
            self.container.appState.value.errors.append(error)
            Logger.product.error("Error adding/updating \(String(describing: self.item.name)) with options to/in basket - \(error.localizedDescription)")
            self.isAddingToBasket = false
        }
    }
    
    private func checkForAndApplyDefaults() {
        if let options = item.menuItemOptions {
            for option in options {
                if let values = option.values {
                    for value in values {
                        if value.defaultSelection > 0 {
                            guard option.mutuallyExclusive == false else {
                                self.optionController.actualSelectedOptionsAndValueIDs[option.id] = [value.id]
                                return
                            }
                            var values = [Int]()
                            
                            let count = (value.defaultSelection > option.instances && option.instances != 0) ? option.instances : value.defaultSelection
                            for _ in 1...count {
                                values.append(value.id)
                            }
                            
                            self.optionController.actualSelectedOptionsAndValueIDs[option.id] = values
                        }
                    }
                }
            }
        }
    }
    
    private func applySizeDefault() {
        if let sizeOptions = item.menuItemSizes {
            optionController.selectedSizeID = sizeOptions.first?.id
        }
    }
    
    func dismissView() {
        viewDismissed = true
    }
    
    func makeProductOptionSectionViewModel(itemOption: RetailStoreMenuItemOption) -> ProductOptionSectionViewModel {
        ProductOptionSectionViewModel(container: container, itemOption: itemOption, optionID: itemOption.id, optionController: optionController)
    }
    
    func makeProductOptionSectionViewModel(itemSizes: [RetailStoreMenuItemSize]) -> ProductOptionSectionViewModel {
        ProductOptionSectionViewModel(container: container, itemSizes: itemSizes, optionController: optionController)
    }
    
    func makeOptionValueCardViewModel(optionValue: RetailStoreMenuItemOptionValue, optionID: Int, optionsType: OptionValueType) -> OptionValueCardViewModel {
        OptionValueCardViewModel(container: container, currency: container.appState.value.userData.selectedStore.value?.currency ?? AppV2Constants.Business.defaultStoreCurrency, optionValue: optionValue, optionID: optionID, optionsType: optionsType, optionController: optionController)
    }
    
    func makeOptionValueCardViewModel(size: RetailStoreMenuItemSize) -> OptionValueCardViewModel {
        OptionValueCardViewModel(container: container, currency: container.appState.value.userData.selectedStore.value?.currency ?? AppV2Constants.Business.defaultStoreCurrency, size: size, optionController: optionController)
    }
}
