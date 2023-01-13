//
//  GlobalpaymentsHPPView.swift
//  SnappyV2
//
//  Created by Kevin Palser on 16/02/2022.
//

import SwiftUI
struct GlobalpaymentsHPPView: View {
    
    @StateObject var viewModel: GlobalpaymentsHPPViewModel
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    var body: some View {
        
        NavigationView {
            VStack(spacing: 0) {
                Divider()
                VStack {
                    GlobalpaymentsWebView(viewModel: viewModel)
                        .onChange(of: viewModel.viewDismissed) { dismissed in
                            if dismissed {
                                self.presentationMode.wrappedValue.dismiss()
                            }
                        }
                        .onAppear {
                            // Because of the way this is reworked from a UIKit approach it needs
                            // know that the webkit is ready to start showing contents.
                            viewModel.loadHPP()
                        }
                        .dismissableNavBar(
                            presentation: nil,
                            color: colorPalette.primaryBlue,
                            title: Strings.CheckoutDetails.GlobalPayments.navTitle.localized,
                            navigationDismissType: .close,
                            backButtonAction: {
                                viewModel.cancelButtonTapped()
                            })
                }
                .background(colorPalette.secondaryWhite)
                .standardCardFormat()
                .padding()
            }
            .withLoadingToast(container: viewModel.container, loading: $viewModel.isLoading)
        }
    }
}
