//
//  ProductOptionsView.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 20/07/2021.
//

import SwiftUI

class ProductOptionsViewModel: ObservableObject {
    @Published var itemOptions: MenuItemOption?
    @Published var item: MenuItem
    
    init(item: MenuItem) {
        self.item = item
    }
}

struct ProductOptionsView: View {
    @StateObject var viewModel: ProductOptionsViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ZStack {
                    Image("pizza")
                        .resizable()
                        .scaledToFill()
                        .frame(height: UIScreen.main.bounds.height/5)
                        .clipShape(Rectangle())
                        .brightness(-0.5)
                    
                    VStack {
                        Text(viewModel.item.name)
                            .font(.snappyTitle)
                            .fontWeight(.bold)
                            .padding(.bottom)
                        
                        if let subtitle = viewModel.item.description {
                            Text(subtitle)
                                .font(.snappyTitle2)
                                .fontWeight(.semibold)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .foregroundColor(.white)
                    .padding(.vertical)
                }
                
                ForEach(viewModel.item.options, id: \.id) { option in
                    section(title: option.name, item: viewModel.item)
                }
                
                Spacer()
            }
            .bottomSheet(item: $viewModel.itemOptions) { _ in
                ManyOptionsView()
            }
        }
    }
    
    func section(title: String, item: MenuItem) -> some View {
        VStack(spacing: 0) {
            sectionHeading(title: "Your \(title)")
            
            VStack {
                Button(action: { viewModel.itemOptions = MockData.toppings }) {
                    OptionsCardView(item: MenuItemOptionValue(name: viewModel.itemOptions?.name ?? "Add \(title)", extraCost: nil, default: nil, sizeExtraCost: nil), optionsMode: .manyMore)
                }
            }
            .padding()
            
            Button(action: {}) {
                Text("Next")
                    .fontWeight(.semibold)
            }
            .buttonStyle(SnappyMainActionButtonStyle(isEnabled: true))
            .padding(.bottom)
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

struct MenuItem {
    let id = UUID() // later Int64
    let name: String
    let description: String?
    let sizes: [MenuItemSize]?
    let options: [MenuItemOption]
}

struct MenuItemSize {
    let id = UUID() // change to String
    let name: String
    let price: String
}

struct MenuItemOption: Equatable, Identifiable {
    let id = UUID()
    let name: String
    var placeholder: String?
    let maxiumSelected: Int?
    var displayAsGrid: Bool?
    let mutuallyExlusive: Bool
    let minimumSelected: Int?
    var dependantOn: [Int]?
    let values: [MenuItemOptionValue]
    let type: String
}

struct MenuItemOptionValue: Equatable, Identifiable {
    let id = UUID()
    let name: String?
    let extraCost: Double?
    let `default`: Bool?
    let sizeExtraCost: [MenuItemOptionValueSize]?
}

struct MenuItemOptionValueSize: Identifiable, Equatable {
    let id = UUID() // change to Int
    let sizeId: Int
    let extraCost: Double
}

struct ProductOptionsView_Previews: PreviewProvider {
    static var previews: some View {
        ProductOptionsView(viewModel: ProductOptionsViewModel(item: MockData.item))
            .previewCases()
    }
}

#if DEBUG

extension MockData {
    static let item = MenuItem(name: "Fresh Pizzas", description: "Choose your own pizza from as little as £5.00 and a drink", sizes: nil, options: [toppings, bases, drinks, sides])
    
    static let toppings = MenuItemOption(name: "Toppings", maxiumSelected: 10, mutuallyExlusive: false, minimumSelected: 2, values: [topping1, topping2, topping3, topping4, topping5, topping6], type: "")
    static let bases = MenuItemOption(name: "Base", maxiumSelected: 1, mutuallyExlusive: false, minimumSelected: 1, values: [base1, base2, base3], type: "")
    static let drinks = MenuItemOption(name: "Drinks", maxiumSelected: nil, mutuallyExlusive: false, minimumSelected: 0, values: [drink1, drink2, drink3], type: "")
    static let sides = MenuItemOption(name: "Side", maxiumSelected: 0, mutuallyExlusive: true, minimumSelected: 0, values: [side1, side2, side3], type: "")
    
    static let topping1 = MenuItemOptionValue(name: "Mushrooms", extraCost: nil, default: nil, sizeExtraCost: nil)
    static let topping2 = MenuItemOptionValue(name: "Peppers", extraCost: 1.5, default: nil, sizeExtraCost: nil)
    static let topping3 = MenuItemOptionValue(name: "Goats Cheese", extraCost: 1.5, default: nil, sizeExtraCost: nil)
    static let topping4 = MenuItemOptionValue(name: "Red Onions", extraCost: nil, default: nil, sizeExtraCost: nil)
    static let topping5 = MenuItemOptionValue(name: "Falafel", extraCost: 1.5, default: nil, sizeExtraCost: nil)
    static let topping6 = MenuItemOptionValue(name: "Beef Strips", extraCost: 1.5, default: nil, sizeExtraCost: nil)
    
    static let base1 = MenuItemOptionValue(name: "Thin Base", extraCost: nil, default: nil, sizeExtraCost: nil)
    static let base2 = MenuItemOptionValue(name: "Thin Base", extraCost: nil, default: nil, sizeExtraCost: nil)
    static let base3 = MenuItemOptionValue(name: "Thin Base", extraCost: nil, default: nil, sizeExtraCost: nil)
    
    static let drink1 = MenuItemOptionValue(name: "Coca Cola", extraCost: 1.5, default: nil, sizeExtraCost: nil)
    static let drink2 = MenuItemOptionValue(name: "Fanta", extraCost: 1.5, default: nil, sizeExtraCost: nil)
    static let drink3 = MenuItemOptionValue(name: "Coke Zero", extraCost: 1.5, default: nil, sizeExtraCost: nil
    )
    
    static let side1 = MenuItemOptionValue(name: "Chicken Wings", extraCost: 1.5, default: nil, sizeExtraCost: nil)
    static let side2 = MenuItemOptionValue(name: "Wedges", extraCost: 1.5, default: nil, sizeExtraCost: nil)
    static let side3 = MenuItemOptionValue(name: "Cookies", extraCost: 1.5, default: nil, sizeExtraCost: nil)
}

#endif
