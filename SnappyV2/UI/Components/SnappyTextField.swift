//
//  SnappyTextField.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 23/09/2021.
//

import SwiftUI

struct SnappyTextField: View {
    let title: String
    @Binding var fieldString: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.snappyCaption)
                .foregroundColor(.snappyTextGrey2)
                .offset(x: 2, y: 10)
            
            TextField("", text: $fieldString)
                .font(.snappyBody)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}

struct SnappyTextField_Previews: PreviewProvider {
    static var previews: some View {
        SnappyTextField(title: "Title", fieldString: .constant("Entered text"))
            .previewLayout(.sizeThatFits)
            .padding()
            .previewCases()
    }
}
