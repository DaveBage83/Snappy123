//
//  MissedPromotionsBanner.swift
//  SnappyV2
//
//  Created by David Bage on 17/01/2022.
//

import SwiftUI

struct BasketAndPastOrderItemBanner: View {
    @Environment(\.colorScheme) var colorScheme
    struct Constants {
        static let vPadding: CGFloat = 8
        static let hPadding: CGFloat = 8
        static let plusSize: CGFloat = 12
        static let cornerRadius: CGFloat = 8
        static let leadingIconHeight: CGFloat = 12
    }
    
    @StateObject var viewModel: BasketAndPastOrderItemBannerViewModel
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    var body: some View {
        HStack {
            HStack {
                if let leadingIcon = viewModel.banner.type.leadingIcon {
                    leadingIcon
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: Constants.leadingIconHeight)
                        .foregroundColor(.white)
                }
                
                Text(viewModel.banner.text)
                    .foregroundColor(viewModel.banner.type.textColor(colorPalette: colorPalette))
                    .font(.Body2.semiBold())
            }

            Spacer()
            
            if viewModel.showBannerActionButton, let icon = viewModel.banner.type.icon {
                icon
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(viewModel.banner.type.textColor(colorPalette: colorPalette))
                    .frame(width: Constants.plusSize)
            }
        }
        .padding(.vertical, Constants.vPadding)
        .padding(.horizontal, Constants.hPadding)
        .frame(maxWidth: .infinity)
        .background(viewModel.banner.type.bgColor(colorPalette: colorPalette))
        .cornerRadius(viewModel.curveBottomCorners ? Constants.cornerRadius : 0, corners: [.bottomLeft, .bottomRight])
        .onTapGesture {
            if let bannerTapAction = viewModel.tapAction {
                bannerTapAction()
            }
        }
    }
}

#if DEBUG
struct BasketAndPastOrderItemBanner_Previews: PreviewProvider {
    static var previews: some View {
        BasketAndPastOrderItemBanner(viewModel: .init(container: .preview, banner: .init(type: .substitutedItem, text: "Test", action: {}), isBottomBanner: true))
    }
}
#endif
