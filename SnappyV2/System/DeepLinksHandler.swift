//
//  DeepLinksHandler.swift
//  SnappyV2
//
//  Created by Kevin Palser on 10/08/2022.
//

import Foundation
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
        
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: true) {
            print(components.host)
            print(components.queryItems)
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

struct DeepLinksHandler: DeepLinksHandlerProtocol {
    
    private let container: DIContainer
    
    init(container: DIContainer) {
        self.container = container
    }
    
    func open(deepLink: DeepLink) {
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
        case .showPasswordReset(token: let token):
            break
        }
    }
}

