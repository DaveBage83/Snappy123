//
//  DeliverySlotSelectionViewModel.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 24/09/2021.
//
import Foundation

class DeliverySlotSelectionViewModel: ObservableObject {
    @Published var isDeliverySelected = false
    
    @Published var selectedDaySlot: Int?
    @Published var selectedTimeSlot: UUID?
    
    var isDateSelected: Bool {
        return selectedDaySlot != nil && selectedTimeSlot != nil
    }
    
    @Published var isASAPDeliverySelected = false
    @Published var isFutureDeliverySelected = false
    
    func isASAPDeliveryTapped() { isASAPDeliverySelected = true }
    
    func isFutureDeliveryTapped() { isFutureDeliverySelected = true }
}
