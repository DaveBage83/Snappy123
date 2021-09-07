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
    let valueID: Int
    var price = ""
    @Published var quantity = Int()
    let optionsType: OptionValueType
    @Published var isSelected = Bool()
    var showPrice = false
    var sizeExtraCosts: [MenuItemOptionValueSize]?
    
    private var cancellables = Set<AnyCancellable>()
    
    init(optionValue: MenuItemOptionValue, optionID: Int, optionsType: OptionValueType, optionController: OptionController) {
        self.title = optionValue.name ?? "Unnamed option"
        self.valueID = optionValue.id
        self.optionID = optionID
        self.optionsType = optionsType
        self.optionController = optionController
        
        if let sizeExtraCosts = optionValue.sizeExtraCost {
            self.sizeExtraCosts = sizeExtraCosts
        }
        
        if let extraCost = optionValue.extraCost {
            setupPrice(price: extraCost)
        }
        
        setupQuantity()
    }
    
    init(size: MenuItemSize, optionController: OptionController) {
        self.title = size.name
        self.valueID = size.id
        self.optionID = 0
        self.optionsType = .radio
        self.optionController = optionController
        
        if let price = size.price {
            setupPrice(price: price)
        }
        
        setupQuantity()
    }
    
    func setupQuantity() {
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
                return value.filter { $0 == self.valueID }
            }
            .map { $0.count }
            .sink { [weak self] value in
                guard let self = self else { return }
                self.quantity = value
                self.isSelected = value >= 1
            }
            .store(in: &cancellables)
    }
    
    func addValue(maxReached: Binding<Bool>) {
        if isDisabled(maxReached) == false {
            if optionController.selectedOptionAndValueIDs[optionID] != nil, optionsType != .radio {
                optionController.selectedOptionAndValueIDs[optionID]?.append(valueID)
            } else {
                optionController.selectedOptionAndValueIDs[optionID] = [valueID]
            }
        }
    }
    
    func removeValue() {
        if let _ = optionController.selectedOptionAndValueIDs[optionID] {
            if let index = optionController.selectedOptionAndValueIDs[optionID]?.firstIndex(of: valueID) {
                optionController.selectedOptionAndValueIDs[optionID]?.remove(at: index)
            }
        }
    }
    
    func toggleValue(maxReached: Binding<Bool>) {
        guard optionsType != .manyMore else { return }
        if optionsType == .stepper && quantity > 0 { return }
        
        isSelected ? removeValue() : addValue(maxReached: maxReached)
    }
    
    func setupPrice(price: Double) {
        optionController.$selectedOptionAndValueIDs
            .sink { [weak self] dict in
                guard let self = self else { return }
                guard let values = dict[0] else { self.price =  " + \(CurrencyFormatter.uk(price))"; return  }
                
                if let sizeExtraCosts = self.sizeExtraCosts {
                    for sizeExtraCost in sizeExtraCosts {
                        if let sizeId = sizeExtraCost.sizeId, values.contains(sizeId), let extraCostPrice = sizeExtraCost.extraCost {
                            self.price =  " + \(CurrencyFormatter.uk(extraCostPrice))"
                        }
                    }
                }
            }
            .store(in: &cancellables)
        
        showPrice = true
    }
    
    lazy var isDisabled = { [weak self] (maxReached: Binding<Bool>) -> Bool in
        guard let self = self else { return false }
        guard self.optionsType != .radio else { return false }
        
        if maxReached.wrappedValue && self.optionsType == .stepper { return true }
        
        if maxReached.wrappedValue && self.isSelected == false { return true }
        
        return false
    }
}

#warning("Temporary solution, needs to move to app state")
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
