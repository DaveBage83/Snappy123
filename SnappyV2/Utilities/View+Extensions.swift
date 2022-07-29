//
//  View+Extensions.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 11/01/2022.
//

import UIKit
import SwiftUI

enum NavigationDismissType {
    case back
    case cancel
    case close
    case done
}

// From: https://www.hackingwithswift.com/quick-start/swiftui/how-to-dismiss-the-keyboard-for-a-textfield
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// Helper extension to make toolbar clear
extension View {
    
    /// Sets background color and title color for UINavigationBar.
    func navigationBar(backgroundColor: Color, titleColor: Color) -> some View {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor(backgroundColor)

        let uiTitleColor = UIColor(titleColor)
        appearance.largeTitleTextAttributes = [.foregroundColor: uiTitleColor]
        appearance.titleTextAttributes = [.foregroundColor: uiTitleColor]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        return self
    }
}

extension View {
    @ViewBuilder func dismissableNavBar(presentation: Binding<PresentationMode>?, color: Color, title: String? = nil, navigationDismissType: NavigationDismissType = .back, backButtonAction: (() -> Void)? = nil) -> some View {
        
        self
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(
                leading: Button(action: {
                    if let backButtonAction = backButtonAction {
                        backButtonAction()
                    } else {
                        presentation?.wrappedValue.dismiss()
                    }
                }) {
                    switch navigationDismissType {
                    case .back:
                        Image.Icons.Chevrons.Left.medium
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 20.21)
                            .foregroundColor(color)
                    case .cancel:
                        Text(GeneralStrings.cancel.localized)
                            .font(.Body1.regular())
                    case .close:
                        EmptyView()
                    case .done:
                        EmptyView()
                    }
                },
                trailing: Button(action: {
                    if let backButtonAction = backButtonAction {
                        backButtonAction()
                    } else {
                        presentation?.wrappedValue.dismiss()
                    }
                }) {
                    switch navigationDismissType {
                    case .back, .cancel:
                        EmptyView()
                    case .close:
                        Image.Icons.Xmark.standard
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 12)
                            .foregroundColor(color)
                    case .done:
                        Text(GeneralStrings.done.localized)
                            .font(.Body1.semiBold())
                    }
                })
            .navigationTitle(title ?? "")
            .font(.heading4())
            .navigationBarTitleDisplayMode(.inline)
    }
}

extension View {
    func toAnyView() -> AnyView {
        AnyView(self)
    }
}
