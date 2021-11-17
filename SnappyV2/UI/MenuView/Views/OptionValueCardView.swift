//
//  OptionValueCardView.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 21/07/2021.
//

import SwiftUI

struct OptionValueCardView: View {
    
    @StateObject var viewModel: OptionValueCardViewModel
    
    @Binding var maxiumReached: Bool
    
    var body: some View {
        if viewModel.optionsType == .manyMore {
            HStack {
                VStack(alignment: .leading) {
                    HStack {
                        Text(viewModel.title)
                            .font(.snappyHeadline)
                            .fontWeight(.regular)
                            .foregroundColor(.snappyDark)
                    }
                }
                
                Spacer()
                
                optionsMode
            }
            .padding()
            .background(Color.white)
            .cornerRadius(6)
            .snappyShadow()
        } else {
            Button(action: { viewModel.toggleValue(maxReached: $maxiumReached) }) {
                HStack {
                    VStack(alignment: .leading) {
                        HStack {
                            Text(viewModel.title)
                                .font(.snappyHeadline)
                                .fontWeight(.regular)
                                .foregroundColor(.snappyDark)
                            
                            if viewModel.showPrice {
                                Text(viewModel.price)
                                    .font(.snappyHeadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.snappyBlue)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    optionsMode
                }
                .padding()
                .background(Color.white)
                .cornerRadius(6)
                .snappyShadow()
            }
        }
    }
    
    @ViewBuilder var optionsMode: some View {
        switch viewModel.optionsType {
        case .manyMore:
            manyMoreOptions
        case .stepper:
            stepper
        case .radio:
            radio
        case .checkbox:
            checkbox
        }
    }
    
    @ViewBuilder var manyMoreOptions: some View {
        Image(systemName: "plus")
            .font(.title)
            .foregroundColor(.snappyDark)
    }
    
    @ViewBuilder var stepper: some View {
        if viewModel.quantity == 0 {
                Image(systemName: "plus.circle")
                .font(.title)
                .foregroundColor(viewModel.isDisabled($maxiumReached) ? .snappyTextGrey3 : .snappyDark)
        } else {
            HStack {
                Button(action: { viewModel.removeValue() }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.title)
                        .foregroundColor(.snappyDark)
                }
                
                Text("\(viewModel.quantity)")
                    .font(.snappyBody)
                    .foregroundColor(.snappyDark)
                
                Button(action: { viewModel.addValue(maxReached: $maxiumReached) }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                        .foregroundColor(viewModel.isDisabled($maxiumReached) ? .snappyTextGrey3 : .snappyDark)
                }
            }
        }
    }
    
    @ViewBuilder var radio: some View {
            Image(systemName: viewModel.isSelected ? "largecircle.fill.circle" : "circle")
                .font(.title)
                .foregroundColor(.snappyDark)
    }
    
    @ViewBuilder var checkbox: some View {
            Image(systemName: viewModel.isSelected ? "checkmark.circle.fill" : "checkmark.circle")
                .font(.title)
                .foregroundColor(viewModel.isDisabled($maxiumReached) ? .snappyTextGrey3 : .snappyDark)
    }
}

struct OptionsCardView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            OptionValueCardView(viewModel: OptionValueCardViewModel(optionValue: RetailStoreMenuItemOptionValue(id: 1, name: "Add Cheese", extraCost: 0, default: 0, sizeExtraCost: nil), optionID: 123, optionsType: .checkbox, optionController: OptionController()), maxiumReached: .constant(false))
                .environmentObject(ProductOptionsViewModel(item: MockData.item))
                .previewDisplayName("Checkbox")
            
            OptionValueCardView(viewModel: OptionValueCardViewModel(optionValue: RetailStoreMenuItemOptionValue(id: 2, name: "Thin Base", extraCost: 1, default: 0, sizeExtraCost: nil), optionID: 123, optionsType: .radio, optionController: OptionController()), maxiumReached: .constant(false))
                .environmentObject(ProductOptionsViewModel(item: MockData.item))
                .previewDisplayName("Radio")
            
            OptionValueCardView(viewModel: OptionValueCardViewModel(size: RetailStoreMenuItemSize(id: 123, name: "Medium", price: MenuItemSizePrice(price: 1.5)), optionController: OptionController()), maxiumReached: .constant(false))
                .environmentObject(ProductOptionsViewModel(item: MockData.item))
                .previewDisplayName("Size")
            
            OptionValueCardView(viewModel: OptionValueCardViewModel(optionValue: RetailStoreMenuItemOptionValue(id: 0, name: "Add Toppings", extraCost: 0, default: 0, sizeExtraCost: nil), optionID: 123, optionsType: .manyMore, optionController: OptionController()), maxiumReached: .constant(false))
                .environmentObject(ProductOptionsViewModel(item: MockData.item))
                .previewDisplayName("ManyMore")
            
            OptionValueCardView(viewModel: OptionValueCardViewModel(optionValue: RetailStoreMenuItemOptionValue(id: 4, name: "Coke", extraCost: 0.25, default: 0, sizeExtraCost: nil), optionID: 123, optionsType: .stepper, optionController: OptionController()), maxiumReached: .constant(false))
                .environmentObject(ProductOptionsViewModel(item: MockData.item))
                .previewDisplayName("Stepper")
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
