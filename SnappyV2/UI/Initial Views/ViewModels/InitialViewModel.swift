//
//  InitialViewModel.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 16/09/2021.
//

import Combine
import SwiftUI

class InitialViewModel: ObservableObject {
    let container: DIContainer
    
    @Published var postcode: String
    
    @Published var loginButtonPressed = false
    
    @Published var hasStore = false
    
    @Published var search: Loadable<RetailStoresSearch>
    @Published var details: Loadable<RetailStoreDetails>
    
    var cancellables = Set<AnyCancellable>()
    
    init(container: DIContainer, search: Loadable<RetailStoresSearch> = .notRequested, details: Loadable<RetailStoreDetails> = .notRequested) {
        self.postcode = ""
        self.container = container
        self.search = search
        self.details = details
        
        let appState = container.appState
        
        _postcode = .init(initialValue: appState.value.userData.postcodeSearch)
        
        $postcode
            .sink { appState.value.userData.postcodeSearch = $0 }
            .store(in: &cancellables)
        
        appState
            .map(\.userData.postcodeSearch)
            .removeDuplicates()
            .assignWeak(to: \.postcode, on: self)
            .store(in: &cancellables)
        
        $search
            .sink { appState.value.userData.searchResult = $0 }
            .store(in: &cancellables)
        
        appState
            .map(\.userData.searchResult)
            .removeDuplicates()
            .assignWeak(to: \.search, on: self)
            .store(in: &cancellables)
        
        $search
            .sink { value in
                container.appState.value.routing.showInitialView = value.value?.stores == nil
            }
            .store(in: &cancellables)
    }
    
    func searchLocalStoresPressed() {
        container.appState.value.routing.showInitialView = false
    }
    
    func tapLoadRetailStores() {
        
        container.services.retailStoresService.searchRetailStores(search: loadableSubject(\.search), postcode: "DD2 1RW")
        //container.services.retailStoresService.getStoreDetails(details: loadableSubject(\.details), storeId: 30, postcode: "DD1 3JA")
        
        //let mockData = RetailStoreDetails.mockedData
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Europe/London")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        // for testing set the dates to the current or future date
        if
            let startDate = formatter.date(from: "2021-10-11 00:00:00"),
            let endDate = formatter.date(from: "2021-10-11 23:59:59")
        {
            container.services.retailStoresService.getStoreDeliveryTimeSlots(
                slots: loadableSubject(\.slots),
                storeId: 30,
                startDate: startDate,
                endDate: endDate,
                location: CLLocationCoordinate2D(latitude: 56.473358599999997, longitude: -3.0111853000000002)
            )
        }
        
        
// old search style fetch prior to embracing loadables
//        let publisher = container.services.retailStoresService.searchRetailStores(postcode: "DD1 3JA")
//
//        publisher
//            .sink(receiveCompletion: { completion in
//                if case .failure(let error) = completion {
//                    print("** error \(error) **")
//                } else {
//                    print("** concluded **")
//                }
//            }, receiveValue: { (found: Bool) in
//                print(found)
//            })
//            .store(in: &cancellables)
    }
}
