//
//  SnappyV2AppViewModel.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 21/09/2021.
//

import Combine
import Foundation
import SwiftUI
import AppTrackingTransparency
import OSLog

// 3rd Party
import FBSDKCoreKit
import FacebookCore
import GoogleSignIn

@MainActor
class SnappyV2AppViewModel: ObservableObject {
    
    private let systemEventsHandler: SystemEventsHandlerProtocol
    let container: DIContainer
    private let networkMonitor: NetworkMonitor
    
    @Published var showInitialView: Bool
    @Published var isActive: Bool
    @Published var isConnected: Bool
    @Published var storeReview: RetailStoreReview?
    @Published var pushNotification: DisplayablePushNotification?
    @Published var urlToOpen: URL?
    @Published var showPushNotificationsEnablePromptView: Bool
    @Published var showVerifyMobileNumberView: Bool
    @Published var showDriverMap: Bool = false
    
    private var pushNotificationsQueue: [DisplayablePushNotification] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    private var previouslyEnteredForeground = false
    
    lazy var driverMapViewModel: DriverMapViewModel = {
        DriverMapViewModel(container: container) { [weak self] in
            guard let self = self else { return }
            self.dismissDriverMap()
        }
    }()
    
    init(container: DIContainer, systemEventsHandler: SystemEventsHandlerProtocol) {
        
        self.systemEventsHandler = systemEventsHandler
        self.container = container
        networkMonitor = NetworkMonitor(container: container)
        networkMonitor.startMonitoring()
        
        _showInitialView = .init(initialValue: container.appState.value.routing.showInitialView)
        _isActive = .init(initialValue: container.appState.value.system.isInForeground)
        _isConnected = .init(initialValue: container.appState.value.system.isConnected)
        _showPushNotificationsEnablePromptView = .init(initialValue: container.appState.value.pushNotifications.showPushNotificationsEnablePromptView)
        _showVerifyMobileNumberView = .init(initialValue: container.appState.value.routing.showVerifyMobileView)
        
        // In the https://github.com/nalexn/clean-architecture-swiftui/tree/mvvmthe AppDelegate would
        // get the systemEventsHandler from the iOS 13 Scene Delegate. With the iOS 14 @main 'App'
        // approach there is no Scene Delegate, so the systemEventsHandler is set directly below.
        //appDelegate.systemEventsHandler = systemEventsHandler

        #if DEBUG
        //Use this for inspecting the Core Data
        if let directoryLocation = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).last {
            print("Documents Directory: \(directoryLocation)Application Support")
        }
        #endif
        
        #if TEST
        #else
        container.eventLogger.initialiseSentry()
        setupIsActive()
        setupSystemSceneState()
        setupSystemConnectivityMonitor()
        setUpIsConnected()
        setupStoreReview()
        setupNotificationView()
        setupShowPushNotificationsEnablePrompt(with: container.appState)
        setupURLToOpen(with: container.appState)
        setupShowVerifyMobileNumberView(with: container.appState)
        #endif
        
