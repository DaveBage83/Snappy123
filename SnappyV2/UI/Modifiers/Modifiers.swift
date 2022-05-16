//
//  Modifiers.swift
//  SnappyV2
//
//  Created by David Bage on 07/05/2022.
//

import SwiftUI

struct LoadingModifier: ViewModifier {
    @Binding var isLoading: Bool
    let color: Color
    
    func body(content: Content) -> some View {
        
        content
            .overlay(Group { // We need to wrap in a group as <iOS15 has no way of directly including conditions in overlays
                if isLoading {
                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: color))
                }
            }, alignment: .center)
    }
}

struct CardShadowModifier: ViewModifier {

    func body(content: Content) -> some View {
        content
            .shadow(color: .cardShadow, radius: 9, x: 0, y: 0)
    }
}

struct StandardCardCornerRadius: ViewModifier {

    func body(content: Content) -> some View {
        content
            .cornerRadius(8)
    }
}

extension View {
    func withLoadingView(isLoading: Binding<Bool>, color: Color) -> some View {
        modifier(LoadingModifier(isLoading: isLoading, color: color))
    }
}

extension View {
    func cardShadow() -> some View {
        modifier(CardShadowModifier())
    }
}

extension View {
    func standardCardCornerRadius() -> some View {
        modifier(StandardCardCornerRadius())
    }
}
