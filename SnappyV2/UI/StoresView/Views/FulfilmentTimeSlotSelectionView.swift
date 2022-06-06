//
//  FulfilmentTimeSlotSelectionView.swift
//  SnappyV2Study
//
//  Created by Henrik Gustavii on 16/06/2021.
//

import SwiftUI

struct FulfilmentTimeSlotSelectionView: View {
    @Environment(\.presentationMode) var presentation

    typealias CustomStrings = Strings.SlotSelection.Customisable
    
    struct Constants {
        struct Grid {
            static let minWidth: CGFloat = 100
            static let spacing: CGFloat = 16
        }
        
        struct NavBar {
            static let bottomPadding: CGFloat = 60
        }
        
        struct TimeSelection {
            static let cornerRadius: CGFloat = 6
            static let vPadding: CGFloat = 10
            static let disabledOpacity: CGFloat = 0.5
        }
        
        struct AvailableDays {
            static let leadingPadding: CGFloat = 12
            
            struct Scroll {
                static let height: CGFloat = 150
                static let topPadding: CGFloat = 20
            }
        }
        
        struct ShopNow {
            static let padding: CGFloat = 10
            static let cornerRadius: CGFloat = 10
        }
        
        struct CheckoutMessage {
            static let scale: CGFloat = 2
        }
    }
    
    @StateObject var viewModel: FulfilmentTimeSlotSelectionViewModel
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    let gridLayout = [GridItem(.adaptive(minimum: Constants.Grid.minWidth), spacing: Constants.Grid.spacing)]
    
