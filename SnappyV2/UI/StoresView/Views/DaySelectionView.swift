//
//  DaySelectionView.swift
//  SnappyV2Study
//
//  Created by Henrik Gustavii on 16/06/2021.
//

import SwiftUI

class DaySelectionViewModel: ObservableObject {
    let stringDate: String
    let weekday: String
    let dayOfMonth: String
    let month: String
    var isToday: Bool = false
    
    init(date: Date, stringDate: String) {
        self.stringDate = stringDate
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd"
        self.dayOfMonth = dateFormatter.string(from: date)
        dateFormatter.dateFormat = "MMMM"
        self.month = dateFormatter.string(from: date)
        dateFormatter.dateFormat = "EEEE"
        self.weekday = dateFormatter.string(from: date)
        
        self.isToday = Calendar.current.isDateInToday(date)
    }
}

struct DaySelectionView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: DaySelectionViewModel
    @Binding var selectedDayTimeSlot: RetailStoreSlotDay?
    
    var body: some View {
            ZStack {
                VStack {
                    VStack(alignment: .center) {
                        Text(viewModel.weekday)
                            .font(.snappyCaption)
                            .foregroundColor(selectedDayTimeSlot?.slotDate == viewModel.stringDate ? .white : (colorScheme == .dark ? .white : .black))
                            .fontWeight(.light)
                        Text(viewModel.dayOfMonth)
                            .font(.snappyTitle)
                            .foregroundColor(selectedDayTimeSlot?.slotDate == viewModel.stringDate ? .white : (colorScheme == .dark ? .white : .black))
                            .fontWeight(.semibold)
                            .padding([.top, .bottom], 4)
                        Text(viewModel.month)
                            .font(.snappyCaption)
                            .foregroundColor(selectedDayTimeSlot?.slotDate == viewModel.stringDate ? .white : (colorScheme == .dark ? .white : .black))
                            .fontWeight(.light)
                    }
                    .frame(width: 80, height: 95)
                    .padding(EdgeInsets(top: 20, leading: 16, bottom: 20, trailing: 16))
                    .background(backgroundView())
                    .cornerRadius(5)
                    
                }
                
                VStack(alignment: .center) {
                    HStack(alignment: .top) {
                        if viewModel.isToday {
                            Text(GeneralStrings.today.localized)
                                .font(.caption)
                                .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                                .foregroundColor(selectedDayTimeSlot?.slotDate == viewModel.stringDate ? .snappyBlue : .white)
                                .background(Capsule().fill(selectedDayTimeSlot?.slotDate == viewModel.stringDate ? Color.white : Color.snappyBlue))

                        }
                    }
                    Spacer()
                }
                .frame(width: 80, height: 150)
            }
    }
    
    func backgroundView() -> some View {
        ZStack {
            if selectedDayTimeSlot?.slotDate == viewModel.stringDate {
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
        DaySelectionView(viewModel: .init(date: Date(), stringDate: ""), selectedDayTimeSlot: .constant(RetailStoreSlotDay(status: "", reason: "", slotDate: "", slots: nil)))
            .previewLayout(.sizeThatFits)
            .padding()
            .previewCases()
    }
}
