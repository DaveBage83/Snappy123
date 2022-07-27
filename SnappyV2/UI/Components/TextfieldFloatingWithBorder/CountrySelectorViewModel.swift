//
//  CountrySelectorViewModel.swift
//  SnappyV2
//
//  Created by David Bage on 27/07/2022.
//

import Foundation
import Combine

class CountrySelectorViewModel: ObservableObject {
    @Published var selectedCountry: AddressSelectionCountry?
    @Published var selectionCountriesRequest: Loadable<[AddressSelectionCountry]?> = .notRequested
    @Published var selectionCountries = [AddressSelectionCountry]()
    @Published var countryText = ""
    
    let container: DIContainer
    private var cancellables = Set<AnyCancellable>()
    private let fulfilmentLocation: String
    
    init(container: DIContainer, starterCountryCode: String? = nil, countrySelected: @escaping (AddressSelectionCountry) -> ()) {
        self.container = container
        self.fulfilmentLocation = self.container.appState.value.userData.currentFulfilmentLocation?.country ?? AppV2Constants.Business.operatingCountry
        
        getCountries()
        setupSelectionCountries(starterCountryCode: starterCountryCode)
        setupSelectedCountry(countrySelected: countrySelected)
    }

    // MARK: - Country methods
    private func getCountries() {
        self.container.services.addressService.getSelectionCountries(countries: self.loadableSubject(\.selectionCountriesRequest))
    }
    
    private func setupSelectionCountries(starterCountryCode: String?) {
        $selectionCountriesRequest
            .map { result in
                return result.value
            }
            .replaceNil(with: [])
            .receive(on: RunLoop.main)
            .sink { [weak self] countries in
                guard let self = self, let countries = countries else { return }
                self.selectionCountries = countries
                
                // Set default country if we have it stored in the userData
                
                if let starterCountryCode = starterCountryCode {
                    self.selectedCountry = countries.filter { $0.countryCode == starterCountryCode }.first
                } else {
                    self.selectedCountry = countries.filter { $0.countryCode == self.fulfilmentLocation }.first
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupSelectedCountry(countrySelected: @escaping (AddressSelectionCountry) -> ()) {
        $selectedCountry
            .receive(on: RunLoop.main)
            .sink { [weak self] country in
                guard let self = self, country != nil else { return }
                self.countryText = country?.countryName ?? ""
                
                if let country = country {
                    countrySelected(country)
                }
            }
            .store(in: &cancellables)
    }
    
    func selectCountry(country: AddressSelectionCountry) {
        self.selectedCountry = country
    }
}

