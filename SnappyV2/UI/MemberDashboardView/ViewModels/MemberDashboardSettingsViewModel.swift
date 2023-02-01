//
//  MemberDashboardSettingsViewModel.swift
//  SnappyV2
//
//  Created by Kevin Palser on 22/01/2023.
//

import UIKit // required for UIPasteboard
import Combine
import DeviceCheck

class MemberDashboardSettingsViewModel: ObservableObject {
    let container: DIContainer
    let versionTapsForDebugInformation = 5
    
    @Published var showHorizontalItemCards: Bool
    @Published var showDropdownCategoryMenu: Bool
    
    private var cancellables = Set<AnyCancellable>()
    private var versionTappedCount = 0
    private let deviceChecker: DCDeviceCheckerProtocol
    
    var showMarketingPreferences: Bool {
        container.appState.value.userData.memberProfile != nil
    }
    
    init(container: DIContainer, deviceChecker: DCDeviceCheckerProtocol = DCDeviceChecker()) {
        self.container = container
        self.deviceChecker = deviceChecker
        self.showHorizontalItemCards = container.appState.value.storeMenu.showHorizontalItemCards
        self.showDropdownCategoryMenu = container.appState.value.storeMenu.showDropdownCategoryMenu
        
        setupItemCardOrientation()
        setupCategoryDropdownMenu()
    }
    
    func setupItemCardOrientation() {
        container.appState
            .map(\.storeMenu.showHorizontalItemCards)
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .assignWeak(to: \.showHorizontalItemCards, on: self)
            .store(in: &cancellables)
        
        $showHorizontalItemCards
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] value in
                guard let self else { return }
                self.container.appState.value.storeMenu.showHorizontalItemCards = value
            }
            .store(in: &cancellables)
    }
    
    func setupCategoryDropdownMenu() {
        container.appState
            .map(\.storeMenu.showDropdownCategoryMenu)
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .assignWeak(to: \.showDropdownCategoryMenu, on: self)
            .store(in: &cancellables)
        
        $showDropdownCategoryMenu
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] value in
                guard let self else { return }
                self.container.appState.value.storeMenu.showDropdownCategoryMenu = value
            }
            .store(in: &cancellables)
    }
    
    func versionTapped(debugInformationCopied: @escaping ()->()) async {
        versionTappedCount += 1
        if versionTappedCount == versionTapsForDebugInformation {
            
            let dateFormatterGet = DateFormatter()
            dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let version = (AppV2Constants.Client.appVersion ?? "UNKNOWN") + " (" + (AppV2Constants.Client.bundleVersion ?? "UNKNOWN") + ")"
            #if DEBUG
            let runtime = "DEBUG"
            #else
            let runtime = "PRODUCTION"
            #endif
            let deviceCheckingToken = await deviceChecker.getAppleDeviceToken()
            let selectedStoreId = container.appState.value.userData.selectedStore.value?.id ?? 0
            
            var debugString = "------------------------ BEGIN ------------------------\n"
            debugString += "DATE/TIME: " + dateFormatterGet.string(from: Date().trueDate) + "\n"
            debugString += "BUNDLE: " + (AppV2Constants.Client.bundleVersion ?? "UNKNOWN") + "\n"
            debugString += "VERSION: " + version + "\n"
            debugString += "RUNTIME: " + runtime + " (\(AppV2Constants.Business.id)/\(AppV2Constants.Business.appWhiteLabelProfileId ?? 0))\n"
            debugString += "DEVICE: " + AppV2Constants.Client.deviceModel + "\n"
            debugString += "DEVICE OS VERSION: " + AppV2Constants.Client.systemVersion + "\n"
            debugString += "DEVICE ID: " + (AppV2Constants.Client.deviceIdentifier ?? "UNKNOWN") + "\n"
            debugString += "MESSAGING DEVICE ID: " + (container.appState.value.system.notificationDeviceToken ?? "UNKNOWN") + "\n"
            debugString += "DEVICE CHECKING TOKEN: " + (deviceCheckingToken ?? "UNKNOWN") + "\n"
            debugString += "DEVICE FIRST ORDERED STATE: " + (container.appState.value.userData.isFirstOrder ? "TRUE" : "FALSE") + "\n"
            debugString += "BASKET SESSION: " + (container.appState.value.userData.basket?.basketToken ?? "UNKNOWN") + "\n"
            debugString += "BEARER: " + (NetworkAuthenticator.shared.currentToken.accessToken ?? "UNKNOWN") + "\n"
            debugString += "MEMBER SIGNED IN: " + (container.appState.value.userData.memberProfile != nil ? "TRUE" : "FALSE") + "\n"
            debugString += "SELECTED STORE ID: \(selectedStoreId)\n"
            debugString += "------------------------- END -------------------------\n"

            UIPasteboard.general.string = debugString
            versionTappedCount = 0
            debugInformationCopied()
        }
    }
}
