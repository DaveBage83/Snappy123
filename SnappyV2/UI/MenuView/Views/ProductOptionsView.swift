//
//  ProductOptionsView.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 20/07/2021.
//

import SwiftUI

struct ProductOptionsView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    
    struct Constants {
        static let spacing: CGFloat = 0
        static let brightness: Double = -0.5
        static let cornerRadius: CGFloat = 10
        static let imageHeight: CGFloat = UIScreen.main.bounds.height/5
        
        struct Padding {
            static let standard: CGFloat = 10
            static let bottom: CGFloat = 60
            static let buttonBottom: CGFloat = 5
        }
    }
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    @StateObject var viewModel: ProductOptionsViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: Constants.spacing) {
                    VStack {
                        AsyncImage(urlString: viewModel.item.images?.first?[AppV2Constants.API.imageScaleFactor]?.absoluteString) {
                            Image.Placeholders.productPlaceholder
                                .resizable()
                        }
                        .scaledToFill()
                        .frame(height: Constants.imageHeight)
                        .clipShape(Rectangle())
                        .brightness(Constants.brightness)
                        
                        ExpandableText(viewModel: .init(container: viewModel.container, title: viewModel.item.name, shortTitle: nil, text: viewModel.item.description ?? "", shortText: nil, isComplexItem: true))
                        
                    }
                    
                    if let sizes = viewModel.item.menuItemSizes {
                        ProductOptionSectionView(viewModel: viewModel.makeProductOptionSectionViewModel(itemSizes: sizes), optionsViewModel: viewModel)
                    }
                    
                    ForEach(viewModel.filteredOptions) { itemOption in
                        ProductOptionSectionView(viewModel: viewModel.makeProductOptionSectionViewModel(itemOption: itemOption), optionsViewModel: viewModel)
                    }
                    
                    Spacer()
                }
                .padding(.bottom, Constants.Padding.bottom)
                .onChange(of: viewModel.viewDismissed) { dismissed in
                    if dismissed {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .overlay(
                addToBasketFloatingButton()
            )
            .dismissableNavBar(presentation: presentationMode, color: colorPalette.primaryBlue, navigationDismissType: .close)
        }
    }
    
    func addToBasketFloatingButton() -> some View {
        VStack {
            Spacer()
            
            HStack {
                Button(action: { Task { await viewModel.addItemToBasket() } }) {
                    if viewModel.isAddingToBasket {
                        ProgressView()
                            .font(.snappyTitle3)
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .padding(Constants.Padding.standard)
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: Constants.cornerRadius)
                                    .fill(Color.snappyTeal)
                                    .padding(.horizontal)
                            )
                    } else {
                        HStack {
                            Text(Strings.ProductOptions.add.localized)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Text(viewModel.totalPrice)
                                .fontWeight(.semibold)
                        }
                        .font(.snappyTitle3)
                        .foregroundColor(.white)
                        .padding(Constants.Padding.standard)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: Constants.cornerRadius)
                                .fill(Color.snappyTeal)
                                .padding(.horizontal)
                        )
                    }
                }
                .disabled(viewModel.isAddingToBasket)
            }
        }
        .padding(.bottom, Constants.Padding.buttonBottom)
    }
}

#if DEBUG
struct ProductOptionsView_Previews: PreviewProvider {
    static var previews: some View {
        ProductOptionsView(viewModel: ProductOptionsViewModel(container: .preview, item: MockData.item))
            .previewCases()
    }
}

extension MockData {
    static let item = RetailStoreMenuItem(id: 123, name: "Fresh Pizzas", eposCode: nil, outOfStock: false, ageRestriction: 0, description: "Choose your own pizza from as little as £5.00 and a drink", quickAdd: false, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: price, images: nil, menuItemSizes: [sizeS, sizeM, sizeL], menuItemOptions: [bases, makeAMeal, drinks, sides, toppings], availableDeals: nil, itemCaptions: ItemCaptions(portionSize: "495 Kcal per 100g"), mainCategory: MenuItemCategory(id: 234, name: "Pizzas"), itemDetails: nil)
    
    static let price = RetailStoreMenuItemPrice(price: 10, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil)
    
    static let toppings = RetailStoreMenuItemOption(id: 377, name: "Toppings", type: .item, placeholder: "", instances: 5, displayAsGrid: true, mutuallyExclusive: true, minimumSelected: 2, extraCostThreshold: 0, dependencies: nil, values: [topping1, topping2, topping3, topping4, topping5, topping6, topping7, topping8, topping9])
    static let bases = RetailStoreMenuItemOption(id: 366, name: "Base", type: .item, placeholder: "", instances: 1, displayAsGrid: true, mutuallyExclusive: true, minimumSelected: 1, extraCostThreshold: 0, dependencies: nil, values: [base1, base2, base3])
    static let makeAMeal = RetailStoreMenuItemOption(id: 994, name: "Make a meal out of it", type: .item, placeholder: "Choose", instances: 1, displayAsGrid: true, mutuallyExclusive: false, minimumSelected: 1, extraCostThreshold: 0, dependencies: nil, values: [mealYes, mealNo])
    static let drinks = RetailStoreMenuItemOption(id: 355, name: "Drinks", type: .item, placeholder: "", instances: 3, displayAsGrid: false, mutuallyExclusive: false, minimumSelected: 0, extraCostThreshold: 0, dependencies: [222], values: [drink1, drink2, drink3])
    static let sides = RetailStoreMenuItemOption(id: 344, name: "Side", type: .item, placeholder: "", instances: 2, displayAsGrid: true, mutuallyExclusive: false, minimumSelected: 0, extraCostThreshold: 0, dependencies: [222], values: [side1, side2, side3])
    
