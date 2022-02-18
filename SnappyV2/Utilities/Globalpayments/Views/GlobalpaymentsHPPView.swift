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
    
    init(viewModel: GlobalpaymentsHPPViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
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
                    viewModel.loadHPP()
                }
            
        }
    }
    
}
