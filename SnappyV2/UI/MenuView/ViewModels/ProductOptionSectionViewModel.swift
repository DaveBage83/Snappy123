//
//  ProductOptionSectionViewModel.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 13/08/2021.
//

import Foundation
import Combine

@MainActor
class ProductOptionSectionViewModel: ObservableObject {
    let container: DIContainer
    @Published var optionController: OptionController
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
    @Published var minimumReached = true
    
    private var cancellables = Set<AnyCancellable>()
    
    enum SectionType {
        case bottomSheet
        case options
        case sizes
    }
    
    // value options init
    init(container: DIContainer, itemOption: RetailStoreMenuItemOption, optionID: Int, optionController: OptionController) {
        self.container = container
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
        setupMinimumReached()
        setupMinimumReachedInOptionsController()
    }
    
    // size options init
    init(container: DIContainer, itemSizes: [RetailStoreMenuItemSize], optionController: OptionController) {
        self.container = container
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
    
    private func setOptionValueType() {
        if mutuallyExclusive == false && maximumSelected > 1 {
            optionsType = .stepper
        } else if mutuallyExclusive == true && maximumSelected > 1 {
            optionsType = .checkbox
        } else if maximumSelected == 1 {
            optionsType = .radio
        }
    }
    
    func showBottomSheet() {
        #warning("Is this finished? E.g. id is hard coded")
        bottomSheetValues = RetailStoreMenuItemOption(id: 123, name: title, type: .item, placeholder: "", instances: maximumSelected, displayAsGrid: useBottomSheet, mutuallyExclusive: mutuallyExclusive, minimumSelected: minimumSelected, extraCostThreshold: 0, dependencies: [], values: optionValues)
    }
    
    func dismissBottomSheet() {
        bottomSheetValues = nil
    }
    
    private func setupSelectedOptionValues() {
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
            .receive(on: RunLoop.main)
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
    
    var showOptionLimitationsSubtitle: Bool { optionLimitationsSubtitle.isEmpty == false }
    
    private func setupMaximumReached() {
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
            .receive(on: RunLoop.main)
            .assignWeak(to: \.maximumReached, on: self)
            .store(in: &cancellables)
    }
    
    private func setupMinimumReached() {
        optionController.$selectedOptionAndValueIDs
            .receive(on: RunLoop.main)
            .map { [weak self] dict -> [Int] in
                guard let self = self else { return [] }
                if let values = dict[self.optionID] {
                    return values
                }
                return []
            }
            .map { [weak self] values in
                guard let self = self else { return false }
                guard self.minimumSelected > 0 else { return true }
                
                return values.count >= self.minimumSelected ? true : false
            }
            .assignWeak(to: \.minimumReached, on: self)
            .store(in: &cancellables)
    }
    
    private func setupMinimumReachedInOptionsController() {
        $minimumReached
            .receive(on: RunLoop.main)
            .sink { [weak self] minReachedBool in
                guard let self = self else { return }
                self.optionController.allMinimumReached[self.optionID] = minReachedBool
            }
            .store(in: &cancellables)
    }
    
    // triggered by on .opDisappear() for clearing data from sections that are dependencies
    func removeMinimumReachedFromOptionController() {
        optionController.allMinimumReached[self.optionID] = nil
    }
}
