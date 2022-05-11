//
//  ErrorAlertHandler.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 06/05/2022.
//

import Foundation
import SwiftUI

// Adapted from: https://www.swiftbysundell.com/articles/propagating-user-facing-errors-in-swift/
protocol ErrorHandler {
    func handle<T: View>(
        _ error: Error?,
        in view: T
    ) -> AnyView
}

struct AlertErrorHandler: ErrorHandler {
    // We give our handler an ID, so that SwiftUI will be able
    // to keep track of the alerts that it creates as it updates
    // our various views:
    private let id = UUID()

    func handle<T: View>(
        _ error: Error?,
        in view: T
    ) -> AnyView {
        var presentation = error.map { Presentation(
            id: id,
            error: $0
        )}

        // We need to convert our model to a Binding value in
        // order to be able to present an alert using it:
        let binding = Binding(
            get: { presentation },
            set: { presentation = $0 }
        )

        return AnyView(view.alert(item: binding, content: makeAlert))
    }
}

private extension AlertErrorHandler {
    struct Presentation: Identifiable {
        let id: UUID
        let error: Error
    }
    
    func makeAlert(for presentation: Presentation) -> Alert {
        let error = presentation.error
        
        if let error = error as? APIErrorResult {
            return Alert(
                title: Text(error.errorTitle ?? Strings.General.anErrorOccured.localized),
                message: Text(error.errorDisplay),
                dismissButton: .default(Text(Strings.General.ok.localized))
            )
        } else {
            return Alert(
                title: Text(Strings.General.anErrorOccured.localized),
                message: Text(error.localizedDescription),
                dismissButton: .default(Text(Strings.General.ok.localized))
            )
        }
    }
}

struct ErrorHandlerEnvironmentKey: EnvironmentKey {
    static var defaultValue: ErrorHandler = AlertErrorHandler()
}

extension EnvironmentValues {
    var errorHandler: ErrorHandler {
        get { self[ErrorHandlerEnvironmentKey.self] }
        set { self[ErrorHandlerEnvironmentKey.self] = newValue }
    }
}

extension View {
    func handlingErrors(
        using handler: ErrorHandler
    ) -> some View {
        environment(\.errorHandler, handler)
    }
}

struct ErrorDisplayingViewModifier: ViewModifier {
    @Environment(\.errorHandler) var handler

    var error: Error?

    func body(content: Content) -> some View {
        handler.handle(error,
            in: content
        )
    }
}

extension View {
    func displayError(
        _ error: Error?
    ) -> some View {
        modifier(ErrorDisplayingViewModifier(
            error: error
        ))
    }
}
