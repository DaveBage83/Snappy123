//
//  RetailStore.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 15/09/2021.
//

import Foundation
import CoreLocation

struct RetailStoresSearch: Codable, Equatable {
    // Coable - populated by API response
    let storeProductTypes: [RetailStoreProductType]?
    let stores: [RetailStore]?
    
    // populated by request and cached data
    let postcode: String?
    let latitude: Double?
    let longitude: Double?
}

struct RetailStore: Codable, Equatable, Hashable {
    let id: Int
    let storeName: String
    let distance: Double
    let storeLogo: [String: URL]?
    let storeProductTypes: [Int]?
    let orderMethods: [String: RetailStoreOrderMethod]?
}

struct RetailStoreProductType: Codable, Equatable, Hashable {
    let id: Int
    let name: String
    let image: [String: URL]?
}

enum RetailStoreOrderMethodName: String, Codable {
    case delivery
    case collection
    case table
    case room
}

enum RetailStoreOrderMethodStatus: String, Codable {
    case open
    case closed
    case preorder
}

struct RetailStoreOrderMethod: Codable, Equatable {
    let name: RetailStoreOrderMethodName
    let earliestTime: String?
    let status: RetailStoreOrderMethodStatus
    let cost: Double?
    let fulfilmentIn: String?
    // workingHours - todo, differs from spolight
}

struct RetailStoreDetails: Codable {
    let id: Int
    let menuGroupId: Int
    let storeName: String
    let telephone: String
    let lat: Double
    let lng: Double
    let ordersPaused: Bool
    let canDeliver: Bool
    let distance: Double?
    let pausedMessage: String?
    let address1: String
    let address2: String?
    let town: String
    let postcode: String
    
    let storeLogo: [String: URL]?
    let storeProductTypes: [Int]?
    let orderMethods: [String: RetailStoreOrderMethod]?
    let deliveryDays: [RetailStoreFulfilmentDay]?
    let collectionDays: [RetailStoreFulfilmentDay]?
    
    // populated by request and cached data
    let searchPostcode: String?
}

struct RetailStoreFulfilmentDay: Codable {
    let date: String
    let start: String
    let end: String
}

