//
//  ProductOptionsViewModel.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 12/08/2021.
//

import Foundation
import Combine

enum OptionValueType {
    case manyMore
    case radio
    case checkbox
    case stepper
}

class OptionController: ObservableObject {
    @Published var selectedOptionAndValueIDs = [Int: [Int]]() // [optionID: [ValueID]] Includes all selected values, regardless of dependencies
    @Published var actualSelectedOptionsAndValueIDs = [Int: [Int]]() // Selected values to be sent back to server
}

class ProductOptionsViewModel: ObservableObject {
    let container: DIContainer
    let optionController = OptionController()
    @Published var item: RetailStoreMenuItem
    var availableOptions = [RetailStoreMenuItemOption]()
    @Published var filteredOptions = [RetailStoreMenuItemOption]()
    @Published var totalPrice: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    init(container: DIContainer, item: RetailStoreMenuItem) {
        self.container = container
        self.item = item
        
        initAvailableOptions()
        setupFilteredOptions()
        setupActualSelectedOptionsAndValueIDs()
        setupTotalPrice()
    }
    
    func initAvailableOptions() {
        if let options = item.menuItemOptions {
            availableOptions = options
        }
    }
    
    func setupFilteredOptions() {
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
            .assignWeak(to: \.filteredOptions, on: self)
            .store(in: &cancellables)
    }
    
    func setupTotalPrice() {
        optionController.$selectedOptionAndValueIDs
            .map { dict in
                return dict.values.flatMap { $0 }
            }
            .map { [weak self] valueIDs -> [Double] in
                guard let self = self else { return [] }
                var prices = [Double]()
                
                if let sizes = self.item.menuItemSizes {
                    for size in sizes {
                        if valueIDs.contains(size.id) {
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
                                            if valueIDs.contains(sizeExtraCost.sizeId) {
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
            .map { pricesArray -> Double in
                return pricesArray.reduce(0, +) }
            .sink { [weak self] sum in
                guard let self = self else { return }
                self.totalPrice = CurrencyFormatter.uk(sum + self.item.price.price)
            }
            .store(in: &cancellables)
    }
    
    func setupActualSelectedOptionsAndValueIDs() {
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
    
    func addItemToBasket() {
        
    }
    
    func makeProductOptionSectionViewModel(itemOption: RetailStoreMenuItemOption) -> ProductOptionSectionViewModel {
        ProductOptionSectionViewModel(itemOption: itemOption, optionID: itemOption.id, optionController: optionController)
    }
    
    func makeProductOptionSectionViewModel(itemSizes: [RetailStoreMenuItemSize]) -> ProductOptionSectionViewModel {
        ProductOptionSectionViewModel(itemSizes: itemSizes, optionController: optionController)
    }
    
    func makeOptionValueCardViewModel(optionValue: RetailStoreMenuItemOptionValue, optionID: Int, optionsType: OptionValueType) -> OptionValueCardViewModel {
        OptionValueCardViewModel(optionValue: optionValue, optionID: optionID, optionsType: optionsType, optionController: optionController)
    }
    
    func makeOptionValueCardViewModel(size: RetailStoreMenuItemSize) -> OptionValueCardViewModel {
        OptionValueCardViewModel(size: size, optionController: optionController)
    }
}
