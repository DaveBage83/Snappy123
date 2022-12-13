//
//  CheckoutSlotExpiryViewModel.swift
//  SnappyV2
//
//  Created by David Bage on 12/12/2022.
//

import Combine
import SwiftUI
import Foundation

enum SlotExpiryError: Swift.Error, Equatable {
    case slotExpired
}

extension SlotExpiryError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .slotExpired:
            return Strings.CheckoutView.SlotExpiry.error.localized
        }
    }
}

class CheckoutSlotExpiryViewModel: ObservableObject {
    // MARK: - Expiry state - controls format of expiry pill depending on time remaining
    enum ExpiryState {
        case ok
        case warning
        case ended
        
        func color(colorPalette: ColorPalette) -> Color {
            switch self {
            case .ok:
                return colorPalette.alertSuccess
            case .warning, .ended:
                return colorPalette.alertWarning
            }
        }
        
        func editIconColor(colorPalette: ColorPalette) -> Color {
            switch self {
            case .ok, .warning:
                return colorPalette.primaryBlue
            case .ended:
                return .white
            }
        }
        
        func textColor(colorPalette: ColorPalette) -> Color {
            switch self {
            case .ok:
                return colorPalette.alertSuccess
            case .warning:
                return colorPalette.alertWarning
            case .ended:
                return .white
            }
        }
        
        var pillOpacity: Color.Opacity {
            switch self {
            case .ok, .warning:
                return .ten
            case .ended:
                return .full
            }
        }
    }
    
    // MARK: - Publishers
    @Published var timeRemaining: Double = 0
    @Published var fulfilmentTimeSlotSelectionPresented = false
    
    // MARK: - Properties
    let container: DIContainer
    let visible: Bool
    private let dateGenerator: () -> Date
    
    private let currentTime = Date()
    var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - State
    var expiryState: ExpiryState {
        if timeRemaining > AppV2Constants.Business.expiryWarningThreshold {
            return .ok
        } else if timeRemaining > 0 {
            return .warning
        }
        return .ended
    }
    
    // MARK: - Computed variables
    var timeRemainingString: String {
        let mins = Int(timeRemaining / 60)
        let hrs = Int(mins / 60)
        let hrsInMins = Double(hrs * 60)
        let remainingMins = Int(Double(mins) - hrsInMins)
        
        if hrs > 0 {
            let hrString = hrs > 1 ? GeneralStrings.hours.localized : GeneralStrings.hour.localized
            return Strings.CheckoutView.SlotExpiryCustom.expiresInHrsAndMins.localizedFormat(String(hrs), hrString, String(remainingMins))
        } else if mins > 0 {
            return Strings.CheckoutView.SlotExpiryCustom.expiresInMins.localizedFormat(String(mins))
        } else if timeRemaining > 0 {
            return Strings.CheckoutView.SlotExpiryCustom.expiresInSecs.localizedFormat(String(Int(timeRemaining)))
        }
        
        return Strings.CheckoutView.SlotExpiry.tapForNewSlot.localized
    }
        
    // MARK: - Init
    init(container: DIContainer, visible: Bool = true, dateGenerator: @escaping () -> Date = Date.init) {
        self.container = container
        self.visible = visible
        self.dateGenerator = dateGenerator
        let appState = container.appState
        self.setupBindToBasketSlotExpiry(with: appState)
        self.setupBindToTodayExpiry(with: appState)
    }

    // MARK: - Bind to slot expiry in the appState
    private func setupBindToBasketSlotExpiry(with appState: Store<AppState>) {
        appState
            .map(\.userData.basket?.selectedSlot?.expires)
            .receive(on: RunLoop.main)
            .sink { [weak self] expires in
                guard let self = self else { return }
                
                if let expires {
                    self.timer.upstream.connect().cancel()
                    let expiresTimeInterval = expires.timeIntervalSince1970
                    let currentDateTimeInterval = self.dateGenerator().timeIntervalSince1970
                    
                    self.timeRemaining = expiresTimeInterval - currentDateTimeInterval
                    
                    if self.timeRemaining > 0 {
                        self.timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Bind to today expiry in appState (for temp time slots)
    private func setupBindToTodayExpiry(with appState: Store<AppState>) {
        appState
            .map(\.userData.todaySlotExpiry)
            .receive(on: RunLoop.main)
            .sink { [weak self] todaySlotExpiry in
                guard let self = self else { return }
                if let todaySlotExpiry {
                    self.timer.upstream.connect().cancel()
                    self.timeRemaining = todaySlotExpiry - self.dateGenerator().timeIntervalSince1970
                    
                    if self.timeRemaining > 0 {
                        self.timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Timer method
    func configureTimeRemaining() {
        if timeRemaining > 1 {
            container.appState.value.userData.slotExpired = false
            timeRemaining -= 1
        } else {
            self.timer.upstream.connect().cancel()
            container.appState.value.errors.append(SlotExpiryError.slotExpired)
            container.appState.value.userData.slotExpired = true
        }
    }
}
