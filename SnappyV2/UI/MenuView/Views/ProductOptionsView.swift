//
//  ProductOptionsView.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 20/07/2021.
//

import SwiftUI

struct ProductOptionsView: View {
    @StateObject var viewModel: ProductOptionsViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
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
                
                if let sizes = viewModel.item.sizes {
                    ProductOptionSectionView(viewModel: viewModel.makeProductOptionSectionViewModel(itemSizes: sizes))
                        .environmentObject(viewModel)
                }
                
                ForEach(viewModel.filteredOptions) { itemOption in
                    ProductOptionSectionView(viewModel: viewModel.makeProductOptionSectionViewModel(itemOption: itemOption))
                        .environmentObject(viewModel)
                }
                .animation(.easeInOut)
                
                Spacer()
            }
            .padding(.bottom, 60)
        }
        .overlay(
            addToBasketFloatingButton()
        )
    }
    
    func addToBasketFloatingButton() -> some View {
        VStack {
            Spacer()
            
            HStack {
                Button(action: {
                }) {
                    HStack {
                        Text("Add to Basket")
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Text(viewModel.totalPrice)
                            .fontWeight(.semibold)
                    }
                    .font(.snappyTitle3)
                    .foregroundColor(.white)
                    .padding(10)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.snappyTeal)
                            .padding(.horizontal)
                    )
                }
            }
        }
        .padding(.bottom, 5)
    }
}

struct ProductOptionsView_Previews: PreviewProvider {
    static var previews: some View {
        ProductOptionsView(viewModel: ProductOptionsViewModel(item: MockData.item))
            .previewCases()
    }
}

#if DEBUG

extension MockData {
    static let item = MenuItem(name: "Fresh Pizzas", price: price, description: "Choose your own pizza from as little as £5.00 and a drink", sizes: [sizeS, sizeM, sizeL], options: [bases, makeAMeal, drinks, sides, toppings])
    
    static let price = Price(price: 10, fromPrice: nil, wasPrice: nil, unitMetric: nil, unitsInPack: nil, unitVolume: nil)
    
    static let toppings = MenuItemOption(id: 377, name: "Toppings", maximumSelected: 5, mutuallyExclusive: true, minimumSelected: 2, values: [topping1, topping2, topping3, topping4, topping5, topping6, topping7, topping8, topping9], type: "")
    static let bases = MenuItemOption(id: 366, name: "Base", maximumSelected: 1, displayAsGrid: true, mutuallyExclusive: true, minimumSelected: 1, values: [base1, base2, base3], type: "")
    static let makeAMeal = MenuItemOption(id: 994, name: "Make a meal out of it", placeholder: "Choose", maximumSelected: 1, displayAsGrid: true, mutuallyExclusive: false, minimumSelected: 1, dependentOn: nil, values: [mealYes, mealNo], type: "")
    static let drinks = MenuItemOption(id: 355, name: "Drinks", maximumSelected: 3, displayAsGrid: false, mutuallyExclusive: false, minimumSelected: 0, dependentOn: [222], values: [drink1, drink2, drink3], type: "")
    static let sides = MenuItemOption(id: 344, name: "Side", maximumSelected: 2, mutuallyExclusive: false, minimumSelected: 0, dependentOn: [222], values: [side1, side2, side3], type: "")
    
    static let sizeS = MenuItemSize(id: 123, name: "Small - 9", price: 0)
    static let sizeM = MenuItemSize(id: 124, name: "Medium - 11", price: 1.5)
    static let sizeL = MenuItemSize(id: 142, name: "Large - 13", price: 3)
    
    static let topping1 = MenuItemOptionValue(id: 435, name: "Mushrooms", extraCost: nil, default: nil, sizeExtraCost: nil)
    static let topping2 = MenuItemOptionValue(id: 324, name: "Peppers", extraCost: 1.5, default: nil, sizeExtraCost: nil)
    static let topping3 = MenuItemOptionValue(id: 643, name: "Goats Cheese", extraCost: 1.5, default: nil, sizeExtraCost: nil)
    static let topping4 = MenuItemOptionValue(id: 153, name: "Red Onions", extraCost: nil, default: nil, sizeExtraCost: nil)
    static let topping5 = MenuItemOptionValue(id: 984, name: "Falafel", extraCost: 1, default: nil, sizeExtraCost: [falafelSizeS, falafelSizeM, falafelSizeL])
    static let topping6 = MenuItemOptionValue(id: 904, name: "Beef Strips", extraCost: 1.5, default: nil, sizeExtraCost: nil)
    static let topping7 = MenuItemOptionValue(id: 783, name: "Bacon", extraCost: 1.5, default: nil, sizeExtraCost: nil)
    static let topping8 = MenuItemOptionValue(id: 376, name: "Pepperoni", extraCost: 1.5, default: nil, sizeExtraCost: nil)
    static let topping9 = MenuItemOptionValue(id: 409, name: "Sweetcorn", extraCost: 1.5, default: nil, sizeExtraCost: nil)
    
    static let falafelSizeS = MenuItemOptionValueSize(id: 678, sizeId: 123, extraCost: 1)
    static let falafelSizeM = MenuItemOptionValueSize(id: 679, sizeId: 124, extraCost: 1.5)
    static let falafelSizeL = MenuItemOptionValueSize(id: 680, sizeId: 142, extraCost: 2)
    
    static let base1 = MenuItemOptionValue(id: 234, name: "Classic", extraCost: nil, default: nil, sizeExtraCost: nil)
    static let base2 = MenuItemOptionValue(id: 759, name: "Stuffed crust", extraCost: nil, default: nil, sizeExtraCost: nil)
    static let base3 = MenuItemOptionValue(id: 333, name: "Italian style", extraCost: nil, default: nil, sizeExtraCost: nil)
    
    static let mealYes = MenuItemOptionValue(id: 222, name: "Yes", extraCost: nil, default: nil, sizeExtraCost: nil)
    static let mealNo = MenuItemOptionValue(id: 111, name: "No", extraCost: nil, default: nil, sizeExtraCost: nil)
    
    static let drink1 = MenuItemOptionValue(id: 555, name: "Coca Cola", extraCost: 1.5, default: nil, sizeExtraCost: nil)
    static let drink2 = MenuItemOptionValue(id: 666, name: "Fanta", extraCost: 1.5, default: nil, sizeExtraCost: nil)
    static let drink3 = MenuItemOptionValue(id: 777, name: "Coke Zero", extraCost: 1.5, default: nil, sizeExtraCost: nil)
    
    static let side1 = MenuItemOptionValue(id: 888, name: "Chicken Wings", extraCost: 1.5, default: nil, sizeExtraCost: nil)
    static let side2 = MenuItemOptionValue(id: 999, name: "Wedges", extraCost: 1.5, default: nil, sizeExtraCost: nil)
    static let side3 = MenuItemOptionValue(id: 327, name: "Cookies", extraCost: 1.5, default: nil, sizeExtraCost: nil)
}

#endif
