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
                    
                    OptionsCardView(item: MenuItemOptionValue(id: 1, name: "Mushrooms", extraCost: nil, default: nil, sizeExtraCost: nil))
                    OptionsCardView(item: MenuItemOptionValue(id: 2, name: "Peppers", extraCost: nil, default: nil, sizeExtraCost: nil))
                    OptionsCardView(item: MenuItemOptionValue(id: 3, name: "Goats Cheese", extraCost: nil, default: nil, sizeExtraCost: nil))
                    OptionsCardView(item: MenuItemOptionValue(id: 4, name: "Red Onions", extraCost: nil, default: nil, sizeExtraCost: nil))
                    OptionsCardView(item: MenuItemOptionValue(id: 5, name: "Falafel", extraCost: nil, default: nil, sizeExtraCost: nil))
                    OptionsCardView(item: MenuItemOptionValue(id: 7, name: "Beef Strips", extraCost: nil, default: nil, sizeExtraCost: nil))
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


