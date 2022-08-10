//
//  ProductAddButton.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 18/01/2022.
//

import SwiftUI

#warning("To be deprecated and replaced with ProductIncrementButton")
struct ProductAddButton: View {
    @StateObject var viewModel: ProductAddButtonViewModel
    
    var body: some View {
        if viewModel.isUpdatingQuantity {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .gray))
        } else {
            if viewModel.quickAddIsEnabled {
                quickAddButton
            } else {
                standardAddButton
            }
        }
        
        // MARK: NavigationLinks
        NavigationLink(destination: ProductOptionsView(viewModel: .init(container: viewModel.container, item: viewModel.item)), isActive: $viewModel.showOptions) { EmptyView() }
    }
    
    @ViewBuilder var quickAddButton: some View {
        if viewModel.showStandardButton {
            standardAddButton
        } else {
            HStack {
                Button(action: { viewModel.removeItem() }) {
                    Image.Actions.Remove.circleFilled
                        .foregroundColor(.snappyBlue)
                }
                
                Text("\(viewModel.basketQuantity)")
                    .font(.snappyBody)
                
                Button(action: { viewModel.addItem() }) {
                    Image.Actions.Add.circleFilled
                        .foregroundColor(viewModel.quantityLimitReached ? .snappyGrey : .snappyBlue)
                }
                .disabled(viewModel.quantityLimitReached)
            }
        }
    }
    
    @ViewBuilder var standardAddButton: some View {
        if viewModel.itemHasOptionsOrSizes {
            Button(action: { viewModel.addItemWithOptionsTapped() }) {
                Text(GeneralStrings.add.localized)
            }
            .buttonStyle(SnappyPrimaryButtonStyle(isEnabled: !viewModel.quantityLimitReached))
            .disabled(viewModel.quantityLimitReached)
        } else {
            Button(action: { viewModel.addItem() }) {
                Text(GeneralStrings.add.localized)
            }
            .buttonStyle(SnappyPrimaryButtonStyle(isEnabled: !viewModel.quantityLimitReached))
            .disabled(viewModel.quantityLimitReached)
        }
    }
}

#if DEBUG
struct ProductAddButton_Previews: PreviewProvider {
    static var previews: some View {
        ProductAddButton(viewModel: .init(container: .preview, menuItem: RetailStoreMenuItem(id: 123, name: "ItemName", eposCode: nil, outOfStock: false, ageRestriction: 0, description: nil, quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: RetailStoreMenuItemPrice(price: 10, fromPrice: 10, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil), images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: ItemCaptions(portionSize: "495 Kcal per 100g"), mainCategory: MenuItemCategory(id: 0, name: ""), itemDetails: nil)))
            .previewCases()
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
#endif
