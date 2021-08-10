//
//  ProductOptionsView.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 20/07/2021.
//

import SwiftUI
import Combine

class ProductOptionsViewModel: ObservableObject {
    @Published var bottomSheetOptions: MenuItemOption?
    @Published var item: MenuItem
    @Published var selectedOptionValueIDs = Set<Int>()
    @Published var availableOptions = [MenuItemOption]()
    @Published var filteredOptions = [MenuItemOption]()
    
    var cancellables = Set<AnyCancellable>()
    
    init(item: MenuItem) {
        self.item = item
        
        initAvailableOptions()
        filterAvailableOptions()
    }
    
    func initAvailableOptions() {
        if let options = item.options {
            availableOptions = options
        }
    }
    
    func tapOption(optionID: Int) {
        if selectedOptionValueIDs.contains(optionID) {
            selectedOptionValueIDs.remove(optionID)
        } else {
            selectedOptionValueIDs.insert(optionID)
        }
    }
    
    func filterAvailableOptions() {
        $selectedOptionValueIDs
            .map { [weak self] ids in
                guard let self = self else { return [] }
                var array = [MenuItemOption]()
                
                for option in self.availableOptions {
                    guard array.contains(option) == false else { continue }
                    guard let dependentOn = option.dependentOn else { array.append(option); continue }
                    
                    if (dependentOn.contains {
                        return ids.contains($0)
                    }) {
                        array.append(option)
                    }
                }
                
                return array
            }
            .assignNoRetain(to: \.filteredOptions, on: self)
            .store(in: &cancellables)
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
                
//                if let sizes = viewModel.item.sizes {
//                    ForEach(sizes, id: \.id) { size in
//                        sizeSection(title: size.name, item: size)
//                    }
//                }
                
                ForEach(viewModel.filteredOptions) { _ in
                    ProductOptionSectionView()
                        .environmentObject(viewModel)
                }
                
//                if let options = viewModel.filteredOptions {
//                    ForEach(options, id: \.id) { option in
//                        optionSection(title: option.name, item: viewModel.item)
//                    }
//                }
                
                Spacer()
            }
            .bottomSheet(item: $viewModel.bottomSheetOptions) { _ in
                ManyOptionsView()
            }
        }
    }
    
//    func sizeSection(title: String, item: MenuItemSize) -> some View {
//        VStack(spacing: 0) {
//            sectionHeading(title: "Choose Size")
//
//            VStack {
//                Button(action: { viewModel.itemOptions = MockData.toppings }) {
//                    OptionsCardView(item: MenuItemOptionValue(id: 1, name: viewModel.itemOptions?.name ?? "Add \(title)", extraCost: nil, default: nil, sizeExtraCost: nil), optionsMode: .manyMore)
//                }
//            }
//            .padding()
//
//            Button(action: {}) {
//                Text("Next")
//                    .fontWeight(.semibold)
//            }
//            .buttonStyle(SnappyMainActionButtonStyle(isEnabled: true))
//            .padding(.bottom)
//        }
//    }
//
//    func optionSection(title: String, item: MenuItem) -> some View {
//        VStack(spacing: 0) {
//            sectionHeading(title: "Choose \(title)")
//
//            VStack {
//                Button(action: { viewModel.itemOptions = MockData.toppings }) {
//                    OptionsCardView(item: MenuItemOptionValue(id: 1, name: viewModel.itemOptions?.name ?? "Add \(title)", extraCost: nil, default: nil, sizeExtraCost: nil), optionsMode: .manyMore)
//                }
//            }
//            .padding()
//
//            Button(action: {}) {
//                Text("Next")
//                    .fontWeight(.semibold)
//            }
//            .buttonStyle(SnappyMainActionButtonStyle(isEnabled: true))
//            .padding(.bottom)
//        }
//    }
    
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
    let id = UUID() // later Int
    let name: String
    let description: String?
    let sizes: [MenuItemSize]?
    let options: [MenuItemOption]?
}

struct MenuItemSize {
    let id: Int
    let name: String
    let price: Double
}

struct MenuItemOption: Equatable, Identifiable, Hashable {
    let id: Int
    let name: String
    var placeholder: String?
    let maxiumSelected: Int?
    var displayAsGrid: Bool?
    let mutuallyExlusive: Bool
    let minimumSelected: Int?
    var dependentOn: [Int]?
    let values: [MenuItemOptionValue]
    let type: String
}

struct MenuItemOptionValue: Equatable, Identifiable, Hashable {
    let id: Int
    let name: String?
    let extraCost: Double?
    let `default`: Bool?
    let sizeExtraCost: [MenuItemOptionValueSize]?
}

