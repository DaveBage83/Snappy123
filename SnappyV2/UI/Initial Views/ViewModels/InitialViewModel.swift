//
//  InitialViewModel.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 16/09/2021.
//

import Combine
import SwiftUI

// just for testing with CLLocationCoordinate2D
import MapKit

class InitialViewModel: ObservableObject {
    
    enum NavigationDestination: Hashable {
            case login
            case create
    }
    
    let container: DIContainer
    
    @Published var postcode: String
    
    @Published var loginButtonPressed = false
    
    @Published var hasStore = false

    @Published var viewState: NavigationDestination?
    
    @Published var isUserSignedIn: Bool
    
    @Published var search: Loadable<RetailStoresSearch>
    @Published var details: Loadable<RetailStoreDetails>
    @Published var slots: Loadable<RetailStoreTimeSlots>
    @Published var menuFetch: Loadable<RetailStoreMenuFetch>
    @Published var globalSearch: Loadable<RetailStoreMenuGlobalSearch>
    
    private var cancellables = Set<AnyCancellable>()
    
    init(container: DIContainer, search: Loadable<RetailStoresSearch> = .notRequested, details: Loadable<RetailStoreDetails> = .notRequested, slots: Loadable<RetailStoreTimeSlots> = .notRequested, menuFetch: Loadable<RetailStoreMenuFetch> = .notRequested, globalSearch: Loadable<RetailStoreMenuGlobalSearch> = .notRequested) {
        
        #if DEBUG
        self.postcode = "PA34 4AG"
        #else
        self.postcode = ""
        #endif
        self.container = container
        self.search = search
        self.details = details
        self.slots = slots
        self.menuFetch = menuFetch
        self.globalSearch = globalSearch
        
        let appState = container.appState
        
        // Set initial isUserSignedIn flag to current appState value
        self._isUserSignedIn = .init(initialValue: appState.value.userData.memberSignedIn)

        setupBindToRetailStoreSearch(with: appState)
        setupBindToMemberSignedIn()
        
        $search
            .sink { value in
                container.appState.value.routing.showInitialView = value.value?.stores == nil
            }
            .store(in: &cancellables)
    }
    
    private func setupBindToMemberSignedIn() {
        $isUserSignedIn 
            .sink { [weak self] signedIn in
                guard let self = self else { return }
                
                if signedIn {
                    self.viewState = nil
                }
            }
            .store(in: &cancellables)
        
        container.appState
            .map(\.userData.memberSignedIn)
            .receive(on: RunLoop.main)
            .assignWeak(to: \.isUserSignedIn, on: self)
            .store(in: &cancellables)
    }
    
    var isLoading: Bool {
        switch search {
        case .isLoading(last: _, cancelBag: _):
            return true
        default:
            return false
        }
    }
    
    private func setupBindToRetailStoreSearch(with appState: Store<AppState>) {
        appState
            .map(\.userData.searchResult)
            .removeDuplicates()
            .assignWeak(to: \.search, on: self)
            .store(in: &cancellables)
    }
    
    func searchLocalStoresPressed() {
        container.appState.value.routing.showInitialView = false
    }
    
    func loginTapped() {
        viewState = .login
    }
    
    func signUpTapped() {
        viewState = .create
    }
    
