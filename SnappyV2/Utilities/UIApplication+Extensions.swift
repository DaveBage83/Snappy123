//
//  UIApplication+Extensions.swift
//  SnappyV2
//
//  Created by Kevin Palser on 23/08/2022.
//

import UIKit

extension UIApplication {
    
    // Based on: http://stackoverflow.com/questions/11637709/get-the-current-displaying-uiviewcontroller-on-the-screen-in-appdelegate-m
    // Required in this SwiftUI project because at the time of writing using UIKit is the
    // only way to present a view above all other views. The ZStack approach on the main
    // App view body does not work with presented(..) or fullScreenCover(..) modifiers.
    
    class func topViewController(_ base: UIViewController? = nil) -> UIViewController? {
        
        var currentBase: UIViewController?
        if let base = base {
            currentBase = base
        } else {
            currentBase = UIApplication
                .shared
                .connectedScenes
                .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
                .first { $0.isKeyWindow }?.rootViewController
        }
        
        if let nav = currentBase as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }

        if let tab = currentBase as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }

        if let presented = currentBase?.presentedViewController {
            return topViewController(presented)
        }
        
        return currentBase
    }
}

// Solution proposed from https://stackoverflow.com/questions/56491386/how-to-hide-keyboard-when-using-swiftui by pawello2222
extension UIApplication {
    func addTapGestureRecognizer() {
        guard let window = windows.first else { return }
        let tapGesture = UITapGestureRecognizer(target: window, action: #selector(UIView.endEditing))
        tapGesture.requiresExclusiveTouchType = false
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        window.addGestureRecognizer(tapGesture)
    }
}

extension UIApplication: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true // set to `false` if you don't want to detect tap during other gestures
    }
}
