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
    
    var body: some Scene {
        WindowGroup {
            switch state {
            case .inital:
                InitialView($state)
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

class AppDelegate: NSObject, UIApplicationDelegate {
    static var orientationLock = UIInterfaceOrientationMask.all
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
}
