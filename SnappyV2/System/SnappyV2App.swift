//
//  SnappyV2StudyApp.swift
//  SnappyV2Study
//
//  Created by Henrik Gustavii on 11/06/2021.
//

import SwiftUI

// 3rd party
import FacebookCore
import GoogleSignIn

@main
struct SnappyV2StudyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) var scenePhase
    
    @StateObject var viewModel = SnappyV2AppViewModel()
    
    var body: some Scene {
        WindowGroup {
            if self.viewModel.showInitialView {
                InitialView(viewModel: InitialViewModel(container: viewModel.environment.container))
                    .onOpenURL(perform: { (url) in
                        open(url: url)
                    })
                    .navigationViewStyle(.stack)
            } else {
                RootView(viewModel: RootViewModel(container: viewModel.environment.container))
                    .onOpenURL(perform: { (url) in
                        open(url: url)
                    })
                    .navigationViewStyle(.stack)
            }
        }
        .onChange(of: scenePhase) { newPhase in
            viewModel.setAppForegroundStatus(phase: newPhase)
        }
    }
}

extension SnappyV2StudyApp {
    private func open(url: URL) {
        
        if GIDSignIn.sharedInstance.handle(url) {
            return
        }
        
        // To support Facebook Login based on: https://stackoverflow.com/questions/67147877/swiftui-facebook-login-button-dialog-still-open
        ApplicationDelegate.shared.application(
            UIApplication.shared,
            open: url,
            sourceApplication: nil,
            annotation: [UIApplication.OpenURLOptionsKey.annotation]
        )
    }
}
