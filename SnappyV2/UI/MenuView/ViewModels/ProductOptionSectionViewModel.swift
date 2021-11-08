//
//  ProductOptionSectionViewModel.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 13/08/2021.
//

import Foundation
import Combine

class ProductOptionSectionViewModel: ObservableObject {
    let optionController: OptionController
    let title: String
    let optionID: Int
    @Published var optionValues: [RetailStoreMenuItemOptionValue]
    @Published var sizeValues: [RetailStoreMenuItemSize]
    var optionsType: OptionValueType = .manyMore
    let mutuallyExclusive: Bool
    var useBottomSheet = false
    let minimumSelected: Int
    let maximumSelected: Int
    @Published var bottomSheetValues: RetailStoreMenuItemOption?
    let sectionType: SectionType
    @Published var selectedOptionValues = [RetailStoreMenuItemOptionValue]()
    @Published var maximumReached = false
    
    private var cancellables = Set<AnyCancellable>()
    
    enum SectionType {
        case bottomSheet
        case options
        case sizes
    }
    
    init(itemOption: RetailStoreMenuItemOption, optionID: Int, optionController: OptionController) {
        self.title = itemOption.name
        self.optionID = optionID
        self.optionValues = itemOption.values ?? []
        self.mutuallyExclusive = itemOption.mutuallyExclusive
        self.sectionType = itemOption.displayAsGrid == false ? .bottomSheet : .options
        self.minimumSelected = itemOption.minimumSelected
        self.maximumSelected = itemOption.instances
        self.sizeValues = []
        self.optionController = optionController
        
        setOptionValueType()
        
        setupSelectedOptionValues()
        
        setupMaximumReached()
    }
    
    init(itemSizes: [RetailStoreMenuItemSize], optionController: OptionController) {
        self.title = "Size"
        self.optionID = Int()
        self.mutuallyExclusive = true
        self.sectionType = .sizes
        self.minimumSelected = 1
        self.maximumSelected = 1
        self.optionValues = []
        self.sizeValues = itemSizes
        self.optionController = optionController
    }
    
    func setOptionValueType() {
        if mutuallyExclusive == false && maximumSelected > 1 {
            optionsType = .stepper
        } else if mutuallyExclusive == true && maximumSelected > 1 {
            optionsType = .checkbox
        } else if maximumSelected == 1 {
            optionsType = .radio
        }
    }
    
    func showBottomSheet() {
        bottomSheetValues = RetailStoreMenuItemOption(id: 123, name: title, type: .item, placeholder: "", instances: maximumSelected, displayAsGrid: useBottomSheet, mutuallyExclusive: mutuallyExclusive, minimumSelected: minimumSelected, extraCostThreshold: 0, dependencies: nil, values: optionValues)
    }
    
    func dismissBottomSheet() {
        bottomSheetValues = nil
    }
    
    func setupSelectedOptionValues() {
        optionController.$selectedOptionAndValueIDs
            .map { [weak self] dict -> [Int] in
                guard let self = self else { return [] }
                if let valueIDs = dict[self.optionID] {
                    return valueIDs
                }
                return []
            }
            .map { [weak self] valueIDs in
                guard let self = self else { return [] }
                var array = [RetailStoreMenuItemOptionValue]()
                
                for optionValue in self.optionValues {
                    guard array.contains(optionValue) == false else { continue }
                    
                    if valueIDs.contains(optionValue.id) {
                        array.append(optionValue)
                    }
                }
                
                return array
            }
            .assignWeak(to: \.selectedOptionValues, on: self)
            .store(in: &cancellables)
    }
    
    var optionLimitationsSubtitle: String {
        guard sizeValues.isEmpty else { return "" }
        guard optionsType != .radio else { return "Select 1" }
        
        var minString = ""
        var maxString = ""
        
        if minimumSelected > 0 {
            minString = "Select \(minimumSelected) minimum. "
        }
        
        if maximumSelected > 0 {
            maxString = "Choose up to \(maximumSelected)."
        }
        
        return minString + maxString
    }
    
    func setupMaximumReached() {
        optionController.$selectedOptionAndValueIDs
            .map { [weak self] dict -> [Int] in
                guard let self = self else { return [] }
                if let values = dict[self.optionID] {
                    return values
                }
                return []
            }
            .map { [weak self] values in
                guard let self = self else { return false }
                guard self.maximumSelected > 0 else { return false }
                
                return values.count >= self.maximumSelected ? true : false
            }
            .assignWeak(to: \.maximumReached, on: self)
            .store(in: &cancellables)
    }
}
