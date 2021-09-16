//
//  SnappyV2StudyApp.swift
//  SnappyV2Study
//
//  Created by Henrik Gustavii on 11/06/2021.
//

import SwiftUI

@main
struct SnappyV2StudyApp: App {
    @State var state: ViewState = .inital
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    let environment = AppEnvironment.bootstrap()
    
    var body: some Scene {
        WindowGroup {
            switch state {
            case .inital:
                InitialView(viewModel: InitialViewModel(container: environment.container, viewState: $state))
            default:
                RootView()
            }
        }
    }
}

enum ViewState {
    case inital
    case root
}
