//
//  LoadingDotsView.swift
//  SnappyV2
//
//  Created by David Bage on 25/10/2022.
//

import SwiftUI

struct LoadingDotsView: View {
    
    @State private var shouldAnimate = false
    
    struct Constants {
        static let size: CGFloat = 20
        static let maxScale: CGFloat = 1.0
        static let minScale: CGFloat = 0.2
        static let animationDuration: CGFloat = 0.5
        static let firstCircleDelay: CGFloat = 0.3
        static let secondCircleDelay: CGFloat = 0.6
        static let thirdCircleDelay: CGFloat = 0.9
    }
    
    let color: Color
    
    init(color: Color = .white) {
        self.color = color
    }
    
    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: Constants.size, height: Constants.size)
                .scaleEffect(shouldAnimate ? Constants.maxScale : Constants.minScale)
                .animation(Animation.easeInOut(duration: Constants.animationDuration).repeatForever(), value: shouldAnimate)
            Circle()
                .fill(color)
                .frame(width: Constants.size, height: Constants.size)
                .scaleEffect(shouldAnimate ? Constants.maxScale : Constants.minScale)
                .animation(Animation.easeInOut(duration: Constants.animationDuration).repeatForever().delay(Constants.firstCircleDelay), value: shouldAnimate)
            Circle()
                .fill(color)
                .frame(width: Constants.size, height: Constants.size)
                .scaleEffect(shouldAnimate ? Constants.maxScale : Constants.minScale)
                .animation(Animation.easeInOut(duration: Constants.animationDuration).repeatForever().delay(Constants.secondCircleDelay), value: shouldAnimate)
            Circle()
                .fill(color)
                .frame(width: Constants.size, height: Constants.size)
                .scaleEffect(shouldAnimate ? Constants.maxScale : Constants.minScale)
                .animation(Animation.easeInOut(duration: Constants.animationDuration).repeatForever().delay(Constants.thirdCircleDelay), value: shouldAnimate)
        }
        .onAppear {
            self.shouldAnimate = true
        }
    }
}