    var addressViewModel: AddressSearchViewModel {
        return AddressSearchViewModel(container: viewModel.container, type: .delivery)
    }
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    var body: some View {
        Text("")
        .displayError(viewModel.error)
        
        VStack {
            ScrollView(.vertical, showsIndicators: false) {
                fulfilmentSelection()
                    .navigationTitle(Text(CustomStrings.chooseSlot.localizedFormat(viewModel.slotDescription)))
                    .padding(.bottom, Constants.NavBar.bottomPadding)
                    .onChange(of: viewModel.viewDismissed) { dismissed in
                        if dismissed {
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    }
            }
            .simpleBackButtonNavigation(presentation: presentation, color: colorPalette.primaryBlue)
            
            SnappyButton(
                container: viewModel.container,
                type: .primary,
                size: .large,
                title: Strings.SlotSelection.update.localized,
                largeTextTitle: nil,
                icon: nil,
                isEnabled: .constant(viewModel.isFulfilmentSlotSelected),
                isLoading: .constant(viewModel.isReservingTimeSlot)) {
                    Task {
                        await viewModel.shopNowButtonTapped()
                    }
                }
                .padding()
                .background(colorPalette.backgroundMain)
        }
        .background(colorPalette.backgroundMain)
    }

    func fulfilmentSelection() -> some View {
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack {
                    ForEach(viewModel.availableFulfilmentDays, id: \.self) { day in
                        if let startDate = day.storeDateStart, let endDate = day.storeDateEnd {
                            Button(action: { viewModel.selectFulfilmentDate(startDate: startDate, endDate: endDate, storeID: viewModel.selectedRetailStoreDetails.value?.id) } ) {
                                DaySelectionView(viewModel: .init(container: viewModel.container, date: startDate, stringDate: day.date), selectedDayTimeSlot: $viewModel.selectedDaySlot)
                            }
                        } else {
                            Text(Strings.SlotSelection.noDaysAvailable.localized)
                                .font(.snappyTitle2)
                        }
                    }
                }
            }
            .frame(height: Constants.AvailableDays.Scroll.height)
            .padding(.top, Constants.AvailableDays.Scroll.topPadding)
            
            if viewModel.isTodaySelectedWithSlotSelectionRestrictions {
                todaySelectSlotDuringCheckoutMessage()
            } else {
                timeSlots()
            }
        }
        .padding(.horizontal)
        .background(colorScheme == .dark ? Color.black : Color.snappyBGMain)
    }
    
    func todaySelectSlotDuringCheckoutMessage() -> some View {
        VStack(alignment: .center) {
            Image.General.fulfilmentTypeDelivery
                .padding()
                .scaleEffect(x: Constants.CheckoutMessage.scale, y: Constants.CheckoutMessage.scale)
            
            Text(CustomStrings.deliveryInTimeframe.localizedFormat(viewModel.earliestFulfilmentTimeString ?? ""))
                .font(.snappyTitle2)
                .bold()
                .multilineTextAlignment(.center)
                .padding()
            
            Text(Strings.SlotSelection.selectSlotAtCheckout.localized)
                .font(.snappyBody)
                .multilineTextAlignment(.center)
                .padding()
            
        }
        .padding()
    }
    
    func shopNowFloatingButton() -> some View {
        VStack {
            Spacer()
            
            Button(action: { Task { await viewModel.shopNowButtonTapped() } }) {
                if viewModel.isReservingTimeSlot {
                    ProgressView()
                        .font(.snappyTitle)
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .padding(Constants.ShopNow.padding)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: Constants.ShopNow.cornerRadius)
                                .fill(Color.snappyDark)
                                .padding(.horizontal)
                        )
                } else {
                    Text(GeneralStrings.shopNow.localized)
                        .font(.snappyTitle)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(Constants.ShopNow.padding)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: Constants.ShopNow.cornerRadius)
                                .fill(viewModel.isFulfilmentSlotSelected ? Color.snappyDark : Color.gray)
                                .padding(.horizontal)
                        )
                }
            }
            .padding(.bottom)
            .disabled(viewModel.isReservingTimeSlot)
        }
    }
    
    func timeSlots() -> some View {
        VStack(alignment: .leading) {
            if viewModel.morningTimeSlots.isEmpty == false {
                Text(Strings.SlotSelection.morningSlots.localized)
                    .font(.Body1.semiBold())
                    .foregroundColor(colorPalette.primaryBlue)
                
                LazyVGrid(columns: gridLayout) {
                    ForEach(viewModel.morningTimeSlots, id: \.slotId) { data in
                        TimeSlotView(viewModel: .init(container: viewModel.container ,timeSlot: data), selectedTimeSlot: $viewModel.selectedTimeSlot)
                    }
                }
                .padding(.bottom)
            }
            
            if viewModel.afternoonTimeSlots.isEmpty == false {
                Text(Strings.SlotSelection.afternoonSlots.localized)
                    .font(.Body1.semiBold())
                    .foregroundColor(colorPalette.primaryBlue)
                
                LazyVGrid(columns: gridLayout) {
                    ForEach(viewModel.afternoonTimeSlots, id: \.slotId) { data in
                        TimeSlotView(viewModel: .init(container: viewModel.container ,timeSlot: data), selectedTimeSlot: $viewModel.selectedTimeSlot)
                    }
                }
                .padding(.bottom)
            }
            
            if viewModel.eveningTimeSlots.isEmpty == false {
                Text(Strings.SlotSelection.eveningSlots.localized)
                    .font(.Body1.semiBold())
                    .foregroundColor(colorPalette.primaryBlue)
                
                LazyVGrid(columns: gridLayout) {
                    ForEach(viewModel.eveningTimeSlots
                            , id: \.slotId) { data in
                        TimeSlotView(viewModel: .init(container: viewModel.container ,timeSlot: data), selectedTimeSlot: $viewModel.selectedTimeSlot)
                    }
                }
            }
        }
        .redacted(reason: viewModel.isTimeSlotsLoading ? .placeholder : [])
    }
}

struct TimeSlotSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        FulfilmentTimeSlotSelectionView(viewModel: FulfilmentTimeSlotSelectionViewModel(container: .preview))
            .previewCases()
    }
}
