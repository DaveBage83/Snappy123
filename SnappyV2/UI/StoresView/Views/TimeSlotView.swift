//
//  TimeSlotView.swift
//  SnappyV2Study
//
//  Created by Henrik Gustavii on 16/06/2021.
//

import SwiftUI

class TimeSlotViewModel: ObservableObject {
    let timeSlot: RetailStoreSlotDayTimeSlot
    let startTime: String
    let endTime: String
    
    init(container: DIContainer, timeSlot: RetailStoreSlotDayTimeSlot) {
        let appState = container.appState
        self.timeSlot = timeSlot
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.timeZone = appState.value.userData.selectedStore.value?.storeTimeZone
        self.startTime = dateFormatter.string(from: timeSlot.startTime)
        self.endTime = dateFormatter.string(from: timeSlot.endTime)
    }
    
    var cost: String {
        if timeSlot.info.price == 0 { return GeneralStrings.free.localized}
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "£"

        guard let total = formatter.string(from: NSNumber(value: timeSlot.info.price)) else { return "" }
        return total
    }
}

struct TimeSlotView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: TimeSlotViewModel
    @Binding var selectedTimeSlot: RetailStoreSlotDayTimeSlot?
    
    var body: some View {
        Button(action: { selectedTimeSlot = viewModel.timeSlot }) {
            VStack(alignment: .leading) {
                Text("\(viewModel.startTime)-\(viewModel.endTime)")
                    .font(.snappyBody)
                    .foregroundColor( selectedTimeSlot?.slotId == viewModel.timeSlot.slotId ? .white : (colorScheme == .dark ? .white : .black))
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
            if selectedTimeSlot?.slotId == viewModel.timeSlot.slotId {
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
        TimeSlotView(viewModel: TimeSlotViewModel(container: .preview ,timeSlot: RetailStoreSlotDayTimeSlot(slotId: "1", startTime: Date(), endTime: Date(), daytime: "morning", info: RetailStoreSlotDayTimeSlotInfo(status: "", isAsap: false, price: 3.5, fulfilmentIn: ""))), selectedTimeSlot: .constant(nil))
            .previewLayout(.sizeThatFits)
            .padding()
            .previewCases()
    }
}
