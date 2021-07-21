//
//  ProductOptionsView.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 20/07/2021.
//

import SwiftUI

struct ProductOptionsView: View {
    @State var itemOptions: ItemOptions?
    
    var body: some View {
        VStack {
            ZStack {
                Image("pizza")
                    .resizable()
                    .scaledToFill()
                    .frame(height: UIScreen.main.bounds.height/5)
                    .clipShape(Rectangle())
                
                VStack {
                    Text("Fresh Pizzas")
                        .font(.snappyTitle)
                        .fontWeight(.bold)
                        .padding(.bottom)
                    Text("Choose your own pizza from as little as £5.00 and a drink")
                        .font(.snappyTitle2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                }
                .foregroundColor(.white)
                .padding(.vertical)
            }
            
            VStack {
                Button(action: { itemOptions = ItemOptions(title: "", subTitle: nil, itemOptions: nil)}) {
                    OptionsCardView(title: "Add Toppings", subtitle: "Choose up to 10")
                }
            }
            .padding()
            
            sectionHeading(title: "Your Base")
            sectionHeading(title: "Your Drink")
            sectionHeading(title: "Your Side")
            
            Spacer()
        }
        .bottomSheet(item: $itemOptions) { _ in
            ManyOptionsView()
        }
    }
    
    func sectionHeading(title: String) -> some View {
        HStack {
            Text("Choose")
            Text(title).bold()
            Spacer()
        }
        .font(.snappyBody)
        .foregroundColor(.snappyTextGrey2)
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.snappyTextGrey4)
    }
}

struct ItemOptions: Equatable, Identifiable {
    let id = UUID()
    let title: String
    let subTitle: String?
    let itemOptions: [ItemOption]?
}

struct ItemOption: Equatable, Identifiable {
    let id = UUID()
    let title: String
    let subTitle: String?
    let optionType: String? // enum for type of option, e.g. checkbox, radio, stepper etc.
}

struct ProductOptionsView_Previews: PreviewProvider {
    static var previews: some View {
        ProductOptionsView()
            .previewCases()
    }
}
