//
//  Images.swift
//  SnappyV2
//
//  Created by David Bage on 07/01/2022.
//

import SwiftUI

extension Image {
    
    struct InitialViewItems {
        static let oval = Image("oval1")
        static let bread = Image("bread")
        static let chocolate = Image("chocolate")
        static let crisps = Image("crisps")
        static let orange = Image("orange")
        static let pizza = Image("pizza")
        static let tomato = Image("tomato")
        static let milk = Image("milk")
    }
    
    struct Branding {
        struct Logo {
            static let fullColor = Image("logoFullColor")
            static let white = Image("logoWhite")
            static let inline = Image("logoInline")
        }
        
        struct StockPhotos {
            static let deliveryMan = Image("deliveryMan")
            static let phoneInHand = Image("phoneInHand")
        }
    }
    
    struct PaymentMethods {
        static let applePay = Image("applePay")
        static let applePayDisabled = Image("applePayDisabled")
    }
    
    struct Placeholders {
        static let productPlaceholder = Image("productPlaceholder")
    }
    
    struct Social {
        static let facebook = Image("facebook")
        static let google = Image("google")
    }
    
    struct Icons {
        
        static let star = Image("star")
        
        struct Truck {
            static let standard = Image("truck")
            static let filled = Image("truckFilled")
            static let heavy = Image("truckHeavy")
        }
        
        struct Clock {
            static let standard = Image("clock")
            static let filled = Image("clockFilled")
            static let heavy = Image("clockHeavy")
        }
        
        struct Padlock {
            static let standard = Image("padlock")
            static let filled = Image("padlockFilled")
            static let heavy = Image("padlockHeavy")
        }
        
        struct Bars {
            static let standard = Image("bars")
            static let medium = Image("barsMedium")
            static let heavy = Image("barsHeavy")
        }
        
        struct House {
            static let standard = Image("house")
            static let filled = Image("houseFilled")
            static let heavy = Image("houseHeavy")
        }
        
        struct MagnifyingGlass {
            static let standard = Image("magnifyingGlass")
            static let medium = Image("magnifyingGlassMedium")
            static let heavy = Image("magnifyingGlassHeavy")
        }
        
        struct Xmark {
            static let standard = Image("xmark")
            static let medium = Image("xmarkMedium")
            static let heavy = Image("xmarkHeavy")
        }
        
        struct CircleCheck {
            static let standard = Image("circleCheck")
            static let filled = Image("circleCheckFilled")
            static let heavy = Image("circleCheckHeavy")
        }
        
        struct Circle {
            static let standard = Image("circle")
            static let filled = Image("circleFilled")
            static let heavy = Image("circleHeavy")
        }
        
        struct Info {
            static let standard = Image("info")
            static let filled = Image("infoFilled")
            static let heavy = Image("infoHeavy")
        }
        
        struct LocationArrow {
            static let standard = Image("locationArrow")
            static let filled = Image("locationArrowFilled")
            static let heavy = Image("locationArrowHeavy")
        }
        
        struct LocationCrosshairs {
            static let standard = Image("locationCrosshairs")
            static let medium = Image("locationCrosshairsMedium")
            static let heavy = Image("locationCrosshairsHeavy")
        }
        
        struct LocationDot {
            static let standard = Image("locationDot")
            static let filled = Image("locationDotFilled")
            static let heavy = Image("locationDotHeavy")
        }
        
        struct ThumbsUp {
            static let standard = Image("thumbsUp")
            static let filled = Image("thumbsUpFilled")
            static let heavy = Image("thumbsUpHeavy")
        }
        
        struct Piggy {
            static let standard = Image("piggy")
            static let filled = Image("piggyFilled")
            static let heavy = Image("piggyHeavy")
        }
        
        struct CartFast {
            static let standard = Image("cartFast")
            static let filled = Image("cartFastFilled")
            static let heavy = Image("cartFastHeavy")
        }
        
        struct Basket {
            static let standard = Image("basket")
            static let filled = Image("basketFilled")
            static let heavy = Image("basketHeavy")
        }
        
