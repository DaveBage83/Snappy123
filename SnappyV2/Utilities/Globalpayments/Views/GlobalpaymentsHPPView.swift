//
//  GlobalpaymentsHPPView.swift
//  SnappyV2
//
//  Created by Kevin Palser on 16/02/2022.
//

import SwiftUI

// Example usage of the view:
//
//    GlobalpaymentsHPPView(
//        viewModel: GlobalpaymentsHPPViewModel(
//            container: viewModel.container,
//            fulfilmentDetails: DraftOrderFulfilmentDetailsRequest(
//                time: DraftOrderFulfilmentDetailsTimeRequest(
//                    date: "2020-02-16",
//                    requestedTime: "14:30 - 14:45"
//                ),
//                place: nil
//            ),
//            instructions: "Knock quietly, baby sleeping.",
//            result: { businessOrderId, error in
//                print("\(businessOrderId) \(error)")
//            }
//        )
//    )

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
                            title: "Secure Payment",
                            navigationDismissType: .close,
                            backButtonAction: {
                                viewModel.cancelButtonTapped()
                            })
                }
                .background(colorPalette.secondaryWhite)
                .standardCardFormat()
                .padding()
            }
            .toast(isPresenting: $viewModel.isLoading) {
                AlertToast(displayMode: .alert, type: .loading)
            }
        }
    }
}
