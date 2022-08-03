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
    @Published var selectedOptionAndValueIDs = [Int: [Int]]() // [optionID: [ValueID]] Includes all selected values, regardless of dependencies
    @Published var actualSelectedOptionsAndValueIDs = [Int: [Int]]() // Selected values to be sent back to server
    @Published var selectedSizeID: Int?
}

class ProductOptionsViewModel: ObservableObject {
    let container: DIContainer
    let optionController = OptionController()
    @Published var item: RetailStoreMenuItem
    var availableOptions = [RetailStoreMenuItemOption]()
    @Published var filteredOptions = [RetailStoreMenuItemOption]()
    @Published var totalPrice: String = ""
    @Published var isAddingToBasket = false
    @Published var viewDismissed: Bool = false
    
    @Published private(set) var error: Error?
    
    private var cancellables = Set<AnyCancellable>()
    
    init(container: DIContainer, item: RetailStoreMenuItem) {
        self.container = container
        self.item = item
        
        initAvailableOptions()
        setupFilteredOptions()
        setupActualSelectedOptionsAndValueIDs()
        setupTotalPrice()
        
        checkForAndApplyDefaults()
    }
    
    func initAvailableOptions() {
        if let options = item.menuItemOptions {
            availableOptions = options
        }
    }
    
    private func setupFilteredOptions() {
        optionController.$selectedOptionAndValueIDs
            .map { dict in
                dict.values.flatMap { $0 }
            }
            .map { [weak self] valueIDs in
                guard let self = self else { return [] }
                var array = [RetailStoreMenuItemOption]()
                
                for option in self.availableOptions {
                    guard array.contains(option) == false else { continue }
                    guard let dependentOn = option.dependencies else { array.append(option); continue }
                    
                    if (dependentOn.contains {
                        return valueIDs.contains($0)
                    }) {
                        array.append(option)
                    }
                }
                
                return array
            }
            .receive(on: RunLoop.main)
            .assignWeak(to: \.filteredOptions, on: self)
            .store(in: &cancellables)
    }
    
    private func setupTotalPrice() {
        Publishers.CombineLatest(optionController.$selectedOptionAndValueIDs, optionController.$selectedSizeID)
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
                
                return (sum + self.item.price.price).toCurrencyString()
            }
            .receive(on: RunLoop.main)
            .assignWeak(to: \.totalPrice, on: self)
            .store(in: &cancellables)
    }
    
    private func setupActualSelectedOptionsAndValueIDs() {
        $filteredOptions
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

    func addItemToBasket() async {
        self.isAddingToBasket = true
        var itemsOptionArray: [BasketItemRequestOption] = []
        for optionValue in optionController.actualSelectedOptionsAndValueIDs {
            let basketOptionValues = BasketItemRequestOption(id: optionValue.key, values: optionValue.value, type: .item)
            itemsOptionArray.append(basketOptionValues)
        }
        #warning("The above is to convert what is saved in options controller to what is needed for service call. It was written before we knew what the server wanted. Ideally option view models should be rewritten to handle 'BasketItemRequestOption' instead of dictionary")
        let basketRequest = BasketItemRequest(menuItemId: self.item.id, quantity: 1, sizeId: optionController.selectedSizeID ?? 0, bannerAdvertId: 0, options: itemsOptionArray, instructions: nil)
            
            do {
                try await self.container.services.basketService.addItem(basketItemRequest: basketRequest, item: self.item)
                
                Logger.product.info("Added item \(String(describing: self.item.name)) with options to basket")
                self.isAddingToBasket = false
                self.dismissView()
            } catch {
                self.error = error
                Logger.product.error("Error adding \(String(describing: self.item.name)) with options to basket - \(error.localizedDescription)")
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
    
    func dismissView() {
        viewDismissed = true
    }
    
    func makeProductOptionSectionViewModel(itemOption: RetailStoreMenuItemOption) -> ProductOptionSectionViewModel {
        ProductOptionSectionViewModel(itemOption: itemOption, optionID: itemOption.id, optionController: optionController)
    }
    
    func makeProductOptionSectionViewModel(itemSizes: [RetailStoreMenuItemSize]) -> ProductOptionSectionViewModel {
        ProductOptionSectionViewModel(itemSizes: itemSizes, optionController: optionController)
    }
    
    func makeOptionValueCardViewModel(optionValue: RetailStoreMenuItemOptionValue, optionID: Int, optionsType: OptionValueType) -> OptionValueCardViewModel {
        OptionValueCardViewModel(currency: container.appState.value.userData.selectedStore.value?.currency ?? AppV2Constants.Business.defaultStoreCurrency, optionValue: optionValue, optionID: optionID, optionsType: optionsType, optionController: optionController)
    }
    
    func makeOptionValueCardViewModel(size: RetailStoreMenuItemSize) -> OptionValueCardViewModel {
        OptionValueCardViewModel(currency: container.appState.value.userData.selectedStore.value?.currency ?? AppV2Constants.Business.defaultStoreCurrency, size: size, optionController: optionController)
    }
}
