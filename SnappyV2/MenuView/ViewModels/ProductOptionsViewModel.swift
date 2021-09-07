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
    let optionController = OptionController()
    @Published var item: MenuItem
    var availableOptions = [MenuItemOption]()
    @Published var filteredOptions = [MenuItemOption]()
    @Published var totalPrice: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    init(item: MenuItem) {
        self.item = item
        
        initAvailableOptions()
        setupFilteredOptions()
        setupActualSelectedOptionsAndValueIDs()
        setupTotalPrice()
    }
    
    func initAvailableOptions() {
        if let options = item.options {
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
                var array = [MenuItemOption]()
                
                for option in self.availableOptions {
                    guard array.contains(option) == false else { continue }
                    guard let dependentOn = option.dependentOn else { array.append(option); continue }
                    
                    if (dependentOn.contains {
                        return valueIDs.contains($0)
                    }) {
                        array.append(option)
                    }
                }
                
                return array
            }
            .assignNoRetain(to: \.filteredOptions, on: self)
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
                
                if let sizes = self.item.sizes {
                    for size in sizes {
                        if valueIDs.contains(size.id), let price = size.price {
                            prices.append(price)
                        }
                    }
                }
                
                for option in self.filteredOptions {
                    for value in option.values {
                        for valueID in valueIDs {
                            if valueID == value.id {
                                if let sizeExtraCosts = value.sizeExtraCost {
                                    for sizeExtraCost in sizeExtraCosts {
                                        if let sizeID = sizeExtraCost.sizeId, valueIDs.contains(sizeID), let extraCostPrice = sizeExtraCost.extraCost {
                                            prices.append(extraCostPrice)
                                        }
                                    }
                                } else {
                                    if let extraCost = value.extraCost {
                                        prices.append(extraCost)
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
            .assignNoRetain(to: \.actualSelectedOptionsAndValueIDs, on: optionController)
            .store(in: &cancellables)
    }
    
    func makeProductOptionSectionViewModel(itemOption: MenuItemOption) -> ProductOptionSectionViewModel {
        ProductOptionSectionViewModel(itemOption: itemOption, optionID: itemOption.id, optionController: optionController)
    }
    
    func makeProductOptionSectionViewModel(itemSizes: [MenuItemSize]) -> ProductOptionSectionViewModel {
        ProductOptionSectionViewModel(itemSizes: itemSizes, optionController: optionController)
    }
    
    func makeOptionValueCardViewModel(optionValue: MenuItemOptionValue, optionID: Int, optionsType: OptionValueType) -> OptionValueCardViewModel {
        OptionValueCardViewModel(optionValue: optionValue, optionID: optionID, optionsType: optionsType, optionController: optionController)
    }
    
    func makeOptionValueCardViewModel(size: MenuItemSize) -> OptionValueCardViewModel {
        OptionValueCardViewModel(size: size, optionController: optionController)
    }
}

struct MenuItem {
    let id = UUID() // later Int
    let name: String
    let price: Price
    let description: String?
    let sizes: [MenuItemSize]?
    let options: [MenuItemOption]?
}

struct Price {
    let price: Double
    let fromPrice: Double?
    let wasPrice: Double?
    let unitMetric: String?
    let unitsInPack: String?
    let unitVolume: String?
}

struct MenuItemSize: Identifiable {
    let id: Int
    let name: String
    let price: Double?
}

struct MenuItemOption: Equatable, Identifiable, Hashable {
    let id: Int
    let name: String
    var placeholder: String?
    let maximumSelected: Int?
    var displayAsGrid: Bool?
    let mutuallyExclusive: Bool?
    let minimumSelected: Int?
    var dependentOn: [Int]?
    let values: [MenuItemOptionValue]
    let type: String
}

struct MenuItemOptionValue: Equatable, Identifiable, Hashable {
    let id: Int
    let name: String?
    let extraCost: Double?
    let `default`: Bool?
    let sizeExtraCost: [MenuItemOptionValueSize]?
}

struct MenuItemOptionValueSize: Identifiable, Equatable, Hashable {
    let id: Int
    let sizeId: Int?
    let extraCost: Double?
}
