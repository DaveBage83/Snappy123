//
//  DeliverySlotSelectionView.swift
//  SnappyV2Study
//
//  Created by Henrik Gustavii on 16/06/2021.
//

import SwiftUI

class DeliverySlotSelectionViewModel: ObservableObject {
    @Published var isEnabled = false
    @Published var isDeliverySelected = false
    
    @Published var selectedDaySlot: Int?
    @Published var selectedTimeSlot: UUID?
    
    func toggleShowNowButton() {
        isEnabled = !isEnabled
    }
    
    var isDateSelected: Bool {
        return selectedDaySlot != nil && selectedTimeSlot != nil
    }
}

struct DeliverySlotSelectionView: View {
    
    @StateObject var deliveryViewModel = DeliverySlotSelectionViewModel()
    @EnvironmentObject var rootViewModel: RootViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    let gridLayout = [GridItem(.adaptive(minimum: 100), spacing: 10)]
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
                locationSelectorView()
                    .padding(.top, 10)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        DaySelectionView(viewModel: DaySelectionViewModel(isToday: true), day: "Monday", date: 12, month: "October")
                            .environmentObject(deliveryViewModel)
                        DaySelectionView(day: "Tuesday", date: 13, month: "October")
                            .environmentObject(deliveryViewModel)
                        DaySelectionView(day: "Wednesday", date: 14, month: "October")
                            .environmentObject(deliveryViewModel)
                        DaySelectionView(day: "Thursday", date: 15, month: "October")
                            .environmentObject(deliveryViewModel)
                        DaySelectionView(day: "Friday", date: 16, month: "October")
                            .environmentObject(deliveryViewModel)
                        DaySelectionView(day: "Saturday", date: 17, month: "October")
                            .environmentObject(deliveryViewModel)
                        DaySelectionView(day: "Sunday", date: 18, month: "October")
                            .environmentObject(deliveryViewModel)
                    }
                    .padding(.leading, 12)
                }
                .frame(height: 150)
                .padding(.top, 20)
                
                VStack(alignment: .leading) {
                    Text("Morning Slots")
                    LazyVGrid(columns: gridLayout) {
                        ForEach(timeSlotData, id: \.id) { data in
                            TimeSlotView(timeSlot: data)
                                .environmentObject(deliveryViewModel)
                        }
                    }
                    Text("Afternoon Slots")
                    LazyVGrid(columns: gridLayout) {
                        ForEach(timeSlotData2, id: \.id) { data in
                            TimeSlotView(timeSlot: data)
                                .environmentObject(deliveryViewModel)
                        }
                    }
                    Text("Evening Slots")
                    LazyVGrid(columns: gridLayout) {
                        ForEach(timeSlotData3
                                , id: \.id) { data in
                            TimeSlotView(timeSlot: data)
                                .environmentObject(deliveryViewModel)
                            
                        }
                    }
                }
                .padding()
                
            }
            .navigationTitle(Text("Choose Delivery Slot"))
            .padding(.bottom, 60)
            
        }
        .overlay(
            VStack {
            Spacer()
            
            Button(action: {
                rootViewModel.selectedTab = 2
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Text("Shop Now")
                    .font(.snappyTitle)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(10)
                    .padding(.horizontal)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(deliveryViewModel.isDateSelected ? Color.snappyDark : Color.gray)
                            .frame(width: 340)
                    )
            }
        }
        )
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
            
            Button(action: { deliveryViewModel.isDeliverySelected = true }) {
                Label("Delivery", systemImage: "car")
                    .font(.snappyCaption)
                    .padding(7)
                    .foregroundColor(deliveryViewModel.isDeliverySelected ? .white : .snappyBlue)
                    .background(deliveryViewModel.isDeliverySelected ? Color.snappyBlue : Color.snappyBGMain)
                    .cornerRadius(6)
            }
            
            Button(action: { deliveryViewModel.isDeliverySelected = false }) {
                Label("Collection", systemImage: "case")
                    .font(.snappyCaption)
                    .padding(7)
                    .foregroundColor(deliveryViewModel.isDeliverySelected ? .snappyBlue : .white)
                    .background(deliveryViewModel.isDeliverySelected ? Color.white : Color.snappyBlue)
                    .cornerRadius(6)
            }
        }
        .frame(height: 40)
        .padding(.horizontal)
    }
    
    let timeSlotData = [TimeSlot(time: "09:00 - 09:30", cost: "£3.50"), TimeSlot(time: "09:30 - 10:00", cost: "£3.50"), TimeSlot(time: "10:00 - 10:30", cost: "£3.50"), TimeSlot(time: "10:30 - 11:00", cost: "£3.50"), TimeSlot(time: "11:00 - 11:30", cost: "£3.50"), TimeSlot(time: "11:30 - 12:00", cost: "£3.50")]
    let timeSlotData2 = [TimeSlot(time: "12:00 - 12:30", cost: "£3.50"), TimeSlot(time: "12:30 - 13:00", cost: "£3.50"), TimeSlot(time: "13:00 - 13:30", cost: "£3.50"), TimeSlot(time: "13:30 - 14:00", cost: "£3.50"), TimeSlot(time: "14:00 - 14:30", cost: "£3.50"), TimeSlot(time: "14:30 - 15:00", cost: "£3.50")]
    let timeSlotData3 = [TimeSlot(time: "15:00 - 15:30", cost: "£3.50"), TimeSlot(time: "15:30 - 16:00", cost: "£3.50"), TimeSlot(time: "16:00 - 16:30", cost: "£3.50"), TimeSlot(time: "16:30 - 17:00", cost: "£3.50"), TimeSlot(time: "17:00 - 17:30", cost: "£3.50"), TimeSlot(time: "17:30 - 18:00", cost: "£3.50")]
    
    
}

struct TimeSlot {
    let id = UUID()
    let time: String
    let cost: String
}

struct TimeSlotSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        DeliverySlotSelectionView()
        
        DeliverySlotSelectionView()
            .preferredColorScheme(.dark)
    }
}
