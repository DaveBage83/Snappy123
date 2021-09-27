//
//  StoresViewModel.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 27/09/2021.
//

import Combine

class StoresViewModel: ObservableObject {
    let container: DIContainer
    @Published var postcodeSearchString: String
    @Published var isDeliverySelected = false
    @Published var emailToNotify = ""
    
    var hasReturnedResult: Bool = false
    private var cancellables = Set<AnyCancellable>()
    
    init(container: DIContainer) {
        self.container = container
        
        let appState = container.appState
        
        self.postcodeSearchString = appState.value.userSetting.postcodeSearch
        
        $postcodeSearchString
            .sink { appState.value.userSetting.postcodeSearch = $0 }
            .store(in: &cancellables)
        
        appState
            .map(\.userSetting.postcodeSearch)
            .removeDuplicates()
            .assignWeak(to: \.postcodeSearchString, on: self)
            .store(in: &cancellables)
        
        // Temporary sub to demonstrate view change
        $postcodeSearchString
            .sink { value in
                self.hasReturnedResult = value.isEmpty == false
            }
            .store(in: &cancellables)
        
        initialSearch()
    }
    
    func sendNotificationEmail() {
        // send email address to server
    }
    
    func initialSearch() {
        if postcodeSearchString.isEmpty == false {
            
        }
    }
}
