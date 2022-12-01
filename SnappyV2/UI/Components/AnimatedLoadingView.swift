//
//  AnimatedLoadingView.swift
//  SnappyV2
//
//  Created by Peter Whittle on 09/11/2022.
//

import SwiftUI

struct AnimatedLoadingView: View {

    let message: String
    
    let rectangleRadius: CGFloat = 5
    let topSpacerLength: CGFloat = 25
    let midSpacerLength: CGFloat = 20
    let paddingAmount: CGFloat = 50
    
    // MARK: - Constants
    struct Constants {
        struct Rectangle {
            static let radius: CGFloat = 5
        }
        
        struct Spacing {
            static let topSpacerLength: CGFloat = 25
            static let midSpacerLength: CGFloat = 20
            static let paddingAmount: CGFloat = 50
        }
    }
    
    init(message: String) {
        self.message = message
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Constants.Rectangle.radius)
                .fill(Color.snappyBlue)
            VStack {
                Spacer(minLength: Constants.Spacing.topSpacerLength)
                Text(message)
                    .font(Font.snappyTitle2)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                Spacer(minLength: Constants.Spacing.midSpacerLength)
                LoadingDotsView()
                Spacer(minLength: Constants.Spacing.topSpacerLength)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(Constants.Spacing.paddingAmount)
    }
    
}

#if DEBUG
struct AnimatedLoadingView_Previews: PreviewProvider {
    static var previews: some View {
        AnimatedLoadingView(message: Strings.AnimatedLoadingView.loggingIn.localized)
    }
}
#endif
