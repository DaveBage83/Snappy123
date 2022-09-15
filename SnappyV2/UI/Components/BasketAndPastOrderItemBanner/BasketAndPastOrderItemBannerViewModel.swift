//
//  BasketAndPastOrderItemBannerViewModel.swift
//  SnappyV2
//
//  Created by David Bage on 12/09/2022.
//

import Foundation

class BasketAndPastOrderItemBannerViewModel: ObservableObject {
    let container: DIContainer
    let banner: BannerDetails
    let isBottomBanner: Bool

    var showBannerActionButton: Bool {
        banner.action != nil
    }

    // We only need to curve the bottom trailing/leading corners of the banner when it is the bottom banner
    var curveBottomCorners: Bool {
        isBottomBanner
    }
    
    var text: String {
        banner.text
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
