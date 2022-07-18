//
//  Utility.swift
//  SnappyV2
//
//  Created by Kevin Palser on 16/06/2022.
//

import Foundation

struct TrueTime: Codable, Equatable {
    let timeUTC: String
}

struct ShimmedMentionMeCallHomeResponse: Codable, Equatable {
    let status: Bool
    let message: String? // only returned when there is an error
    let requestUrl: String?
    let request: [String: Any]?
    let openInBrowser: Bool?
    let applyCoupon: Bool?
    let postMessageEvent: [String: Any]?

    enum CodingKeys: String, CodingKey {
        case status
        case message
        case requestUrl
        case request
        case openInBrowser
        case applyCoupon
        case postMessageEvent
    }
    
    init(
        status: Bool,
        message: String?,
        requestUrl: String?,
        request: [String: Any]?,
        openInBrowser: Bool?,
        applyCoupon: Bool?,
        postMessageEvent: [String: Any]?
    ) {
        self.status = status
        self.message = message
        self.requestUrl = requestUrl
        self.request = request
        self.openInBrowser = openInBrowser
        self.applyCoupon = applyCoupon
        self.postMessageEvent = postMessageEvent
    }
    
    init (from decoder: Decoder) throws {
        let container =  try decoder.container(keyedBy: CodingKeys.self)
        status = try container.decode(Bool.self, forKey: .status)
        message = try container.decodeIfPresent(String.self, forKey: .message)
        requestUrl = try container.decodeIfPresent(String.self, forKey: .requestUrl)
        request = try container.decodeIfPresent([String: Any].self, forKey: .request)
        openInBrowser = try container.decodeIfPresent(Bool.self, forKey: .openInBrowser)
        applyCoupon = try container.decodeIfPresent(Bool.self, forKey: .applyCoupon)
        postMessageEvent = try container.decodeIfPresent([String: Any].self, forKey: .postMessageEvent)
    }
    
    func encode (to encoder: Encoder) throws {
        var container = encoder.container (keyedBy: CodingKeys.self)
        try container.encode(status, forKey: .status)
        try container.encodeIfPresent(message, forKey: .message)
        try container.encodeIfPresent(requestUrl, forKey: .requestUrl)
        try container.encodeIfPresent(request, forKey: .request)
        try container.encodeIfPresent(openInBrowser, forKey: .openInBrowser)
        try container.encodeIfPresent(postMessageEvent, forKey: .postMessageEvent)
    }
    
    static fileprivate func compareOptionalArray(dict1: [String: Any]?, dict2: [String: Any]?) -> Bool {
        if let dict1 = dict1 {
            if let dict2 = dict2 {
                return dict1.isEqual(to: dict2)
            }
            // dict1 is not nil but dict2 is nil
            return false
        }
        // check both dict2 is also nil
        return dict2 == nil
    }
    
    static func == (lhs: ShimmedMentionMeCallHomeResponse, rhs: ShimmedMentionMeCallHomeResponse) -> Bool {
        return lhs.status == rhs.status && lhs.message == rhs.message && lhs.requestUrl == rhs.requestUrl && ShimmedMentionMeCallHomeResponse.compareOptionalArray(dict1: lhs.request, dict2: rhs.request) && ShimmedMentionMeCallHomeResponse.compareOptionalArray(dict1: lhs.postMessageEvent, dict2: rhs.postMessageEvent)
    }
}
