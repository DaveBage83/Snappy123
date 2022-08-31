//
//  FulfilmentTimeSlotSelectionView.swift
//  SnappyV2Study
//
//  Created by Henrik Gustavii on 16/06/2021.
//

import SwiftUI

struct FulfilmentTimeSlotSelectionView: View {
    
    // MARK: - Environment objects
    @Environment(\.presentationMode) var presentation
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.horizontalSizeClass) var sizeClass
    @ScaledMetric var scale: CGFloat = 1 // Used to scale icon for accessibility options
    @Environment(\.tabViewHeight) var tabViewHeight

    typealias CustomStrings = Strings.SlotSelection.Customisable
    
    // MARK: - Constants
    struct Constants {
        struct Grid {
            static let minWidth: CGFloat = 100
            static let spacing: CGFloat = 16
        }

        struct AvailableDays {
            struct Scroll {
                static let height: CGFloat = 150
            }
        }
        
        struct CheckoutMessage {
            static let scale: CGFloat = 2
        }
        
        struct TimeSlots {
            static let slotStackSpacing: CGFloat = 16
            static let timeSlotSpacing: CGFloat = 32
            static let additionalPadding: CGFloat = 20
        }
        
        struct ShopNowButton {
            static let paddingAdjustment: CGFloat = 10
        }
        
        struct NoSlots {
            static let spacing: CGFloat = 10
        }
    }
    
    // MARK: - View model
    @StateObject var viewModel: FulfilmentTimeSlotSelectionViewModel
    
    // MARK: - Properties
    private let gridLayout = [GridItem(.adaptive(minimum: Constants.Grid.minWidth), spacing: Constants.Grid.spacing)]
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    // MARK: - Main view
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                if let storeDetails = viewModel.selectedRetailStoreDetails.value {
                    StoreInfoBar(container: viewModel.container, store: storeDetails)
                        .padding(.leading)
                }
                Divider()
            }
            .background(colorPalette.secondaryWhite)
            
            ZStack(alignment: .bottom) {
                ScrollView(.vertical, showsIndicators: false) {
                    
                    if viewModel.showFulfilmentToggle {
                        FulfilmentTypeSelectionToggle(viewModel: .init(container: viewModel.container))
                            .padding()
                    }
                    
                    fulfilmentSelection()
                        .navigationTitle(Text(CustomStrings.chooseSlot.localizedFormat(viewModel.slotDescription)))
                        .padding(.bottom, tabViewHeight + Constants.TimeSlots.additionalPadding)
                    
                    if viewModel.showNoSlotsAvailableView {
                        VStack(spacing: Constants.NoSlots.spacing) {
                            (viewModel.showDeliveryIconInFulfilmentInTimeframeMessage ? Image.Icons.Truck.filled : Image.Icons.BagShopping.filled)
                                .renderingMode(.template)
                                .foregroundColor(colorPalette.primaryBlue)
                                .padding()
                                .scaleEffect(x: Constants.CheckoutMessage.scale, y: Constants.CheckoutMessage.scale)
                            
                            Text(Strings.FulfilmentTimeSlotSelection.Main.noSlotsTitle.localized)
                                .font(.heading3())
                                .foregroundColor(colorPalette.primaryRed)
                                .multilineTextAlignment(.center)
                            
                            Text(Strings.FulfilmentTimeSlotSelection.Main.noSlotsSubtitle.localized)
                                .font(.Body1.regular())
                                .foregroundColor(colorPalette.typefacePrimary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    
                    storeUnavailable // displays only for holidays / paused
                }
                .dismissableNavBar(presentation: presentation, color: colorPalette.primaryBlue)
                shopNowButton
            }
            .onDisappear {
                // If user has toggled fulfilment but not committed to the change, we ensure the selectedFulfilmentType in the appState is restored accordingly
                viewModel.resetFulfilment()
            }
        }
        .background(colorPalette.backgroundMain)
        .padding(.bottom, tabViewHeight - Constants.ShopNowButton.paddingAdjustment)
        .withStandardAlert(
            container: viewModel.container,
            isPresenting: $viewModel.showSuccessfullyUpdateTimeSlotAlert,
            type: .success,
            title: Strings.FulfilmentTimeSlotSelection.Update.successTitle.localized,
            subtitle: Strings.FulfilmentTimeSlotSelection.Update.successSubtitle.localized)
    }
    
    // MARK: - Store unavailable view (holiday / paused)
    @ViewBuilder private var storeUnavailable: some View {
        if viewModel.isPaused {
            StoreUnavailableView(
                container: viewModel.container,
                message: viewModel.pausedMessage ?? Strings.FulfilmentTimeSlotSelection.Paused.defaultMessage.localized,
                storeUnavailableStatus: .paused)
            .padding()
        } else if viewModel.selectedDaySlot?.reason == RetailStoreSlotDay.Reason.holiday.rawValue {
            StoreUnavailableView(
                container: viewModel.container,
                message: viewModel.getHolidayMessage(for: viewModel.selectedDaySlot?.slotDate) ?? Strings.FulfilmentTimeSlotSelection.Holiday.defaultMessage.localized,
                storeUnavailableStatus: .closed)
            .padding()
        }
    }

    // MARK: - Today message
    private func todaySelectSlotDuringCheckoutMessage() -> some View {
        VStack(alignment: .center) {
            (viewModel.showDeliveryIconInFulfilmentInTimeframeMessage ? Image.Icons.Truck.filled : Image.Icons.BagShopping.filled)
                .renderingMode(.template)
                .foregroundColor(colorPalette.primaryBlue)
                .padding()
                .scaleEffect(x: Constants.CheckoutMessage.scale, y: Constants.CheckoutMessage.scale)
            
            Text(viewModel.fulfilmentInTimeframeMessage)
                .font(.heading3())
                .foregroundColor(colorPalette.primaryBlue)
                .bold()
                .multilineTextAlignment(.center)
                .padding()
            
            Text(viewModel.selectSlotAtCheckoutMessage)
                .font(.Body1.semiBold())
                .foregroundColor(colorPalette.typefacePrimary)
                .multilineTextAlignment(.center)
                .padding()
            
        }
        .redacted(reason: viewModel.isTimeSlotsLoading ? .placeholder : [])
        .padding()
    }
    
    // MARK: - Timeslots
    private func fulfilmentSelection() -> some View {
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack {
                    ForEach(viewModel.availableFulfilmentDays, id: \.self) { day in
                        if let startDate = day.storeDateStart, let endDate = day.storeDateEnd {
                            Button(action: { viewModel.selectFulfilmentDate(startDate: startDate, endDate: endDate, storeID: viewModel.selectedRetailStoreDetails.value?.id) } ) {
                                VStack {
                                    
                                    DaySelectionView(viewModel: .init(container: viewModel.container, date: startDate, stringDate: day.date, storePaused: viewModel.isPaused, holiday: day.holidayMessage != nil), selectedDayTimeSlot: $viewModel.selectedDaySlot, isLoading: .constant(viewModel.isTimeSlotsLoading && viewModel.selectedDate == startDate))
                                }
                            }
                        } else {
                            Text(Strings.SlotSelection.noDaysAvailable.localized)
                                .font(.snappyTitle2)
                        }
                    }
                }
                .padding(.leading)
            }
            .frame(height: Constants.AvailableDays.Scroll.height * scale)
            
            if viewModel.isTodaySelectedWithSlotSelectionRestrictions {
                todaySelectSlotDuringCheckoutMessage()
            } else {
                timeSlots()
            }
        }
        .background(colorScheme == .dark ? Color.black : Color.snappyBGMain)
    }
    
    @ViewBuilder private func slotsStack(_ slotPeriod: FulfilmentTimeSlotSelectionViewModel.FulfilmentSlotPeriod) -> some View {
        VStack(alignment: .leading, spacing: Constants.TimeSlots.slotStackSpacing) {
            Text(slotPeriod.title)
                .font(.Body1.semiBold())
                .foregroundColor(colorPalette.primaryBlue)
            LazyVGrid(columns: gridLayout) {
                ForEach(slotPeriod.slots(viewModel: viewModel), id: \.slotId) { data in
                    
                    TimeSlotView(viewModel: .init(container: viewModel.container ,timeSlot: data), selectedTimeSlot: $viewModel.selectedTimeSlot)
                }
            }
            .background(colorPalette.backgroundMain)
        }
        .padding(.horizontal)
    }
    
    private func timeSlots() -> some View {
        VStack(alignment: .leading, spacing: Constants.TimeSlots.timeSlotSpacing) {
            if viewModel.morningTimeSlots.isEmpty == false {
                slotsStack(.morning)
            }
            
            if viewModel.afternoonTimeSlots.isEmpty == false {
                slotsStack(.afternoon)
            }
            
            if viewModel.eveningTimeSlots.isEmpty == false {
                slotsStack(.evening)
            }
        }
        .redacted(reason: viewModel.isTimeSlotsLoading ? .placeholder : [])
    }
    
    
    // MARK: - Shop now button
    private var shopNowButton: some View {
        SnappyButton(
            container: viewModel.container,
            type: .primary,
            size: .large,
            title: viewModel.state == .timeSlotSelection ? GeneralStrings.shopNow.localized : GeneralStrings.updateSlot.localized,
            largeTextTitle: nil,
            icon: nil,
            isEnabled: .constant(viewModel.isFulfilmentSlotSelected),
            isLoading: .constant(viewModel.isReservingTimeSlot)) {
                Task {
                    await viewModel.shopNowButtonTapped()
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
            .background(Color.clear)
            .displayError(viewModel.error)
    }
}

#if DEBUG
struct TimeSlotSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        FulfilmentTimeSlotSelectionView(viewModel: FulfilmentTimeSlotSelectionViewModel(container: .preview))
            .previewCases()
    }
}
#endif
