//
//  AddressCardViewModel.swift
//  SnappyV2
//
//  Created by David Bage on 15/04/2022.
//

import Foundation
import Combine
import OSLog

class AddressCardViewModel: ObservableObject {
    private let container: DIContainer
    private let address: Address
    private var cancellables = Set<AnyCancellable>()
    
    @Published var profile: MemberProfile?
    
    var isDefault: Bool
    
    var allowDelete: Bool {
        isDefault == false
    }
    
    init(container: DIContainer, address: Address) {
        self.container = container
        self.address = address
        let appState = container.appState
        self.isDefault = address.isDefault == true // isDefault is optional so == true required here
        
        self._profile = .init(wrappedValue: appState.value.userData.memberProfile)
        
        setupBindToProfile(with: appState)
    }
    
    private func setupBindToProfile(with appState: Store<AppState>) {
        appState
            .map(\.userData.memberProfile)
            .receive(on: RunLoop.main)
            .sink { [weak self] profile in
                guard let self = self else { return }
                self.profile = profile
                
                if let addresses = profile?.savedAddresses {
                    for address in addresses {
                        if address.id == self.address.id {
                            self.isDefault = address.isDefault == true
                        }
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    func setAddressToDefault() {
        guard let addressID = address.id else { return }
        container.services.userService.setDefaultAddress(addressId: addressID)
            .sink { completion in
                switch completion {
                case .finished:
                    Logger.member.log("Successfully set address with ID \(addressID) to default")
                case .failure(let err):
                    Logger.member.error("Failed to set address with ID \(addressID) to default : \(err.localizedDescription)")
                }
            }
            .store(in: &cancellables)
    }
    
    func deleteAddress() {
        guard let addressID = address.id else { return }
        container.services.userService.removeAddress(addressId: addressID)
            .sink { completion in
                switch completion {
                case .finished:
                    Logger.member.log("Successfully deleted address with ID \(addressID)")
                case .failure(let err):
                    Logger.member.error("Failed to delete address with ID \(addressID) : \(err.localizedDescription)")
                }
            }
            .store(in: &cancellables)
    }
}
