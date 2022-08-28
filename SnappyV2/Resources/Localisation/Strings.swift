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
        case table = "general.table"
        case room = "general.room"
        case more = "general.more"
        case deliveryTime = "general.deliverytime"
        case deliveryTimeShort = "general.deliverytime.short"
        case free = "general.free"
        case shopNow = "general.shopnow"
        case updateSlot = "general.updateslot"
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
        case firstName = "general.firstname"
        case lastName = "general.lastname"
        case phone = "general.phone"
        case phoneShort = "general.phone.short"
        case retry = "general.retry"
        case item = "general.item"
        case items = "general.items"
        case defaultCase = "general.default"
        case settings = "general.settings"
        case ok = "general.ok"
        case callStore = "general.callstore"
        case callStoreShort = "general.callstore.short"
        case anErrorOccured = "general.anerroroccured"
        case or = "general.or"
        case send = "general.send"
        case oops = "general.oops"
        case done = "general.done"
        case success = "general.success"
        
        public enum Login: String, IterableSnappyString {
            case email = "general.login.email"
            case apple = "general.login.apple"
            case facebook = "general.login.facebook"
            case facebookShort = "general.login.facebook.short"
            case google = "general.login.google"
            case password = "general.login.password"
            case passwordShort = "general.login.password.short"
            case login = "general.login.login"
            case signup = "general.login.signup"
            case forgot = "general.login.forgot"
            case forgotShortened = "general.login.forgot.shortened"
            case emailAddress = "general.login.emailaddress"
            case title = "general.login.title"
            case titleShortened = "general.login.title.shortened"
            case subtitle = "general.login.subtitle"
            case pay = "general.login.pay"
            case buyWith = "general.login.buywith"
            case noAccount = "general.login.noaccount"
            case noAccountShortened = "general.login.noaccount.shortened"
            case register = "general.login.register"
            case continueWithEmail = "general.login.continuewithemail"
            
            public enum Customisable: String, IterableSnappyStringCustomisable {
                case signInWith = "general.login.customisable.signinwith"
            }
        }
        
        public enum Logout: String, IterableSnappyString {
            case title = "general.logout.title"
            case verify = "general.logout.verify"
        }
        
        public enum Search: String, IterableSnappyString {
            case searchPostcode = "general.search.searchpostcode"
            case search = "general.search.search"
        }
        
        public enum DriverInterface: String, IterableSnappyString {
            case startShift = "general.driverinterface.startshift"
		}
		
        public enum Errors: String, IterableSnappyString {
            case generic = "general.errors.generic"

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
        case subTagline = "initialview.subtagline"
        case createAccount = "initialview.createaccount"
        case postcodeSearch = "initialview.postcodesearch"
        case storeSearch = "initialview.storesearch"
        case businessProfileAlertTitle = "initialview.businessprofilealerttitle"
        case businessProfileAlertMessage = "initialview.businessprofilealertmessage"
        case memberProfileAlertTitle = "initialview.memberprofilealerttitle"
        case memberProfileAlertMessage = "initialview.memberprofilealertmessage"
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
            case email = "checkoutview.adddetails.email"
            case phone = "checkoutview.adddetails.phone"
            case alertTitle = "checkoutview.detailsalerttitle"
            
            public enum Customisable: String, IterableSnappyStringCustomisable {
                case alertMessage = "checkoutview.detailsalertmessage"
            }
        }
        
        public enum CreateAccount: String, IterableSnappyString {
            case subtitle = "checkoutview.createaccount.subtitle"
        }
        
        public enum AddAddress: String, IterableSnappyString {
            case titleDelivery = "checkoutview.addaddress.titledelivery"
            case titleBilling = "checkoutview.addaddress.titlebilling"
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
            case needHelp = "checkoutview.payment.needhelp"
            case callDirect = "checkoutview.payment.calldirect"
            case secureCheckout = "checkoutview.payment.securecheckout"
            case paymentSuccess = "checkoutview.payment.paymentsuccess"
            case billingSameAsDelivery = "checkoutview.payment.billingsameasdelivery"
            case goToSavedAddresses = "checkoutview.payment.gotosavedaddresses"
            case useSavedAddress = "checkoutview.payment.usesavedaddress"
            case savedCards = "checkoutview.payment.savedcards"
            case useNewCard = "checkoutview.payment.usenewcard"
            case cardHolderName = "checkoutview.payment.cardholdername"
            case cardHolderNameShort = "checkoutview.payment.cardholdernameshort"
            case cardNumber = "checkoutview.payment.cardnumbername"
            case cardNumberShort = "checkoutview.payment.cardnumbershort"
            case cvv = "checkoutview.payment.cvv"
            case saveCardDetails = "checkoutview.payment.savecarddetails"
        }
        
        public enum PaymentCustom: String, IterableSnappyStringCustomisable {
            case buttonTitle = "checkoutview.paymentcustom.button.title"
        }
        
        public enum General: String, IterableSnappyString {
            case addInstructions = "checkoutview.general.addinstructions"
        }
        
        public enum OTP: String, IterableSnappyString {
            case promptTitle = "checkoutview.otp.prompttitle"
            case emailOTP = "checkoutview.otp.emailotp"
            case textOTP = "checkoutview.otp.textotp"
            case otpSentTitle = "checkoutview.otp.optsenttitle"
            case enterPassword = "checkoutview.otp.enterpassword"
            
            public enum Customisable: String, IterableSnappyStringCustomisable {
                case promptText = "checkoutview.otp.prompttext"
                case otpSentEmailText = "checkoutview.otp.optsentemailtext"
                case otpSentMobileText = "checkoutview.otp.optsentmobiletext"
            }
        }
    }
    
    public enum BasketView: String, IterableSnappyString {
        case subtotal = "basketview.subtotal"
        case subtotalShort = "basketview.subtotal.short"
        case checkout = "basketview.checkout"
        case total = "basketview.total"
        case drivertips = "basketview.drivertips"
        case slotExpired = "basketview.slotexpired"
        case title = "basketview.title"
        case noItems = "basketview.noitems"
        case notReached = "basketview.notreached"
        case minSpend = "basketview.minspend"
        case valueOf = "basketview.valueof"
        case proceed = "basketview.proceed"
        case minSpendAlertTitle = "basketview.minspend.alert.title"
        case minSpendAlertSubTitle = "basketview.minspend.alert.subtitle"
        case startShopping = "basketview.startshopping"
        case continueShopping = "basketview.continueshopping"
        
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
            case codeTitle = "basketview.coupon.code.title"
            case failure = "basketview.coupon.failure"
            case success = "basketview.coupon.success"
            case alertTitle = "basketview.coupon.alerttitle"
            case alertMessage = "basketview.coupon.alertmessage"
            case alertApply = "basketview.coupon.alertapply"
            case alertApplyShort = "basketview.coupon.alertapply.short"
            case alertRemove = "basketview.coupon.alertremove"
            case couponErrorTitle = "basketview.coupon.title"
            case couponErrorSubtitle = "basketview.coupon.subtitle"
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
            case browseShort = "storesview.storetypes.browse.short"
            case showAll = "storesview.storetypes.showall"
        }
        
        public enum SearchCustom: String, IterableSnappyStringCustomisable {
            case noStores = "storesview.searchcustom.nostores"
        }
        
        public enum FailedSearch: String, IterableSnappyString {
            case notInArea = "storesview.failedsearch.notinarea"
            case showInterest = "storesview.failedsearch.showinterest"
            case showInterestPrompt = "storesview.failedsearch.showinterestprompt"
            case snappyWillLog = "storesview.failedsearch.snappywilllog"
            case snappyWillNotify = "storesview.failedsearch.snappywillnotify"
            case getNotifications = "storesview.failedsearch.getnotifications"
            case getNotificationsShort = "storesview.failedsearch.getnotifications.short"
            case invalidPostcodeTitle = "storesview.failedsearch.invalidpostcode.title"
            case invalidPostcodeSubtitle = "storesview.failedsearch.invalidpostcode.subtitle"
        }
        
        public enum StoreStatus: String, IterableSnappyString {
            case stores = "storesview.storestatus.stores"
            case openStores = "storesview.storestatus.openstores"
            case closedStores = "storesview.storestatus.closedstores"
            case preorderstores = "storesview.storestatus.preorderstores"
            case nearYou = "storesview.storestatus.nearyou"
        }
        
        public enum NoSlots: String, IterableSnappyString {
            case title = "storesview.noslots.title"
        }
        
        public enum NoSlotsCustom: String, IterableSnappyStringCustomisable {
            case subtitle = "storesview.noslotscustom.subtitle"
        }
    }
    
    public enum StoreInfo {
        public enum Status: String, IterableSnappyString {
            case closed = "storeinfo.status.closed"
        }
        
        public enum Delivery: String, IterableSnappyString {
            case distance = "storeinfo.delivery.distance"
            case distanceShort = "storeinfo.delivery.distance.short"
            
            public enum Customisable: String, IterableSnappyStringCustomisable {
                case distance = "storeinfo.delivery.customisable.distance"
                case distanceShort = "storeinfo.delivery.customisable.distance.short"
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
        case noTimeSelected = "slotselection.notimeselected"
        case update = "slotselection.update"
        
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
            case title = "productsview.productcard.title"
            
            public enum SearchStandard: String, IterableSnappyString {
                case enterMoreCharacters = "productsview.productcard.searchstandard.entermore"
                case tryAgain = "productsview.productcard.searchstandard.tryagain"
            }
            
            public enum Search: String, IterableSnappyStringCustomisable {
                case resultThatIncludesCategories = "productsview.productcard.search.resultthatincludescategories"
                case resultThatIncludesItems = "productsview.productcard.search.resultthatincludesitems"
                case noResults = "productsview.productcard.search.noresults"
            }
            
            public enum Sort: String, IterableSnappyString {
                case `default` = "productsview.productcard.sort.default"
                case aToZ = "productsview.productcard.sort.atoz"
                case zToA = "productsview.productcard.sort.ztoa"
                case priceHighToLow = "productsview.productcard.sort.pricehightolow"
                case priceLowToHigh = "productsview.productcard.sort.pricelowtohigh"
                case caloriesLowToHigh = "productsview.productcard.sort.calorieslowtohigh"
            }
        }
        
        public enum ProductDetail: String, IterableSnappyString {
            case was = "productsview.productdetail.was"
            case now = "productsview.productdetail.now"
            case from = "productsview.productdetail.from"
            case orderLimitReached = "productsview.productdetail.orderlimitreached"
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
    
    public enum AddressService: String, IterableSnappyString {
        case noAddressesFound = "addressservice.noaddressesfound"
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
        case addDeliveryTitle = "postcodesearch.adddeliverytitle"
        case addBillingTitle = "postcodesearch.addbillingtitle"
        case editDeliveryTitle = "postcodesearch.editdeliverytitle"
        case editBillingTitle = "postcodesearch.editbillingtitle"
        case deliveryMainTitle = "postcodesearch.deliverymaintitle"
        case billingMainTitle = "postcodesearch.billingmaintitle"
        
        public enum Address: String, IterableSnappyString {
            case line1 = "postcodesearch.address.line1"
            case line2 = "postcodesearch.address.line2"
            case city = "postcodesearch.address.city"
            case county = "postcodesearch.address.county"
            case postcode = "postcodesearch.address.postcode"
            case country = "postcodesearch.address.country"
            case firstName = "postcodesearch.address.firstname"
            case lastName = "postcodesearch.address.lastname"
            case nickname = "postcodesearch.address.nickname"
            case nicknamePrompt = "postcodesearch.address.nicknameprompt"
            case setDefaultPrompt = "postcodesearch.address.setdefaultprompt"
            case save = "postcodesearch.address.save"
            case update = "postcodesearch.address.update"
            case addManually = "postcodesearch.address.addmanually"
            case editAddress = "postcodesearch.address.editaddress"
        }
    }
    
    public enum EditableCardContainer {
        enum Delete: String, IterableSnappyString {
            case areYouSure = "editablecardcontainer.areyousure"
            case cannotUndo = "editablecardcontainer.cannotundo"
        }
        
    }
    
    public enum CheckoutDetails {
        public enum GlobalPayments: String, IterableSnappyString {
            case navTitle = "checkoutdetails.globalpayments.navtitle"
        }
        
        public enum CheckoutProgress: String, IterableSnappyString {
            case details = "checkoutdetails.checkoutprogress.details"
            case payment = "checkoutdetails.checkoutprogress.payment"
        }
        
        public enum EditAddress: String, IterableSnappyString {
            case editDeliveryAddress = "checkoutdetails.editaddress.editDeliveryAddress"
            case postcode = "checkoutdetails.editaddress.postcode"
            case addressLine1 = "checkoutdetails.editaddress.addressline1"
            case addressLine2 = "checkoutdetails.editaddress.addressline2"
            case town = "checkoutdetails.editaddress.town"
            case county = "checkoutdetails.editaddress.county"
            case country = "checkoutdetails.editaddress.country"
            case findButton = "checkoutdetails.editaddress.findbutton"
            case selectSavedAddress = "checkoutdetails.editaddress.selectsavedaddress"
            case selectSavedAddressShort = "checkoutdetails.editaddress.selectsavedaddress.short"
            case noPostcodeErrorTitle = "checkoutdetails.editaddress.nopostcode.error.title"
            case noPostcodeErrorSubtitle = "checkoutdetails.editaddress.nopostcode.error.subtitle"
            case noAddresses = "checkoutdetails.editaddress.noaddresses"
            case firstName = "checkoutdetails.editaddress.firstname"
            case lastName = "checkoutdetails.editaddress.lastname"
            
            public enum Error: String, IterableSnappyString {
                case title = "checkoutdetails.editaddress.error.title"
                case subtitle = "checkoutdetails.editaddress.error.subtitle"
            }
        }
        
        public enum AddressDisplayCard: String, IterableSnappyString {
            case unnamed = "checkoutdetails.addressdisplaycard.unnamed"
            case defaultAddress = "checkoutdetails.addressdisplaycard.default"
        }
        
        public enum AddressSelectionView: String, IterableSnappyString {
            case navTitle = "checkoutdetails.addressselectionview.navtitle"
            case addressErrorTitle = "checkoutdetails.addressselectionview.addresserror.title"
            case addressErrorGeneric = "checkoutdetails.addressselectionview.addresserror.generic"
            case select = "checkoutdetails.addressselectionview.select"
            case selectBilling = "checkoutdetails.addressselectionview.select.billing"
        }
        
        public enum SavedAddressesSelectionView: String, IterableSnappyString {
            case title = "checkoutdetails.savedaddressselectionview.title"
            case titleBilling = "checkoutdetails.savedaddressselectionview.title.billing"
            case setAsDeliveryAddressButton = "checkoutdetails.savedaddressselectionview.button"
            case setAsBillingAddressButton = "checkoutdetails.savedaddressselectionview.button.billing"
            case setAsDeliveryAddressButtonShort = "checkoutdetails.savedaddressselectionview.button.short"
            case navTitle = "checkoutdetails.savedaddressselectionview.navtitle"
            case navTitleBilling = "checkoutdetails.savedaddressselectionview.navtitle.billing"
            case noAddressTitle = "checkoutdetails.savedaddressselectionview.noaddresstitle"
            case noAddressSubtitle = "checkoutdetails.savedaddressselectionview.noaddresssubtitle"
            case addressSetterErrorTitle = "checkoutdetails.savedaddressselectionview.addresssettererror.title"
            case addressSetterErrorGeneric = "checkoutdetails.savedaddressselectionview.addresssettererror.generic"
        }
        
        public enum MarketingPreferences: String, IterableSnappyString {
            case title = "checkoutdetails.marketingpreferences.title"
            case prompt = "checkoutdetails.marketingpreferences.prompt"
            case email = "checkoutdetails.marketingpreferences.email"
            case directMail = "checkoutdetails.marketingpreferences.directmail"
            case notifications = "checkoutdetails.marketingpreferences.notifications"
            case sms = "checkoutdetails.marketingpreferences.sms"
            case telephone = "checkoutdetails.marketingpreferences.telephone"
        }
        
        public enum ChangeFulfilmentMethodCustom: String, IterableSnappyStringCustomisable {
            case button = "checkoutdetails.changefulfilmentmethod.custom.button"
            case slotExpiring = "checkoutdetails.changefulfilmentmethod.custom.slotexpiring"
            case slotTimeDelivery = "checkoutdetails.changefulfilmentmethod.custom.slottime.delivery"
            case slotTimeCollection = "checkoutdetails.changefulfilmentmethod.custom.slottime.collection"
        }
        
        public enum ChangeFulfilmentMethod: String, IterableSnappyString {
            case slotExpired = "checkoutdetails.changefulfilmentmethod.expired"
            case noSlot = "checkoutdetails.changefulfilmentmethod.noslot"
        }
        
        public enum DeliveryNote: String, IterableSnappyString {
            case label = "checkoutdetails.deliverynote.label"
            case title = "checkoutdetails.deliverynote.title"
        }
        
        public enum ContactDetails: String, IterableSnappyString {
            case emailInvalid = "checkoutdetails.contactdetails.emailinvalid"
        }
        
        public enum WhereDidYouHear: String, IterableSnappyString {
            case title = "checkoutdetails.wheredidyouhear.title"
            case choose = "checkoutdetails.wheredidyouhear.choose"
            case placeholder = "checkoutdetails.wheredidyouhear.placeholder"
        }
        
        public enum Errors {
            public enum Missing: String, IterableSnappyString {
                case title = "checkoutdetails.errors.missing.title"
                case subtitle = "checkoutdetails.errors.missing.subtitle"
            }
            
            public enum NoAddresses: String, IterableSnappyString {
                case postcodeSearch = "checkoutdetails.noaddresses.postcodesearch"
                case savedAddresses = "checkoutdetails.noaddresses.savedaddresses"
            }
            
            public enum Field: String, IterableSnappyString {
                case title = "checkoutdetails.errors.field.title"
                case subtitle = "checkoutdetails.errors.field.subtitle"
            }
            
            public enum Submit: String, IterableSnappyString {
                case title = "checkoutdetails.errors.submit"
                case genericSubtitle = "checkoutdetails.errors.genericsubtitle"
            }
            
            public enum NoSlots: String, IterableSnappyString {
                case title = "checkoutdetails.errors.noslots"
            }
        }
        
        public enum Submit: String, IterableSnappyString {
            case title = "checkoutdetails.submit.title"
            case titleLarge = "checkoutdetails.submit.title.large"
        }
    }
    
    public enum OrderSummaryCard: String, IterableSnappyString {
        case status = "ordersummarycard.status"
        case total = "ordersummarycard.total"
        case view = "ordersummarycard.view"
    }
    
    public enum CreateAccount: String, IterableSnappyString {
        case create = "createaccount.create"
        case title = "createaccount.title"
        case newTitle = "createaccount.new.title"
        case titleShort = "createaccount.title.short"
        case subtitle = "createaccount.subtitle"
        case refer = "createaccount.refer"
        case checkout = "createaccount.checkout"
        case deals = "createaccount.deals"
        case addDetails = "createaccount.adddetails"
        case addDetailsShort = "createaccount.adddetails.short"
        case referralTitle = "createaccount.referral.title"
        case referralTitleShort = "createaccount.referral.title.short"
        case referralBody = "createaccount.referral.body"
        case referralPlaceholder = "createaccount.referral.placeholder"
        case referralPlaceholderShort = "createaccount.referral.placeholder.short"
        case createPassword = "createaccount.password.create"
    }
    
    public enum Terms: String, IterableSnappyString {
        case agreeTo = "terms.agreeto"
        case terms = "terms.terms"
        case and = "terms.and"
        case privacy = "terms.privacy"
        case contactUs = "terms.contactus"
    }
    
    public enum MarketingPreferences: String, IterableSnappyString {
        case title = "marketingpreferences.title"
    }
    
    public enum ResetPassword: String, IterableSnappyString {
        case title = "resetpassword.title"
        case subtitle = "resetpassword.subtitle"
        case subtitleShort = "resetpassword.subtitle.short"
    }
    
    public enum ResetPasswordCustom: String, IterableSnappyStringCustomisable {
        case confirmation = "resetpasswordcustom.confirmation"
    }
    
    public enum CustomMemberDashboard: String, IterableSnappyStringCustomisable {
        case welcome = "custommemberdashboard.welcome"
    }
    
    public enum MemberDashboard: String, IterableSnappyString {
        case noMember = "memberdashboard.nomember"
        case errorFindingAccount = "memberdashboard.error"
        
        enum MyDetails: String, IterableSnappyString {
            case savedCardsTitle = "memberdashboard.mydetails.savedcardstitle"
            case addNewCardButton = "memberdashboard.mydetails.addnewcardbutton"
            case addDeliveryAddressButtonTitle = "memberdashboard.mydetails.adddeliveryaddressbuttontitle"
            case addBillingAddressButtonTitle =
                    "memberdashboard.mydetails.addbillingaddressbuttontitle"
            case noSavedCards = "memberdashboard.mydetails.nocards"
            case noDeliveryAddresses = "memberdashboard.mydetails.nodeliveryaddresses"
            case noBillingAddresses = "memberdashboard.mydetails.nobillingaddresses"
        }
        
        enum Options: String, IterableSnappyString {
            case dashboard = "memberdashboard.options.dashboard"
            case orders = "memberdashboard.options.orders"
            case myDetails = "memberdashboard.options.mydetails"
            case profile = "memberdashboard.options.profile"
            case loyalty = "memberdashboard.options.loyalty"
        }
        
        enum Loyalty: String, IterableSnappyString {
            case title = "memberdashboard.loyalty.title"
            case explanation = "memberdashboard.loyalty.explanation"
            case condition = "memberdashboard.loyalty.condition"
            case noCode = "memberdashboard.loyalty.nocode"
            
            enum ReferFriend: String, IterableSnappyString {
                case subtitle = "memberdashboard.loyalty.referfriend.subtitle"
                case caption = "memberdashboard.loyalty.referfriend.caption"
            }
            
            enum Referrals: String, IterableSnappyString {
                case subtitle = "memberdashboard.loyalty.referrals.subtitle"
                case caption = "memberdashboard.loyalty.referrals.caption"
            }
        }
        
        enum Orders: String, IterableSnappyString {
            case noOrders = "memberdashboard.orders.noorders"
        }
        
        enum Profile: String, IterableSnappyString {
            case yourDetails = "memberdashboard.profile.yourdetails"
            case update = "memberdashboard.profile.update"
            case changePassword = "memberdashboard.profile.changePassword"
            case currentPassword = "memberdashboard.profile.currentpassword"
            case newPassword = "memberdashboard.profile.newpassword"
            case verifyPassword = "memberdashboard.profile.verifypassword"
            case backToUpdate = "memberdashboard.profile.backtoupdate"
            case successfullyUpdated = "memberdashboard.profile.successfullyupdated"
            case updatePassword = "memberdashboard.profile.updatepassword"
            case successfullyResetPassword = "memberdashboard.profile.successfullyresetpasssword"

        }
        
        enum AddressSelectionView: String, IterableSnappyString {
            case initialEmptyText = "memberdashboard.addressselectionview.initialemptytext"
            case unnamedAddress = "memberdashboard.addressselectionview.unnamedaddress"

        }
    }
    
    public enum PlacedOrders {
        enum MainView: String, IterableSnappyString {
            case currentOrders = "placedorders.mainview.currentorders"
            case pastOrders = "placedorders.mainview.pastorders"
            case noMoreOrders = "placedorders.mainview.nomoreorders"
            case moreOrders = "placedorders.mainview.moreorders"
        }
        
        enum OrderSummaryCard: String, IterableSnappyString {
            case noSlotSelected = "placedorders.ordersummarycard.noslotselected"
        }
        
        enum OrderDetailsView: String, IterableSnappyString {
            case orderAgain = "placedorders.orderdetailsview.orderagain"
            case orderNumber = "placedorders.orderdetailsview.ordernumber"
            case orderTotal = "placedorders.orderdetailsview.ordertotal"
            case orderSubtotal = "placedorders.orderdetailsview.ordersubtotal"
            case deliveryFee = "placedorders.orderdetailsview.deliveryfee"
            case driverTip = "placedorders.orderdetailsview.drivertip"
        }
        
        enum OrderStoreView: String, IterableSnappyString {
            case store = "placedorders.orderstoreview.store"
            case unknown = "placedorders.orderstoreview.unknown"
        }
        
        enum OrderListItemView: String, IterableSnappyString {
            case items = "placedorders.orderlistitemview.items"
            case quantity = "placedorders.orderlistitemview.quantity"
            case price = "placedorders.orderlistitemview.price"
        }
        
        enum CustomOrderListItem: String, IterableSnappyStringCustomisable {
            case each = "placedorders.customorderlistitem.each"
        }
        
        enum Errors: String, IterableSnappyString {
            case noDeliveryAddressOnOrder = "placedorders.errors.nodeliveryaddressonorder"
            case noMatchingStoreFound = "placedorders.errors.nomatchingstorefound"
            case noStoreFound = "placedorders.errors.nostorefound"
            case failedToSetDeliveryAddress = "placedorders.errors.failedtosetdeliveryaddress"
        }
    }
    
    public enum DriverMap: String, IterableSnappyString {
        case title = "drivermap.navigationbartitle"
        enum InformationBar: String, IterableSnappyString {
            case withDriverNamePrefix = "drivermap.informationbar.driverenroutewithnameprefix"
            case withDriverNameSuffix = "drivermap.informationbar.driverenroutewithnamesuffix"
            case withoutDriverName = "drivermap.informationbar.driverenroutewithoutname"
        }
        
        enum Error: String, IterableSnappyString {
            case title = "drivermap.error.title"
            case body = "drivermap.error.body"
        }
        
        enum Button: String, IterableSnappyString {
            case trackOrder = "drivermap.button.trackorder"
            case trackOrderShort = "drivermap.button.trackorder.short"
        }
    }
    
    public enum ToastNotifications {
        enum BasketChangeTitle: String, IterableSnappyString {
            case itemAdded = "toastnotifications.basketchangetitle.itemadded"
            case itemUpdated = "toastnotifications.basketchangetitle.itemupdated"
            case itemRemoved = "toastnotifications.basketchangetitle.itemremoved"
            case basketChange = "toastnotifications.basketchangetitle.basketchanged"
            case basketChangeSubtitle = "toastnotifications.basketchangetitle.basketchangesubtitle"
        }
        enum BasketChangesItem: String, IterableSnappyStringCustomisable {
            case addedOneItemToBasket = "toastnotifications.basketchangesitem.addedoneitemtobasket"
            case addedMoreItemsToBasket = "toastnotifications.basketchangesitem.addedmoreitemstobasket"
            case updatedItemInBasket = "toastnotifications.basketchangesitem.updatediteminbasket"
            case removedItemFromBasket = "toastnotifications.basketchangesitem.removeditemfrombasket"
        }
        
        enum StoreSearch: String, IterableSnappyString {
            case title = "toastnotifications.storesearch.title"
            case subtitle = "toastnotifications.storesearch.subtitle"
        }
    }
    
    public enum Alerts {
        enum CameraPermission: String, IterableSnappyString {
            case title = "alerts.camerapermission.title"
            case message = "alerts.camerapermission.message"
        }
        enum Location: String, IterableSnappyString {
            case deniedLocationTitle = "alerts.location.deniedlocationtitle"
            case deniedLocationMessage = "alerts.location.deniedlocationmessage"
        }
        enum DeliveryCompleted: String, IterableSnappyString {
            case orderDeliveredTitle = "alerts.drivermap.orderdeliveredtitle"
            case orderDeliveredMessage = "alerts.drivermap.orderdeliveredmessage"
            case orderNotDeliveredTitle = "alerts.drivermap.ordernotdeliveredtitle"
            case orderNotDeliveredMessage = "alerts.drivermap.ordernotdeliveredmessage"
        }
    }
    
    public enum PayMethods {
        enum Card: String, IterableSnappyString {
            case title = "paymentmethods.card.title"
            case subtitle = "paymentmethods.card.subtitle"
        }
        
        enum Cash: String, IterableSnappyString {
            case title = "paymentmethods.cash.title"
            case subtitle = "paymentmethods.cash.subtitle"
        }
        
        enum Apple: String, IterableSnappyString {
            case title = "paymentmethods.apple.title"
            case subtitle = "paymentmethods.apple.subtitle"
        }
    }
    
    public enum StoreRatings: String, IterableSnappyString {
        case numRatingsGeneric = "storereviews.ratings.generic"
    }
    
    public enum FulfilmentTimeSlotSelection {
        enum StoreUnavailableHeadline: String, IterableSnappyString {
            case paused = "fulfilmenttimetlotselection.paused"
            case pausedShort = "fulfilmenttimetlotselection.paused.short"
            case closed = "fulfilmenttimetlotselection.closed"
            case closedShort = "fulfilmenttimetlotselection.closed.short"
        }
        
        enum StoreUnavailableMain: String, IterableSnappyString {
            case closed = "fulfilmenttimetlotselection.storeunavailable.closed"
            case closedShort = "fulfilmenttimetlotselection.storeunavailable.closed.short"
        }
        
        enum Main: String, IterableSnappyString {
            case noSlots = "fulfilmenttimetlotselection.main.noslots"
        }
        
        enum Paused: String, IterableSnappyString {
            case defaultMessage = "fulfilmenttimetlotselection.paused.defaultmessage"
        }
        
        enum Holiday: String, IterableSnappyString {
            case defaultMessage = "fulfilmenttimetlotselection.holiday.defaultmessage"
        }
        
        enum Update: String, IterableSnappyString {
            case successTitle = "fulfilmenttimetlotselection.update.success"
            case successSubtitle = "fulfilmenttimetlotselection.update.success.subtitle"
        }
    }
    
    public enum CheckoutServiceErrors: String, IterableSnappyString {
        case selfError = "checkoutserviceerrors.selferror"
        case storeSelectionRequired = "checkoutserviceerrors.storeselectionrequired"
        case unableToProceedWithoutBasket = "checkoutserviceerrors.unabletoproceedwithoutbasket"
        case draftOrderRequired = "checkoutserviceerrors.draftorderrequired"
        case paymentGatewayNotAvaibleToStore = "checkoutserviceerrors.paymentgatewaynotavaibletostore"
        case paymentGatewayNotAvaibleForFulfilmentMethod = "checkoutserviceerrors.paymentgatewaynotavaibleforfulfilmentmethod"
        case unablePersistLastDeliverOrder = "checkoutserviceerrors.unablepersistlastdeliverorder"
    }
    
    public enum FulfilmentInfoCard: String, IterableSnappyString {
        case editDelivery = "fulfilmentinfocard.editdelivery"
        case editCollection = "fulfilmentinfocard.editcollection"
        case changeToDeliver = "fulfilmentinfocard.changetodeliver"
        case changeToCollect = "fulfilmentinfocard.changetocollect"
    }
    
    public enum MentionMe {
        enum Webview: String, IterableSnappyString {
            case loading = "mentionme.webview.loading"
            case fallbackTitle = "mentionme.webview.fallbackTitle"
        }
    }
    
    public enum Settings {
        enum Main: String, IterableSnappyString {
            case title = "settings.main.title"
        }
        
        enum UsefulInfo: String, IterableSnappyString {
            case title = "settings.userfulinfo.title"
        }
        
        enum MarketingPrefs: String, IterableSnappyString {
            case subtitle = "settings.marketingprefs.subtitle"
            case overrideTitle = "settings.marketingprefs.overridetitle"
        }
        
        enum PushNotifications: String, IterableSnappyString {
            case title = "settings.pushnotifications.title"
            case enable = "settings.pushnotifications.enable"
            case marketingOptionDescription = "settings.pushnotifications.marketingOptionDescription"
        }
    }
    
    public enum FormErrors: String, IterableSnappyString {
        case passwordsDoNotMatch = "formerrors.passwordsdonotmatch"
    }
    
    public enum PushNotifications: String, IterableSnappyString {
        case title = "pushnotifications.incomingview.title"
        case openLink = "pushnotifications.incomingview.openlink"
        case call = "pushnotifications.incomingview.call"
    }
}
