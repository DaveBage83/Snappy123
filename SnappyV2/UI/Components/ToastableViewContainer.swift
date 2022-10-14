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
    let isModal: Bool
    
    init(container: DIContainer, isModal: Bool) {
        self.container = container
        self.isModal = isModal
    }
    
    private func clearErrorsAndToasts() {
        container.appState.value.errors = []
        container.appState.value.successToastStrings = []
    }
    
    func manageToastsOnDisappear() {
        let errors = container.appState.value.errors // keep local copy of errors
        let successes = container.appState.value.successToastStrings
        clearErrorsAndToasts()
        
        if isModal { // if modal, we need to repopulate the errors so that the parent view can react
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.000000001) {
                self.container.appState.value.errors = errors
                self.container.appState.value.successToastStrings = successes
            }
        }
        
        container.appState.value.viewIDs.removeAll(where: { $0 == id })
    }
    
    func manageToastsOnAppear() {
        clearErrorsAndToasts()
        if !container.appState.value.viewIDs.contains(where: {$0 == id}) {
            container.appState.value.viewIDs.append(id)
        }
    }
}

/// A wrapper which allows any injected content to display alert toasts, success toasts and loading toasts
/// when AppState values are changed
struct ToastableViewContainer<Content: View>: View {
    var content: () -> Content
    
    @StateObject var viewModel: ToastableViewModel
    
    var body: some View {
        VStack(content: content)
            .withAlertToast(container: viewModel.container, error: .constant(viewModel.container.appState.value.latestError), viewID: viewModel.id)
            .withSuccessToast(container: viewModel.container, viewID: viewModel.id, toastText: .constant(viewModel.container.appState.value.latestSuccessToast))
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
