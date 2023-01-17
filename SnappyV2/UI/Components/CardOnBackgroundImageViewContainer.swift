//
//  CardOnBackgroundImageViewContainer.swift
//  SnappyV2
//
//  Created by David Bage on 28/09/2022.
//

import SwiftUI

struct CardOnBackgroundImageViewContainer<Content: View>: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.mainWindowSize) var mainWindowSize
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    let container: DIContainer
    let image: Image
            
    private let frameLargeDeviceWidth: CGFloat = UIScreen.screenWidth * 0.7
    private let internalPaddingStandard: CGFloat = 16
    private let internalPaddingLargeDevice: CGFloat = 32
    private let paddingMultiplier: CGFloat = 0.13
    
    private var colorPalette: ColorPalette {
        .init(container: container, colorScheme: colorScheme)
    }
    
    /// Main content, to be presented in card format on top of background image
    var content: () -> Content
    
    var body: some View {
        ZStack(alignment: .top) {
            backgroundImage
            
            ScrollView(showsIndicators: false) {
                cardContent
                    .padding(.top, mainWindowSize.height * paddingMultiplier)
            }
            .clipped()
        }
    }
    
    private var backgroundImage: some View {
        VStack {
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity)
            
            Spacer()
        }
    }
    
    private var cardContent: some View {
        VStack(content: content)
            .frame(maxWidth: sizeClass == .compact ? .infinity : frameLargeDeviceWidth)
            .padding(sizeClass == .compact ? internalPaddingStandard: internalPaddingLargeDevice)
            .background(colorPalette.secondaryWhite)
            .standardCardFormat(container: container)
            .padding(.horizontal)
    }
}

#if DEBUG
struct CardOnBackgroundImageViewContainer_Previews: PreviewProvider {
    static var previews: some View {
        CardOnBackgroundImageViewContainer(container: .preview, image: Image.Branding.StockPhotos.deliveryMan) {
            Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin rutrum bibendum ex ac cursus. Donec lobortis urna massa, in interdum tortor porttitor at. Fusce fermentum sapien vel nisl consectetur tempus. Praesent vitae nunc vel erat venenatis rutrum. Donec aliquam ultrices massa. Nullam suscipit imperdiet bibendum. Sed dictum ipsum urna, eu ullamcorper nibh faucibus in. Nulla in sapien eleifend, eleifend diam ac, sollicitudin nulla. Donec ultricies est sit amet ullamcorper porttitor. Donec lacinia facilisis massa eu rutrum. Aenean in pellentesque enim. Nam iaculis lobortis velit vel accumsan. In hac habitasse platea dictumst. Pellentesque tempus at sem ac vehicula. Sed ultrices dolor nec malesuada commodo. Etiam eu justo at erat suscipit tempor et a augue. Cras ac nunc in felis dapibus laoreet ac eget magna. Sed dictum orci quis lobortis lacinia. In rhoncus sem sit amet nisi maximus, eu consectetur mauris vulputate. Phasellus eget egestas arcu, non.")
        }
    }
}
#endif
