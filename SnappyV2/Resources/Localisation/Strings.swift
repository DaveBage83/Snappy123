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
        case select = "general.select"
        case back = "general.back"
        case edit = "general.edit"
        case submit = "general.submit"
        case cont = "general.cont"
        
        public enum Login: String, IterableSnappyString {
            case email = "general.login.email"
            case apple = "general.login.apple"
            case facebook = "general.login.facebook"
            case password = "general.login.password"
            
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
        
        public enum Payment: String, IterableSnappyString {
            case unsuccessfulPayment = "checkoutview.payment.unsuccessful"
            case checkAndChooseAlternativePayment = "checkoutview.payment.checkandchoosealternativepayment"
            case payByCard = "checkoutview.payment.paybycard"
            case payByCardSubtitle = "checkoutview.payment.paybycardsubtitle"
            case payByApple = "checkoutview.payment.paybyapple"
            case payByCash = "checkoutview.payment.paybycash"
            case payByCashSubtitle = "checkoutview.payment.paybycashsubtitle"
        }
        
        public enum General: String, IterableSnappyString {
            case addInstructions = "checkoutview.general.addinstructions"
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
            case chargeInfo = "basketview.listentry.chargeinfo"
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
    
    public enum SlotSelection: String, IterableSnappyString {
        case upTo10Days = "slotselection.upto10days"
        case noDaysAvailable = "slotselection.nodaysavailable"
        case morningSlots = "slotselection.morningslots"
        case afternoonSlots = "slotselection.afternoonslots"
        case eveningSlots = "slotselection.eveningslots"
        case selectSlotAtCheckout = "slotselection.selectslotatcheckout"
        
        public enum Customisable: String, IterableSnappyStringCustomisable {
            case chooseSlot = "slotselection.customisable.chooseslot"
            case today = "slotselection.customisable.today"
            case upToHour = "slotselection.customisable.uptohour"
            case chooseFuture = "slotselection.customisable.choosefuture"
            case deliveryInTimeframe = "slotselection.customisable.deliveryintimeframe"
        }
    }
    
    public enum ProductsView: String, IterableSnappyString {
        case searchStore = "productsview.searchstore"
        case filter = "productsview.filter"
        
        public enum ProductCard: String, IterableSnappyString {
            case vegetarian = "productsview.productcard.vegetarian"
            
            public enum Search: String, IterableSnappyStringCustomisable {
                case resultThatIncludesCategories = "productsview.productcard.search.resultthatincludescategories"
                case resultThatIncludesItems = "productsview.productcard.search.resultthatincludesitems"
                case noResults = "productsview.productcard.search.noresults"
            }
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
    
    public enum PostCodeSearch: String, IterableSnappyString {
        case findButton = "postcodesearch.findbutton"
        case addAddress = "postcodesearch.addaddress"
        case editAddress = "postcodesearch.editaddress"
        case enterPostCode = "postcodesearch.enterpostcode"
        case prompt = "postcodesearch.prompt"
        case enterManually = "postcodesearch.entermanually"
        case initialPrompt = "postcodesearch.initialprompt"
        case noAddressFound = "postcodesearch.noaddressfound"
        case toPostcodeSearch = "postcodesearch.topostcodesearch"
        
        public enum Address: String, IterableSnappyString {
            case line1 = "postcodesearch.address.line1"
            case line2 = "postcodesearch.address.line2"
            case city = "postcodesearch.address.city"
            case county = "postcodesearch.address.county"
            case postcode = "postcodesearch.address.postcode"
            case country = "postcodesearch.address.country"
            case firstName = "postcodesearch.address.firstname"
            case lastName = "postcodesearch.address.lastname"
        }
    }
    
    public enum CheckoutDetails {
        public enum MarketingPreferences: String, IterableSnappyString {
            case title = "checkoutdetails.marketingpreferences.title"
            case prompt = "checkoutdetails.marketingpreferences.prompt"
            case email = "checkoutdetails.marketingpreferences.email"
            case directMail = "checkoutdetails.marketingpreferences.directmail"
            case notifications = "checkoutdetails.marketingpreferences.notifications"
            case sms = "checkoutdetails.marketingpreferences.sms"
            case telephone = "checkoutdetails.marketingpreferences.telephone"
        }
    }
    
    public enum OrderSummaryCard: String, IterableSnappyString {
        case status = "ordersummarycard.status"
        case total = "ordersummarycard.total"
        case view = "ordersummarycard.view"
    }
    
    public enum CreateAccountCard: String, IterableSnappyString {
        case title = "createaccountcard.create"
        case buttonText = "createaccountcard.buttontext"
        case refer = "createaccountcard.refer"
        case checkout = "createaccountcard.checkout"
        case deals = "createaccountcard.deals"
    }
}
