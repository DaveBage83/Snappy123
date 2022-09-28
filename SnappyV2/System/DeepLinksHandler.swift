//
//  DeepLinksHandler.swift
//  SnappyV2
//
//  Created by Kevin Palser on 10/08/2022.
//

import Foundation
import Combine
import SwiftUI

enum DeepLink: Equatable {
    
    case showStore(id: Int)
    case showPasswordReset(token: String)
    
    init?(url: URL) {
        
        if url.pathComponents.count > 1 {
            let firstNonBackSlashComponent = url.pathComponents[1]
            switch firstNonBackSlashComponent.lowercased() {
            case "member":
                if url.pathComponents.count > 2 {
                    let secondNonBackSlashComponent = url.pathComponents[2]
                    switch secondNonBackSlashComponent.lowercased() {
                    case "reset-token":
                        if url.pathComponents.count > 3 {
                            let thirdNonBackSlashComponent = url.pathComponents[3]
                            self = .showPasswordReset(token: thirdNonBackSlashComponent)
                            return
                        }
                    default:
                        break
                    }
                }
                    
            default:
                break
            }
        }
        
        guard
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
            //components.host == "www.example.com",
            let query = components.queryItems
            else { return nil }
        if
            let item = query.first(where: { $0.name == "storeId" }),
            let storeIdString = item.value,
            let storeId = Int(storeIdString)
        {
            self = .showStore(id: storeId)
            return
        }
        return nil
    }
}

// MARK: - DeepLinksHandler

protocol DeepLinksHandlerProtocol {
    func open(deepLink: DeepLink)
}

final class DeepLinksHandler: DeepLinksHandlerProtocol {
    
    let container: DIContainer
    private var cancellables = Set<AnyCancellable>()
    
    init(container: DIContainer) {
        self.container = container
        setupRestoreFinishedBinding(with: container.appState)
    }
    
    private func setupRestoreFinishedBinding(with appState: Store<AppState>) {
        appState
            .map(\.postponedActions.restoreFinished)
            .first { $0 }
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                for deepLink in self.container.appState.value.postponedActions.deepLinks {
                    self.open(deepLink: deepLink)
                }
                self.container.appState.value.postponedActions.deepLinks.removeAll()
            }
            .store(in: &cancellables)
    }
    
    func open(deepLink: DeepLink) {
        
        guard container.appState.value.postponedActions.restoreFinished else {
            container.appState.value.postponedActions.deepLinks.append(deepLink)
            return
        }
        
        switch deepLink {
        case let .showStore(id):
            break
//            let routeToDestination = {
//                self.container.appState.bulkUpdate {
//                    $0.routing.countriesList.countryDetails = alpha3Code
//                    $0.routing.countryDetails.detailsSheet = true
//                }
//            }
//            /*
//             SwiftUI is unable to perform complex navigation involving
//             simultaneous dismissal or older screens and presenting new ones.
//             A work around is to perform the navigation in two steps:
//             */
//            let defaultRouting = AppState.ViewRouting()
//            if container.appState.value.routing != defaultRouting {
//                self.container.appState[\.routing] = defaultRouting
//                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: routeToDestination)
//            } else {
//                routeToDestination()
//            }
        case let .showPasswordReset(token):
            container.appState.value.passwordResetCode = token
        }
    }
}

