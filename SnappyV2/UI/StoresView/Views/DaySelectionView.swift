//
//  DaySelectionView.swift
//  SnappyV2Study
//
//  Created by Henrik Gustavii on 16/06/2021.
//

import SwiftUI

class DaySelectionViewModel: ObservableObject {
    let container: DIContainer
    
    let stringDate: String
    let weekday: String
    let dayOfMonth: String
    let month: String
    var isToday: Bool = false
#warning("Requesting API change for response to /stores/select.json to include all unfiltered dates + status / reason. Once chagnge is made, we may turn the below into a computed variable based on new response.")
    let disabledReason: String?
    let storePaused: Bool
    let holiday: Bool
    
    var disabled: Bool {
        disabledReason != nil || storePaused || holiday
    }
    
    init(container: DIContainer, date: Date, stringDate: String, disabledReason: String? = nil, storePaused: Bool = false, holiday: Bool) {
        self.container = container
        self.stringDate = stringDate
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd"
        self.dayOfMonth = dateFormatter.string(from: date)
        dateFormatter.dateFormat = "MMMM"
        self.month = dateFormatter.string(from: date)
        dateFormatter.dateFormat = "EEEE"
        self.weekday = dateFormatter.string(from: date)
        self.holiday = holiday
        
        if storePaused || holiday {
            self.disabledReason = Strings.StoresView.StoreStatus.closedStores.localized
        } else {
            self.disabledReason = disabledReason
        }
        
        self.storePaused = storePaused
        
        self.isToday = date.isToday
    }
}

struct DaySelectionView: View {
    // MARK: - Environment objects
    @ScaledMetric var scale: CGFloat = 1 // Used to scale icon for accessibility options
    @Environment(\.colorScheme) var colorScheme
    
    struct Constants {
        struct General {
            static let height: CGFloat = 106
            static let width: CGFloat = 88
            static let cornerRadius: CGFloat = 8
            static let spacing: CGFloat = 4
        }
        
        struct WeekdayLabel {
            static let height: CGFloat = 16
        }
        
        struct DayMonthLabel {
            static let height: CGFloat = 32
        }
    }
    
    // MARK: - View model
    @StateObject var viewModel: DaySelectionViewModel
    @Binding var selectedDayTimeSlot: RetailStoreSlotDay?
    @Binding var isLoading: Bool
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    // MARK: - Main body
    var body: some View {
        ZStack {
            VStack {
                VStack(alignment: .center, spacing: Constants.General.spacing) {
                    Text(viewModel.weekday)
                        .font(.Body2.semiBold())
                        .foregroundColor(viewModel.disabled ? colorPalette.textGrey3 : selectedDayTimeSlot?.slotDate == viewModel.stringDate ? colorPalette.typefaceInvert : colorPalette.textGrey2)
                        .frame(height: Constants.DayMonthLabel.height * scale)
                    Text(viewModel.dayOfMonth)
                        .font(.heading1)
                        .foregroundColor(viewModel.disabled ? colorPalette.textGrey3 : selectedDayTimeSlot?.slotDate == viewModel.stringDate ? colorPalette.typefaceInvert : colorPalette.typefacePrimary)
                        .frame(height: Constants.WeekdayLabel.height * scale)
                    Text(viewModel.month)
                        .font(.Body2.semiBold())
                        .foregroundColor(viewModel.disabled ? colorPalette.textGrey3 : selectedDayTimeSlot?.slotDate == viewModel.stringDate ? colorPalette.typefaceInvert : colorPalette.textGrey2)
                        .frame(height: Constants.DayMonthLabel.height * scale)
                }
                .frame(width: Constants.General.width * scale, height: Constants.General.height * scale)
                .background(viewModel.disabled ? colorPalette.textGrey5 :  selectedDayTimeSlot?.slotDate == viewModel.stringDate ? colorPalette.primaryBlue : colorPalette.secondaryWhite)
                .cornerRadius(Constants.General.cornerRadius)
            }
            .standardCardFormat(isDisabled: .constant(viewModel.disabled))
            
            if viewModel.disabled, let reason = viewModel.disabledReason {
                DayChip(
                    container: viewModel.container,
                    title: reason.uppercased(),
                    type: .chip,
                    scheme: selectedDayTimeSlot?.slotDate == viewModel.stringDate ? .primary : .secondary,
                    size: .large,
                    disabled: true)
                .offset(y: -(Constants.General.height * scale) / 2)
            } else if viewModel.isToday {
                DayChip(
                    container: viewModel.container,
                    title: GeneralStrings.today.localized.uppercased(),
                    type: .chip,
                    scheme: selectedDayTimeSlot?.slotDate == viewModel.stringDate ? .primary : .secondary,
                    size: .large)
                .offset(y: -(Constants.General.height * scale) / 2)
            }
        }
        .toast(isPresenting: $isLoading) {
            AlertToast(displayMode: .alert, type: .loading)
        }
    }
}

struct DaySelectionView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DaySelectionView(viewModel: .init(container: .preview, date: Date(), stringDate: "", disabledReason: "Closed", holiday: false), selectedDayTimeSlot: .constant(RetailStoreSlotDay(status: "", reason: "", slotDate: "", slots: nil)), isLoading: .constant(false))
                .previewLayout(.sizeThatFits)
                .padding()
                .previewCases()
            
            DaySelectionView(viewModel: .init(container: .preview, date: Date().advanced(by: 86400), stringDate: "", holiday: false), selectedDayTimeSlot: .constant(RetailStoreSlotDay(status: "", reason: "", slotDate: "", slots: nil)), isLoading: .constant(false))
                .previewLayout(.sizeThatFits)
                .padding()
                .previewCases()
        }
    }
}
