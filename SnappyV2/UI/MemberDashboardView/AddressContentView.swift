//
//  AddressContentView.swift
//  SnappyV2
//
//  Created by David Bage on 25/07/2022.
//

import SwiftUI

class AddressContentViewModel: ObservableObject {
    let container: DIContainer
    let address: Address
    
    @Published var isDefault: Bool
    
    var showIsDefaultLabel: Bool {
        address.isDefault == true // == true required as bool is optional here
    }
    
    init(container: DIContainer, address: Address) {
        self.container = container
        self.address = address
        
        self._isDefault = .init(initialValue: address.isDefault ?? false)
    }
}

struct AddressContentView: View {
    @Environment(\.colorScheme) var colorScheme
    
    private struct Constants {
        struct FirstLine {
            static let vSpacing: CGFloat = 8
            static let hSpacing: CGFloat = 8
        }
        
        struct IsDefaultLabel {
            static let iconWidth: CGFloat = 16
        }
        
        struct AddressLine1 {
            static let lineLimit: Int = 1
        }
    }
    
    @ObservedObject var viewModel: AddressContentViewModel
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.FirstLine.vSpacing) {
            HStack(spacing: Constants.FirstLine.hSpacing) {
                Text(viewModel.address.addressName ?? Strings.MemberDashboard.AddressSelectionView.unnamedAddress.localized)
                    .font(viewModel.isDefault ? .Body1.semiBold() : .Body1.regular())
                .foregroundColor(viewModel.isDefault ? colorPalette.primaryBlue : colorPalette.typefacePrimary)
                
                if viewModel.showIsDefaultLabel {
                    IsDefaultLabelView(container: viewModel.container)
                }
            }
            
            Text(viewModel.address.singleLineAddress())
                .font(.Body2.regular())
                .foregroundColor(colorPalette.typefacePrimary)
                .lineLimit(Constants.AddressLine1.lineLimit)
        }
    }
}

struct AddressContentView_Previews: PreviewProvider {
    static var previews: some View {
        AddressContentView(viewModel: .init(
            container: .preview,
            address: Address(
                id: 123,
                isDefault: true,
                addressName: "Home Address 1",
                firstName: "Alan",
                lastName: "Sugar",
                addressLine1: "10 Downing Street",
                addressLine2: "Hose Guards Parade",
                town: "London",
                postcode: "SW1A 2AA",
                county: "London",
                countryCode: "GB",
                type: .delivery,
                location: nil,
                email: nil,
                telephone: nil)))
    }
}
