//
//  CheckoutDetailsView.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 27/01/2022.
//

import SwiftUI

struct CheckoutDetailsView: View {

    // MARK: - Typealiases
    typealias AddDetailsStrings = Strings.CheckoutView.AddDetails
    
    // MARK: - Environment objects
    @Environment(\.colorScheme) private var colorScheme
    
    // MARK: - Constants
    struct Constants {
        struct Spacing {
            static let main: CGFloat = 24.5
            static let field: CGFloat = 15
        }
        
        struct General {
            static let vPadding: CGFloat = 30
        }
        
        struct ContactDetails {
            struct EmailFieldWarning {
                static let xOffset: CGFloat = -6
                static let yOffset: CGFloat = 4
            }
        }
        
        struct ExpiryPill {
            static let vPadding: CGFloat = 4
            static let hPadding: CGFloat = 8
            static let bottomPadding: CGFloat = 10
        }
        
        struct DeliverySlotInfo {
            static let borderCornerRadius: CGFloat = 8
            static let borderLineWidth: CGFloat = 1
        }
        
        struct DeliveryNote {
            static let spacing: CGFloat = 24
        }

        struct AllowedMarketingChannels {
            static let spacing: CGFloat = 24.5
        }
        
        struct AutoScrollTo {
            static let contactDetails = 1
            static let editAddress = 2
        }
    }
    
    // MARK: - View models
    @ObservedObject var viewModel: CheckoutRootViewModel
    @StateObject var marketingPreferencesViewModel: MarketingPreferencesViewModel
    @StateObject var editAddressViewModel: EditAddressViewModel
    
    // MARK: - Colors
    private var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    // MARK: - Main content
    var body: some View {
        ScrollView {
            ScrollViewReader { value in
                VStack(spacing: Constants.General.vPadding) {
                    yourDetails()
                        .id(Constants.AutoScrollTo.contactDetails)
                    
                    if viewModel.fulfilmentType?.type == .delivery {
                        EditAddressView(viewModel: editAddressViewModel, checkoutRootViewModel: viewModel)
                            .id(Constants.AutoScrollTo.editAddress)
                    }
                    
                    deliverySlotInfo
                    
                    if viewModel.showDeliveryNote{
                        addDeliveryNote
                    }
                    
                    if viewModel.showMarketingPrefs {
                        marketingPreferences
                    }
                    
                    if let allowedMarketingChannels = viewModel.allowedMarketingChannels {
                        whereDidYouHear(allowedMarketingChannels: allowedMarketingChannels)
                    }
                    
                    SnappyButton(
                        container: viewModel.container,
                        type: .primary,
                        size: .large,
                        title: Strings.CheckoutDetails.Submit.title.localized,
                        largeTextTitle: Strings.CheckoutDetails.Submit.titleLarge.localized,
                        icon: Image.Icons.Padlock.filled,
                        isLoading: $viewModel.isSubmitting,
                        action: {
                            Task {
                                await viewModel.goToPaymentTapped(
                                    setDelivery: {
                                        try await editAddressViewModel.setAddress(
                                            firstName: viewModel.firstname,
                                            lastName: viewModel.lastname,
                                            email: viewModel.email,
                                            phone: viewModel.phoneNumber)
                                    },

                                    updateMarketingPreferences: {
                                        await marketingPreferencesViewModel.updateMarketingPreferences()
                                    })
                            }
                        })
                }
                .padding() // Internal view padding
                .background(colorPalette.secondaryWhite)
                .standardCardFormat()
                .padding() // External view padding
                .onChange(of: viewModel.newErrorsExist) { contactDetailsErrorsExist in
                    withAnimation {
                        if contactDetailsErrorsExist {
                            value.scrollTo(Constants.AutoScrollTo.contactDetails)
                            viewModel.resetNewErrorsExist()
                        }
                    }
                }
                .onChange(of: editAddressViewModel.fieldErrorsPresent) { fieldErrorsPresent in
                    withAnimation {
                        if fieldErrorsPresent {
                            value.scrollTo(Constants.AutoScrollTo.editAddress)
                            editAddressViewModel.resetFieldErrorsPresent()
                        }
                    }
                }
            }
            
            NavigationLink("", isActive: $viewModel.fulfilmentTimeSlotSelectionPresented) {
                FulfilmentTimeSlotSelectionView(viewModel: .init(container: viewModel.container, state: .changeTimeSlot, timeslotSelectedAction: {
                    viewModel.fulfilmentTimeSlotSelectionPresented = false
                }))
            }
        }
    }
    
    // MARK: - Your details
    private func yourDetails() -> some View {
        VStack(alignment: .center, spacing: Constants.Spacing.main) {
            Text(AddDetailsStrings.title.localized)
                .font(.heading4())
                .foregroundColor(colorPalette.primaryBlue)
            
            VStack(spacing: Constants.Spacing.field) {
                // First name
                SnappyTextfield(container: viewModel.container, text: $viewModel.firstname, hasError: $viewModel.firstNameHasWarning, labelText: GeneralStrings.firstName.localized, largeTextLabelText: nil, autoCaps: .words)
                
                // Last name
                SnappyTextfield(container: viewModel.container, text: $viewModel.lastname, hasError: $viewModel.lastnameHasWarning, labelText: GeneralStrings.lastName.localized, largeTextLabelText: nil)
                
                // Email
                EmailField(
                    container: viewModel.container,
                    emailText: $viewModel.email,
                    hasError: $viewModel.emailHasWarning,
                    showInvalidEmailWarning: $viewModel.showEmailInvalidWarning)
                
                // Phone
                SnappyTextfield(container: viewModel.container, text: $viewModel.phoneNumber, hasError: $viewModel.phoneNumberHasWarning, labelText: AddDetailsStrings.phone.localized, largeTextLabelText: nil, keyboardType: .numberPad)
            }
        }
    }
    
