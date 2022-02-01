//
//  TextFieldFloatingWithBorder.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 25/01/2022.
//

import SwiftUI

struct TextFieldFloatingWithBorder: View {
    
    struct Constants {
        static let lineWidth: CGFloat = 1
        static let cornerRadius: CGFloat = 4
        static let frameHeight: CGFloat = 38
        
        struct Padding {
            static let horizontalIsEmpty: CGFloat = 0
            static let horizontalIsNotEmpty: CGFloat = 4
            static let horizontal: CGFloat = 16
            static let leading: CGFloat = 16
            static let top: CGFloat = 8
        }
        
        struct Offset {
            static let isEmpty: CGFloat = 0
            static let isNotEmptyRatio: Double = 1.25
        }
        
        struct ScaleEffect {
            static let isEmpty: CGFloat = 1
            static let isNotEmpty: CGFloat = 0.75
        }
        
        struct Animation {
            static let easeInOut: Double = 0.2
        }
    }
    
    let title: String
    @Binding var text: String
    @Binding var hasWarning: Bool
    @State var isFocused = false
    let background: Color
    let frameHeight: CGFloat

    init(_ title: String, text: Binding<String>, hasWarning: Binding<Bool> = .constant(false), background: Color = .clear, height: CGFloat = Constants.frameHeight) {
        self.title = title
        self._text = text
        self.background = background
        self._hasWarning = hasWarning
        self.frameHeight = height
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: Constants.cornerRadius, style: .continuous)
                .stroke(isFocused ? Color.snappyBlue : hasWarning ? .snappyRed : .gray, lineWidth: Constants.lineWidth)

            Text(title)
                .font(.snappyBody)
                .foregroundColor(isFocused ? Color.snappyBlue : hasWarning ? .snappyRed : .gray)
                .padding(.horizontal, text.isEmpty ? Constants.Padding.horizontalIsEmpty : Constants.Padding.horizontalIsNotEmpty)
                .background(text.isEmpty ? Color.clear : background)
                .padding(.leading, Constants.Padding.leading)
                .offset(y: text.isEmpty ? Constants.Offset.isEmpty : -(frameHeight / Constants.Offset.isNotEmptyRatio))
                .scaleEffect(text.isEmpty ? Constants.ScaleEffect.isEmpty : Constants.ScaleEffect.isNotEmpty, anchor: .leading)
            
            TextField("", text: $text, onEditingChanged: { inFocus in
                self.isFocused = inFocus
            })
                .font(.snappyBody)
                .padding(.horizontal, Constants.Padding.horizontal)
        }
        .frame(height: frameHeight)
        .background(background)
        .animation(.easeInOut(duration: Constants.Animation.easeInOut))
        .padding(.top, Constants.Padding.top)
    }
}

struct TextFieldFloatingWithBorder_Previews: PreviewProvider {
    static var previews: some View {
        TextFieldFloatingWithBorder("", text: .constant("Surname"), hasWarning: .constant(true), background: .white)
            .previewLayout(.sizeThatFits)
            .padding()
            .previewCases()
    }
}


