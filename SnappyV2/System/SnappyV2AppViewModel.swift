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
    private let networkMonitor: NetworkMonitor
    
    @Published var showInitialView: Bool = true
    @Published var isActive: Bool = false
    @Published var isConnected: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init(appEnvironment: AppEnvironment = AppEnvironment.bootstrap()) {
        environment = appEnvironment
        networkMonitor = NetworkMonitor(environment: environment)
        networkMonitor.startMonitoring()
#if DEBUG
        //Use this for inspecting the Core Data
        if let directoryLocation = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).last {
            print("Documents Directory: \(directoryLocation)Application Support")
        }
#endif
        
        setUpInitialView()
        setupSystemSceneState()
        setupSystemConnectivityMonitor()
    }
    
    private func setUpInitialView() {
        environment.container.appState
            .map(\.routing.showInitialView)
            .removeDuplicates() // Needed to make it work. 🤷‍♂️
            .assignWeak(to: \.showInitialView, on: self)
            .store(in: &cancellables)
    }
    
    private func setupSystemSceneState() {
        environment.container.appState
            .map(\.system.isActive)
            .removeDuplicates()
            .sink(receiveValue: { [weak self] isActive in
                guard let self = self else { return }
                self.isActive = isActive
                if self.isActive {
                    self.networkMonitor.startMonitoring() // If the app is active, we start monitoring connectiity changes
                    
                    Timer.scheduledTimer(withTimeInterval: AppV2Constants.Business.trueTimeCheckInterval, repeats: true) { timer in
                        self.environment.container.services.utilityService.setDeviceTimeOffset()
                    }
                    
                } else {
                    self.networkMonitor.stopMonitoring() // If the app is not active, we stop monitoring connectivity changes
                }
            })
            .store(in: &cancellables)
    }
    
    private func setupSystemConnectivityMonitor() {
        environment.container.appState
            .map(\.system.isConnected)
            .removeDuplicates()
            .sink { [weak self] isConnected in
                guard let self = self else { return }
                self.isConnected = isConnected
                if isConnected {
                    self.environment.container.services.utilityService.setDeviceTimeOffset()
                }
            }
            .store(in: &cancellables)
    }
}
