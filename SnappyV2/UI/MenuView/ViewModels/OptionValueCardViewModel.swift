//
//  OptionValueCardViewModel.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 12/08/2021.
//

import Foundation
import Combine
import SwiftUI

@MainActor
class OptionValueCardViewModel: ObservableObject {
    let container: DIContainer
    let optionController: OptionController
    let currency: RetailStoreCurrency
    let title: String
    let optionID: Int
    let optionValueID: Int
    let sizeID: Int?
    let extraCost: Double?
    @Published var price = ""
    @Published var quantity = Int()
    let optionsType: OptionValueType
    @Published var isSelected = Bool()
    let sizeExtraCosts: [RetailStoreMenuItemOptionValueSizeCost]?
    
    var showDeleteButton: Bool { quantity == 1 }
    
    private var cancellables = Set<AnyCancellable>()
    
    init(container: DIContainer, currency: RetailStoreCurrency, optionValue: RetailStoreMenuItemOptionValue, optionID: Int, optionsType: OptionValueType, optionController: OptionController) {
        self.container = container
        self.title = optionValue.name
        self.currency = currency
        self.optionValueID = optionValue.id
        self.sizeID = nil
        self.optionID = optionID
        self.extraCost = optionValue.extraCost
        self.optionsType = optionsType
        self.optionController = optionController
        self.sizeExtraCosts = optionValue.sizeExtraCost
        
        setupQuantity()
        setupPrice()
    }
    
    init(container: DIContainer, currency: RetailStoreCurrency, size: RetailStoreMenuItemSize, optionController: OptionController) {
        self.container = container
        self.title = size.name
        self.currency = currency
        self.optionValueID = Int()
        self.sizeID = size.id
        self.extraCost = nil
        self.optionID = 0
        self.optionsType = .radio
        self.optionController = optionController
        self.sizeExtraCosts = nil
        
        if size.price.price != 0 {
            self.price = " + " + size.price.price.toCurrencyString(using: currency)
        }
        
        setupSizeIsSelected()
    }
    
    lazy var isDisabled = { [weak self] (maxReached: Binding<Bool>) -> Bool in
        guard let self = self else { return false }
        guard self.optionsType != .radio else { return false }
        
        if maxReached.wrappedValue && self.optionsType == .stepper { return true }
        
        if maxReached.wrappedValue && self.isSelected == false { return true }
        
        return false
    }
    
    private func setupQuantity() {
        optionController.$selectedOptionAndValueIDs
            .map { [weak self] dict -> [Int] in
                guard let self = self else { return [] }
                if let value = dict[self.optionID] {
                    return value
                }
                return []
            }
            .map { [weak self] value -> [Int] in
                guard let self = self else { return [] }
                return value.filter { $0 == self.optionValueID }
            }
            .map { $0.count }
            .receive(on: RunLoop.main)
            .sink { [weak self] value in
                guard let self = self else { return }
                guaranteeMainThread {
                    self.quantity = value
                    self.isSelected = value >= 1
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupSizeIsSelected() {
        optionController.$selectedSizeID
            .subscribe(on: RunLoop.main)
            .removeDuplicates()
            .map { [weak self] sizeIdValue in
                guard let self = self else { return false }
                return sizeIdValue == self.sizeID
            }
            .receive(on: RunLoop.main)
            .assignWeak(to: \.isSelected, on: self)
            .store(in: &cancellables)
    }
    
    func addValue(maxReached: Binding<Bool>) {
        if let sizeID = sizeID {
            optionController.selectedSizeID = sizeID
        } else {
            if isDisabled(maxReached) == false {
                if optionController.selectedOptionAndValueIDs[optionID] != nil, optionsType != .radio {
                    optionController.selectedOptionAndValueIDs[optionID]?.append(optionValueID)
                } else {
                    optionController.selectedOptionAndValueIDs[optionID] = [optionValueID]
                }
            }
        }
    }
    
    func removeValue() {
        if sizeID != nil{
            optionController.selectedSizeID = nil
        } else {
            if let _ = optionController.selectedOptionAndValueIDs[optionID] {
                if let index = optionController.selectedOptionAndValueIDs[optionID]?.firstIndex(of: optionValueID) {
                    optionController.selectedOptionAndValueIDs[optionID]?.remove(at: index)
                }
            }
        }
    }
    
    func toggleValue(maxReached: Binding<Bool>) {
        guard optionsType != .manyMore else { return }
        if optionsType == .stepper && quantity > 0 { return }
        
        if sizeID == nil {
            isSelected ? removeValue() : addValue(maxReached: maxReached)
        } else {
            addValue(maxReached: maxReached)
        }
    }
    
    // triggered from view .onAppear() modifier
    func setupPrice() {
        if let extraCost = extraCost, extraCost != 0 {
            
            price = " + " + extraCost.toCurrencyString(using: currency)
            
            optionController.$selectedSizeID
                .map { [weak self] sizeid in
                    guard let self = self else { return "" }
                    
                    if let sizeid = sizeid {
                        if let sizeExtraCosts = self.sizeExtraCosts {
                            for sizeExtraCost in sizeExtraCosts {
                                if sizeid == sizeExtraCost.sizeId {
                                    return  " + " +  sizeExtraCost.extraCost.toCurrencyString(using: self.currency)
                                }
                            }
                        }
                    }
                    return " + " + extraCost.toCurrencyString(using: self.currency)
                }
                .receive(on: RunLoop.main)
                .assignWeak(to: \.price, on: self)
                .store(in: &cancellables)
        }
    }
}
