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
    }
    
    struct SnappyLogos {
        static let snappyLogoWhite = Image("snappy-logo-white")
        static let defaultLargeLogo = Image("default_large_logo")
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
        }
        
        static let edit = Image(systemName: "rectangle.and.pencil.and.ellipsis")
    }
    
    struct Login {
        struct User {
            static let square = Image(systemName: "person.crop.square")
            static let standard = Image(systemName: "person")
        }
        
        struct Methods {
            static let apple = Image(systemName: "applelogo")
        }
    }
    
    struct General {
        struct Number {
            static let filledCircle = Image(systemName: "number.circle.fill")
        }
        
        struct Info {
            static let circle = Image(systemName: "info.circle")
        }
        
        static let bulletList = Image(systemName: "list.bullet.rectangle")
        static let thumbsUp = Image(systemName: "hand.thumbsup")
        static let alert = Image(systemName: "bell")
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
    }
    
    struct Stores {
        static let convenience = Image("convenience")
        static let note = Image(systemName: "note.text")
    }
    
    struct Products {
        static let bottles = Image("bottle-cats")
        static let pizza = Image("pizza")
    }
}