//
//  DependencyInjector.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 15/09/2021.
//

import SwiftUI

struct DIContainer: EnvironmentKey {
    
    let appState: Store<AppState>
    let eventLogger: EventLoggerProtocol
    let services: Services
    
    static var defaultValue: Self { Self.default }
    
    private static let `default` = DIContainer(appState: AppState(), eventLogger: StubEventLogger(), services: .stub)
    
    init(appState: Store<AppState>, eventLogger: EventLoggerProtocol, services: DIContainer.Services) {
        self.appState = appState
        self.eventLogger = eventLogger
        self.services = services
    }
    
    init(appState: AppState, eventLogger: EventLoggerProtocol, services: DIContainer.Services) {
        self.init(appState: Store(appState), eventLogger: eventLogger, services: services)
    }
}

#if DEBUG
extension DIContainer {
    static var preview: Self {
        .init(appState: AppState.preview, eventLogger: StubEventLogger(), services: .stub)
    }
}
#endif
