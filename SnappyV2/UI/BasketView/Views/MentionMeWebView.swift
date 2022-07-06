//
//  MentionMeWebView.swift
//  SnappyV2
//
//  Created by Kevin Palser on 19/06/2022.
//

import SwiftUI

import SwiftUI
import MapKit

struct MentionMeWebView: View {
    
    // MARK: - States
    @State private var showLoading: Bool = false
    
    // MARK: - Environment objects
    @Environment(\.colorScheme) var colorScheme
    
    // MARK: - View model
    @StateObject var viewModel: MentionMeWebViewModel
    
    // MARK: - Computed variables
    private var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    var body: some View {
        MentionMeRepresentableWebView(
            viewModel: MentionMeRepresentableWebViewModel(
                container: viewModel.container,
                mentionMeResult: viewModel.mentionMeRequestResult,
                dismissWebViewHandler: { couponAction in
                    viewModel.dismissWebViewHandler(couponAction: couponAction)
                }),
            showLoading: $showLoading
        )
            .overlay(showLoading ? ProgressView(Strings.MentionMe.Webview.loading.localized).toAnyView() : EmptyView().toAnyView())
            //.dismissableNavBar(presentation: presentation, color: colorPalette.primaryBlue, title: Strings.DriverMap.title.localized, navigationDismissType: dismissType)
    }
}

#if DEBUG
struct MentionMeWebView_Previews: PreviewProvider {
    static var previews: some View {
        MentionMeWebView(
            viewModel: MentionMeWebViewModel(
                container: .preview,
                mentionMeRequestResult: MentionMeRequestResult(
                    success: true,
                    type: .referee,
                    webViewURL: URL(string: "https://demo.mention-me.com/my/dashboard/mmce556aa2/er/kevin.palser@gmail.com/761f52450f2da50c2c23644a9901df84a3200fbd68f179a1a2acae36fdb4948d?locale=en_GB&firstname=Kevin&surname=Palser"),
                    buttonText: "Been referred by a friend?",
                    postMessageConstants: MentionMePostMessageConstants(
                        actionFieldName: "action",
                        closeActions: [
                            "mm:referee:close",
                            "mm:referrer:close",
                            "mm:referrer-share:close"
                        ],
                        clickTypeFieldName: "clickType",
                        clickTypeCloseValues: ["redirect"],
                        refereeFulfilledAction: "mm:referee:fulfilled",
                        couponFieldName: "coupon",
                        couponCodeFieldName: "couponCode"
                    ),
                    applyCoupon: true,
                    openInBrowser: false
                ),
                dismissWebViewHandler: { couponAction in
                }
            )
        )
    }
}
#endif