        struct BagShopping {
            static let standard = Image("bagShopping")
            static let filled = Image("bagShoppingFilled")
            static let heavy = Image("bagShoppingHeavy")
        }
        
        struct Plus {
            static let standard = Image("plus")
            static let medium = Image("plusMedium")
            static let heavy = Image("plusHeavy")
        }
        
        struct Minus {
            static let standard = Image("minus")
            static let medium = Image("minusMedium")
            static let heavy = Image("minusHeavy")
        }
        
        struct Shop {
            static let standard = Image("shop")
            static let filled = Image("shopFilled")
            static let heavy = Image("shopHeavy")
        }
        
        struct Store {
            static let standard = Image("store")
            static let filled = Image("storeFilled")
            static let heavy = Image("storeHeavy")
        }
        
        struct Receipt {
            static let standard = Image("receipt")
            static let filled = Image("receiptFilled")
            static let heavy = Image("receiptHeavy")
        }
        
        struct User {
            static let standard = Image("user")
            static let filled = Image("userFilled")
            static let heavy = Image("userHeavy")
        }
        
        struct UserPlus {
            static let standard = Image("userPlus")
            static let filled = Image("userPlusFilled")
            static let heavy = Image("userPlusHeavy")
        }
        
        struct Tips {
            static let level1 = Image("tipLevel1")
            static let level2 = Image("tipLevel2")
            static let level3 = Image("tipLevel3")
            static let level4 = Image("tipLevel4")
            static let level5 = Image("tipLevel5")
        }
        
        struct Arrows {
            struct Left {
                static let light = Image("arrowLeftLight")
                static let medium = Image("arrowLeftMedium")
                static let heavy = Image("arrowLeftHeavy")
            }
            
            struct Right {
                static let light = Image("arrowRightLight")
                static let medium = Image("arrowRightMedium")
                static let heavy = Image("arrowRightHeavy")
            }
            
            struct Up {
                static let light = Image("arrowUpLight")
                static let medium = Image("arrowUpMedium")
                static let heavy = Image("arrowUpHeavy")
            }
            
            struct Down {
                static let light = Image("arrowDownLight")
                static let medium = Image("arrowDownMedium")
                static let heavy = Image("arrowDownHeavy")
            }
            
            struct RightFromBracket {
                static let light = Image("rightFromBracket")
                static let medium = Image("rightFromBracketMedium")
                static let heavy = Image("rightFromBracketHeavy")
            }
            
            struct RighLeft {
                static let light = Image("rightLeft")
                static let medium = Image("rightLeftMedium")
                static let heavy = Image("rightLeftheavy")
            }
        }
        
        struct Chevrons {
            struct Left {
                static let light = Image("chevronLeftLight")
                static let medium = Image("chevronLeftMedium")
                static let heavy = Image("chevronLeftHeavy")
            }
            
            struct Right {
                static let light = Image("chevronRightLight")
                static let medium = Image("chevronRightMedium")
                static let heavy = Image("chevronRightHeavy")
            }
            
            struct Up {
                static let light = Image("chevronUpLight")
                static let medium = Image("chevronUpMedium")
                static let heavy = Image("chevronUpHeavy")
            }
            
            struct Down {
                static let light = Image("chevronDownLight")
                static let medium = Image("chevronDownMedium")
                static let heavy = Image("chevronDownHeavy")
            }
        }
        
        struct CirclePlus {
            static let standard = Image("circlePlus")
            static let filled = Image("circlePlusFilled")
            static let heavy = Image("circlePlusHeavy")
        }
        
        struct CircleMinus {
            static let standard = Image("circleMinus")
            static let filled = Image("circleMinusFilled")
            static let heavy = Image("circleMinusHeavy")
        }
        
        struct Eye {
            static let standard = Image("eye")
            static let filled = Image("eyeFilled")
            static let heavy = Image("eyeHeavy")
        }
        