    func tapLoadRetailStores() {
        
        container.services.retailStoresService.searchRetailStores(postcode: self.postcode)
        
//        container.services.retailStoresService.searchRetailStores(search: loadableSubject(\.search), postcode: "DD2 1RW")
//        container.services.retailStoresService.searchRetailStores(search: loadableSubject(\.search), postcode: "")
        
//        container.services.retailStoresService.searchRetailStores(
//            search: loadableSubject(\.search),
//            location: CLLocationCoordinate2D(latitude: 56.473358599999997, longitude: -3.0111853000000002)
//        )
        
//        container.services.retailStoresService.getStoreDetails(details: loadableSubject(\.details), storeId: 30, postcode: "DD1 3JA")

        
//        let formatter = DateFormatter()
//        formatter.locale = Locale(identifier: "en_US_POSIX")
//        formatter.timeZone = TimeZone(identifier: "Europe/London")
//        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//
//        // for testing set the dates to the current or future date
//        if
//            let startDate = formatter.date(from: "2021-10-16 00:00:00"),
//            let endDate = formatter.date(from: "2021-10-16 23:59:59")
//        {
//            container.services.retailStoresService.getStoreDeliveryTimeSlots(
//                slots: loadableSubject(\.slots),
//                storeId: 30,
//                startDate: startDate,
//                endDate: endDate,
//                location: CLLocationCoordinate2D(latitude: 56.473358599999997, longitude: -3.0111853000000002)
//            )
//        }
        
//        container.services.retailStoreMenuService.getRootCategories(menuFetch: loadableSubject(\.menuFetch), storeId: 30, fulfilmentMethod: .delivery)
        
//        container.appState.value.userData.selectedFulfilmentMethod = .delivery
//        container.services.retailStoreMenuService.getChildCategoriesAndItems(menuFetch: loadableSubject(\.menuFetch), storeId: 910, categoryId: 179951)
        
//        container.services.basketService.test(delay: 2.0).sink(
//            receiveCompletion: { (error) in
//                print("test finished 0: \(String(describing: error))")
//            },
//            receiveValue: { value in
//                print("test 0: \(value)")
//            }
//        ).store(in: &cancellables)
        
//        container.appState.value.userData.selectedFulfilmentMethod = .delivery
//        container.appState.value.userData.selectedStore = .loaded(RetailStoreDetails.mockedData)
//
//        container.services.retailStoreMenuService.globalSearch(
//            searchFetch: loadableSubject(\.globalSearch),
//            searchTerm: "test",
//            scope: nil,
//            itemsPagination: nil,
//            categoriesPagination: nil
//        )
        

//
//        let item = BasketItemRequest(
//            menuItemId: 2827972,
//            quantity: 2,
//            sizeId: 0,
//            bannerAdvertId: 0,
//            options: []
//        )
//
//        container.services.basketService.addItem(item: item).sink(
//            receiveCompletion: { (error) in
//                print("add finished: \(String(describing: error))")
//            },
//            receiveValue: { value in
//                print("add: \(value)")
//            }
//        ).store(in: &cancellables)
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
//            //call any function
//            self.container.services.basketService.applyCoupon(code: "KKTEST50PERCENTOFF").sink(
//                receiveCompletion: { (error) in
//                    print("restoreBasket finished: \(String(describing: error))")
//                },
//                receiveValue: { value in
//                    print("restoreBasket: \(value)")
//                }
//            ).store(in: &self.cancellables)
//        }
        
//        let item2 = BasketItemRequest(
//            menuItemId: 2896196,
//            quantity: 1,
//            sizeId: 0,
//            bannerAdvertId: 0,
//            options: []
//        )
//
//        container.services.basketService.addItem(item: item2).sink(
//            receiveCompletion: { (error) in
//                print("add finished: \(String(describing: error))")
//            },
//            receiveValue: { value in
//                print("add: \(value)")
//            }
//        ).store(in: &cancellables)
        
        
//        container.services.basketService.restoreBasket().sink(
//            receiveCompletion: { (error) in
//                print("restoreBasket finished: \(String(describing: error))")
//            },
//            receiveValue: { value in
//                print("restoreBasket: \(value)")
//            }
//        ).store(in: &cancellables)
//        
//        container.services.basketService.test(delay: 2.0).sink(
//            receiveCompletion: { (error) in
//                print("test finished 1: \(String(describing: error))")
//            },
//            receiveValue: { value in
//                print("test 1: \(value)")
//            }
//        ).store(in: &cancellables)
//
//        container.services.basketService.test(delay: 3.0).sink(
//            receiveCompletion: { (error) in
//                print("test finished 2: \(String(describing: error))")
//            },
//            receiveValue: { value in
//                print("test 2: \(value)")
//            }
//        ).store(in: &cancellables)

//        container.services.basketService.reserveTimeSlot(
//            timeSlotDate: "2021-12-13",
//            timeSlotTime: "11:00 - 12:00"
//        ).sink(
//            receiveCompletion: { (error) in
//                print("reserveTimeSlot finished: \(String(describing: error))")
//            },
//            receiveValue: { value in
//                print("reserveTimeSlot: \(value)")
//            }
//        ).store(in: &cancellables)
        
    }
}
