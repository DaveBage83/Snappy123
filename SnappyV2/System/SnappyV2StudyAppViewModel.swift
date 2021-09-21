//
//  SnappyV2StudyAppViewModel.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 21/09/2021.
//

import Combine

class SnappyV2StudyAppViewModel: ObservableObject {
    let environment = AppEnvironment.bootstrap()
    @Published private(set) var showInitialView: Bool = true
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        environment.container.appState
            .map(\.routing.showInitialView)
            .removeDuplicates() // Needed to make it work. 🤷‍♂️
            .assign(to: \.showInitialView, on: self)
            .store(in: &cancellables)
    }
}
