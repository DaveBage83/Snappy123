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
        }
    }
    
    // MARK: - View model
    @StateObject var viewModel: FulfilmentTimeSlotSelectionViewModel
    
    // MARK: - Properties
    private let gridLayout = [GridItem(.adaptive(minimum: Constants.Grid.minWidth), spacing: Constants.Grid.spacing)]
    
    // MARK: - Computed variables
    var addressViewModel: AddressSearchViewModel {
        return AddressSearchViewModel(container: viewModel.container, type: .delivery)
    }
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    // MARK: - Main view
    var body: some View {
        VStack {
            if let storeDetails = viewModel.selectedRetailStoreDetails.value {
                StoreInfoBar(container: viewModel.container, store: storeDetails)
            }
            
            ScrollView(.vertical, showsIndicators: false) {
                fulfilmentSelection()
                    .navigationTitle(Text(CustomStrings.chooseSlot.localizedFormat(viewModel.slotDescription)))
                
                storeUnavailable // displays only for holidays / paused
            }
            .background(colorPalette.backgroundMain)
            .simpleBackButtonNavigation(presentation: presentation, color: colorPalette.primaryBlue)
            
            shopNowButton
        }
        .background(colorPalette.backgroundMain)
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
            Image.Icons.Truck.filled
                .renderingMode(.template)
                .foregroundColor(colorPalette.primaryBlue)
                .padding()
                .scaleEffect(x: Constants.CheckoutMessage.scale, y: Constants.CheckoutMessage.scale)
            
            Text(CustomStrings.deliveryInTimeframe.localizedFormat(viewModel.earliestFulfilmentTimeString ?? ""))
                .font(.heading3())
                .foregroundColor(colorPalette.primaryBlue)
                .bold()
                .multilineTextAlignment(.center)
                .padding()
            
            Text(Strings.SlotSelection.selectSlotAtCheckout.localized)
                .font(.Body1.semiBold())
                .foregroundColor(colorPalette.typefacePrimary)
                .multilineTextAlignment(.center)
                .padding()
            
        }
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
            title: GeneralStrings.shopNow.localized,
            largeTextTitle: nil,
            icon: nil,
            isEnabled: .constant(viewModel.isFulfilmentSlotSelected),
            isLoading: .constant(viewModel.isReservingTimeSlot)) {
                Task {
                    await viewModel.shopNowButtonTapped()
                }
            }
            .background(colorPalette.backgroundMain)
            .padding(.horizontal)
            .padding(.bottom)
            .displayError(viewModel.error)
    }
}

struct TimeSlotSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        FulfilmentTimeSlotSelectionView(viewModel: FulfilmentTimeSlotSelectionViewModel(container: .preview))
            .previewCases()
    }
}
