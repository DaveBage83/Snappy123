//
//  DeliverySlotSelectionView.swift
//  SnappyV2Study
//
//  Created by Henrik Gustavii on 16/06/2021.
//

import SwiftUI

class DeliverylotSelectionViewModel: ObservableObject {
    @Published var isEnabled = false
    @Published var isDeliverySelected = false
    
    var selectedDaySlot: Int?
    var selectedTimeSlot: UUID?
    
    func toggleShowNowButton() {
        isEnabled = !isEnabled
    }
}

struct DeliverySlotSelectionView: View {
    
    @StateObject var viewModel = DeliverylotSelectionViewModel()
    
    let gridLayout = [GridItem(.adaptive(minimum: 100), spacing: 10)]
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
                locationSelectorView()
                    .padding(.top, 10)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        DaySelectionView(viewModel: DaySelectionViewModel(isToday: true), day: "Monday", date: 12, month: "October")
                        DaySelectionView(day: "Tuesday", date: 13, month: "October")
                        DaySelectionView(day: "Wednesday", date: 14, month: "October")
                        DaySelectionView(day: "Thursday", date: 15, month: "October")
                        DaySelectionView(day: "Friday", date: 16, month: "October")
                        DaySelectionView(day: "Saturday", date: 17, month: "October")
                        DaySelectionView(day: "Sunday", date: 18, month: "October")
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
                        }
                    }
                    Text("Afternoon Slots")
                    LazyVGrid(columns: gridLayout) {
                        ForEach(timeSlotData, id: \.id) { data in
                            TimeSlotView(timeSlot: data)
                        }
                    }
                    Text("Evening Slots")
                    LazyVGrid(columns: gridLayout) {
                        ForEach(timeSlotData, id: \.id) { data in
                            TimeSlotView(timeSlot: data)
                            
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
                
                Button(action: { viewModel.toggleShowNowButton() }) {
                    Text("Shop Now")
                        .font(.snappyTitle)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(10)
                        .padding(.horizontal)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(viewModel.isEnabled ? Color.snappyDark : Color.gray)
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
            
            Button(action: { viewModel.isDeliverySelected = true }) {
                Label("Delivery", systemImage: "car")
                    .font(.snappyCaption)
                    .padding(7)
                    .foregroundColor(viewModel.isDeliverySelected ? .white : .snappyBlue)
                    .background(viewModel.isDeliverySelected ? Color.snappyBlue : Color.snappyBGMain)
                    .cornerRadius(6)
            }
            
            Button(action: { viewModel.isDeliverySelected = false }) {
                Label("Collection", systemImage: "case")
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
    
    let timeSlotData = [TimeSlot(time: "09:00 - 09:30", cost: "£3.50"), TimeSlot(time: "09:30 - 10:00", cost: "£3.50"), TimeSlot(time: "10:00 - 10:30", cost: "£3.50"), TimeSlot(time: "10:30 - 11:00", cost: "£3.50"), TimeSlot(time: "11:00 - 11:30", cost: "£3.50"), TimeSlot(time: "11:30 - 12:00", cost: "£3.50")]
    
    
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
