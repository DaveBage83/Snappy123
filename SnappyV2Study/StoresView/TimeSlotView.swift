//
//  TimeSlotView.swift
//  SnappyV2Study
//
//  Created by Henrik Gustavii on 16/06/2021.
//

import SwiftUI

class TimeSlotViewModel: ObservableObject {
    @Published var isSelected = false
    
    func toggleSelected() {
        isSelected = !isSelected
    }
}

struct TimeSlotView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel = TimeSlotViewModel()
    @EnvironmentObject var deliveryViewModel: DeliverySlotSelectionViewModel
    
    let timeSlot: TimeSlot
    
    var body: some View {
        Button(action: { deliveryViewModel.selectedTimeSlot = timeSlot.id }) {
            VStack(alignment: .leading) {
                Text(timeSlot.time)
                    .font(.snappyBody)
                    .foregroundColor( deliveryViewModel.selectedTimeSlot == timeSlot.id ? .white : (colorScheme == .dark ? .white : .black))
                Text(timeSlot.cost)
                    .font(.snappyCaption)
                    .foregroundColor(.gray)
            }
            .padding(EdgeInsets(top: 8, leading: 10, bottom: 8, trailing: 10))
            .frame(width: 100, height: 60, alignment: .leading)
            .background(backgroundView())
//            .overlay(
//                RoundedRectangle(cornerRadius: 5)
//                    .stroke(Color.snappyBlue, lineWidth: 4)
//                    .padding(4)
//                    .opacity(viewModel.isSelected ? 1 : 0)
//            )
            .cornerRadius(5)
        }
    }
    
    func backgroundView() -> some View {
        ZStack {
            if deliveryViewModel.selectedTimeSlot == timeSlot.id {
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
        TimeSlotView(timeSlot: TimeSlot(time: "09:00 - 09:30", cost: "£3.50"))
            .previewLayout(.sizeThatFits)
            .padding()
            .previewCases()
            .environmentObject(DeliverySlotSelectionViewModel())
    }
}
