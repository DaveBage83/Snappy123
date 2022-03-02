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
    
    var body: some View {
        HStack {
            Spacer()
            Button(action: {
                viewModel.cancelButtonTapped()
            }) {
                Text(GeneralStrings.cancel.localized)
                    .font(.snappyBody)
                    .bold()
                    .disabled(viewModel.isLoading)
            }
        }
        GlobalpaymentsLoadingView(isShowing: $viewModel.isLoading) {
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
            
        }
    }
    
}
