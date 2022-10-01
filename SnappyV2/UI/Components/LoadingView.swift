//
//  LoadingView.swift
//  SnappyV2
//
//  Created by David Bage on 15/03/2022.
//

import SwiftUI

/// Provides a virtually transparent screen which can be used whilst loading to prevent user interacting with UI elements
struct LoadingView: View {
    struct Constants {
        static let opacity: CGFloat = 0.00001
    }
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.white.opacity(Constants.opacity))
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
