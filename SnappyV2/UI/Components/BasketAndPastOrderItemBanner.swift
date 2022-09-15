//
//  MissedPromotionsBanner.swift
//  SnappyV2
//
//  Created by David Bage on 17/01/2022.
//

import SwiftUI

class BasketAndPastOrderItemBannerViewModel: ObservableObject {
    let container: DIContainer
    let banner: BannerDetails
    let isBottomBanner: Bool

    var showBannerActionButton: Bool {
        banner.action != nil
    }
    
    var bannerButtonIcon: Image? {
        banner.type.icon
    }
    
    var curveBottomCorners: Bool {
        isBottomBanner
    }
    
    var text: String {
        banner.text
    }

    func bgColor(_ colorPalette: ColorPalette) -> Color {
        banner.type.bgColor(colorPalette: colorPalette)
    }
    
    func textColor(_ colorPalette: ColorPalette) -> Color {
        banner.type.textColor(colorPalette: colorPalette)
    }
    
    var tapAction: (() -> Void)? {
        banner.action
    }
    
    init(container: DIContainer, banner: BannerDetails, isBottomBanner: Bool, bannerTapAction: (() -> Void)? = nil) {
        self.container = container
        self.banner = banner
        self.isBottomBanner = isBottomBanner
    }
}

struct BasketAndPastOrderItemBanner: View {
    @Environment(\.colorScheme) var colorScheme
    struct Constants {
        static let vPadding: CGFloat = 8
        static let hPadding: CGFloat = 8
        static let plusSize: CGFloat = 12
        static let cornerRadius: CGFloat = 8
    }

    @StateObject var viewModel: BasketAndPastOrderItemBannerViewModel
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    var body: some View {
        HStack {
            Text(viewModel.banner.text)
                .foregroundColor(viewModel.banner.type.textColor(colorPalette: colorPalette))
                .font(.Body2.semiBold())
            
            Spacer()
            
            if viewModel.showBannerActionButton, let icon = viewModel.bannerButtonIcon {
                icon
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(viewModel.textColor(colorPalette))
                    .frame(width: Constants.plusSize)
            }
        }
        .padding(.vertical, Constants.vPadding)
        .padding(.horizontal, Constants.hPadding)
        .frame(maxWidth: .infinity)
        .background(viewModel.bgColor(colorPalette))
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
