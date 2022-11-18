//
//  AnimatedLoadingView.swift
//  SnappyV2
//
//  Created by Peter Whittle on 09/11/2022.
//

import SwiftUI

struct AnimatedLoadingView: View {

    let message: String
    
    init(message: String) {
        self.message = message
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.snappyBlue)
            VStack {
                Spacer(minLength: 25)
                Text(message)
                    .font(Font.snappyTitle2)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                Spacer(minLength: 20)
                LoadingDotsView()
                Spacer(minLength: 25)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(50)
    }
    
}

struct AnimatedLoadingView_Previews: PreviewProvider {
    static var previews: some View {
        AnimatedLoadingView(message: Strings.AnimatedLoadingView.loggingIn.localized)
    }
}
