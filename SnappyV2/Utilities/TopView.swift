//
//  TopView.swift
//  SnappyV2
//
//  Created by Kevin Palser on 23/08/2022.
//

import UIKit

extension UIApplication {
    
    // Based on: http://stackoverflow.com/questions/11637709/get-the-current-displaying-uiviewcontroller-on-the-screen-in-appdelegate-m
    
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
