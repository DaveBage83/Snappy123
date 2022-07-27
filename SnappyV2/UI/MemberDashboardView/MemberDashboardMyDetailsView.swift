//
//  MemberDashboardAddressView.swift
//  SnappyV2
//
//  Created by David Bage on 15/04/2022.
//

import SwiftUI

struct MemberDashboardMyDetailsView: View {
    @Environment(\.colorScheme) var colorScheme
    
    typealias MyDetailsStrings = Strings.MemberDashboard.MyDetails
    
    struct Constants {
        struct MainStack {
            static let vSpacing: CGFloat = 32
            static let topPadding: CGFloat = 32
        }
        
        struct InnerStacks {
            static let vSpacing: CGFloat = 16
        }
    }
    
    @StateObject var viewModel: MemberDashboardMyDetailsViewModel
    @ObservedObject var memberDashboardViewModel: MemberDashboardViewModel
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    let didSetError: (Swift.Error) -> ()
    let setIsLoading: (Bool) -> ()
    
    var body: some View {
        
        ScrollView {
            VStack(spacing: Constants.MainStack.vSpacing) {
                savedCardsView
                deliveryAddressSectionView
                billingAddressSectionView
            }
            .padding(.top, Constants.MainStack.topPadding)
            .onAppear {
                memberDashboardViewModel.onAppearAddressViewSendEvent()
            }
        }
        .sheet(isPresented: $viewModel.showAddDeliveryAddressView) {
            AddressSelectionView(
                viewModel: .init(
                    container: viewModel.container,
                    addressSelectionType: viewModel.addressType,
                    addresses: [],
                    showAddressSelectionView: .constant(true),
                    firstName: "",
                    lastName: "",
                    email: "",
                    phone: "",
                    starterPostcode: "",
                    isInCheckout: false),
                didSelectAddress: { _ in },
                addressSaved: {
                    viewModel.dismissAddDeliveryAddressView()
                })
        }
        .sheet(isPresented: $viewModel.showEditAddressView) {
            NavigationView {
                ManualInputAddressView(
                    viewModel: .init(
                        container: viewModel.container,
                        address: viewModel.addressToEdit,
                        addressType: viewModel.addressType, viewState: .editAddress),
                    addressSaved: {
                        viewModel.dismissEditAddressView()
                    })
            }
        }
    }

    private var savedCardsView: some View {
        
        VStack(alignment: .leading, spacing: Constants.InnerStacks.vSpacing) {
            header(MyDetailsStrings.savedCardsTitle.localized)
            
            if viewModel.noCards {
                noAddressWarning(MyDetailsStrings.noSavedCards.localized)
            } else {
                #warning("Card functionality not yet ready due to no designs.")
                VStack(spacing: Constants.InnerStacks.vSpacing) {
                    ForEach(viewModel.savedCards, id: \.id) { card in
                        EditableCardContainer(
                            container: viewModel.container,
                            deleteAction: { print("Delete") }, // To be replaced with actual functionality
                            editAction: { print("Edit") }, // To be replaced with actual functionality
                            content: {
                                SavedPaymentCardCard(viewModel: .init(container: viewModel.container, card: card))
                            })
                    }
                }
            }
            SnappyButton(
                container: viewModel.container,
                type: .outline,
                size: .large,
                title: MyDetailsStrings.addNewCardButton.localized,
                largeTextTitle: nil,
                icon: nil,
                action: {
                    #warning("No design yet for this view.")
                    print("Go to new card view")
                })
        }
    }
    
    private var deliveryAddressSectionView: some View {
        VStack(alignment: .leading, spacing: Constants.InnerStacks.vSpacing) {
            header(Strings.PostCodeSearch.deliveryMainTitle.localized)
            
            if viewModel.noDeliveryAddresses {
                noAddressWarning(MyDetailsStrings.noDeliveryAddresses.localized)
                
            } else {
                VStack(spacing: Constants.InnerStacks.vSpacing) {
                    ForEach(viewModel.deliveryAddresses) { address in
                        EditableCardContainer(
                            container: viewModel.container,
                            deleteAction: {
                                Task {
                                    await viewModel.deleteAddressTapped(address, didSetError: didSetError, setLoading: setIsLoading)
                                }
                            },
                            editAction: {
                                viewModel.editAddressTapped(addressType: .delivery, address: address)
                            }) {
                                AddressContentView(viewModel: .init(container: viewModel.container, address: address))
                            }
                    }
                }
            }
            
            SnappyButton(
                container: viewModel.container,
                type: .outline,
                size: .large,
                title: MyDetailsStrings.addDeliveryAddressButtonTitle.localized,
                largeTextTitle: nil,
                icon: nil,
                action: {
                    viewModel.addAddressTapped(addressType: .delivery)
                })
        }
    }
    
    var billingAddressSectionView: some View {
        VStack(alignment: .leading, spacing: Constants.InnerStacks.vSpacing) {
            header(Strings.PostCodeSearch.billingMainTitle.localized)
            
            if viewModel.noBillingAddresses {
                noAddressWarning(MyDetailsStrings.noBillingAddresses.localized)
            } else {
                VStack(spacing: Constants.InnerStacks.vSpacing) {
                    ForEach(viewModel.billingAddresses) { address in
                        EditableCardContainer(
                            container: viewModel.container,
                            deleteAction: {
                                Task {
                                    await viewModel.deleteAddressTapped(address, didSetError: didSetError, setLoading: setIsLoading)
                                }
                            },
                            editAction: {
                                viewModel.editAddressTapped(addressType: .billing, address: address)
                            },
                            content: {
                                AddressContentView(viewModel: .init(container: viewModel.container, address: address))
                            })
                    }
                }
            }
            
            SnappyButton(
                container: viewModel.container,
                type: .outline,
                size: .large,
                title: MyDetailsStrings.addBillingAddressButtonTitle.localized,
                largeTextTitle: nil,
                icon: nil,
                action: {
                    viewModel.addAddressTapped(addressType: .billing)
                })
        }
    }
    
    func header(_ title: String) -> some View {
        Text(title)
            .font(.heading4())
            .foregroundColor(colorPalette.primaryBlue)
    }
    
    func noAddressWarning(_ text: String) -> some View {
        Text(text)
            .font(.Body1.regular())
            .foregroundColor(colorPalette.typefacePrimary)
            .padding(.vertical)
    }
}

#if DEBUG
struct MemberDashboardAddressView_Previews: PreviewProvider {
    static var previews: some View {
        MemberDashboardMyDetailsView(viewModel: .init(container: .preview), memberDashboardViewModel: .init(container: .preview), didSetError: { _ in }, setIsLoading: { _ in })
    }
}
#endif
