//
//  SearchBarView.swift
//  SnappyV2Study
//
//  Created by Henrik Gustavii on 02/07/2021.
//

import SwiftUI

struct SearchBarView: View {
    var label: String
    @Binding var text: String
    @Binding var isEditing: Bool
    
    init(label: String = GeneralStrings.Search.search.localized, text: Binding<String>, isEditing: Binding<Bool>) {
        self.label = label
        self._text = text
        self._isEditing = isEditing
    }
 
    var body: some View {
        HStack {
            TextField(label, text: $text)
                .padding(7)
                .padding(.horizontal, 25)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    HStack {
                        Image.Actions.Search.standard
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)
                 
                        if isEditing {
                            Button(action: {
                                self.text = ""
                            }) {
                                Image.Actions.Close.multiply
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 8)
                            }
                        }
                    }
                )
                .padding(.horizontal, 10)
                .onTapGesture {
                    self.isEditing = true
                }
 
            if isEditing {
                Button(action: {
                    self.isEditing = false
                    self.text = ""
                    hideKeyboard()
                }) {
                    Text(GeneralStrings.cancel.localized)
                }
                .padding(.trailing, 10)
                .transition(.move(edge: .trailing))
                .animation(.default)
            }
        }
    }
}

struct SearchBarView_Previews: PreviewProvider {
    static var previews: some View {
        SearchBarView(text: .constant(""), isEditing: .constant(false))
            .previewLayout(.sizeThatFits)
            .previewCases()
    }
}
