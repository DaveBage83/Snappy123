//
//  ButtonStyles.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 21/07/2021.
//

import SwiftUI

struct SnappyPrimaryButtonStyle: ButtonStyle {
    var isEnabled = true
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.snappyFootnote.bold())
            .foregroundColor(.white)
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isEnabled ? Color.snappyBlue : Color.gray)
            )
    }
}

struct SnappySecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.snappyFootnote)
            .foregroundColor(.black)
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(Color.black, lineWidth: 1)
            )
    }
}

struct SnappyMainActionButtonStyle: ButtonStyle {
    let isEnabled: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.snappyTitle)
            .foregroundColor(.white)
            .padding(10)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isEnabled ? Color.snappyDark : Color.gray)
                    .padding(.horizontal)
            )
    }
}
