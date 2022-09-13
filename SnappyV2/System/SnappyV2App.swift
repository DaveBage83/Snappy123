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

    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    
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
            /// Allows us to access any view's size throughout the app by adopting @Environment(\.mainWindowSize) locally
            GeometryReader { proxy in
                SnappyV2StudyApp(container: environment.container)
                    .environment(\.mainWindowSize, proxy.size)
            }
        }
    }
}

struct SnappyV2StudyApp: View {
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.openURL) private var openURL
    
    @StateObject var viewModel: SnappyV2AppViewModel
    @StateObject var rootViewModel: RootViewModel
    @StateObject var initialViewModel: InitialViewModel
    
    @State private var closePushNotificationsEnablePromptView: (()->())? = nil
    @State private var closePushNotificationView: ((DisplayablePushNotification?)->())? = nil
    @State private var closeRetailStoreReviewView: (()->())? = nil
    
    init(container: DIContainer) {
        self._viewModel = .init(wrappedValue: SnappyV2AppViewModel(container: container))
        self._rootViewModel = .init(wrappedValue: RootViewModel(container: container))
        self._initialViewModel = .init(wrappedValue: InitialViewModel(container: container))
    }
    
    private func showPushNotificationsEnablePromptView() {
        
        if let closePushNotificationsEnablePromptView = closePushNotificationsEnablePromptView {
            closePushNotificationsEnablePromptView()
        }
        
        guard let rootViewController = UIApplication.topViewController() else { return }
        
        let popup = UIHostingController(
            rootView: PushNotificationsEnablePromptView(
                viewModel: .init(
                    container: viewModel.container,
                    dismissPushNotificationViewHandler: {
                        viewModel.dismissEnableNotificationsPromptView()
                        closePushNotificationsEnablePromptView?()
                    }
                )
            )
        )
        
        popup.modalPresentationStyle = .overCurrentContext
        popup.modalTransitionStyle = .crossDissolve
        popup.view.backgroundColor = .clear
        
        rootViewController.present(
            popup,
            animated: true,
            completion: { }
        )
        
        closePushNotificationsEnablePromptView = {
            popup.dismiss(animated: true) {
                closePushNotificationsEnablePromptView = nil
            }
        }
    }
    
    private func showPushNotification(_ pushNotification: DisplayablePushNotification) {
        
        if let closePushNotificationView = closePushNotificationView {
            // notification already displayed so dimiss the current notification
            closePushNotificationView(pushNotification)
            return
        }
        
        guard let rootViewController = UIApplication.topViewController() else { return }
        
        let popup = UIHostingController(
            rootView: PushNotificationView(
                viewModel: .init(
                    container: viewModel.container,
                    notification: pushNotification,
                    dismissPushNotificationViewHandler: {
                        viewModel.dismissNotificationView()
                        closePushNotificationView?(nil)
                    }
                )
            )
        )
        
        popup.modalPresentationStyle = .overCurrentContext
        popup.modalTransitionStyle = .crossDissolve
        popup.view.backgroundColor = .clear
        
        rootViewController.present(
            popup,
            animated: true,
            completion: { }
        )
        
        closePushNotificationView = { pushNotification in
            popup.dismiss(animated: true) {
                closePushNotificationView = nil
                // recursively present the next notification
                if let pushNotification = pushNotification {
                    showPushNotification(pushNotification)
                }
            }
        }
    }
    
    private func showStoreReview(_ review: RetailStoreReview) {
        
        if let closeRetailStoreReviewView = closeRetailStoreReviewView {
            closeRetailStoreReviewView()
            return
        }
        
        guard let rootViewController = UIApplication.topViewController() else { return }
        
        let popup = UIHostingController(
            rootView: StoreReviewView(
                viewModel: StoreReviewViewModel(
                    container: viewModel.container,
                    review: review,
                    dismissStoreReviewViewHandler: {
                        viewModel.dismissRetailStoreReviewView()
                        closeRetailStoreReviewView?()
                    }
                )
            )
        )
        
        popup.modalPresentationStyle = .overCurrentContext
        popup.modalTransitionStyle = .crossDissolve
        popup.view.backgroundColor = .clear
        
        rootViewController.present(
            popup,
            animated: true,
            completion: { }
        )
        
        closeRetailStoreReviewView = {
            popup.dismiss(animated: true) {
                closeRetailStoreReviewView = nil
            }
        }
    }
    
    var body: some View {
        ZStack {
            Group {
                if viewModel.showInitialView {
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
            
            // "Global Model Overlay" views added below will be shown over any other app
            // content. Criteria for deciding whether they should be placed here:
            // (1) when the functionality can be initiated from anywhere and not only from
            // fixed locations within the app. E.g. Push notifications, Driver Map
            // (2) when there might be a process before a parent view would be known and/or
            // the number of locations is so numerous that it significantly complicates the
            // app. E.g. Push notification enable prompt
            
//            if viewModel.showPushNotificationsEnablePromptView {
//                PushNotificationsEnablePromptView(
//                    viewModel: .init(
//                        container: viewModel.container,
//                        dismissPushNotificationViewHandler: {
//                            viewModel.dismissEnableNotificationsPromptView()
//                        }
//                    )
//                )
//            } else if let pushNotification = viewModel.pushNotification {
//                PushNotificationView(
//                    viewModel: .init(
//                        container: viewModel.container,
//                        notification: pushNotification,
//                        dismissPushNotificationViewHandler: {
//                            viewModel.dismissNotificationView()
//                        }
//                    )
//                )
//            }
        }
        .onChange(of: viewModel.storeReview) { storeReview in
            if let storeReview = storeReview {
                showStoreReview(storeReview)
            }
        }
        .onChange(of: viewModel.showPushNotificationsEnablePromptView) { showPrompt in
            if showPrompt {
                showPushNotificationsEnablePromptView()
            }
        }
        .onChange(of: viewModel.pushNotification) { pushNotification in
            if let pushNotification = pushNotification {
                showPushNotification(pushNotification)
            }
        }
        .onChange(of: viewModel.urlToOpen) { url in
            if let url = url {
                openURL(url) { _ in
                    viewModel.urlToOpenAttempted()
                }
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
