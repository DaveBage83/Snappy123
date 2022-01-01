//
//  Member.swift
//  SnappyV2
//
//  Created by Kevin Palser on 29/12/2021.
//

import Foundation

struct MemberProfile: Codable, Equatable {
    let firstName: String
    let lastName: String
    let emailAddress: String
    let type: MemberType
}

enum MemberType: String, Codable, Equatable {
    case customer
    case driver
}
