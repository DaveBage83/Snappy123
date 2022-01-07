//
//  SearchBarView.swift
//  SnappyV2Study
//
//  Created by Henrik Gustavii on 02/07/2021.
//

import SwiftUI

struct SearchBarView: View {
    var label = GeneralStrings.Search.search.localized
    @Binding var text: String
    
    init(label: String = GeneralStrings.Search.search.localized, text: Binding<String>) {
        self.label = label
        self._text = text
    }
    
    @State private var isEditing = false
 
    var body: some View {
        HStack {
            TextField(label, text: $text)
                .padding(7)
                .padding(.horizontal, 25)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)
                 
                        if isEditing {
                            Button(action: {
                                self.text = ""
                            }) {
                                Image(systemName: "multiply.circle.fill")
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
        SearchBarView(text: .constant(""))
            .previewLayout(.sizeThatFits)
            .previewCases()
    }
}
