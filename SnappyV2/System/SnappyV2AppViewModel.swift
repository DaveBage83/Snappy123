//
//  SnappyV2AppViewModel.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 21/09/2021.
//

import Combine
import Foundation

class SnappyV2AppViewModel: ObservableObject {
    let environment: AppEnvironment
    @Published var showInitialView: Bool = true
    
    private var cancellables = Set<AnyCancellable>()
    
    init(appEnvironment: AppEnvironment = AppEnvironment.bootstrap()) {
        environment = appEnvironment
        
#if DEBUG
//Use this for inspecting the Core Data
if let directoryLocation = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).last {
    print("Documents Directory: \(directoryLocation)Application Support")
}
#endif
        
        environment.container.appState
            .map(\.routing.showInitialView)
            .removeDuplicates() // Needed to make it work. 🤷‍♂️
            .assignWeak(to: \.showInitialView, on: self)
            .store(in: &cancellables)
    }
}
