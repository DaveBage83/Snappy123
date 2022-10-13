//
//  ToastableViewContainer.swift
//  SnappyV2
//
//  Created by David Bage on 11/10/2022.
//

import SwiftUI
import Combine

class ToastableViewModel: ObservableObject {
    let id = UUID()
    let container: DIContainer

    init(container: DIContainer) {
        self.container = container
    }
}

/// A wrapper which allows any injected content to display alert toasts, success toasts and loading toasts
/// when AppState values are changed
struct ToastableViewContainer<Content: View>: View {
    var content: () -> Content
    let isModal: Bool
    
    @StateObject var viewModel: ToastableViewModel
    
    var body: some View {
        VStack(content: content)
            .withAlertToast(container: viewModel.container, error: .constant(viewModel.container.appState.value.latestError), viewID: viewModel.id)
            .withSuccessToast(container: viewModel.container, viewID: viewModel.id, toastText: .constant(viewModel.container.appState.value.latestSuccessToast))
            .onDisappear {
                // Clear errors when navigating to ...
                let errors = viewModel.container.appState.value.errors // keep local copy of errors
                let successes = viewModel.container.appState.value.successToastStrings
                viewModel.container.appState.value.errors = []
                viewModel.container.appState.value.successToastStrings = []
                
                if isModal { // if modal, we need to repopulate the errors so that the parent view can react
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.000000001) {
                        viewModel.container.appState.value.errors = errors
                        viewModel.container.appState.value.successToastStrings = successes
                    }
                }
                viewModel.container.appState.value.loading =  false
            }
            .onAppear {
                // ... or from a view
                viewModel.container.appState.value.errors = []
                viewModel.container.appState.value.loading =  false
            }
            .edgesIgnoringSafeArea(.all)
    }
}

struct ToastableViewContainer_Previews: PreviewProvider {
    static var previews: some View {
        ToastableViewContainer(content: {
            Text("This is a test")
        }, isModal: false, viewModel: .init(container: .preview))
    }
}
