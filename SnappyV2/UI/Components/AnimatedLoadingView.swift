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
    
    init(message: String) {
        self.message = message
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: rectangleRadius)
                .fill(Color.snappyBlue)
            VStack {
                Spacer(minLength: topSpacerLength)
                Text(message)
                    .font(Font.snappyTitle2)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                Spacer(minLength: midSpacerLength)
                LoadingDotsView()
                Spacer(minLength: topSpacerLength)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(paddingAmount)
    }
    
}

#if DEBUG
struct AnimatedLoadingView_Previews: PreviewProvider {
    static var previews: some View {
        AnimatedLoadingView(message: Strings.AnimatedLoadingView.loggingIn.localized)
    }
}
#endif