        struct EyeSlash {
            static let standard = Image("eyeSlash")
            static let filled = Image("eyeSlashFilled")
            static let heavy = Image("eyeSlashHeavy")
        }
        
        struct CreditCard {
            static let standard = Image("creditCard")
            static let filled = Image("creditCardFilled")
            static let heavy = Image("creditCardHeavy")
        }
        
        struct CircleUser {
            static let standard = Image("circleUser")
            static let filled = Image("circleUserFilled")
            static let heavy = Image("circleUserHeavy")
        }
        
        struct Trash {
            static let standard = Image("trash")
            static let filled = Image("trashFilled")
            static let heavy = Image("trashHeavy")
        }
        
        struct PersonWalking {
            static let standard = Image("personWalking")
            static let medium = Image("personWalkingMedium")
            static let heavy = Image("personWalkingHeavy")
        }
        
        struct CircleXmark {
            static let standard = Image("circleXmark")
            static let medium = Image("circleXmarkFilled")
            static let heavy = Image("circleXmarkHeavy")
        }
        
        struct MoneyBill {
            static let standard = Image("moneyBill")
            static let filled = Image("moneyBillFilled")
            static let heavy = Image("moneyBillHeavy")
        }
        
        struct Pen {
            static let standard = Image("pen")
            static let filled = Image("penFilled")
            static let heavy = Image("penHeavy")
        }
        
        struct Phone {
            static let standard = Image("phone")
            static let filled = Image("phoneFilled")
            static let heavy = Image("phoneHeavy")
        }
        
        struct CircleTrash {
            static let standard = Image("circleTrash")
            static let filled = Image("circleTrashFilled")
            static let heavy = Image("circleTrashHeavy")
        }
        
        struct TrashXmark {
            static let standard = Image("trashXmark")
            static let filled = Image("trashXmarkFilled")
            static let heavy = Image("trashXmarkHeavy")
        }
        
        struct MoneyBill1Wave {
            static let standard = Image("moneyBill1Wave")
            static let filled = Image("moneyBill1WaveFilled")
            static let heavy = Image("moneyBill1WaveHeavy")
        }
        
        struct UserGroup {
            static let standard = Image("userGroup")
            static let filled = Image("userGroupFilled")
            static let heavy = Image("userGroupHeavy")
        }
        
        struct Comment {
            static let standard = Image("comment")
            static let filled = Image("commentFilled")
            static let heavy = Image("commentHeavy")
        }
        
        struct Door {
            static let standard = Image("door")
            static let filled = Image("doorFilled")
            static let heavy = Image("doorHeavy")
        }
        
        struct StoreSlash {
            static let standard = Image("storeSlash")
            static let filled = Image("storeSlashFilled")
            static let heavy = Image("storeSlashHeavy")
        }
        
        struct Tag {
            static let standard = Image("tag")
            static let filled = Image("tagFilled")
            static let heavy = Image("tagHeavy")
        }
        
        struct CircleExclamation {
            static let standard = Image("circleExclamation")
            static let filled = Image("circleExclamationFilled")
            static let heavy = Image("circleExclamationHeavy")
        }
        
        struct WeightScale {
            static let standard = Image("weightScale")
            static let filled = Image("weightScaleFilled")
            static let heavy = Image("weightScaleHeavy")
        }
        
        struct Microphone {
            static let standard = Image("microphone")
            static let filled = Image("microphoneFilled")
            static let heavy = Image("microphoneHeavy")
        }
    }

    // The following icons to be deprecated in favour of the above official design ones
    
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
            static let address = Image(systemName: "mail.and.text.magnifyingglass")
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
    
    struct Fulfilment {
        struct Truck {
            static let standard = Image("truck")
            static let filled = Image("truckFilled")
            static let heavy = Image("truckHeavy")
        }
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
        static let delete = Image(systemName: "trash")
        static let noDelete = Image(systemName: "trash.slash")
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
        static let delivery = Image(systemName: "car")
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
    
    struct OrderStore {
        static let address = Image(systemName: "pin.circle.fill")
        static let phone = Image(systemName: "phone.fill")
    }
}
