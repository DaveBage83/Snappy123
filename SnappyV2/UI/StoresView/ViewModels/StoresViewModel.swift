//
//  StoresViewModel.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 27/09/2021.
//

import Combine
import Foundation
import OSLog

class StoresViewModel: ObservableObject {
    let container: DIContainer
    @Published var postcodeSearchString: String
    @Published var emailToNotify = ""
    @Published var selectedOrderMethod: RetailStoreOrderMethodType
    @Published var selectedRetailStoreDetails: Loadable<RetailStoreDetails>
    @Published var storeSearchResult: Loadable<RetailStoresSearch>
    @Published var retailStores = [RetailStore]()
    @Published var shownRetailStores = [RetailStore]()
    @Published var retailStoreTypes = [RetailStoreProductType]()
    @Published var filteredRetailStoreType: Int?
    
    @Published var showOpenStores = [RetailStore]()
    @Published var showClosedStores = [RetailStore]()
    @Published var showPreorderStores = [RetailStore]()
    
    @Published var isFocused = false
    @Published var showFulfilmentSlotSelection = false
            
    private(set) var selectedStoreID: Int?
        
    private var cancellables = Set<AnyCancellable>()
    
    init(container: DIContainer) {
        self.container = container
        let appState = container.appState
        
        self.postcodeSearchString = appState.value.userData.searchResult.value?.fulfilmentLocation.postcode ?? ""
        
        _storeSearchResult = .init(initialValue: appState.value.userData.searchResult)
        _selectedRetailStoreDetails = .init(initialValue: appState.value.userData.selectedStore)
        _selectedOrderMethod = .init(initialValue: appState.value.userData.selectedFulfilmentMethod)
        setupBindToSearchStoreResult(with: appState)
        setupRetailStores()
        setupBindToSelectedRetailStoreDetails(with: appState)
        setupBindToSelectedOrderMethod(with: appState)
        setupRetailStoreTypes()
        setupSelectedRetailStoreTypesANDIsDeliverySelected()
        setupOrderMethodStatusSections()
        setupSelectedRetailStoreDetails()
    }
    
    var storesSearchIsLoading: Bool {
        switch storeSearchResult {
        case .isLoading(last: _, cancelBag: _):
            return true
        default:
            return false
        }
    }
    
    var selectedStoreIsLoading: Bool {
        switch selectedRetailStoreDetails {
        case .isLoading(last: _, cancelBag: _):
            return true
        default:
            return false
        }
    }
    
    var isDeliverySelected: Bool { selectedOrderMethod == .delivery }
    
    private func setupBindToSearchStoreResult(with appState: Store<AppState>) {
        appState
            .map(\.userData.searchResult)
            .removeDuplicates()
            .assignWeak(to: \.storeSearchResult, on: self)
            .store(in: &cancellables)
    }
    
    private func setupRetailStores() {
        $storeSearchResult
            .compactMap { result in
                result.value?.stores
            }
            .receive(on: RunLoop.main)
            .assignWeak(to: \.retailStores, on: self)
            .store(in: &cancellables)
    }
    
    private func setupSelectedRetailStoreDetails() {
        $selectedRetailStoreDetails
            .receive(on: RunLoop.main)
            .sink { [weak self] details in
                guard let self = self, self.selectedStoreID == details.value?.id else { return }

                switch self.selectedOrderMethod {
                case .delivery:
                    if let deliveryDays = details.value?.deliveryDays {
                        self.setNextView(fulfilmentDays: deliveryDays, storeTimeZone: details.value?.storeTimeZone)
                    }
                case .collection:
                    if let collectionDays = details.value?.collectionDays {
                        self.setNextView(fulfilmentDays: collectionDays, storeTimeZone: details.value?.storeTimeZone)
                    }
                default:
                    Logger.stores.fault("Failed to set next view as 'selectedOrderMethod is of unknown type - \(self.selectedOrderMethod.rawValue)")
                    return // We should not hit this as stores should only have delivery and collection
                }
            }
            .store(in: &cancellables)
    }

    private func setupBindToSelectedRetailStoreDetails(with appState: Store<AppState>) {
        appState
            .map(\.userData.selectedStore)
            .removeDuplicates()
            .assignWeak(to: \.selectedRetailStoreDetails, on: self)
            .store(in: &cancellables)
    }
    
    private func setupBindToSelectedOrderMethod(with appState: Store<AppState>) {
        $selectedOrderMethod
            .removeDuplicates()
            .sink { appState.value.userData.selectedFulfilmentMethod = $0 }
            .store(in: &cancellables)
        
        appState
            .map(\.userData.selectedFulfilmentMethod)
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .assignWeak(to: \.selectedOrderMethod, on: self)
            .store(in: &cancellables)
    }
    
    func fulfilmentMethodButtonTapped(_ method: RetailStoreOrderMethodType) {
        selectedOrderMethod = method
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
            .receive(on: RunLoop.main)
            .sink { [weak self] stores, selectedOrderMethod in
                guard let self = self else { return }
                self.showOpenStores = stores.filter { $0.orderMethods?[selectedOrderMethod.rawValue]?.status == .open }
                self.showClosedStores = stores.filter { $0.orderMethods?[selectedOrderMethod.rawValue]?.status == .closed }
                self.showPreorderStores = stores.filter { $0.orderMethods?[selectedOrderMethod.rawValue]?.status == .preorder }
            }
            .store(in: &cancellables)
    }
    
    private func setNextView(fulfilmentDays: [RetailStoreFulfilmentDay], storeTimeZone: TimeZone?) {
        if fulfilmentDays.count == 1, let fulfilmentDate = fulfilmentDays[0].date.trueDate, fulfilmentDate.isToday {
            self.showFulfilmentSlotSelection = false
            self.navigateToProductsView()
        } else {
            self.showFulfilmentSlotSelection = true
        }
    }
    
    func navigateToProductsView() {
        container.appState.value.routing.selectedTab = .menu
    }
    
    func sendNotificationEmail() {
        #warning("send email address to server once API exists")
    }
    
    func searchPostcode() {
        isFocused = false
        container.services.retailStoresService.searchRetailStores(postcode: postcodeSearchString)
    }
    
    func selectStore(id: Int) {
        selectedStoreID = id
        if let postcode = storeSearchResult.value?.fulfilmentLocation.postcode {
            container.services.retailStoresService.getStoreDetails(storeId: id, postcode: postcode)
            
            showFulfilmentSlotSelection = true
        }
	}

    func selectFilteredRetailStoreType(id: Int) {
        filteredRetailStoreType = id
    }
    
    func clearFilteredRetailStoreType() {
        filteredRetailStoreType = nil
    }
}
