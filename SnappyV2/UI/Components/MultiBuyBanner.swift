//
//  MultiBuyBanner.swift
//  SnappyV2
//
//  Created by David Bage on 12/01/2022.
//

import SwiftUI

struct MultiBuyBanner: View {
    struct Constants {
        static let height: CGFloat = 40
    }
    
    let offerText: String
    
    var body: some View {
        Text(offerText)
            .font(.snappyHeadline)
            .frame(maxWidth: .infinity)
            .frame(height: Constants.height)
            .background(Color.yellow)
    }
}

struct MultiBuyBanner_Previews: PreviewProvider {
    static var previews: some View {
        MultiBuyBanner(offerText: "3 for £7.00")
    }
}
