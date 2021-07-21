//
//  ManyOptionsView.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 21/07/2021.
//

import SwiftUI

struct ManyOptionsView: View {
    var body: some View {
        VStack {
            ScrollView(.vertical) {
                VStack {
                    VStack {
                        Text("Choose 2 Toppings")
                            .font(.snappyHeadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.snappyDark)
                        Text("Select 2 minimum")
                            .font(.snappySubheadline)
                            .foregroundColor(.snappyRed)
                    }
                    .padding()
                    
                    OptionsCardView(title: "Mushrooms", subtitle: "Finest fungi")
                    OptionsCardView(title: "Peppers", subtitle: "Colourful")
                    OptionsCardView(title: "Goats Cheese", subtitle: "Acquired taste")
                    OptionsCardView(title: "Red Onions", subtitle: "Tastier")
                    OptionsCardView(title: "Falafel", subtitle: "Taʿmiya")
                    OptionsCardView(title: "Beef Strips", subtitle: "Strips of... beef")
                }
                .padding()
            }
            .frame(maxHeight: .infinity)
            .overlay(
                VStack {
                    Spacer()
                    
                    Button(action: {} ) {
                        Text("Done")
                            .fontWeight(.semibold)
                    }
                    .buttonStyle(SnappyMainActionButtonStyle(isEnabled: true))
                }
                .padding(.bottom, UIScreen.main.bounds.height/20)
            )
        }
    }
}

struct ManyOptionsView_Previews: PreviewProvider {
    static var previews: some View {
        ManyOptionsView()
            .previewLayout(.sizeThatFits)
            .padding()
            .previewCases()
    }
}