    static let sizeS = RetailStoreMenuItemSize(id: 123, name: "Small - 9", price: sizeSPrice)
    static let sizeM = RetailStoreMenuItemSize(id: 124, name: "Medium - 11", price: sizeMPrice)
    static let sizeL = RetailStoreMenuItemSize(id: 142, name: "Large - 13", price: sizeLPrice)
    
    static let sizeSPrice = MenuItemSizePrice(price: 0)
    static let sizeMPrice = MenuItemSizePrice(price: 1.5)
    static let sizeLPrice = MenuItemSizePrice(price: 3)
    
    static let topping1 = RetailStoreMenuItemOptionValue(id: 435, name: "Mushrooms", extraCost: 0, defaultSelection: 0, sizeExtraCost: nil)
    static let topping2 = RetailStoreMenuItemOptionValue(id: 324, name: "Peppers", extraCost: 1.5, defaultSelection: 0, sizeExtraCost: nil)
    static let topping3 = RetailStoreMenuItemOptionValue(id: 643, name: "Goats Cheese", extraCost: 1.5, defaultSelection: 0, sizeExtraCost: nil)
    static let topping4 = RetailStoreMenuItemOptionValue(id: 153, name: "Red Onions", extraCost: 0, defaultSelection: 0, sizeExtraCost: nil)
    static let topping5 = RetailStoreMenuItemOptionValue(id: 984, name: "Falafel", extraCost: 1, defaultSelection: 0, sizeExtraCost: [falafelSizeS, falafelSizeM, falafelSizeL])
    static let topping6 = RetailStoreMenuItemOptionValue(id: 904, name: "Beef Strips", extraCost: 1.5, defaultSelection: 0, sizeExtraCost: nil)
    static let topping7 = RetailStoreMenuItemOptionValue(id: 783, name: "Bacon", extraCost: 1.5, defaultSelection: 0, sizeExtraCost: nil)
    static let topping8 = RetailStoreMenuItemOptionValue(id: 376, name: "Pepperoni", extraCost: 1.5, defaultSelection: 0, sizeExtraCost: nil)
    static let topping9 = RetailStoreMenuItemOptionValue(id: 409, name: "Sweetcorn", extraCost: 1.5, defaultSelection: 0, sizeExtraCost: nil)
    
    static let falafelSizeS = RetailStoreMenuItemOptionValueSizeCost(id: 678, sizeId: 123, extraCost: 1)
    static let falafelSizeM = RetailStoreMenuItemOptionValueSizeCost(id: 679, sizeId: 124, extraCost: 1.5)
    static let falafelSizeL = RetailStoreMenuItemOptionValueSizeCost(id: 680, sizeId: 142, extraCost: 2)
    
    static let base1 = RetailStoreMenuItemOptionValue(id: 234, name: "Classic", extraCost: 0, defaultSelection: 0, sizeExtraCost: nil)
    static let base2 = RetailStoreMenuItemOptionValue(id: 759, name: "Stuffed crust", extraCost: 0, defaultSelection: 0, sizeExtraCost: nil)
    static let base3 = RetailStoreMenuItemOptionValue(id: 333, name: "Italian style", extraCost: 0, defaultSelection: 0, sizeExtraCost: nil)
    
    static let mealYes = RetailStoreMenuItemOptionValue(id: 222, name: "Yes", extraCost: 0, defaultSelection: 0, sizeExtraCost: nil)
    static let mealNo = RetailStoreMenuItemOptionValue(id: 111, name: "No", extraCost: 0, defaultSelection: 0, sizeExtraCost: nil)
    
    static let drink1 = RetailStoreMenuItemOptionValue(id: 555, name: "Coca Cola", extraCost: 1.5, defaultSelection: 0, sizeExtraCost: nil)
    static let drink2 = RetailStoreMenuItemOptionValue(id: 666, name: "Fanta", extraCost: 1.5, defaultSelection: 0, sizeExtraCost: nil)
    static let drink3 = RetailStoreMenuItemOptionValue(id: 777, name: "Coke Zero", extraCost: 1.5, defaultSelection: 0, sizeExtraCost: nil)
    
    static let side1 = RetailStoreMenuItemOptionValue(id: 888, name: "Chicken Wings", extraCost: 1.5, defaultSelection: 0, sizeExtraCost: nil)
    static let side2 = RetailStoreMenuItemOptionValue(id: 999, name: "Wedges", extraCost: 1.5, defaultSelection: 0, sizeExtraCost: nil)
    static let side3 = RetailStoreMenuItemOptionValue(id: 327, name: "Cookies", extraCost: 1.5, defaultSelection: 0, sizeExtraCost: nil)
}

#endif
