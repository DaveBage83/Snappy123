//
//  TextFieldFloatingWithBorder.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 25/01/2022.
//

import SwiftUI

struct TextFieldFloatingWithBorder: View {
    let title: String
    @Binding var text: String
    @State var isFocused = false
    let background: Color

    init(_ title: String, text: Binding<String>, background: Color = .clear) {
        self.title = title
        self._text = text
        self.background = background
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .stroke(isFocused ? .blue : .gray, lineWidth: 1)

            Text(title)
                .foregroundColor(isFocused ? .accentColor : .gray)
                .padding(.horizontal, text.isEmpty ? 0 : 4)
                .background(text.isEmpty ? Color.clear : background)
                .padding(.leading, 16)
                .offset(y: text.isEmpty ? 0 : -30)
                .scaleEffect(text.isEmpty ? 1 : 0.75, anchor: .leading)
            
            TextField("", text: $text, onEditingChanged: { inFocus in
                self.isFocused = inFocus
            })
                .padding(.horizontal, 16)
        }
        .frame(height: 38)
        .background(background)
        .animation(.easeInOut(duration: 0.2))
        .padding(.top, 8)
    }
}

struct TextFieldFloatingWithBorder_Previews: PreviewProvider {
    static var previews: some View {
        TextFieldFloatingWithBorder("", text: .constant("Surname"), background: .white)
            .previewLayout(.sizeThatFits)
            .padding()
            .previewCases()
    }
}


