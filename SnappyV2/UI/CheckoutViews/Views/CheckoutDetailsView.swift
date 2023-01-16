//
//  CheckoutDetailsView.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 27/01/2022.
//

import SwiftUI
import Combine

struct CheckoutDetailsView: View {

    // MARK: - Typealiases
    typealias RetailMembershipStrings = Strings.CheckoutView.RetailMembership
    typealias AddDetailsStrings = Strings.CheckoutView.AddDetails
    
    // MARK: - Environment objects
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.tabViewHeight) var tabViewHeight
    
    // MARK: - Constants
    struct Constants {
        struct Spacing {
            static let main: CGFloat = 24.5
            static let field: CGFloat = 15
        }
        
        struct General {
            static let vPadding: CGFloat = 30
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
                    
                    if viewModel.showRetailMembership {
                        retailMembership
                    }
                    
                    yourDetails()
                    
                    if viewModel.fulfilmentType?.type == .delivery {
                        EditAddressView(viewModel: editAddressViewModel, setContactDetailsHandler: viewModel.setContactDetails, errorHandler: viewModel.setError(_:))
                    }
                    
                    deliverySlotInfo
                        .id(CheckoutRootViewModel.DetailsFormElements.timeSlot)
                    
                    addDeliveryNote
                    
                    if viewModel.showMarketingPrefs {
                        marketingPreferences
                    }
                    
                    if let allowedMarketingChannels = viewModel.allowedMarketingChannels {
                        whereDidYouHear(allowedMarketingChannels: allowedMarketingChannels)
                            .id(CheckoutRootViewModel.DetailsFormElements.whereDidYouHear)
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
                                    editAddressFieldErrors: editAddressViewModel.fieldErrors(), setDelivery: {
                                        try await editAddressViewModel.setAddress(
                                            firstName: viewModel.firstname,
                                            lastName: viewModel.lastname,
                                            email: viewModel.email,
                                            phone: viewModel.phoneNumber)
                                    },

                                    updateMarketingPreferences: {
                                        await marketingPreferencesViewModel.updateMarketingPreferences(channelId: viewModel.selectedChannel?.id)
                                    })
                            }
                        })
                }
                .padding() // Internal view padding
                .padding(.bottom, tabViewHeight)
                .background(colorPalette.secondaryWhite)
                .standardCardFormat(container: viewModel.container)
                .padding() // External view padding
                .onChange(of: viewModel.newErrorsExist) { contactDetailsErrorsExist in
                    withAnimation {
                        if contactDetailsErrorsExist, let firstError = viewModel.firstError {
                            value.scrollTo(firstError, anchor: .bottom)
                            viewModel.resetNewErrorsExist()
                        }
                    }
                }
            }
            
            NavigationLink("", isActive: $viewModel.fulfilmentTimeSlotSelectionPresented) {
                FulfilmentTimeSlotSelectionView(viewModel: .init(container: viewModel.container, isInCheckout: true, state: .changeTimeSlot, timeslotSelectedAction: {
                    viewModel.fulfilmentTimeSlotSelectionPresented = false
                }))
            }
        }
    }
    
    // MARK: - Retail Membership
    @ViewBuilder private var retailMembership: some View {
        VStack(alignment: .center, spacing: Constants.Spacing.main) {
            Text(RetailMembershipStrings.title.localized)
                .font(.heading4())
                .foregroundColor(colorPalette.primaryBlue)
            
            Text(viewModel.retailMembershipIdInstructions)
                .font(.Body2.regular())
                .foregroundColor(colorPalette.typefacePrimary)
            
            SnappyTextfield(
                container: viewModel.container,
                text: $viewModel.retailMembershipId,
                hasError: $viewModel.retailMembershipIdHasWarning,
                labelText: viewModel.retailMembershipIdName,
                largeTextLabelText: nil
            )
                .id(CheckoutRootViewModel.DetailsFormElements.retailMembershipId)
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
                    .id(CheckoutRootViewModel.DetailsFormElements.firstName)
                
                // Last name
                SnappyTextfield(container: viewModel.container, text: $viewModel.lastname, hasError: $viewModel.lastnameHasWarning, labelText: GeneralStrings.lastName.localized, largeTextLabelText: nil)
                    .id(CheckoutRootViewModel.DetailsFormElements.lastName)
                // Email
                ValidatableField(
                    container: viewModel.container,
                    labelText: GeneralStrings.Login.emailAddress.localized,
                    largeLabelText: nil,
                    warningText: Strings.CheckoutDetails.ContactDetails.emailInvalid.localized,
                    keyboardType: .emailAddress,
                    fieldText: $viewModel.email,
                    hasError: $viewModel.emailHasWarning,
                    showInvalidFieldWarning: $viewModel.showEmailInvalidWarning)
                .id(CheckoutRootViewModel.DetailsFormElements.email)
                
                // Phone
                SnappyTextfield(container: viewModel.container, text: $viewModel.phoneNumber, hasError: $viewModel.phoneNumberHasWarning, labelText: AddDetailsStrings.phone.localized, largeTextLabelText: nil, keyboardType: .phonePad)
                    .onReceive(Just(viewModel.phoneNumber)) { newValue in
                        viewModel.filterPhoneNumber(newValue: newValue)
                    }
                    .id(CheckoutRootViewModel.DetailsFormElements.phone)
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
        .standardCardFormat(container: viewModel.container)
        .overlay(
            RoundedRectangle(cornerRadius: Constants.DeliverySlotInfo.borderCornerRadius)
                .stroke((viewModel.deliverySlotExpired || viewModel.timeSlotHasWarning) ? colorPalette.primaryRed : .clear, lineWidth: Constants.DeliverySlotInfo.borderLineWidth)
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
                text: $viewModel.deliveryNote,
                minHeight: 100
            ) {}
        }
    }

    // MARK: - Marketing preferences
    private var marketingPreferences: some View {
    #warning("Setting isCheckout returns only the preferences that are marked as 'out' unless all are marked as 'in'. To consider: do we really only want to present those marked as 'out' at this stage? NB: Web shows all")
        return MarketingPreferencesView(viewModel: marketingPreferencesViewModel)
    }

    // MARK: - Where did you hear about us?
    @ViewBuilder private func whereDidYouHear(allowedMarketingChannels: [AllowedMarketingChannel]) -> some View {
        if !viewModel.hideSelectedChannel {
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
                        hasError: $viewModel.selectedChannelHasWarning,
                        labelText: Strings.CheckoutDetails.WhereDidYouHear.choose.localized,
                        largeTextLabelText: nil,
                        fieldType: .label)
                }
            }
        }
    }
    
}

#if DEBUG
struct CheckoutDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = CheckoutRootViewModel(container: .preview)
        CheckoutDetailsView(viewModel: viewModel, marketingPreferencesViewModel: .init(container: .preview, viewContext: .checkout, hideAcceptedMarketingOptions: false), editAddressViewModel: .init(container: .preview, addressType: .delivery, includeSavedAddressButton: true))
    }
}
#endif
