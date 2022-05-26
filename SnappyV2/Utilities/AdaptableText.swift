//
//  AdaptableText.swift
//  SnappyV2
//
//  Created by David Bage on 26/05/2022.
//

// View which allows for altText to passed in and displayed when pre-defined size
// threshold is met for accessibility purposes

import SwiftUI

struct AdaptableText: View {
    @Environment(\.sizeCategory) var sizeCategory: ContentSizeCategory
    
    struct Constants {
        static let defaultSizeThreshold = 7
    }
    
    let text: String
    let altText: String
    let threshold: Int?
    
    var body: some View {
        Text(sizeCategory.size > (threshold ?? Constants.defaultSizeThreshold) ? altText : text)
    }
}
