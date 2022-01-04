//
//  BasketListItemView.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 03/01/2022.
//

import SwiftUI
import Combine

class BasketListItemViewModel: ObservableObject {
    
}

struct BasketListItemView: View {
    @State var item: BasketItem
    @State var quantity: String = ""
    var changeQuantity: (_ itemId: Int, _ quantity: Int, _ basketLineId: Int) -> Void
    
    init(item: BasketItem, changeQuantity: @escaping (Int, Int, Int) -> Void) {
        self.item = item
        self.changeQuantity = changeQuantity
    }
    
    var body: some View {
        VStack {
            HStack {
                if let image = item.menuItem.images?.first?["xhdpi_2x"]?.absoluteString {
                    RemoteImage(url: image)
                        .scaledToFit()
                } else {
                    Image("whiskey")
                        .resizable()
                        .scaledToFit()
                }
                
                Text(item.menuItem.price.price.toCurrencyString() + " - \(item.menuItem.name)")
                    .font(.snappyCaption)
                
                Spacer()
                
                #warning("Sort out iOS 14 versions of onSubmit")
                if #available(iOS 15.0, *) {
                    TextField("\(item.quantity)", text: $quantity)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.snappyBody)
                        .scaledToFit()
                        .keyboardType(.numbersAndPunctuation)
                        .submitLabel(.done)
                        // adapted from: https://stackoverflow.com/questions/58733003/swiftui-how-to-create-textfield-that-only-accepts-numbers
                        .onReceive(Just(quantity)) { newValue in
                            let filtered = newValue.filter { $0.isNumber }
                            
                            if quantity != filtered {
                                quantity = filtered
                            }
                        }
                        .onSubmit {
                            #warning("Should be moved to a view model")
                            changeQuantity(item.menuItem.id ,Int(quantity) ?? 0, item.basketLineId)
                            quantity = ""
                        }
                } else {
                    TextField("\(item.quantity)", text: $quantity)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.snappyBody)
                        .scaledToFit()
                        .keyboardType(.decimalPad)
                    // adapted from: https://stackoverflow.com/questions/58733003/swiftui-how-to-create-textfield-that-only-accepts-numbers
                        .onReceive(Just(quantity)) { newValue in
                            let filtered = newValue.filter { $0.isNumber }
                            
                            if quantity != filtered {
                                quantity = filtered
                            }
                        }
                }
                
                Text(item.totalPrice.toCurrencyString())
                    .font(.snappyBody)
            }
            .background(
                Rectangle().fill(Color.white)
                    .padding([.top, .horizontal], -3)
            )
            .frame(height: 40)
        }
        .background(
            RoundedRectangle(cornerRadius: 4)
                .padding([.top, .horizontal], -3)
        )
    }
}

struct BasketListItemView_Previews: PreviewProvider {
    static var previews: some View {
        BasketListItemView(
            item: BasketItem(basketLineId: 123, menuItem: RetailStoreMenuItem(id: 12, name: "Some Product Name", eposCode: nil, outOfStock: false, ageRestriction: 0, description: nil, quickAdd: true, price: RetailStoreMenuItemPrice(price: 10, fromPrice: 9, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil), images: nil, menuItemSizes: nil, menuItemOptions: nil), totalPrice: 10, totalPriceBeforeDiscounts: 9, price: 9, pricePaid: 4, quantity: 1, size: nil, selectedOptions: nil)) { _, _, _ in }
            .previewLayout(.sizeThatFits)
            .padding()
            .previewCases()
    }
}
