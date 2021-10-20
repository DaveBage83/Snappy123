//
//  SnappyV2StudyApp.swift
//  SnappyV2Study
//
//  Created by Henrik Gustavii on 11/06/2021.
//

import SwiftUI

@main
struct SnappyV2StudyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject var viewModel = SnappyV2AppViewModel()
    
    var body: some Scene {
        WindowGroup {
            if self.viewModel.showInitialView {
                InitialView(viewModel: InitialViewModel(container: viewModel.environment.container))
            } else {
                RootView(viewModel: RootViewModel(container: viewModel.environment.container))
            }
        }
    }
}
