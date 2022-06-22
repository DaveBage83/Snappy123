//
//  AddressCardViewModel.swift
//  SnappyV2
//
//  Created by David Bage on 15/04/2022.
//

import Foundation
import Combine
import OSLog

@MainActor
class AddressCardViewModel: ObservableObject {
    private let container: DIContainer
    private let address: Address
    private var cancellables = Set<AnyCancellable>()
    
    @Published var profile: MemberProfile?
    @Published private(set) var error: Error?
    
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
    
    func setAddressToDefault() async {
        guard let addressID = address.id else { return }
        do {
            try await container.services.userService.setDefaultAddress(addressId: addressID)
            Logger.member.log("Successfully set address with ID \(addressID) to default")
        } catch {
            self.error = error
            Logger.member.error("Failed to set address with ID \(addressID) to default : \(error.localizedDescription)")
        }
    }
    
    func deleteAddress() async {
        guard let addressID = address.id else { return }
        do {
            try await container.services.userService.removeAddress(addressId: addressID)
            Logger.member.log("Successfully deleted with ID \(addressID) to default")
        } catch {
            self.error = error
            Logger.member.error("Failed to deleted address with ID \(addressID): \(error.localizedDescription)")
        }
    }
}
