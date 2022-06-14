//
//  FulfilmentTypeSelectionToggle.swift
//  SnappyV2
//
//  Created by David Bage on 30/05/2022.
//

import SwiftUI

struct FulfilmentTypeSelectionToggle: View {
    // MARK: - Environment objects
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.sizeCategory) var sizeCategory: ContentSizeCategory
    @ScaledMetric var scale: CGFloat = 1
    @Environment(\.horizontalSizeClass) var sizeClass
    
    // MARK: - Constants
    private struct Constants {
        struct Container {
            static let padding: CGFloat = 3
            static let height: CGFloat = 38
            static let cornerRadius: CGFloat = 8.91
        }
        
        struct Buttons {
            static let width: CGFloat = 16
            static let padding: CGFloat = 8
            static let cornerRadius: CGFloat = 8
        }
    }
    
    // MARK: - View model
    @ObservedObject var viewModel: StoresViewModel
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    private var minimalLayout: Bool {
        sizeCategory.size < 9
    }
    
    // MARK: - Main body
    var body: some View {
        HStack(spacing: 0) {
            toggleButton(.delivery)
            
            toggleButton(.collection)
        }
        .padding(Constants.Container.padding)
        .frame(maxWidth: .infinity, maxHeight: sizeClass == .compact ? Constants.Container.height : .infinity)
        .background(colorPalette.secondaryDark.withOpacity(.ten))
        .cornerRadius(Constants.Container.cornerRadius)
    }
    
    // MARK: - Toggle button
    private func toggleButton(_ type: RetailStoreOrderMethodType) -> some View {
        Button {
            viewModel.fulfilmentMethodButtonTapped(type == .delivery ? .delivery : .collection)
        } label: {
            HStack {
                (type == .delivery ? Image.Icons.Truck.standard : Image.Icons.BagShopping.standard)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: Constants.Buttons.width * scale)
                    .foregroundColor(viewModel.selectedOrderMethod == type ? .white : colorPalette.typefacePrimary.withOpacity(.eighty))
                
                if minimalLayout {
                    Text(type == .delivery ? GeneralStrings.delivery.localized : GeneralStrings.collection.localized)
                        .font(.Body2.semiBold())
                        .foregroundColor(viewModel.selectedOrderMethod == type ? .white : colorPalette.typefacePrimary.withOpacity(.eighty))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding([.leading, .vertical], Constants.Buttons.padding)
            .background(viewModel.selectedOrderMethod == type ? colorPalette.primaryBlue : .clear)
            .cornerRadius(Constants.Buttons.cornerRadius)
        }
    }
}

#if DEBUG
struct FulfilmentTypeSelectionToggle_Previews: PreviewProvider {
    static var previews: some View {
        FulfilmentTypeSelectionToggle(viewModel: .init(container: .preview))
    }
}
#endif
