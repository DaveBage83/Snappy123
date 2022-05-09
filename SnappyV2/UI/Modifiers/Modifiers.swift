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
