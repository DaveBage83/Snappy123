//
//  FulfilmentTimeSlotSelectionView.swift
//  SnappyV2Study
//
//  Created by Henrik Gustavii on 16/06/2021.
//

import SwiftUI

struct FulfilmentTimeSlotSelectionView: View {
    typealias CustomStrings = Strings.SlotSelection.Customisable
    
    struct Constants {
        struct Grid {
            static let minWidth: CGFloat = 100
            static let spacing: CGFloat = 10
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
    }
    
    @StateObject var viewModel: FulfilmentTimeSlotSelectionViewModel
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    let gridLayout = [GridItem(.adaptive(minimum: Constants.Grid.minWidth), spacing: Constants.Grid.spacing)]
    var addressViewModel: AddressSearchViewModel {
        return AddressSearchViewModel(container: viewModel.container)
    }
    
    var body: some View {
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
        .overlay(
            shopNowFloatingButton()
        )
    }
    
    func fulfilmentSelection() -> some View {
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack {
                    ForEach(viewModel.availableFulfilmentDays, id: \.self) { day in
                        if let startDate = day.storeDateStart, let endDate = day.storeDateEnd {
                            Button(action: { viewModel.selectFulfilmentDate(startDate: startDate, endDate: endDate, storeID: viewModel.selectedRetailStoreDetails.value?.id) } ) {
                                DaySelectionView(viewModel: .init(date: startDate, stringDate: day.date), selectedDayTimeSlot: $viewModel.selectedDaySlot)
                            }
                        } else {
                            Text(Strings.SlotSelection.noDaysAvailable.localized)
                                .font(.snappyTitle2)
                        }
                    }
                }
                .padding(.leading, Constants.AvailableDays.leadingPadding)
            }
            .frame(height: Constants.AvailableDays.Scroll.height)
            .padding(.top, Constants.AvailableDays.Scroll.topPadding)
            
            if viewModel.showTodaySelectSlotDuringCheckoutMessage {
                todaySelectSlotDuringCheckoutMessage()
            } else {
                timeSlots()
            }
        }
        .background(colorScheme == .dark ? Color.black : Color.snappyBGMain)
    }
    
    func todaySelectSlotDuringCheckoutMessage() -> some View {
        VStack {
            Image(systemName: "car")
            
            Text("Your order should be delivered between 45 to 60 minutes")
                .font(.snappyTitle)
                .bold()
            
            Text("You can select a different delivery time slot for today during the checkout")
                .font(.snappyBody)
        }
    }
    
    func shopNowFloatingButton() -> some View {
        VStack {
            Spacer()
            
            Button(action: { viewModel.shopNowButtonTapped() }) {
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
            .disabled(viewModel.isReservingTimeSlot)
        }
    }
    
    func timeSlots() -> some View {
        VStack(alignment: .leading) {
            if viewModel.morningTimeSlots.isEmpty == false {
                Text(Strings.SlotSelection.morningSlots.localized)
                    .font(.snappyBody)
                
                LazyVGrid(columns: gridLayout) {
                    ForEach(viewModel.morningTimeSlots, id: \.slotId) { data in
                        TimeSlotView(viewModel: .init(container: viewModel.container ,timeSlot: data), selectedTimeSlot: $viewModel.selectedTimeSlot)
                    }
                }
                .padding(.bottom)
            }
            
            if viewModel.afternoonTimeSlots.isEmpty == false {
                Text(Strings.SlotSelection.afternoonSlots.localized)
                    .font(.snappyBody)
                
                LazyVGrid(columns: gridLayout) {
                    ForEach(viewModel.afternoonTimeSlots, id: \.slotId) { data in
                        TimeSlotView(viewModel: .init(container: viewModel.container ,timeSlot: data), selectedTimeSlot: $viewModel.selectedTimeSlot)
                    }
                }
                .padding(.bottom)
            }
            
            if viewModel.eveningTimeSlots.isEmpty == false {
                Text(Strings.SlotSelection.eveningSlots.localized)
                    .font(.snappyBody)
                
                LazyVGrid(columns: gridLayout) {
                    ForEach(viewModel.eveningTimeSlots
                            , id: \.slotId) { data in
                        TimeSlotView(viewModel: .init(container: viewModel.container ,timeSlot: data), selectedTimeSlot: $viewModel.selectedTimeSlot)
                    }
                }
            }
        }
        .redacted(reason: viewModel.isTimeSlotsLoading ? .placeholder : [])
        .padding()
    }
}

struct TimeSlotSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        FulfilmentTimeSlotSelectionView(viewModel: FulfilmentTimeSlotSelectionViewModel(container: .preview))
            .previewCases()
    }
}


#if DEBUG

extension MockData {
//    static let timeSlotData = [TimeSlot(time: "09:00 - 09:30", cost: "£3.50"), TimeSlot(time: "09:30 - 10:00", cost: "£3.50"), TimeSlot(time: "10:00 - 10:30", cost: "£3.50"), TimeSlot(time: "10:30 - 11:00", cost: "£3.50"), TimeSlot(time: "11:00 - 11:30", cost: "£3.50"), TimeSlot(time: "11:30 - 12:00", cost: "£3.50")]
//    static let timeSlotData2 = [TimeSlot(time: "12:00 - 12:30", cost: "£3.50"), TimeSlot(time: "12:30 - 13:00", cost: "£3.50"), TimeSlot(time: "13:00 - 13:30", cost: "£3.50"), TimeSlot(time: "13:30 - 14:00", cost: "£3.50"), TimeSlot(time: "14:00 - 14:30", cost: "£3.50"), TimeSlot(time: "14:30 - 15:00", cost: "£3.50")]
//    static let timeSlotData3 = [TimeSlot(time: "15:00 - 15:30", cost: "£3.50"), TimeSlot(time: "15:30 - 16:00", cost: "£3.50"), TimeSlot(time: "16:00 - 16:30", cost: "£3.50"), TimeSlot(time: "16:30 - 17:00", cost: "£3.50"), TimeSlot(time: "17:00 - 17:30", cost: "£3.50"), TimeSlot(time: "17:30 - 18:00", cost: "£3.50")]
}

#endif
