//
//  Strings(UK).swift
//  SnappyV2
//
//  Created by David Bage on 06/01/2022.
//

import Foundation

typealias IterableSnappyString = SnappyString & CaseIterable

typealias IterableSnappyStringCustomisable = SnappyStringCustomisable & CaseIterable

public enum Strings {
    public enum General: String, IterableSnappyString {
        case close = "general.close"
        case next = "general.next"
        case showAll = "general.showall"
        case delivery = "general.delivery"
        case collection = "general.collection"
        case more = "general.more"
        case deliveryTime = "general.deliverytime"
        case free = "general.free"
        case shopNow = "general.shopnow"
        case today = "general.today"
        case add = "general.add"
        case description = "general.description"
        case noDescription = "general.nodescription"
        case cancel = "general.cancel"
        
        public enum Login: String, IterableSnappyString {
            case email = "general.login.email"
            case apple = "general.login.apple"
            case facebook = "general.login.facebook"
            
            public enum Customisable: String, IterableSnappyStringCustomisable {
                case loginWith = "general.login.customisable.loginwith"
                case signInWith = "general.login.customisable.signinwith"
            }
        }
        
        public enum Search: String, IterableSnappyString {
            case searchPostcode = "general.search.searchpostcode"
            case search = "general.search.search"
        }
    }
    
    public enum RootView {
        public enum Tabs: String, IterableSnappyString {
            case stores = "rootview.tabs.stores"
            case menu = "rootview.tabs.menu"
            case basket = "rootview.tabs.basket"
            case account = "rootview.tabs.account"
        }
        
        public enum ChangeStore: String, IterableSnappyString {
            case noStore = "rootview.changestore.nostore"
            case changeStore = "rootview.changestore.changestore"
        }
    }
    
    public enum InitialView: String, IterableSnappyString {
        case tagline = "initialview.tagline"
        case mainlLoginButton = "initialview.mainloginbutton"
        case createAccount = "initialview.createaccount"
        case postcodeSearch = "initialview.postcodesearch"
        case storeSearch = "initialview.storesearch"
    }
    
    public enum CheckoutView {
        public enum Progress: String, IterableSnappyString {
            case time = "checkoutview.progress.time"
            case orderTotal = "checkoutview.progress.ordertotal"
        }
        
        public enum GuestCheckoutCard: String, IterableSnappyString {
            case guest = "checkoutview.guestcheckoutcard.guest"
            case noTies = "checkoutview.guestcheckoutcard.noties"
        }
        
        public enum LoginToAccount: String, IterableSnappyString {
            case login = "checkoutview.logintoaccount.login"
            case earnPoints = "checkoutview.logintoaccount.earnpoints"
        }
        
        public enum AddDetails: String, IterableSnappyString {
            case title = "checkoutview.adddetails.title"
            case firstName = "checkoutview.adddetails.firstname"
            case lastName = "checkoutview.adddetails.lastname"
            case email = "checkoutview.adddetails.email"
            case phone = "checkoutview.adddetails.phone"
        }
        
        public enum AddAddress: String, IterableSnappyString {
            case title = "checkoutview.addaddress.title"
            case findAddress = "checkoutview.addaddress.findaddress"
            case line1 = "checkoutview.addaddress.line1"
            case line2 = "checkoutview.addaddress.line2"
            case postcode = "checkoutview.addaddress.postcode"
            case city = "checkoutview.addaddress.city"
            case country = "checkoutview.addaddress.country"
        }
        
        public enum TsAndCs: String, IterableSnappyString {
            case confirm = "checkoutview.tsandcs.confirm"
            case title = "checkoutview.tsandcs.title"
            case emailMarketing = "checkoutview.tsandcs.emailmarketing"
        }
    }
    
    public enum BasketView: String, IterableSnappyString {
        case subtotal = "basketview.subtotal"
        case checkout = "basketview.checkout"
        case total = "basketview.total"
        
        public enum DeliveryBanner: String, IterableSnappyString {
            case change = "basketview.deliverybanner.change"
            
            public enum Customisable: String, IterableSnappyStringCustomisable {
                case expires = "basketview.deliverybanner.customisable.expires"
            }
        }
        
        public enum Promotions: String, IterableSnappyStringCustomisable {
            case missed = "basketview.promotions.missed"
        }
        
        public enum Coupon: String, IterableSnappyString {
            case code = "basketview.coupon.code"
            case failure = "basketview.coupon.failure"
            case success = "basketview.coupon.success"
        }
        
        public enum ListEntry: String, IterableSnappyString {
            case changeInfo = "basketview.listentry,changeinfo"
            case gotIt = "basketview.listentry.gotit"
        }
    }
    
    public enum StoresView: String, IterableSnappyString {
        case available = "storesview.available"
        
        public enum StoreTypes: String, IterableSnappyString {
            case browse = "storesview.storetypes.browse"
            case showAll = "storesview.storetypes.showall"
        }
        
        public enum FailedSearch: String, IterableSnappyString {
            case notInArea = "storesview.failedsearch.notinarea"
            case showInterest = "storesview.failedsearch.showinterest"
            case showInterestPrompt = "storesview.failedsearch.showinterestprompt"
            case snappyWillLog = "storesview.failedsearch.snappywilllog"
            case snappyWillNotify = "storesview.failedsearch.snappywillnotify"
            case getNotifications = "storesview.failedsearch.getnotifications"
        }
        
        public enum StoreStatus: String, IterableSnappyString {
            case openStores = "storesview.storestatus.openstores"
            case closedStores = "storesview.storestatus.closedstores"
            case preorderstores = "storesview.storestatus.preorderstores"
        }
    }
    
    public enum StoreInfo {
        public enum Delivery: String, IterableSnappyString {
            case fromYou = "storeinfo.delivery.fromyou"
            
            public enum Customisable: String, IterableSnappyStringCustomisable {
                case distance = "storeinfo.delivery.customisable.distance"
            }
        }
    }
    
    public enum DeliverySelection: String, IterableSnappyString {
        case chooseSlot = "deliveryselection.chooseslot"
        case asap = "deliveryselection.asap"
        case upToHour = "deliveryselection.uptohour"
        case chooseFuture = "deliveryselection.choosefuture"
        case upTo10Days = "deliveryselection.upto10days"
        case noDaysAvailable = "deliveryselection.nodaysavailable"
        case morningSlots = "deliveryselection.morningslots"
        case afternoonSlots = "deliveryselection.afternoonslots"
        case eveningSlots = "deliveryselection.eveningslots"
    }
    
    public enum ProductsView: String, IterableSnappyString {
        case searchStore = "productsview.searchstore"
        case filter = "productsview.filter"
        
        public enum ProductCard: String, IterableSnappyString {
            case vegetarian = "productsview.productcard.vegetarian"
        }
        
        public enum ProductDetail: String, IterableSnappyString {
            case was = "productsview.productdetail.was"
            case now = "productsview.productdetail.now"
            case from = "productsview.productdetail.from"
        }
    }
    
    public enum ProductOptions: String, IterableSnappyString {
        case add = "productoptions.add"
        
        enum Customisable: String, IterableSnappyStringCustomisable {
            case add = "productoptions.customisable.add"
        }
    }
    
    public enum ProductCarousel: String, IterableSnappyString {
        case offers = "productcarousel.offers"
    }
}
