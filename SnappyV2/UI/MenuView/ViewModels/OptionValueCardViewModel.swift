//
//  OptionValueCardViewModel.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 12/08/2021.
//

import Foundation
import Combine
import SwiftUI

class OptionValueCardViewModel: ObservableObject {
    let optionController: OptionController
    let title: String
    let optionID: Int
    let optionValueID: Int
    let sizeID: Int?
    let extraCost: Double?
    var price = ""
    @Published var quantity = Int()
    let optionsType: OptionValueType
    @Published var isSelected = Bool()
    let sizeExtraCosts: [RetailStoreMenuItemOptionValueSizeCost]?
    
    private var cancellables = Set<AnyCancellable>()
    
    init(optionValue: RetailStoreMenuItemOptionValue, optionID: Int, optionsType: OptionValueType, optionController: OptionController) {
        self.title = optionValue.name
        self.optionValueID = optionValue.id
        self.sizeID = nil
        self.optionID = optionID
        self.extraCost = optionValue.extraCost
        self.optionsType = optionsType
        self.optionController = optionController
        self.sizeExtraCosts = optionValue.sizeExtraCost
        
        setupQuantity()
    }
    
    init(size: RetailStoreMenuItemSize, optionController: OptionController) {
        self.title = size.name
        self.optionValueID = Int()
        self.sizeID = size.id
        self.extraCost = nil
        self.optionID = 0
        self.optionsType = .radio
        self.optionController = optionController
        self.sizeExtraCosts = nil
        
        if size.price.price != 0 {
            self.price = " + \(CurrencyFormatter.uk(size.price.price))"
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
            .sink { [weak self] value in
                guard let self = self else { return }
                self.quantity = value
                self.isSelected = value >= 1
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
        
        isSelected ? removeValue() : addValue(maxReached: maxReached)
    }
    
    func setupPrice() {
        if let extraCost = self.extraCost, self.extraCost != 0 {
            
            self.price = " + \(CurrencyFormatter.uk(extraCost))"
            
            optionController.$selectedSizeID
                .receive(on: RunLoop.main)
                .map { [weak self] sizeid in
                    guard let self = self else { return "" }
                    
                    if let sizeid = sizeid {
                        if let sizeExtraCosts = self.sizeExtraCosts {
                            for sizeExtraCost in sizeExtraCosts {
                                if sizeid == sizeExtraCost.sizeId {
                                    return  " + \(CurrencyFormatter.uk(sizeExtraCost.extraCost))"
                                }
                            }
                        }
                    }
                    return " + \(CurrencyFormatter.uk(extraCost))"
                }
                .assignWeak(to: \.price, on: self)
                .store(in: &cancellables)
        }
    }
}

#warning("Temporary solution, needs to move to somewhere central")
struct CurrencyFormatter {
    static var uk = { (price: Double) -> String in
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "gbp"
        formatter.maximumFractionDigits = 2
        
        let number = NSNumber(value: price)
        return formatter.string(from: number)!
    }
}
