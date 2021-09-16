//
//  NetworkingHelpers.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 16/09/2021.
//

import Foundation

func requestBodyFrom(parameters: [String: Any]?, forDebug debug: Bool = false) -> Data? {
    guard let params = parameters else { return nil }
    guard let httpBody = try? JSONSerialization.data(withJSONObject: params, options: debug ? [.prettyPrinted] : []) else {
        return nil
    }
    return httpBody
}
