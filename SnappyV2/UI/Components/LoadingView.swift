//
//  LoadingView.swift
//  SnappyV2
//
//  Created by David Bage on 15/03/2022.
//

import SwiftUI

struct LoadingView: View {
    struct Constants {
        static let opacity: CGFloat = 0.8
        static let scale: CGFloat = 1.5
    }
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.white.opacity(Constants.opacity))
            ProgressView()
                .scaleEffect(Constants.scale)
        }
    }
}

#if DEBUG
struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
#endif
