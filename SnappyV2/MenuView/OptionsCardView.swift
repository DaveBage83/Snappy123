//
//  OptionsCardView.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 21/07/2021.
//

import SwiftUI

class OptionsCardViewModel: ObservableObject {
    let title: String
    let optionsType: OptionType
    
    init(option: MenuItemOption, optionsType: OptionType) {
        self.title = option.name
        self.optionsType = optionsType
    }
    
    init(size: MenuItemSize) {
        self.title = size.name
        self.optionsType = .radio
    }
}

enum OptionType {
    case manyMore
    case radio
    case checkbox
    case stepper
}

struct OptionsCardView: View {
    
    @StateObject var viewModel: OptionsCardViewModel
    
    @State var quantity = 0
    @State var toggle = false
    
    init(option: MenuItemOption, optionsType: OptionType = .manyMore) {
        self._viewModel = StateObject(wrappedValue: OptionsCardViewModel(option: option, optionsType: optionsType))
    }
    
    init(size: MenuItemSize) {
        self._viewModel = StateObject(wrappedValue: OptionsCardViewModel(size: size))
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(viewModel.title)
                    .font(.snappyHeadline)
                    .fontWeight(.regular)
                    .foregroundColor(.snappyDark)
                
//                if let subtitle = subtitle {
//                    Text(subtitle)
//                        .font(.snappySubheadline)
//                        .foregroundColor(.snappyTextGrey2)
//                }
            }
            
            Spacer()
            
            optionsMode
        }
        .padding()
        .background(Color.white)
        .cornerRadius(6)
        .snappyShadow()
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
        if quantity == 0 {
            Button(action: { quantity = 1 }) {
                Image(systemName: "plus.circle")
                .font(.title)
                .foregroundColor(.snappyDark)
            }
        } else {
            HStack {
                Button(action: { quantity -= 1 }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.title)
                        .foregroundColor(.snappyDark)
                }
                
                Text("\(quantity)")
                    .font(.snappyBody)
                
                Button(action: { quantity += 1 }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                        .foregroundColor(.snappyDark)
                }
            }
        }
    }
    
    @ViewBuilder var radio: some View {
        Button(action: { toggle.toggle() }) {
            Image(systemName: toggle ? "largecircle.fill.circle" : "circle")
                .font(.title)
                .foregroundColor(.snappyDark)
        }
    }
    
    @ViewBuilder var checkbox: some View {
        Button(action: { toggle.toggle() }) {
            Image(systemName: toggle ? "checkmark.circle.fill" : "checkmark.circle")
                .font(.title)
                .foregroundColor(.snappyDark)
        }
    }
}

struct OptionsCardView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            OptionsCardView(item: MenuItemOptionValue(id: 1, name: "Add Toppings", extraCost: nil, default: nil, sizeExtraCost: nil))
                .previewCases()
            
            OptionsCardView(item: MenuItemOptionValue(id: 2, name: "Thin Base", extraCost: nil, default: nil, sizeExtraCost: nil))
            
            OptionsCardView(item: MenuItemOptionValue(id: 3, name: "Chicken Kickers", extraCost: nil, default: nil, sizeExtraCost: nil))
            
            OptionsCardView(item: MenuItemOptionValue(id: 4, name: "Coke", extraCost: nil, default: nil, sizeExtraCost: nil))
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
