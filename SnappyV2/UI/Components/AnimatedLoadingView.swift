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
            Color.gray
                .opacity(0.5)
                .blur(radius: 8, opaque: false)
            VStack {
                Text(message)
                LoadingDotsView()
            }
        }
    }
    
}

struct AnimatedLoadingView_Previews: PreviewProvider {
    static var previews: some View {
        AnimatedLoadingView(message: "Logging In...")
    }
}
