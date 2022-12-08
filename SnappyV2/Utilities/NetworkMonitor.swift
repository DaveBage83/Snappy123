//
//  NetworkMonitor.swift
//  SnappyV2
//
//  Created by David Bage on 20/01/2022.
//

import Foundation
import Network

class NetworkMonitor {
    var monitor = NWPathMonitor()
    private let container: DIContainer
    
    init(container: DIContainer) {
        self.container = container
    }
    
    func startMonitoring() {
        monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { path in
            guaranteeMainThread { [weak self] in
                guard let self = self else { return }
                self.container.appState.value.system.isConnected = path.status == .satisfied
            }
        }
        let queue = DispatchQueue(label: "Network")
        monitor.start(queue: queue)
    }
    
    func stopMonitoring() {
        monitor.cancel()
    }
}
