//
//  SnappyV2StudyApp.swift
//  SnappyV2Study
//
//  Created by Henrik Gustavii on 11/06/2021.
//

import SwiftUI

@main
struct SnappyV2StudyMain: App {

    // Note that the @UIApplicationDelegateAdaptor property wrapper can only be used
    // in the main app and not associated view models
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate: AppDelegate
    
    @State var environment: AppEnvironment = AppEnvironment.bootstrap()
    
    init() {
        appDelegate.systemEventsHandler = environment.systemEventsHandler
    }
    
    var body: some Scene {
        WindowGroup {
            /// Allows us to access any view's size throughout the app by adopting @Environment(\.mainWindowSize) locally
            GeometryReader { proxy in
                SnappyV2StudyApp(
                    viewModel: .init(
                        container: environment.container,
                        systemEventsHandler: environment.systemEventsHandler
                    )
                )
                    .environment(\.mainWindowSize, proxy.size)
            }
            .onAppear(perform: UIApplication.shared.addTapGestureRecognizer)
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
    @State private var closeVerifyMobileNumberView: (()->())? = nil
    @State private var closeDriverMapView: (()->())? = nil
    @State private var closeOrderDetailView: (()->())? = nil
    
    init(viewModel: SnappyV2AppViewModel) {
        self._viewModel = .init(wrappedValue: viewModel)
        self._rootViewModel = .init(wrappedValue: RootViewModel(container: viewModel.container))
        self._initialViewModel = .init(wrappedValue: InitialViewModel(container: viewModel.container))
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
            // outside of dismiss closure below to avoid strong retention memory leak
            closePushNotificationsEnablePromptView = nil
            popup.dismiss(animated: true) { }
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
                    dismissPushNotificationViewHandler: { displayAction in
                        viewModel.dismissNotificationView(withAction: displayAction)
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
            // outside of dismiss closure below to avoid strong retention memory leak
            closePushNotificationView = nil
            popup.dismiss(animated: true) {
                viewModel.pushNotificationViewDismissed()
                // recursively present the next notification
                if let pushNotification = pushNotification {
                    showPushNotification(pushNotification)
                }
            }
        }
    }
    
    private func showOrder(_ order: PlacedOrder) {
        
        if let closeOrderDetailView = closeOrderDetailView {
            closeOrderDetailView()
            return
        }
        
        guard let rootViewController = UIApplication.topViewController() else { return }
        
        let popup = UIHostingController(
            rootView: OrderDetailsView(
                viewModel: .init(
                    container: viewModel.container,
                    order: order,
                    showTrackOrderButton: false
                ) {
                    closeOrderDetailView?()
                }
            )
            .navigationViewStyle(.stack)
        )
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            // Using .popover causes problems for iPads even when supplying the sourceView
            // as rootViewController.view
            popup.modalPresentationStyle = .overCurrentContext
        } else {
            popup.modalPresentationStyle = .popover
            // Disable the swip down to dismiss because we cannot detect and set
            // closeOrderDetailView to nil. Tried various strategies such as using the
            // OrderDetailsViewModel deinit to clear closeOrderDetailView but it is never
            // reached because of the popup reference in the closeOrderDetailView closure
            popup.isModalInPresentation = true
        }
        
        rootViewController.present(
            popup,
            animated: true,
            completion: {
                viewModel.orderViewShown()
            }
        )
        
        closeOrderDetailView = {
            // outside of dismiss closure below to avoid strong retention memory leak
            closeOrderDetailView = nil
            popup.dismiss(animated: true) { }
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
                    dismissStoreReviewViewHandler: { reviewSentMessage in
                        viewModel.dismissRetailStoreReviewView(reviewSentMessage: reviewSentMessage)
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
            // outside of dismiss closure below to avoid strong retention memory leak
            closeRetailStoreReviewView = nil
            popup.dismiss(animated: true) { }
        }
    }
    
    private func showVerifyMobileNumberView() {
        if let closeVerifyMobileNumberView = closeVerifyMobileNumberView {
            closeVerifyMobileNumberView()
        }
        
        guard let rootViewController = UIApplication.topViewController() else { return }
        
        let popup = UIHostingController(
            rootView: VerifyMobileNumberView(
                viewModel: .init(
                    container: viewModel.container,
                    dismissViewHandler: { error, toast in
                        viewModel.dismissMobileVerifyNumberView(error: error, toast: toast)
                        closeVerifyMobileNumberView?()
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
        
        closeVerifyMobileNumberView = {
            // outside of dismiss closure below to avoid strong retention memory leak
            closeVerifyMobileNumberView = nil
            popup.dismiss(animated: true) { }
        }
    }
    
    private func showDriverMapView(_ driverMapParameters: DriverLocationMapParameters) {
        if let closeDriverMapView = closeDriverMapView {
            closeDriverMapView()
        }
        
        guard let rootViewController = UIApplication.topViewController() else { return }
        
        let driverMapViewModel = DriverMapViewModel(
            container: viewModel.container,
            mapParameters: driverMapParameters,
            dismissDriverMapHandler: {
                viewModel.dismissDriverMap()
                closeDriverMapView?()
            }
        )

        let popup = UIHostingController(
            rootView: ToastableViewContainer(
                content: {
                    DriverMapView(
                        viewModel: driverMapViewModel,
                        isModal: true
                    )
                },
                viewModel: .init(container: viewModel.container, isModal: true)
            )
        )
        
        popup.modalPresentationStyle = .automatic
        popup.modalTransitionStyle = .crossDissolve
        popup.view.backgroundColor = .clear
        
        rootViewController.present(
            popup,
            animated: true,
            completion: {
                driverMapViewModel.viewShown()
            }
        )
        
        closeDriverMapView = {
            // outside of dismiss closure below to avoid strong retention memory leak
            closeDriverMapView = nil
            popup.dismiss(animated: true) { }
        }
    }
    
    var body: some View {
        ZStack {
            Group {
                if viewModel.showInitialView {
                    ToastableViewContainer(content: {
                        InitialView(viewModel: initialViewModel)
                            .onOpenURL(perform: { (url) in
                                viewModel.openUniversalLink(url: url)
                            })
                            .navigationViewStyle(.stack)
                    }, viewModel: .init(container: viewModel.container, isModal: false))
                    
                } else {
                    ToastableViewContainer(content: {
                        RootView(viewModel: rootViewModel)
                            .onOpenURL(perform: { (url) in
                                viewModel.openUniversalLink(url: url)
                            })
                            .navigationViewStyle(.stack)
                    }, viewModel: .init(container: viewModel.container, isModal: false))
                }
            }
            
            // "Global Model Overlay" views added below will be shown over any other app
            // content. Criteria for deciding whether they should be placed here:
            // (1) when the functionality can be initiated from anywhere and not only from
            // fixed locations within the app. E.g. Push notifications, Driver Map
            // (2) when there might be a process before a parent view would be known and/or
            // the number of locations is so numerous that it significantly complicates the
            // app. E.g. Push notification enable prompt
        }
        .onChange(of: viewModel.showOrder) { order in
            if let order {
                showOrder(order)
            }
        }
        .onChange(of: viewModel.storeReview) { storeReview in
            if let storeReview {
                showStoreReview(storeReview)
            }
        }
        .onChange(of: viewModel.showPushNotificationsEnablePromptView) { showPrompt in
            if showPrompt {
                showPushNotificationsEnablePromptView()
            }
        }
        .onChange(of: viewModel.pushNotification) { pushNotification in
            if let pushNotification {
                showPushNotification(pushNotification)
            }
        }
        .onChange(of: viewModel.urlToOpen) { url in
            if let url {
                openURL(url) { _ in
                    viewModel.urlToOpenAttempted()
                }
            }
        }
        .onChange(of: viewModel.showVerifyMobileNumberView) { showPrompt in
            if showPrompt {
                showVerifyMobileNumberView()
            }
        }
        .onChange(of: viewModel.driverMapParameters) { driverMapParameters in
            if let driverMapParameters {
                showDriverMapView(driverMapParameters)
            }
        }
        .onChange(of: scenePhase) { newPhase in
            viewModel.setAppForegroundStatus(phase: newPhase)
        }
    }
}
