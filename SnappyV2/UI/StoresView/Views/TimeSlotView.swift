//
//  TimeSlotView.swift
//  SnappyV2Study
//
//  Created by Henrik Gustavii on 16/06/2021.
//

import SwiftUI

class TimeSlotViewModel: ObservableObject {
    @Published var isSelected = false
    let timeSlot: RetailStoreSlotDayTimeSlot
    let startTime: String
    let endTime: String
    
    var cost: String {
        if timeSlot.info.price == 0.0 { return "Free"}
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "£"

        guard let total = formatter.string(from: NSNumber(value: timeSlot.info.price)) else { return "" }
        return total
    }
    
    init(timeSlot: RetailStoreSlotDayTimeSlot) {
        self.timeSlot = timeSlot
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        self.startTime = dateFormatter.string(from: timeSlot.startTime)
        self.endTime = dateFormatter.string(from: timeSlot.endTime)
    }
    
    func toggleSelected() {
        isSelected = !isSelected
    }
}

struct TimeSlotView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: TimeSlotViewModel
    @EnvironmentObject var deliveryViewModel: DeliverySlotSelectionViewModel
    
    var body: some View {
        Button(action: { deliveryViewModel.selectedTimeSlot = viewModel.timeSlot.slotId }) {
            VStack(alignment: .leading) {
                Text("\(viewModel.startTime)-\(viewModel.endTime)")
                    .font(.snappyBody)
                    .foregroundColor( deliveryViewModel.selectedTimeSlot == viewModel.timeSlot.slotId ? .white : (colorScheme == .dark ? .white : .black))
                Text(viewModel.cost)
                    .font(.snappyCaption)
                    .foregroundColor(.gray)
            }
            .padding(EdgeInsets(top: 8, leading: 10, bottom: 8, trailing: 10))
            .frame(width: 110, height: 60, alignment: .leading)
            .background(backgroundView())
            .cornerRadius(5)
        }
    }
    
    func backgroundView() -> some View {
        ZStack {
            if deliveryViewModel.selectedTimeSlot == viewModel.timeSlot.slotId {
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.snappyBlue)
                    .shadow(color: .gray, radius: 2)
                    .padding(4)
            } else {
                RoundedRectangle(cornerRadius: 5)
                    .fill(colorScheme == .dark ? Color.black : Color.white)
                    .shadow(color: .gray, radius: 2)
                    .padding(4)
            }
        }
    }
}

struct TimeSlotView_Previews: PreviewProvider {
    static var previews: some View {
        TimeSlotView(viewModel: TimeSlotViewModel(timeSlot: RetailStoreSlotDayTimeSlot(slotId: "1", startTime: Date(), endTime: Date(), daytime: RetailStoreSlotDayTimeSlotDaytime.morning, info: RetailStoreSlotDayTimeSlotInfo(status: "", isAsap: false, price: 3.5, fulfilmentIn: ""))))
            .previewLayout(.sizeThatFits)
            .padding()
            .previewCases()
            .environmentObject(DeliverySlotSelectionViewModel(container: .preview))
    }
}