    // MARK: - Delivery slot expiry pill
    private func expiryPill(text: String) -> some View {
        Text(text)
            .font(.Body2.semiBold())
            .padding(.vertical, Constants.ExpiryPill.vPadding)
            .padding(.horizontal, Constants.ExpiryPill.hPadding)
            .background(colorPalette.primaryRed)
            .foregroundColor(.white)
            .standardPillFormat()
            .padding(.bottom, Constants.ExpiryPill.bottomPadding)
    }
    
    // MARK: - Delivery slot
    private var deliverySlotInfo: some View {
        VStack(alignment: .leading) {
            if viewModel.deliverySlotExpired {
                expiryPill(text: Strings.CheckoutDetails.ChangeFulfilmentMethod.slotExpired.localized)
            } else if let timeUntilExpiry = viewModel.slotExpiringIn {
                expiryPill(text: Strings.CheckoutDetails.ChangeFulfilmentMethodCustom.slotExpiring.localizedFormat(timeUntilExpiry))
            }
            
            Text(viewModel.selectedSlot)
                .font(viewModel.deliverySlotExpired ? .Body1.semiBold() : .Body1.regular())
                .foregroundColor(viewModel.deliverySlotExpired ? colorPalette.primaryRed : colorPalette.typefacePrimary)
            
            SnappyButton(
                container: viewModel.container,
                type: viewModel.deliverySlotExpired ? .primary : .outline,
                size: .large,
                title: Strings.CheckoutDetails.ChangeFulfilmentMethodCustom.button.localizedFormat(viewModel.fulfilmentTypeString),
                largeTextTitle: nil,
                icon: Image.Icons.Clock.standard,
                action: {
                viewModel.fulfilmentTimeSlotSelectionPresented = true
            })
        }
        .padding()
        .background(viewModel.deliverySlotExpired ? colorPalette.alertWarning.withOpacity(.ten) : colorPalette.secondaryWhite)
        .standardCardFormat()
        .overlay(
            RoundedRectangle(cornerRadius: Constants.DeliverySlotInfo.borderCornerRadius)
                .stroke((viewModel.deliverySlotExpired || viewModel.slotIsEmpty) ? colorPalette.primaryRed : .clear, lineWidth: Constants.DeliverySlotInfo.borderLineWidth)
        )
    }
    
    // MARK: - Delivery note
    private var addDeliveryNote: some View {
        VStack(spacing: Constants.DeliveryNote.spacing) {
            Text(Strings.CheckoutDetails.DeliveryNote.title.localized)
                .font(.Body1.semiBold())
                .foregroundColor(colorPalette.typefacePrimary)
            
            SnappyMultilineTextField(
                container: viewModel.container,
                placeholder: Strings.CheckoutDetails.DeliveryNote.label.localized,
                text: $viewModel.deliveryNote) {}
        }
    }

    // MARK: - Marketing preferences
    private var marketingPreferences: some View {
    #warning("Setting isCheckout returns only the preferences that are marked as 'out' unless all are marked as 'in'. To consider: do we really only want to present those marked as 'out' at this stage? NB: Web shows all")
        return MarketingPreferencesView(viewModel: marketingPreferencesViewModel)
    }

    // MARK: - Where did you hear about us?
    @ViewBuilder private func whereDidYouHear(allowedMarketingChannels: [AllowedMarketingChannel]) -> some View {
        VStack(spacing: Constants.AllowedMarketingChannels.spacing) {
            Text(Strings.CheckoutDetails.WhereDidYouHear.title.localized)
                .font(.Body1.semiBold())
                .foregroundColor(colorPalette.typefacePrimary)
            
            Menu {
                ForEach(allowedMarketingChannels, id: \.self) { channel in
                    Button {
                        viewModel.channelSelected(channel)
                    } label: {
                        Text(channel.name)
                    }
                }
            } label: {
                SnappyTextfield(
                    container: viewModel.container,
                    text: $viewModel.allowedMarketingChannelText,
                    hasError: .constant(false),
                    labelText: Strings.CheckoutDetails.WhereDidYouHear.choose.localized,
                    largeTextLabelText: nil,
                    fieldType: .label)
            }
        }
    }
}

#if DEBUG
struct CheckoutDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = CheckoutRootViewModel(container: .preview, keepCheckoutFlowAlive: .constant(true))
        CheckoutDetailsView(viewModel: viewModel, marketingPreferencesViewModel: .init(container: .preview, viewContext: .checkout, hideAcceptedMarketingOptions: true), editAddressViewModel: .init(container: .preview, addressType: .delivery))
    }
}
#endif
