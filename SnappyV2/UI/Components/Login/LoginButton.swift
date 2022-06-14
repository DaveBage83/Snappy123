//
//  LoginButton.swift
//  SnappyV2
//
//  Created by David Bage on 11/03/2022.
//

import SwiftUI

struct LoginButton: View {
    struct Constants {
        static let size: CGFloat = 13
        static let height: CGFloat = 30
    }
    
    let action: () -> Void
    let text: String
    let icon: Image?
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack {
                Spacer()
                HStack {
                    icon?.resizable().frame(width: Constants.size, height: Constants.size)
                    Text(text)
                        .font(.snappyBody2)
                        .fontWeight(.medium)
                        .frame(height: Constants.height)
                }
                Spacer()
            }
        }
    }
}

#if DEBUG
struct LoginButton_Previews: PreviewProvider {
    static var previews: some View {
        LoginButton(action: {
            print("Pressed")
        }, text: "Test", icon: nil)
    }
}
#endif