        setUpInitialView()
    }
    
    private func setUpInitialView() {
        container.appState
            .map(\.routing.showInitialView)
            .receive(on: RunLoop.main)
            .removeDuplicates() // Needed to make it work. 🤷‍♂️
            .assignWeak(to: \.showInitialView, on: self)
            .store(in: &cancellables)
    }
    
    private func setupIsActive() {
        container.appState
            .map(\.system.isInForeground)
            .receive(on: RunLoop.main)
            .removeDuplicates()
            .assignWeak(to: \.isActive, on: self)
            .store(in: &cancellables)
    }
    
    private func setupStoreReview() {
        container.appState
            .map(\.retailStoreReview)
            .removeDuplicates()
            .filter { $0 != nil }
            .receive(on: RunLoop.main)
            .sink { [weak self] review in
                guard let self = self else { return }
                self.storeReview = review
            }.store(in: &cancellables)
    }
    
    private func setupNotificationView() {
        // no attempt to remove duplicates because similar incoming
        // notifications may be receieved
        container.appState
            .map(\.pushNotifications.displayableNotification)
            .filter { $0 != nil }
            .sink { [weak self] displayableNotification in
                guard
                    let self = self,
                    let displayableNotification = displayableNotification
                else { return }
                // if a notification is currently being displayed then
                // queue the incoming notification otherwise display
                // it immediately
                if self.pushNotification != nil {
                    self.pushNotificationsQueue.append(displayableNotification)
                } else {
                    self.pushNotification = displayableNotification
                }
            }.store(in: &cancellables)
    }
    
    private func setupURLToOpen(with appState: Store<AppState>) {
        
        $urlToOpen
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { appState.value.routing.urlToOpen = $0 }
            .store(in: &cancellables)
        
        appState
            .map(\.routing.urlToOpen)
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] urlToOpen in
                guard let self = self else { return }
                self.urlToOpen = urlToOpen
            }.store(in: &cancellables)
    }
    
    private func setupShowPushNotificationsEnablePrompt(with appState: Store<AppState>) {
        
        $showPushNotificationsEnablePromptView
            .receive(on: RunLoop.main)
            .sink { appState.value.pushNotifications.showPushNotificationsEnablePromptView = $0 }
            .store(in: &cancellables)
        
        appState
            .map(\.pushNotifications.showPushNotificationsEnablePromptView)
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .assignWeak(to: \.showPushNotificationsEnablePromptView, on: self)
            .store(in: &cancellables)
    }
    
    private func setupShowVerifyMobileNumberView(with appState: Store<AppState>) {
        
        $showVerifyMobileNumberView
            .receive(on: RunLoop.main)
            .sink { appState.value.routing.showVerifyMobileView = $0 }
            .store(in: &cancellables)
        
        appState
            .map(\.routing.showVerifyMobileView)
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .assignWeak(to: \.showVerifyMobileNumberView, on: self)
            .store(in: &cancellables)
    }
    
    private func setupSystemSceneState() {
        $isActive
            .sink { [weak self] appIsActive in
                guard let self = self else { return }
                if appIsActive {
                    self.container.eventLogger.initialiseLoggers(container: self.container)
                    // If the app is active, we start monitoring connectiity changes
                    self.networkMonitor.startMonitoring()
                    #if TEST
                    #else
                    self.onetimeAfterActiveSetup()
                    #endif
                } else {
                    // If the app is not active, we stop monitoring connectivity changes
                    self.networkMonitor.stopMonitoring()
                }
            }
            .store(in: &cancellables)
    }
    
    private func setUpIsConnected() {
        container.appState
            .map(\.system.isConnected)
            .receive(on: RunLoop.main)
            .removeDuplicates()
            .assignWeak(to: \.isConnected, on: self)
            .store(in: &cancellables)
    }
    
    private func setupSystemConnectivityMonitor() {
        $isConnected
            .sink { [weak self] deviceIsConnected in
                guard let self = self else { return }
                if deviceIsConnected {
                    self.container.services.utilityService.setDeviceTimeOffset()
                }
            }
            .store(in: &cancellables)
    }
    
    private func onetimeAfterActiveSetup() {
        // functionality when the app first enters the foreground
        if previouslyEnteredForeground == false {
            previouslyEnteredForeground = true
            
            Timer.scheduledTimer(withTimeInterval: AppV2Constants.Business.trueTimeCheckInterval, repeats: true) { timer in
                self.container.services.utilityService.setDeviceTimeOffset()
            }
            
            // Request IDFA Permission
            ATTrackingManager.requestTrackingAuthorization { status in
                #if DEBUG
                switch status {
                case .authorized:
                    // Tracking authorization dialog was shown
                    // and we are authorized
                    Logger.initial.info("ATTrackingManager.requestTrackingAuthorization: Authorized")
                case .denied:
                    // Tracking authorization dialog was
                    // shown and permission is denied
                    Logger.initial.info("ATTrackingManager.requestTrackingAuthorization: Denied")
                case .notDetermined:
                    // Tracking authorization dialog has not been shown
                    Logger.initial.info("ATTrackingManager.requestTrackingAuthorization: Not Determined")
                case .restricted:
                    Logger.initial.info("ATTrackingManager.requestTrackingAuthorization: Restricted")
                @unknown default:
                    Logger.initial.info("ATTrackingManager.requestTrackingAuthorization: Unknown")
                }
                #endif
                
                // Facebook
                Settings.shared.isAdvertiserTrackingEnabled = status == .authorized
            }
            
            // Facebook
            AppEvents.shared.activateApp()
        }
    }
    
    func setAppForegroundStatus(phase: ScenePhase) {
        container.appState.value.system.isInForeground = phase == .active
    }
    
    func dismissNotificationView() {
        pushNotification = nil
        // display the next queued push notification
        if pushNotificationsQueue.count > 0 {
            pushNotification = pushNotificationsQueue.remove(at: 0)
        }
    }
    
    func dismissEnableNotificationsPromptView() {
        showPushNotificationsEnablePromptView = false
    }
    
    func dismissMobileVerifyNumberView(error: Error?, toast: String?) {
        showVerifyMobileNumberView = false
        if let error = error {
            self.container.appState.value.errors.append(error)
        } else if let toast = toast {
            container.appState.value.successToastStrings.append(toast)
        }
    }
    
    func dismissRetailStoreReviewView(reviewSent: Bool) {
        container.appState.value.retailStoreReview = nil
        storeReview = nil
        container.appState.value.successToastStrings.append(Strings.StoreReview.StaticText.submittedMessage.localized)
    }
    
    func dismissDriverMap() {
        container.appState.value.pushNotifications.driverMapOpenNotification = nil
        showDriverMap = false
    }
    
    func urlToOpenAttempted() {
        // needs to be cleared so that onChange modifier will work
        // in the view if the same URL is requested
        urlToOpen = nil
    }
    
    func openUniversalLink(url: URL) {
        guard GIDSignIn.sharedInstance.handle(url) == false else {
            return
        }
        
        guard systemEventsHandler.handle(url: url) == false else {
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
