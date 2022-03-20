//
//  Images.swift
//  SnappyV2
//
//  Created by David Bage on 07/01/2022.
//

import SwiftUI

extension Image {
    struct Navigation {
        static let chevronLeft = Image(systemName: "chevron.left")
        static let chevronRight = Image(systemName: "chevron.right")
        static let chevronDown = Image(systemName: "chevron.down")
        static let close = Image(systemName: "xmark.circle")
    }
    
    struct SnappyLogos {
        static let snappyLogoWhite = Image("snappy-logo-white")
        static let defaultLargeLogo = Image("default_large_logo")
        static let colouredLogo = Image("large_logo_3")
    }
    
    struct Actions {
        struct Close {
            static let xmarkCircle = Image(systemName: "xmark.circle")
            static let xCircle = Image(systemName: "x.circle")
            static let multiply = Image(systemName: "multiply.circle.fill")
        }
        
        struct Search {
            static let standard = Image(systemName: "magnifyingglass")
        }
        
        struct Add {
            static let circleFilled = Image(systemName: "plus.circle.fill")
            static let circle = Image(systemName: "plus.circle")
            static let standard = Image(systemName: "plus")
        }
        
        struct Remove {
            static let circleFilled = Image(systemName: "minus.circle.fill")
            static let circle = Image(systemName: "minus.circle")
        }
        
        static let edit = Image(systemName: "rectangle.and.pencil.and.ellipsis")
    }
    
    struct Login {
        struct User {
            static let square = Image(systemName: "person.crop.square")
            static let standard = Image(systemName: "person")
        }
        
        static let signup = Image(systemName: "person.badge.plus")
        
        struct Password {
            static let showPassword = Image(systemName: "eye.fill")
            static let hidePassword = Image(systemName: "eye.slash.fill")
        }
        
        struct Methods {
            static let apple = Image(systemName: "applelogo")
            static let facebook = Image("facebook-logo")
        }
    }
    
    struct General {
        struct Number {
            static let filledCircle = Image(systemName: "number.circle.fill")
        }
        
        struct Info {
            static let circle = Image(systemName: "info.circle")
        }
        
        struct Checkbox {
            static let checked = Image(systemName: "checkmark.circle.fill")
            static let unChecked = Image(systemName: "circle")
        }
        
        static let bulletList = Image(systemName: "list.bullet.rectangle")
        static let thumbsUp = Image(systemName: "hand.thumbsup")
        static let alert = Image(systemName: "bell")
        static let rightArrow = Image(systemName: "arrow.forward")
        static let savings = Image(systemName: "giftcard")
        static let fulfilmentTypeDelivery = Image(systemName: "car")
    }
    
    struct Tabs {
        static let home = Image(systemName: "house")
        static let menu = Image(systemName: "square.grid.2x2")
        static let basket = Image(systemName: "bag")
        static let more = Image(systemName: "ellipsis")
    }
    
    struct InitialView {
        static let screenBackground = Image("screen")
    }
    
    struct Checkout {
        static let leave = Image(systemName: "figure.walk")
        static let car = Image(systemName: "car")
        static let creditCard = Image(systemName: "creditcard")
        static let cash = Image(systemName: "banknote")
        static let cart = Image(systemName: "cart")
    }
    
    struct Stores {
        static let convenience = Image("convenience")
        static let note = Image(systemName: "note.text")
    }
    
    struct Products {
        static let bottles = Image("bottle-cats")
        static let pizza = Image("pizza")
        static let chevronLeft = Image(systemName: "chevron.left")
    }
    
    struct RemoteImage {
        static let placeholder = Image(systemName: "photo")
    }
    
    struct Basket {
        static let tip0 = Image("tip-0")
        static let tip1 = Image("tip-1")
        static let tip2 = Image("tip-2")
        static let tip3 = Image("tip-3")
        static let tip4 = Image("tip-4")
    }
    
    struct MemberDashboard {
        struct Options {
            static let dashboard = Image(systemName: "person.circle")
            static let orders = Image(systemName: "list.bullet.rectangle")
            static let addresses = Image(systemName: "house")
            static let profile = Image(systemName: "person.text.rectangle")
            static let loyalty = Image(systemName: "gift")
            static let logOut = Image(systemName: "rectangle.portrait.and.arrow.right")
        }
        
        struct Loyalty {
            static let copyToClipboard = Image(systemName: "doc.on.doc")
        }
    }
}
