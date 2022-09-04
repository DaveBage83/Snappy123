//
//  OptionValueCardView.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 21/07/2021.
//

import SwiftUI

struct OptionValueCardView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject var viewModel: OptionValueCardViewModel
    
    @Binding var maximumReached: Bool
    
    var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    var body: some View {
        if viewModel.optionsType == .manyMore {
            HStack {
                VStack(alignment: .leading) {
                    HStack {
                        Text(maximumReached ? Strings.ProductOptions.Customisable.change.localizedFormat(viewModel.title) : Strings.ProductOptions.Customisable.add.localizedFormat(viewModel.title))
                            .font(.heading4())
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
            Button(action: { viewModel.toggleValue(maxReached: $maximumReached) }) {
                HStack {
                    VStack(alignment: .leading) {
                        HStack {
                            Text(viewModel.title)
                                .font(.heading4())
                                .fontWeight(.regular)
                                .foregroundColor(.snappyDark)
                            
                            Text(viewModel.price)
                                .font(.heading4())
                                .fontWeight(.semibold)
                                .foregroundColor(colorPalette.primaryBlue)
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
            .onAppear { viewModel.setupPrice() }
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
        Image.Icons.CirclePlus.standard
            .renderingMode(.template)
            .font(.title)
            .foregroundColor(colorPalette.primaryBlue)
    }
    
    @ViewBuilder var stepper: some View {
        if viewModel.quantity == 0 {
            SnappyButton(container: viewModel.container, type: .primary, size: .medium, title: GeneralStrings.add.localized, largeTextTitle: nil, icon: Image.Icons.Plus.medium, isEnabled: .constant(viewModel.isDisabled($maximumReached) == false), isLoading: .constant(false), clearBackground: false, action: { viewModel.addValue(maxReached: $maximumReached) })
                .frame(maxWidth: 70)
        } else {
            HStack {
                if viewModel.showDeleteButton {
                    Button {
                        viewModel.removeValue()
                    } label: {
                        Image.Icons.TrashXmark.standard
                            .renderingMode(.template)
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(colorPalette.alertWarning)
                    }
                } else {
                    Button(action: { viewModel.removeValue() }) {
                        Image.Icons.CircleMinus.filled
                            .renderingMode(.template)
                            .font(.title)
                            .foregroundColor(colorPalette.primaryBlue)
                    }
                }
                
                Text("\(viewModel.quantity)")
                    .font(.snappyBody)
                    .foregroundColor(.snappyDark)
                
                Button(action: { viewModel.addValue(maxReached: $maximumReached) }) {
                    Image.Icons.CirclePlus.filled
                        .renderingMode(.template)
                        .font(.title)
                        .foregroundColor(viewModel.isDisabled($maximumReached) ? colorPalette.textGrey3 : colorPalette.primaryBlue)
                }
            }
        }
    }
    
    @ViewBuilder var radio: some View {
            Image(systemName: viewModel.isSelected ? "largecircle.fill.circle" : "circle")
                .font(.title)
                .foregroundColor(colorPalette.primaryBlue)
    }
    
    @ViewBuilder var checkbox: some View {
            Image(systemName: viewModel.isSelected ? "checkmark.circle.fill" : "checkmark.circle")
                .font(.title)
                .foregroundColor(viewModel.isDisabled($maximumReached) ? colorPalette.textGrey3 : colorPalette.primaryBlue)
    }
}

#if DEBUG
struct OptionsCardView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            OptionValueCardView(viewModel: OptionValueCardViewModel(container: .preview, currency: RetailStoreCurrency(currencyCode: "GBP", symbol: "&pound;", ratio: 0, symbolChar: "£", name: "Great British Pound"), optionValue: RetailStoreMenuItemOptionValue(id: 1, name: "Add Cheese", extraCost: 0, defaultSelection: 0, sizeExtraCost: nil), optionID: 123, optionsType: .checkbox, optionController: OptionController()), maximumReached: .constant(false))
                .previewDisplayName("Checkbox")
            
            OptionValueCardView(viewModel: OptionValueCardViewModel(container: .preview, currency: RetailStoreCurrency(currencyCode: "GBP", symbol: "&pound;", ratio: 0, symbolChar: "£", name: "Great British Pound"), optionValue: RetailStoreMenuItemOptionValue(id: 2, name: "Thin Base", extraCost: 1, defaultSelection: 0, sizeExtraCost: nil), optionID: 123, optionsType: .radio, optionController: OptionController()), maximumReached: .constant(false))
                .previewDisplayName("Radio")
            
            OptionValueCardView(viewModel: OptionValueCardViewModel(container: .preview, currency: RetailStoreCurrency(currencyCode: "GBP", symbol: "&pound;", ratio: 0, symbolChar: "£", name: "Great British Pound"), size: RetailStoreMenuItemSize(id: 123, name: "Medium", price: MenuItemSizePrice(price: 1.5)), optionController: OptionController()), maximumReached: .constant(false))
                .previewDisplayName("Size")
            
            OptionValueCardView(viewModel: OptionValueCardViewModel(container: .preview, currency: RetailStoreCurrency(currencyCode: "GBP", symbol: "&pound;", ratio: 0, symbolChar: "£", name: "Great British Pound"), optionValue: RetailStoreMenuItemOptionValue(id: 0, name: "Add Toppings", extraCost: 0, defaultSelection: 0, sizeExtraCost: nil), optionID: 123, optionsType: .manyMore, optionController: OptionController()), maximumReached: .constant(false))
                .previewDisplayName("ManyMore")
            
            OptionValueCardView(viewModel: OptionValueCardViewModel(container: .preview, currency: RetailStoreCurrency(currencyCode: "GBP", symbol: "&pound;", ratio: 0, symbolChar: "£", name: "Great British Pound"), optionValue: RetailStoreMenuItemOptionValue(id: 4, name: "Coke", extraCost: 0.25, defaultSelection: 0, sizeExtraCost: nil), optionID: 123, optionsType: .stepper, optionController: OptionController()), maximumReached: .constant(false))
                .previewDisplayName("Stepper")
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
#endif
