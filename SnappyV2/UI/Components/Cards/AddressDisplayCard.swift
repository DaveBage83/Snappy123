//
//  AddressCard.swift
//  SnappyV2
//
//  Created by David Bage on 08/07/2022.
//

import SwiftUI

class AddressDisplayCardViewModel: ObservableObject {
    
    @Published var address: Address
    let container: DIContainer
    
    init(container: DIContainer, address: Address) {
        self.container = container
        self.address = address
    }
}

struct AddressDisplayCard: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: AddressDisplayCardViewModel
    
    @Binding var isSelected: Bool
    
    struct Constants {
        static let spacing: CGFloat = 8
        static let addressLineLimit = 1
        static let height: CGFloat = 80
        static let cornerRadius: CGFloat = 8
        static let borderLineWidth: CGFloat = 1
    }
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.spacing) {
            HStack(spacing: Constants.spacing) {
                Text(viewModel.address.addressName ?? Strings.CheckoutDetails.AddressDisplayCard.unnamed.localized)
                    .font(.Body1.semiBold())
                    .foregroundColor(colorPalette.primaryBlue)
                
                if viewModel.address.isDefault == true { // == isTrue used to avoid unwrapping
                    defaultView
                }
            }
            
            Text(viewModel.address.singleLineAddress())
                .font(.Body2.regular())
                .foregroundColor(colorPalette.typefacePrimary)
                .lineLimit(Constants.addressLineLimit)
        }
        .padding()
        .frame(height: Constants.height)
        .frame(maxWidth: .infinity)
        .background(colorPalette.secondaryWhite)
        .standardCardFormat()
        .overlay(
            RoundedRectangle(cornerRadius: Constants.cornerRadius)
                .stroke(isSelected ? colorPalette.primaryBlue : .clear, lineWidth: Constants.borderLineWidth)
        )
    }
    
    private var defaultView: some View {
        Text(Strings.CheckoutDetails.AddressDisplayCard.defaultAddress.localized)
            .font(.Caption1.semiBold())
            .foregroundColor(colorPalette.primaryBlue)
    }
}

#if DEBUG
struct AddressCard_Previews: PreviewProvider {
    static var previews: some View {
        AddressDisplayCard(viewModel: .init(container: .preview, address:
            Address(
                id: 123,
                isDefault: true,
                addressName: "Home",
                firstName: "Dave",
                lastName: "Bage",
                addressLine1: "1 Address Line 1",
                addressLine2: "1 Address Line 2",
                town: "Toonville",
                postcode: "TN3 4DG",
                county: "Surrey",
                countryCode: "UK",
                type: .delivery,
                location: nil,
                email: "tn@gmail.com",
                telephone: nil)),
                           isSelected: .constant(true))
    }
}
#endif