struct MenuItemOptionValueSize: Identifiable, Equatable, Hashable {
    let id: Int
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
    static let item = MenuItem(name: "Fresh Pizzas", description: "Choose your own pizza from as little as £5.00 and a drink", sizes: nil, options: [toppings, bases, makeAMeal, drinks, sides])
    
    static let toppings = MenuItemOption(id: 377, name: "Toppings", maxiumSelected: 8, mutuallyExlusive: false, minimumSelected: 2, values: [topping1, topping2, topping3, topping4, topping5, topping6, topping7, topping8, topping9], type: "")
    static let bases = MenuItemOption(id: 366, name: "Base", maxiumSelected: 1, mutuallyExlusive: true, minimumSelected: 1, values: [base1, base2, base3], type: "")
    static let makeAMeal = MenuItemOption(id: 994, name: "Make a meal out of it", placeholder: "Choose", maxiumSelected: 1, displayAsGrid: false, mutuallyExlusive: false, minimumSelected: 1, dependentOn: nil, values: [mealYes, mealNo], type: "")
    static let drinks = MenuItemOption(id: 355, name: "Drinks", maxiumSelected: nil, mutuallyExlusive: false, minimumSelected: 0, dependentOn: [222], values: [drink1, drink2, drink3], type: "")
    static let sides = MenuItemOption(id: 344, name: "Side", maxiumSelected: 0, mutuallyExlusive: false, minimumSelected: 0, dependentOn: [222], values: [side1, side2, side3], type: "")
    
    static let sizeS = MenuItemSize(id: 123, name: "Small - 9", price: 0)
    static let sizeM = MenuItemSize(id: 124, name: "Medium - 11", price: 1.5)
    static let sizeL = MenuItemSize(id: 142, name: "Large - 13", price: 3)
    
    static let topping1 = MenuItemOptionValue(id: 435, name: "Mushrooms", extraCost: nil, default: nil, sizeExtraCost: nil)
    static let topping2 = MenuItemOptionValue(id: 324, name: "Peppers", extraCost: 1.5, default: nil, sizeExtraCost: nil)
    static let topping3 = MenuItemOptionValue(id: 643, name: "Goats Cheese", extraCost: 1.5, default: nil, sizeExtraCost: nil)
    static let topping4 = MenuItemOptionValue(id: 153, name: "Red Onions", extraCost: nil, default: nil, sizeExtraCost: nil)
    static let topping5 = MenuItemOptionValue(id: 984, name: "Falafel", extraCost: 1.5, default: nil, sizeExtraCost: nil)
    static let topping6 = MenuItemOptionValue(id: 904, name: "Beef Strips", extraCost: 1.5, default: nil, sizeExtraCost: nil)
    static let topping7 = MenuItemOptionValue(id: 783, name: "Bacon", extraCost: 1.5, default: nil, sizeExtraCost: nil)
    static let topping8 = MenuItemOptionValue(id: 376, name: "Pepperoni", extraCost: 1.5, default: nil, sizeExtraCost: nil)
    static let topping9 = MenuItemOptionValue(id: 409, name: "Sweetcorn", extraCost: 1.5, default: nil, sizeExtraCost: nil)
    
    static let base1 = MenuItemOptionValue(id: 234, name: "Classic", extraCost: nil, default: nil, sizeExtraCost: nil)
    static let base2 = MenuItemOptionValue(id: 759, name: "Stuffed crust", extraCost: nil, default: nil, sizeExtraCost: nil)
    static let base3 = MenuItemOptionValue(id: 333, name: "Italian style", extraCost: nil, default: nil, sizeExtraCost: nil)
    
    static let mealYes = MenuItemOptionValue(id: 222, name: "Yes", extraCost: 0, default: nil, sizeExtraCost: nil)
    static let mealNo = MenuItemOptionValue(id: 111, name: "No", extraCost: 0, default: nil, sizeExtraCost: nil)
    
    static let drink1 = MenuItemOptionValue(id: 555, name: "Coca Cola", extraCost: 1.5, default: nil, sizeExtraCost: nil)
    static let drink2 = MenuItemOptionValue(id: 666, name: "Fanta", extraCost: 1.5, default: nil, sizeExtraCost: nil)
    static let drink3 = MenuItemOptionValue(id: 777, name: "Coke Zero", extraCost: 1.5, default: nil, sizeExtraCost: nil)
    
    static let side1 = MenuItemOptionValue(id: 888, name: "Chicken Wings", extraCost: 1.5, default: nil, sizeExtraCost: nil)
    static let side2 = MenuItemOptionValue(id: 999, name: "Wedges", extraCost: 1.5, default: nil, sizeExtraCost: nil)
    static let side3 = MenuItemOptionValue(id: 327, name: "Cookies", extraCost: 1.5, default: nil, sizeExtraCost: nil)
}

#endif
