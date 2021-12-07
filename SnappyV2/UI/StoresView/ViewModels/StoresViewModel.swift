//
//  StoresViewModel.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 27/09/2021.
//

import Combine
import Foundation

class StoresViewModel: ObservableObject {
    let container: DIContainer
    @Published var postcodeSearchString: String = ""
    @Published var emailToNotify = ""
    @Published var selectedOrderMethod: RetailStoreOrderMethodType
    @Published var selectedRetailStoreDetails: Loadable<RetailStoreDetails>
    @Published var storeSearchResult: Loadable<RetailStoresSearch>
    @Published var retailStores = [RetailStore]()
    @Published var shownRetailStores = [RetailStore]()
    @Published var retailStoreTypes = [RetailStoreProductType]()
    @Published var filteredRetailStoreType: Int?
    
    @Published var shownOpenStores = [RetailStore]()
    @Published var showClosedStores = [RetailStore]()
    @Published var showPreorderStores = [RetailStore]()
    
    @Published var isFocused = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init(container: DIContainer) {
        self.container = container
        let appState = container.appState
        
        _storeSearchResult = .init(initialValue: appState.value.userData.searchResult)
        _selectedRetailStoreDetails = .init(initialValue: appState.value.userData.selectedStore)
        _selectedOrderMethod = .init(initialValue: appState.value.userData.selectedFulfilmentMethod)
        
        setupBindToSearchStoreResult(with: appState)
        
        setupBindToSelectedRetailStoreDetails(with: appState)
        
        setupBindToSelectedOrderMethod(with: appState)
        
        setupRetailStoreTypes()
        
        setupSelectedRetailStoreTypesANDIsDeliverySelected()
        
        setupOrderMethodStatusSections()
    }
    
    var isLoading: Bool {
        switch storeSearchResult {
        case .isLoading(last: _, cancelBag: _):
            return true
        default:
            return false
        }
    }
    
    var isDeliverySelected: Bool {
        selectedOrderMethod == .delivery
    }
    
    private func setupBindToSearchStoreResult(with appState: Store<AppState>) {
        appState
            .map(\.userData.searchResult)
            .removeDuplicates()
            .assignWeak(to: \.storeSearchResult, on: self)
            .store(in: &cancellables)
        
        $storeSearchResult
            .compactMap { result in
                result.value?.stores
            }
            .receive(on: RunLoop.main)
            .assignWeak(to: \.retailStores, on: self)
            .store(in: &cancellables)
    }
    
    private func setupBindToSelectedRetailStoreDetails(with appState: Store<AppState>) {
        $selectedRetailStoreDetails
            .sink { appState.value.userData.selectedStore = $0 }
            .store(in: &cancellables)
        
        appState
            .map(\.userData.selectedStore)
            .removeDuplicates()
            .assignWeak(to: \.selectedRetailStoreDetails, on: self)
            .store(in: &cancellables)
    }
    
    private func setupBindToSelectedOrderMethod(with appState: Store<AppState>) {
        $selectedOrderMethod
            .sink { appState.value.userData.selectedFulfilmentMethod = $0 }
            .store(in: &cancellables)
        
        appState
            .map(\.userData.selectedFulfilmentMethod)
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .assignWeak(to: \.selectedOrderMethod, on: self)
            .store(in: &cancellables)
    }
    
    private func setupRetailStoreTypes() {
        $storeSearchResult
            .map { result in
                result.value?.storeProductTypes ?? []
            }
            .receive(on: RunLoop.main)
            .assignWeak(to: \.retailStoreTypes, on: self)
            .store(in: &cancellables)
    }
    
    private func setupSelectedRetailStoreTypesANDIsDeliverySelected() {
        Publishers.CombineLatest3($selectedOrderMethod, $filteredRetailStoreType, $retailStores)
            .map { selectedOrderMethod, selectedType, retailStores -> ([RetailStore], RetailStoreOrderMethodType) in
                
                var returnStores = [RetailStore]()
                
                if let unwrappedSelectedType = selectedType {
                        var tempStores = [RetailStore]()
                        
                        for store in retailStores {
                            if let storeTypes = store.storeProductTypes {
                                if storeTypes.contains(unwrappedSelectedType) {
                                    tempStores.append(store)
                                }
                            }
                        }
                        
                        returnStores = tempStores
                    } else {
                        returnStores = retailStores
                    }
                
                return (returnStores, selectedOrderMethod)
            }
            .map { stores, selectedOrderMethod in
                guard stores.isEmpty == false else { return [] }
                
                var returnStores = [RetailStore]()
                
                returnStores = stores.filter { value in
                    if let orderMethods = value.orderMethods {
                        return orderMethods.keys.contains(selectedOrderMethod.rawValue)
                    }
                    return false
                }
                
                return returnStores
            }
            .receive(on: RunLoop.main)
            .assignWeak(to: \.shownRetailStores, on: self)
            .store(in: &cancellables)
    }
    
    private func setupOrderMethodStatusSections() {
        // setup Open Stores
        Publishers.CombineLatest($shownRetailStores, $selectedOrderMethod)
            .map { stores, selectedOrderMethod in
                return stores.filter { store in
                    return store.orderMethods?[selectedOrderMethod.rawValue]?.status == .open
                }
            }
            .receive(on: RunLoop.main)
            .assignWeak(to: \.shownOpenStores, on: self)
            .store(in: &cancellables)
        
        // setup Closed Stores
        Publishers.CombineLatest($shownRetailStores, $selectedOrderMethod)
            .map { stores, selectedOrderMethod in
                return stores.filter { store in
                    return store.orderMethods?[selectedOrderMethod.rawValue]?.status == .closed
                }
            }
            .receive(on: RunLoop.main)
            .assignWeak(to: \.showClosedStores, on: self)
            .store(in: &cancellables)
        
        // setup Preorder Stores
        Publishers.CombineLatest($shownRetailStores, $selectedOrderMethod)
            .map { stores, selectedOrderMethod in
                return stores.filter { store in
                    return store.orderMethods?[selectedOrderMethod.rawValue]?.status == .preorder
                }
            }
            .receive(on: RunLoop.main)
            .assignWeak(to: \.showPreorderStores, on: self)
            .store(in: &cancellables)
    }
    
    func sendNotificationEmail() {
        #warning("send email address to server once API exists")
    }
    
    func searchPostcode() {
        isFocused = false
        container.services.retailStoresService.searchRetailStores(search: loadableSubject(\.storeSearchResult), postcode: postcodeSearchString)
    }
    
    func selectStore(id: Int) {
        if let postcode = storeSearchResult.value?.fulfilmentLocation.postcode {
        container.services.retailStoresService.getStoreDetails(details: loadableSubject(\.selectedRetailStoreDetails), storeId: id, postcode: postcode)
        }
	}

    func selectFilteredRetailStoreType(id: Int) {
        filteredRetailStoreType = id
    }
    
    func clearFilteredRetailStoreType() {
        filteredRetailStoreType = nil
    }
}
