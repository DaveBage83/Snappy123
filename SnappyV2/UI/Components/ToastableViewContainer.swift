//
//  ToastableViewContainer.swift
//  SnappyV2
//
//  Created by David Bage on 11/10/2022.
//

import SwiftUI
import Combine

class ToastableViewModel: ObservableObject {
    let id = UUID() // The ID allows us to keep track of which view is being presented
    let container: DIContainer
    let isModal: Bool
    
    init(container: DIContainer, isModal: Bool) {
        self.container = container
        self.isModal = isModal
    }
    
    private func clearErrorsAndToasts() {
        container.appState.value.errors = []
        container.appState.value.successToasts = []
    }
    
    func manageToastsOnDisappear() {
        // If the user navigates away from a modal view whilst a toast is still being presented, the toast will be dismissed as well as it belongs to that modal view.
        // If this is the case, we therefore need to re-send any prematurely dismissed errors or successes
        // to the appState once dismissed in order to show them on the underlying view.
        // Therefore, before dismissing, we keep a local copy of the errors before clearing the AppState
        // values and then we re-apend these to either the 'errors' or 'successToasts' arrays in the AppState
        // to re-trigger the toast view.
        let errors = container.appState.value.errors // keep local copy of errors
        let successes = container.appState.value.successToasts
        clearErrorsAndToasts()
        
        if isModal { // if modal, we need to repopulate the errors so that the parent view can react
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.000000001) {
                self.container.appState.value.errors = errors
                self.container.appState.value.successToasts = successes
            }
        }
    }
    
    func manageToastsOnAppear() {
        // When the view appears we first need to clear errors and toasts from the appState
        clearErrorsAndToasts()
    }
}

/// A wrapper which allows any injected content to display alert toasts and success  toasts when AppState values are changed.
/// Usage:
/// 1- Pass content into this container e.g. ToastableViewContainer(content: <Content>, viewModel: <ToastableViewModel>)
/// 2- From the content's viewModel, append any errors or successes to either the 'errors' (type: Error)  or 'successToasts' (type: String)  arrays in the AppState
/// 3- Relevant toasts will be  presented on top of the content view when any change to these arrays in the AppState is detected
/// NB: For toasts which are required to be displayed on top of a sheet view, 'SnappySheet' is already wrapped in a ToastableViewContainer. However, 'SnappySheet' does not support Binding items (it can only be triggered using a Binding Boolean). If a binding item trigger is required
/// then use iOS system Sheet instead, but ensure to wrap the content in a ToastableViewContainer.
struct ToastableViewContainer<Content: View>: View {
    var content: () -> Content
    
    @StateObject var viewModel: ToastableViewModel
    
    var body: some View {
        VStack(content: content)
            .withAlertToast(container: viewModel.container, toastType: .error)
            .withAlertToast(container: viewModel.container, toastType: .success)
            .onDisappear {
                viewModel.manageToastsOnDisappear()
            }
            .onAppear {
                viewModel.manageToastsOnAppear()
            }
            .edgesIgnoringSafeArea(.bottom)
    }
}

#if DEBUG
struct ToastableViewContainer_Previews: PreviewProvider {
    static var previews: some View {
        ToastableViewContainer(content: {
            Text("This is a test")
        }, viewModel: .init(container: .preview, isModal: false))
    }
}
#endif
