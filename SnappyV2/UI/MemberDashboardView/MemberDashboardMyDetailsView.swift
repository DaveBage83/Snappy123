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
                Task { await viewModel.loadSavedCards() }
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
        .sheet(isPresented: $viewModel.showAddCardView) {
            PaymentCardEntryView(viewModel: .init(container: viewModel.container), editAddressViewModel: .init(container: viewModel.container, addressType: .card))
                .onDisappear {
                    Task { await viewModel.loadSavedCards() }
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
                    ForEach(viewModel.savedCardDetails, id: \.id) { card in
                        EditableCardContainer(hasWarning: .constant(false), editDisabled: .constant(false), deleteDisabled: .constant(false), content: {
                            SavedPaymentCardCard(viewModel: .init(container: viewModel.container, card: card))
                        }, viewModel: .init(
                            container: viewModel.container,
                            editAction: nil,
                            deleteAction: { Task { await viewModel.deleteCardTapped(id: card.id) } }
                        ))
                        .redacted(reason: viewModel.savedCardsLoading ? .placeholder : [])
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
                action: { viewModel.addNewCardButtonTapped() }
            )
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
                            hasWarning: .constant(false), editDisabled: .constant(false), deleteDisabled: .constant(false), content: {
                                AddressContentView(viewModel: .init(container: viewModel.container, address: address))
                            },
                            viewModel: .init(
                                container: viewModel.container,
                                editAction: {
                                    viewModel.editAddressTapped(addressType: .delivery, address: address)
                                },
                                deleteAction: {
                                    Task {
                                        await viewModel.deleteAddressTapped(address, didSetError: didSetError, setLoading: setIsLoading)
                                    }
                                }))
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
                            hasWarning: .constant(false), editDisabled: .constant(false), deleteDisabled: .constant(false), content: {
                                AddressContentView(viewModel: .init(container: viewModel.container, address: address))
                            },
                            viewModel: .init(
                                container: viewModel.container,
                                editAction: {
                                    viewModel.editAddressTapped(addressType: .billing, address: address)
                                },
                                deleteAction: {
                                    Task {
                                        await viewModel.deleteAddressTapped(address, didSetError: didSetError, setLoading: setIsLoading)
                                    }
                                }))
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
