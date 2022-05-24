//
//  View+Extensions.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 11/01/2022.
//

import UIKit
import SwiftUI

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
    func simpleBackButton(presentation: Binding<PresentationMode> ) -> some View {
        self
            .navigationBarBackButtonHidden(true)
                .navigationBarItems(
                  leading: Button(action: { presentation.wrappedValue.dismiss() }) {
                      Image.Icons.Chevrons.Left.medium
                          .renderingMode(.template)
                          .resizable()
                          .aspectRatio(contentMode: .fit)
                          .frame(height: 20.21)
                      .foregroundColor(.white)})
    }
}
