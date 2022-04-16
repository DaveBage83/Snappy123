//
//  SnappyV2AppViewModel.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 21/09/2021.
//

import Combine
import Foundation
import SwiftUI

class SnappyV2AppViewModel: ObservableObject {
    let environment: AppEnvironment
    private let networkMonitor: NetworkMonitor
    
    @Published var showInitialView: Bool
    @Published var isActive: Bool
    @Published var isConnected: Bool
    
    private var cancellables = Set<AnyCancellable>()
    
    init(appEnvironment: AppEnvironment = AppEnvironment.bootstrap()) {
        
        environment = appEnvironment
        networkMonitor = NetworkMonitor(environment: environment)
        networkMonitor.startMonitoring()
        
        _showInitialView = .init(initialValue: environment.container.appState.value.routing.showInitialView)
        _isActive = .init(initialValue: environment.container.appState.value.system.isInForeground)
        _isConnected = .init(initialValue: environment.container.appState.value.system.isConnected)
#if DEBUG
        //Use this for inspecting the Core Data
        if let directoryLocation = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).last {
            print("Documents Directory: \(directoryLocation)Application Support")
        }
#endif
        
        setUpInitialView()
        setupIsActive()
        setupSystemSceneState()
        setupSystemConnectivityMonitor()
        setUpIsConnected()
    }
    
    private func setUpInitialView() {
        environment.container.appState
            .map(\.routing.showInitialView)
            .removeDuplicates() // Needed to make it work. 🤷‍♂️
            .assignWeak(to: \.showInitialView, on: self)
            .store(in: &cancellables)
    }
    
    private func setupIsActive() {
        environment.container.appState
            .map(\.system.isInForeground)
            .removeDuplicates()
            .assignWeak(to: \.isActive, on: self)
            .store(in: &cancellables)
    }
    
    private func setupSystemSceneState() {
        $isActive
            .sink { [weak self] appIsActive in
                guard let self = self else { return }
                if appIsActive {
                    self.environment.container.eventLogger.initialiseLoggers()
                    // If the app is active, we start monitoring connectiity changes
                    self.networkMonitor.startMonitoring()
                    Timer.scheduledTimer(withTimeInterval: AppV2Constants.Business.trueTimeCheckInterval, repeats: true) { timer in
                        self.environment.container.services.utilityService.setDeviceTimeOffset()
                    }
                } else {
                    // If the app is not active, we stop monitoring connectivity changes
                    self.networkMonitor.stopMonitoring()
                }
            }
            .store(in: &cancellables)
    }
    
    private func setUpIsConnected() {
        environment.container.appState
            .map(\.system.isConnected)
            .removeDuplicates()
            .assignWeak(to: \.isConnected, on: self)
            .store(in: &cancellables)
    }
    
    private func setupSystemConnectivityMonitor() {
        $isConnected
            .sink { [weak self] deviceIsConnected in
                guard let self = self else { return }
                if deviceIsConnected {
                    self.environment.container.services.utilityService.setDeviceTimeOffset()
                }
            }
            .store(in: &cancellables)
    }
    
    func setAppForegroundStatus(phase: ScenePhase) {
        environment.container.appState.value.system.isInForeground = phase == .active
    }
}
