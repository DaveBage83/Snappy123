//
//  DaySelectionView.swift
//  SnappyV2Study
//
//  Created by Henrik Gustavii on 16/06/2021.
//

import SwiftUI

class DaySelectionViewModel: ObservableObject {
    @Published var isSelected = false
    let isToday: Bool
    
    init(isToday: Bool = false) {
        self.isToday = isToday
    }
    
    func toggleSelected() {
        isSelected = !isSelected
    }
}

struct DaySelectionView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel = DaySelectionViewModel()
    @EnvironmentObject var deliveryViewModel: DeliverySlotSelectionViewModel
    
    let day: String
    let date: Int
    let month: String
    
    var body: some View {
            ZStack {
                VStack {
                    Button(action: { deliveryViewModel.selectedDaySlot = date } ) {
                        VStack(alignment: .center) {
                            Text(day)
                                .font(.snappyCaption)
                                .foregroundColor(deliveryViewModel.selectedDaySlot == date ? .white : (colorScheme == .dark ? .white : .black))
                                .fontWeight(.light)
                            Text("\(date)")
                                .font(.snappyTitle)
                                .foregroundColor(deliveryViewModel.selectedDaySlot == date ? .white : (colorScheme == .dark ? .white : .black))
                                .fontWeight(.semibold)
                                .padding([.top, .bottom], 4)
                            Text(month)
                                .font(.snappyCaption)
                                .foregroundColor(deliveryViewModel.selectedDaySlot == date ? .white : (colorScheme == .dark ? .white : .black))
                                .fontWeight(.light)
                        }
                        .frame(width: 80, height: 95)
                        .padding(EdgeInsets(top: 20, leading: 16, bottom: 20, trailing: 16))
                        .background(backgroundView())
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 5)
//                                .stroke(Color.blue, lineWidth: 4)
//                                .padding(4)
//                                .opacity(viewModel.isSelected ? 1 : 0)
//                        )
                        .cornerRadius(5)
                    }
                }
                
                VStack(alignment: .center) {
                    HStack(alignment: .top) {
                        if viewModel.isToday {
                            Text("Today")
                                .font(.caption)
                                .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                                .foregroundColor(deliveryViewModel.selectedDaySlot == date ? .snappyBlue : .white)
                                .background(Capsule().fill(deliveryViewModel.selectedDaySlot == date ? Color.white : Color.snappyBlue))

                        }
                    }
                    Spacer()
                }
                .frame(width: 80, height: 150)
            }
    }
    
    func backgroundView() -> some View {
        ZStack {
            if deliveryViewModel.selectedDaySlot == date {
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

struct DaySelectionView_Previews: PreviewProvider {
    static var previews: some View {
        DaySelectionView(day: "Monday", date: 12, month: "October")
            .previewLayout(.sizeThatFits)
            .padding()
            .previewCases()
            .environmentObject(DeliverySlotSelectionViewModel(container: .preview))
    }
}
