//
//  MemberDashboardAddressView.swift
//  SnappyV2
//
//  Created by David Bage on 15/04/2022.
//

import SwiftUI

struct MemberDashboardAddressView: View {
    struct Constants {
        struct MainStack {
            static let vSpacing: CGFloat = 20
        }
        
        struct InnerStacks {
            static let vSpacing: CGFloat = 10
        }
    }
    
    @ObservedObject var viewModel: MemberDashboardViewModel
    
    var body: some View {
        
        ScrollView {
            VStack(spacing: Constants.MainStack.vSpacing) {
                deliveryAddressSectionView
                billingAddressSectionView
            }
            .padding()
        }
    }
    
    var deliveryAddressSectionView: some View {
        VStack(alignment: .leading, spacing: Constants.InnerStacks.vSpacing) {
            header(Strings.PostCodeSearch.deliveryMainTitle.localized)
            
            if viewModel.noDeliveryAddresses {
                noAddressWarning(Strings.PostCodeSearch.noDeliveryAddress.localized)
                    
            } else {
                ForEach(viewModel.deliveryAddresses) { address in
                    AddressSearchContainer(viewModel: .init(container: viewModel.container, address: address, type: .delivery)) { returnedAddress in
                        guard let returnedAddress = returnedAddress else { return }
                        viewModel.updateAddress(address: returnedAddress)
                    }
                }
            }
            
            AddressSearchContainer(viewModel: .init(container: viewModel.container, type: .delivery, initialSearchActionType: .button)) { address in
                if let address = address {
                    viewModel.addAddress(address: address)
                }
            }
        }
    }
    
    var billingAddressSectionView: some View {
        VStack(alignment: .leading, spacing: Constants.InnerStacks.vSpacing) {
            header(Strings.PostCodeSearch.billingMainTitle.localized)
            
            if viewModel.noBillingAddresses {
                noAddressWarning(Strings.PostCodeSearch.noBillingAddress.localized)
            } else {
                ForEach(viewModel.billingAddresses) { address in
                    AddressSearchContainer(viewModel: .init(container: viewModel.container, address: address, type: address.type)) {_ in }
                }
            }
            
            AddressSearchContainer(viewModel: .init(container: viewModel.container, type: .billing, initialSearchActionType: .button)) { address
                in
                if let address = address {
                    viewModel.addAddress(address: address)
                }
            }
        }
    }
    
    func header(_ title: String) -> some View {
        Text(title)
            .font(.snappyTitle3)
            .foregroundColor(.snappyDark)
            .fontWeight(.semibold)
    }
    
    func noAddressWarning(_ text: String) -> some View {
        Text(text)
            .font(.snappyBody)
            .foregroundColor(.snappyDark)
            .padding(.vertical)
    }
}

struct MemberDashboardAddressView_Previews: PreviewProvider {
    static var previews: some View {
        MemberDashboardAddressView(viewModel: .init(container: .preview))
    }
}
