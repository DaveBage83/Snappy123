//
//  RemoteImageView.swift
//  SnappyV2
//
//  Created by David Bage on 28/01/2022.
//

import SwiftUI
import Combine

struct RemoteImageView: View {
    
    private let imageURL: URL
    private let container: DIContainer
    @State private var image: Loadable<UIImage>
    private let inspection = Inspection<Self>()
    
    init(imageURL: URL, image: Loadable<UIImage> = .notRequested, container: DIContainer) {
        self.imageURL = imageURL
        self.container = container
        self._image = .init(initialValue: image)
    }
    
    var body: some View {
        content
            .onReceive(inspection.notice) { self.inspection.visit(self, $0) }
    }
    
    private var content: AnyView {
        switch image {
        case .notRequested: return AnyView(notRequestedView)
        case .isLoading: return AnyView(loadingView)
        case let .loaded(image): return AnyView(loadedView(image))
        case let .failed(error): return AnyView(failedView(error))
        }
    }
}

extension RemoteImageView {
    func loadImage() {
        container.services.imageService
            .load(image: $image, url: imageURL)
    }
}

// MARK: - Content

extension RemoteImageView {
    private var notRequestedView: some View {
        Text("").onAppear {
            self.loadImage()
        }
    }
    
    private var loadingView: some View {
        ZStack {
            Image.RemoteImage.placeholder
                .resizable()
                .aspectRatio(contentMode: .fit)
            ProgressView()
        }
            
    }
    
    private func failedView(_ error: Error) -> some View {
        Image.RemoteImage.placeholder
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
    
    private func loadedView(_ image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}

#if DEBUG
struct RemoteImageView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            RemoteImageView(imageURL: URL(string: "www.snappyshopper.co.uk/uploads/images/stores/xhdpi_2x/1589564824552274_13470292_2505971_9c972622_image.png")!, container: DIContainer.defaultValue)
            RemoteImageView(imageURL: URL(string: "www.snappyshopper.co.uk/uploads/images/stores/xhdpi_2x/1589564824552274_13470292_2505971_9c972622_image.png")!, container: DIContainer.defaultValue)
            RemoteImageView(imageURL: URL(string: "www.snappyshopper.co.uk/uploads/images/stores/xhdpi_2x/1589564824552274_13470292_2505971_9c972622_image.png")!, container: DIContainer.defaultValue)
        }
    }
}
#endif
