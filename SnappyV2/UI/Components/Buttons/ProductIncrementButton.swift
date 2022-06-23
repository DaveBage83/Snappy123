//
//  ProductIncrementButton.swift
//  SnappyV2
//
//  Created by David Bage on 08/05/2022.
//

import SwiftUI

struct ProductIncrementButton: View {
    struct Constants {
        static let stackSpacing: CGFloat = 8
        static let quickAddWidth: CGFloat = 78
    }
    
    @Environment(\.colorScheme) var colorScheme
    @ScaledMetric var scale: CGFloat = 1 // Used to scale icon for accessibility options
    @ObservedObject var viewModel: ProductAddButtonViewModel
    
    enum Size {
        case standard
        case large
        
        var height: CGFloat {
            switch self {
            case .standard:
                return 16
            case .large:
                return 24
            }
        }
        
        var font: Font {
            switch self {
            case .standard:
                return .heading4()
            case .large:
                return .heading3()
            }
        }
    }
    
    enum ButtonType {
        case increment
        case decrement
        
        var icon: Image {
            switch self {
            case .increment:
                return Image.Icons.CirclePlus.filled
            case .decrement:
                return Image.Icons.CircleMinus.filled
            }
        }
    }
    
    let size: Size
    
    var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    var body: some View {
        if viewModel.quickAddIsEnabled, viewModel.basketQuantity == 0 {
            quickAddButton
                .frame(width: Constants.quickAddWidth * scale)
        } else {
            HStack(spacing: Constants.stackSpacing) {
                
                if viewModel.showDeleteButton {
                    Button {
                        viewModel.removeItem()
                    } label: {
                        Image.Icons.TrashXmark.standard
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: size.height)
                            .foregroundColor(colorPalette.alertWarning)
                    }
                } else {
                    incrementDecrementButton(.decrement)
                }
                
                Text("\(viewModel.basketQuantity)")
                    .font(size.font)
                    .foregroundColor(colorPalette.typefacePrimary)
                    .opacity(viewModel.isUpdatingQuantity ? 0 : 1)
                    .withLoadingView(isLoading: $viewModel.isUpdatingQuantity, color: colorPalette.textGrey1)
                incrementDecrementButton(.increment)
            }
        }
    }
    
    func incrementDecrementButton(_ type: ButtonType) -> some View {
        Button {
            switch type {
            case .increment:
                viewModel.addItem()
            case .decrement:
                viewModel.removeItem()
            }
        } label: {
            type.icon
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(type == .increment && viewModel.quantityLimitReached ? colorPalette.textGrey3 : colorPalette.primaryBlue)
                .frame(width: size.height * scale)
            
        }
    }
    
    var quickAddButton: some View {
        SnappyButton(
            container: viewModel.container,
            type: .primary,
            size: .medium,
            title: GeneralStrings.add.localized,
            largeTextTitle: nil,
            icon: Image.Icons.Plus.medium,
            isLoading: .constant(viewModel.isUpdatingQuantity)) {
                viewModel.addItem()
            }
    }
}

#if DEBUG
struct ProductIncrementButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ProductIncrementButton(viewModel: .init(container: .preview, menuItem: RetailStoreMenuItem(id: 123, name: "ItemName", eposCode: nil, outOfStock: false, ageRestriction: 0, description: nil, quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: RetailStoreMenuItemPrice(price: 10, fromPrice: 10, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: ItemCaptions(portionSize: "495 Kcal per 100g"), mainCategory: MenuItemCategory(id: 0, name: ""))), size: .standard)
            
            ProductIncrementButton(viewModel: .init(container: .preview, menuItem: RetailStoreMenuItem(id: 123, name: "ItemName", eposCode: nil, outOfStock: false, ageRestriction: 0, description: nil, quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: RetailStoreMenuItemPrice(price: 10, fromPrice: 10, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: ItemCaptions(portionSize: "495 Kcal per 100g"), mainCategory: MenuItemCategory(id: 0, name: ""))), size: .large)
            
            ProductIncrementButton(viewModel: .init(container: .preview, menuItem: RetailStoreMenuItem(id: 123, name: "ItemName", eposCode: nil, outOfStock: false, ageRestriction: 0, description: nil, quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: RetailStoreMenuItemPrice(price: 10, fromPrice: 10, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: ItemCaptions(portionSize: "495 Kcal per 100g"), mainCategory: MenuItemCategory(id: 0, name: ""))), size: .standard)
                .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
        }
        
    }
}
#endif
