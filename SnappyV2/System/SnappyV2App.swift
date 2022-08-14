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
import Sentry

@main
struct SnappyV2StudyMain: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @State var environment: AppEnvironment = AppEnvironment.bootstrap()
    
    init() {
        // In the https://github.com/nalexn/clean-architecture-swiftui/tree/mvvmthe AppDelegate would
        // get the systemEventsHandler from the iOS 13 Scene Delegate. With the iOS 14 @main 'App'
        // approach there is no Scene Delegate, so the systemEventsHandler is set directly below.
        appDelegate.systemEventsHandler = environment.systemEventsHandler
        
        // Sentry
        if let dsn = AppV2Constants.EventsLogging.sentrySettings.dsn {
            SentrySDK.start { options in
                options.dsn = dsn
                options.debug = AppV2Constants.EventsLogging.sentrySettings.debugLogs
                options.tracesSampleRate = AppV2Constants.EventsLogging.sentrySettings.tracesSampleRate
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            /// Allows us to access any view's side throughout the app by adopting @Environment(\.mainWindowSize) locally
            GeometryReader { proxy in
                SnappyV2StudyApp(container: environment.container)
                    .environment(\.mainWindowSize, proxy.size)
            }
        }
    }
}

struct SnappyV2StudyApp: View {
    @Environment(\.scenePhase) var scenePhase
    
    @StateObject var viewModel: SnappyV2AppViewModel
    @StateObject var rootViewModel: RootViewModel
    @StateObject var initialViewModel: InitialViewModel
    
    init(container: DIContainer) {
        self._viewModel = .init(wrappedValue: SnappyV2AppViewModel(container: container))
        self._rootViewModel = .init(wrappedValue: RootViewModel(container: container))
        self._initialViewModel = .init(wrappedValue: InitialViewModel(container: container))
    }
    
    var body: some View {
        VStack {
            if self.viewModel.showInitialView {
                InitialView(viewModel: initialViewModel)
                    .onOpenURL(perform: { (url) in
                        open(url: url)
                    })
                    .navigationViewStyle(.stack)
            } else {
                RootView(viewModel: rootViewModel)
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