/*
{
  "storeProductTypes" : [
    {
      "id" : 21,
      "name" : "Convenience Stores",
      "image" : {
        "mdpi_1x" : "https:\/\/www.snappyshopper.co.uk\/uploads\/images\/store_types_full_width\/mdpi_1x\/1613754190stores.png",
        "xhdpi_2x" : "https:\/\/www.snappyshopper.co.uk\/uploads\/images\/store_types_full_width\/xhdpi_2x\/1613754190stores.png",
        "xxhdpi_3x" : "https:\/\/www.snappyshopper.co.uk\/uploads\/images\/store_types_full_width\/xxhdpi_3x\/1613754190stores.png"
      }
    },
    {
      "id" : 32,
      "name" : "Greengrocers",
      "image" : {
        "mdpi_1x" : "https:\/\/www.snappyshopper.co.uk\/uploads\/images\/store_types_half_width\/mdpi_1x\/1613754280greengrocers.png",
        "xhdpi_2x" : "https:\/\/www.snappyshopper.co.uk\/uploads\/images\/store_types_half_width\/xhdpi_2x\/1613754280greengrocers.png",
        "xxhdpi_3x" : "https:\/\/www.snappyshopper.co.uk\/uploads\/images\/store_types_half_width\/xxhdpi_3x\/1613754280greengrocers.png"
      }
    }
  ],
  "stores" : [
    {
      "slug" : "premier-nethergate-1944",
      "distance" : 0.57999999999999996,
      "id" : 1944,
      "storeProductTypes" : [
        21
      ],
      "storeName" : "Premier Nethergate",
      "storeLogo" : {
        "mdpi_1x" : "https:\/\/www.snappyshopper.co.uk\/uploads\/mobile_app_images\/mdpi_1x\/14867386811484320803snappy_store_logo.png",
        "xhdpi_2x" : "https:\/\/www.snappyshopper.co.uk\/uploads\/mobile_app_images\/xhdpi_2x\/14867386811484320803snappy_store_logo.png",
        "xxhdpi_3x" : "https:\/\/www.snappyshopper.co.uk\/uploads\/mobile_app_images\/xxhdpi_3x\/14867386811484320803snappy_store_logo.png"
      },
      "orderMethods" : {
        "delivery" : {
          "name" : "delivery",
          "status" : "closed",
          "cost" : 0
        }
      }
    },
    {
      "slug" : "polish-deli-kubus-1414",
      "distance" : 0.84999999999999998,
      "id" : 1414,
      "storeProductTypes" : [
        21
      ],
      "storeName" : "Polish Deli Kubus",
      "storeLogo" : {
        "mdpi_1x" : "https:\/\/www.snappyshopper.co.uk\/uploads\/images\/stores\/mdpi_1x\/1599144659Untitleddesign20200903T155045.296.png",
        "xhdpi_2x" : "https:\/\/www.snappyshopper.co.uk\/uploads\/images\/stores\/xhdpi_2x\/1599144659Untitleddesign20200903T155045.296.png",
        "xxhdpi_3x" : "https:\/\/www.snappyshopper.co.uk\/uploads\/images\/stores\/xxhdpi_3x\/1599144659Untitleddesign20200903T155045.296.png"
      },
      "orderMethods" : {
        "collection" : {
          "name" : "collection",
          "status" : "closed",
          "cost" : 0
        },
        "delivery" : {
          "status" : "closed",
          "earliestTime" : null,
          "name" : "delivery",
          "cost" : 3,
          "workingHours" : {
            "close" : "19:00:00",
            "open" : "10:00:00"
          }
        }
      }
    },
    {
      "slug" : "polish-deli-dundee-scanning-1798",
      "distance" : 0.84999999999999998,
      "id" : 1798,
      "storeProductTypes" : [
        21
      ],
      "storeName" : "Polish Deli Dundee Scanning",
      "storeLogo" : {
        "mdpi_1x" : "https:\/\/www.snappyshopper.co.uk\/uploads\/mobile_app_images\/mdpi_1x\/14867386811484320803snappy_store_logo.png",
        "xhdpi_2x" : "https:\/\/www.snappyshopper.co.uk\/uploads\/mobile_app_images\/xhdpi_2x\/14867386811484320803snappy_store_logo.png",
        "xxhdpi_3x" : "https:\/\/www.snappyshopper.co.uk\/uploads\/mobile_app_images\/xxhdpi_3x\/14867386811484320803snappy_store_logo.png"
      },
      "orderMethods" : [

      ]
    },
    {
      "slug" : "spar-perth-road-1807",
      "distance" : 1.4399999999999999,
      "id" : 1807,
      "storeProductTypes" : [
        21
      ],
      "storeName" : "SPAR Perth Road",
      "storeLogo" : {
        "mdpi_1x" : "https:\/\/www.snappyshopper.co.uk\/uploads\/images\/stores\/mdpi_1x\/1605800838sparlogo.png",
        "xhdpi_2x" : "https:\/\/www.snappyshopper.co.uk\/uploads\/images\/stores\/xhdpi_2x\/1605800838sparlogo.png",
        "xxhdpi_3x" : "https:\/\/www.snappyshopper.co.uk\/uploads\/images\/stores\/xxhdpi_3x\/1605800838sparlogo.png"
      },
      "orderMethods" : {
        "delivery" : {
          "name" : "delivery",
          "status" : "closed",
          "cost" : 0
        }
      }
    },
    {
      "slug" : "premier-hayats-supersaver-787",
      "distance" : 1.74,
      "id" : 787,
      "storeProductTypes" : [
        21
      ],
      "storeName" : "Premier Hayats Supersaver",
      "storeLogo" : {
        "mdpi_1x" : "https:\/\/www.snappyshopper.co.uk\/uploads\/images\/stores\/mdpi_1x\/1562880568premierlogo.png",
        "xhdpi_2x" : "https:\/\/www.snappyshopper.co.uk\/uploads\/images\/stores\/xhdpi_2x\/1562880568premierlogo.png",
        "xxhdpi_3x" : "https:\/\/www.snappyshopper.co.uk\/uploads\/images\/stores\/xxhdpi_3x\/1562880568premierlogo.png"
      },
      "orderMethods" : {
        "delivery" : {
          "status" : "closed",
          "earliestTime" : null,
          "name" : "delivery",
          "cost" : 3,
          "workingHours" : {
            "close" : "22:30:00",
            "open" : "09:30:00"
          }
        }
      }
    },
    {
      "slug" : "family-shopper-lochee-30",
      "distance" : 2.1299999999999999,
      "id" : 30,
      "storeProductTypes" : [
        21,
        32
      ],
      "storeName" : "Family Shopper Lochee",
      "storeLogo" : {
        "mdpi_1x" : "https:\/\/www.snappyshopper.co.uk\/uploads\/images\/stores\/mdpi_1x\/1581190214Barassie3.png",
        "xhdpi_2x" : "https:\/\/www.snappyshopper.co.uk\/uploads\/images\/stores\/xhdpi_2x\/1581190214Barassie3.png",
        "xxhdpi_3x" : "https:\/\/www.snappyshopper.co.uk\/uploads\/images\/stores\/xxhdpi_3x\/1581190214Barassie3.png"
      },
      "orderMethods" : {
        "collection" : {
          "status" : "open",
          "earliestTime" : "14:40 - 14:45",
          "name" : "collection",
          "cost" : 0,
          "workingHours" : {
            "close" : "22:30:00",
            "open" : "09:30:00"
          }
        },
        "delivery" : {
          "status" : "preorder",
          "earliestTime" : null,
          "name" : "delivery",
          "cost" : 3.5,
          "workingHours" : {
            "close" : "22:30:00",
            "open" : "09:30:00"
          }
        }
      }
    },
    {
      "slug" : "spar-glamis-road-1806",
      "distance" : 2.48,
      "id" : 1806,
      "storeProductTypes" : [
        21
      ],
      "storeName" : "SPAR Glamis Road",
      "storeLogo" : {
        "mdpi_1x" : "https:\/\/www.snappyshopper.co.uk\/uploads\/images\/stores\/mdpi_1x\/1605799757bigspar.png",
        "xhdpi_2x" : "https:\/\/www.snappyshopper.co.uk\/uploads\/images\/stores\/xhdpi_2x\/1605799757bigspar.png",
        "xxhdpi_3x" : "https:\/\/www.snappyshopper.co.uk\/uploads\/images\/stores\/xxhdpi_3x\/1605799757bigspar.png"
      },
      "orderMethods" : {
        "delivery" : {
          "name" : "delivery",
          "status" : "closed",
          "cost" : 0
        }
      }
    },
    {
      "slug" : "premier-claypotts-broughty-ferry-1888",
      "distance" : 2.9700000000000002,
      "id" : 1888,
      "storeProductTypes" : [
        21
      ],
      "storeName" : "Premier Claypotts Broughty Ferry",
      "storeLogo" : {
        "mdpi_1x" : "https:\/\/www.snappyshopper.co.uk\/uploads\/images\/stores\/mdpi_1x\/1611740244da11553998ee641a0a0b4bde58fb73ec.png",
        "xhdpi_2x" : "https:\/\/www.snappyshopper.co.uk\/uploads\/images\/stores\/xhdpi_2x\/1611740244da11553998ee641a0a0b4bde58fb73ec.png",
        "xxhdpi_3x" : "https:\/\/www.snappyshopper.co.uk\/uploads\/images\/stores\/xxhdpi_3x\/1611740244da11553998ee641a0a0b4bde58fb73ec.png"
      },
      "orderMethods" : {
        "delivery" : {
          "status" : "closed",
          "earliestTime" : null,
          "name" : "delivery",
          "cost" : 0,
          "workingHours" : {
            "close" : "21:15:00",
            "open" : "07:00:00"
          }
        }
      }
    },
    {
      "slug" : "spar-orleans-pl-dundee-1244",
      "distance" : 3.0699999999999998,
      "id" : 1244,
      "storeProductTypes" : [
        21
      ],
      "storeName" : "Spar Orleans Pl Dundee",
      "storeLogo" : {
        "mdpi_1x" : "https:\/\/www.snappyshopper.co.uk\/uploads\/images\/stores\/mdpi_1x\/1587146488Untitleddesign20200412T231044.844.png",
        "xhdpi_2x" : "https:\/\/www.snappyshopper.co.uk\/uploads\/images\/stores\/xhdpi_2x\/1587146488Untitleddesign20200412T231044.844.png",
        "xxhdpi_3x" : "https:\/\/www.snappyshopper.co.uk\/uploads\/images\/stores\/xxhdpi_3x\/1587146488Untitleddesign20200412T231044.844.png"
      },
      "orderMethods" : {
        "delivery" : {
          "status" : "closed",
          "earliestTime" : null,
          "name" : "delivery",
          "cost" : 0,
          "workingHours" : {
            "close" : "21:00:00",
            "open" : "10:00:00"
          }
        }
      }
    },
    {
      "slug" : "premier-tayport-1536",
      "distance" : 3.1600000000000001,
      "id" : 1536,
      "storeProductTypes" : [
        21
      ],
      "storeName" : "Premier Tayport",
      "storeLogo" : {
        "mdpi_1x" : "https:\/\/www.snappyshopper.co.uk\/uploads\/images\/stores\/mdpi_1x\/1599204265da11553998ee641a0a0b4bde58fb73ec.png",
        "xhdpi_2x" : "https:\/\/www.snappyshopper.co.uk\/uploads\/images\/stores\/xhdpi_2x\/1599204265da11553998ee641a0a0b4bde58fb73ec.png",
        "xxhdpi_3x" : "https:\/\/www.snappyshopper.co.uk\/uploads\/images\/stores\/xxhdpi_3x\/1599204265da11553998ee641a0a0b4bde58fb73ec.png"
      },
      "orderMethods" : {
        "collection" : {
          "name" : "collection",
          "status" : "closed",
          "cost" : 0
        },
        "delivery" : {
          "status" : "closed",
          "earliestTime" : null,
          "name" : "delivery",
          "cost" : 0,
          "workingHours" : {
            "close" : "19:00:00",
            "open" : "10:00:00"
          }
        }
      }
    },
    {
      "slug" : "premier-monifieth-1887",
      "distance" : 4.9000000000000004,
      "id" : 1887,
      "storeProductTypes" : [
        21
      ],
      "storeName" : "Premier Monifieth",
      "storeLogo" : {
        "mdpi_1x" : "https:\/\/www.snappyshopper.co.uk\/uploads\/images\/stores\/mdpi_1x\/1611740298da11553998ee641a0a0b4bde58fb73ec.png",
        "xhdpi_2x" : "https:\/\/www.snappyshopper.co.uk\/uploads\/images\/stores\/xhdpi_2x\/1611740298da11553998ee641a0a0b4bde58fb73ec.png",
        "xxhdpi_3x" : "https:\/\/www.snappyshopper.co.uk\/uploads\/images\/stores\/xxhdpi_3x\/1611740298da11553998ee641a0a0b4bde58fb73ec.png"
      },
      "orderMethods" : {
        "delivery" : {
          "status" : "closed",
          "earliestTime" : null,
          "name" : "delivery",
          "cost" : 0,
          "workingHours" : {
            "close" : "21:15:00",
            "open" : "07:00:00"
          }
        }
      }
    }
  ]
}
 */
