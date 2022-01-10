//
//  DeliverySlotSelectionView.swift
//  SnappyV2Study
//
//  Created by Henrik Gustavii on 16/06/2021.
//

import SwiftUI

struct DeliverySlotSelectionView: View {
    
    @StateObject var viewModel: DeliverySlotSelectionViewModel
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    let gridLayout = [GridItem(.adaptive(minimum: 100), spacing: 10)]
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
                locationSelectorView()
                    .padding(.top, 10)
                
                if viewModel.isFutureDeliverySelected {
                    futureDeliverySelection()
                        .onAppear(perform: { viewModel.futureDeliverySetup() })
                } else {
                    deliveryTimeSelection()
                }
                
            }
            .navigationTitle(Text(Strings.DeliverySelection.chooseSlot.localized))
            .padding(.bottom, 60)
            .onChange(of: viewModel.viewDismissed) { dismissed in
                if dismissed {
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .overlay(
            shopNowFloatingButton
        )
    }
    
    func deliveryTimeSelection() -> some View {
        VStack {
            Button(action: {
                viewModel.asapDeliveryTapped()
            }) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(Strings.DeliverySelection.asap.localized)
                            .font(.snappyHeadline)
                            .foregroundColor(.snappyDark)
                        
                        Text(Strings.DeliverySelection.upToHour.localized)
                            .font(.snappyBody)
                            .foregroundColor(.snappyTextGrey2)
                    }
                    
                    Spacer()
                    
                    Image.Navigation.chevronRight
                        .foregroundColor(.black)
                }
                .opacity(viewModel.isReservingTimeSlot ? 0 : 1)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(6)
            .snappyShadow()
            .padding([.bottom, .top], 10)
            .disabled(viewModel.isASAPDeliveryDisabled || viewModel.isReservingTimeSlot)
            .opacity(viewModel.isASAPDeliveryDisabled ? 0.5 : 1)
            .overlay(
                HStack {
                    if viewModel.isReservingTimeSlot {
                        ProgressView()
                    }
                }
            )
            
            Button(action: { viewModel.futureDeliveryTapped() }) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(Strings.DeliverySelection.chooseFuture.localized)
                            .font(.snappyHeadline)
                            .foregroundColor(.snappyDark)
                        
                        Text(Strings.DeliverySelection.upTo10Days.localized)
                            .font(.snappyBody)
                            .foregroundColor(.snappyTextGrey2)
                    }
                    
                    Spacer()
                    
                    Image.Navigation.chevronLeft
                        .foregroundColor(.black)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(6)
            .snappyShadow()
            .disabled(viewModel.isFutureDeliveryDisabled)
            .opacity(viewModel.isFutureDeliveryDisabled ? 0.5 : 1)
        }
        .padding()
    }
    
    func futureDeliverySelection() -> some View {
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack {
                    ForEach(viewModel.availableDeliveryDays, id: \.self) { day in
                        if let startDate = day.storeDateStart, let endDate = day.storeDateEnd {
                            Button(action: { viewModel.selectDeliveryDate(startDate: startDate, endDate: endDate, storeID: viewModel.selectedRetailStoreDetails.value?.id) } ) {
                                DaySelectionView(viewModel: .init(date: startDate, stringDate: day.date), selectedDayTimeSlot: $viewModel.selectedDaySlot)
                            }
                        } else {
                            #warning("Change to localised text key")
                            Text(Strings.DeliverySelection.noDaysAvailable.localized)
                                .font(.snappyTitle2)
                        }
                    }
                }
                .padding(.leading, 12)
            }
            .frame(height: 150)
            .padding(.top, 20)
            
            VStack(alignment: .leading) {
                if viewModel.morningTimeSlots.isEmpty == false {
                    Text(Strings.DeliverySelection.morningSlots.localized)
                        .font(.snappyBody)
                    
                    LazyVGrid(columns: gridLayout) {
                        ForEach(viewModel.morningTimeSlots, id: \.slotId) { data in
                            TimeSlotView(viewModel: .init(timeSlot: data), selectedTimeSlot: $viewModel.selectedTimeSlot)
                        }
                    }
                    .padding(.bottom)
                }
                
                if viewModel.afternoonTimeSlots.isEmpty == false {
                    Text(Strings.DeliverySelection.afternoonSlots.localized)
                        .font(.snappyBody)
                    
                    LazyVGrid(columns: gridLayout) {
                        ForEach(viewModel.afternoonTimeSlots, id: \.slotId) { data in
                            TimeSlotView(viewModel: .init(timeSlot: data), selectedTimeSlot: $viewModel.selectedTimeSlot)
                        }
                    }
                    .padding(.bottom)
                }
                
                if viewModel.eveningTimeSlots.isEmpty == false {
                    Text(Strings.DeliverySelection.eveningSlots.localized)
                        .font(.snappyBody)
                    
                    LazyVGrid(columns: gridLayout) {
                        ForEach(viewModel.eveningTimeSlots
                                , id: \.slotId) { data in
                            TimeSlotView(viewModel: .init(timeSlot: data), selectedTimeSlot: $viewModel.selectedTimeSlot)
                        }
                    }
                }
            }
            .redacted(reason: viewModel.isTimeSlotsLoading ? .placeholder : [])
            .padding()
        }
        .background(colorScheme == .dark ? Color.black : Color.snappyBGMain)
    }
    
    func locationSelectorView() -> some View {
        LazyHStack {
            Image("coop-logo")
                .resizable()
                .scaledToFit()
                .clipShape(Circle())
                .padding(.vertical, 4)
            
            VStack(alignment: .leading) {
                Text("Coop")
                Text("Long address")
            }
            .font(.snappyCaption2)
            
            Button(action: { viewModel.isDeliverySelected = true }) {
                Label(GeneralStrings.delivery.localized, systemImage: "car")
                    .font(.snappyCaption)
                    .padding(7)
                    .foregroundColor(viewModel.isDeliverySelected ? .white : .snappyBlue)
                    .background(viewModel.isDeliverySelected ? Color.snappyBlue : Color.snappyBGMain)
                    .cornerRadius(6)
            }
            
            Button(action: { viewModel.isDeliverySelected = false }) {
                Label(GeneralStrings.collection.localized, systemImage: "case")
                    .font(.snappyCaption)
                    .padding(7)
                    .foregroundColor(viewModel.isDeliverySelected ? .snappyBlue : .white)
                    .background(viewModel.isDeliverySelected ? Color.white : Color.snappyBlue)
                    .cornerRadius(6)
            }
        }
        .frame(height: 40)
        .padding(.horizontal)
    }
    
    @ViewBuilder var shopNowFloatingButton: some View {
        if viewModel.isFutureDeliverySelected {
            VStack {
                Spacer()
                
                Button(action: { viewModel.shopNowButtonTapped() }) {
                    if viewModel.isReservingTimeSlot {
                        ProgressView()
                            .font(.snappyTitle)
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .padding(10)
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.snappyDark)
                                    .padding(.horizontal)
                            )
                    } else {
                        Text(GeneralStrings.shopNow.localized)
                            .font(.snappyTitle)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(10)
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(viewModel.isDeliverySlotSelected ? Color.snappyDark : Color.gray)
                                    .padding(.horizontal)
                            )
                    }
                }
            }
        }
    }
}


struct TimeSlotSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        DeliverySlotSelectionView(viewModel: DeliverySlotSelectionViewModel(container: .preview))
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
