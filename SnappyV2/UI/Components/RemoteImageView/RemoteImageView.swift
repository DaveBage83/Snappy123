//
//  RemoteImageView.swift
//  SnappyV2
//
//  Created by David Bage on 28/01/2022.
//

import SwiftUI
import Combine

struct RemoteImageView: View {
    
    @StateObject var viewModel: RemoteImageViewModel
    
    var body: some View {
        ZStack {
            viewModel.image
                .resizable()
                .aspectRatio(contentMode: .fit)
            
            if viewModel.imageIsLoading {
                ProgressView()
            }
        }
    }
}

struct RemoteImageView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            RemoteImageView(viewModel: .init(container: .preview, imageURL: URL(string: "www.snappyshopper.co.uk/uploads/images/stores/xhdpi_2x/1589564824552274_13470292_2505971_9c972622_image.png")!))
        }
    }
}
