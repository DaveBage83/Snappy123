//
//  AdaptableText.swift
//  SnappyV2
//
//  Created by David Bage on 26/05/2022.
//

// View which allows for altText to passed in and displayed when pre-defined size
// threshold is met for accessibility purposes

import SwiftUI

/// A text view which accepts a title and a short title. The short title is used when the user changes the font size and the ContentSizeCategory exceeds the threshold. Threshold is set to 7 by default but can be amended through the init of this view.
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
