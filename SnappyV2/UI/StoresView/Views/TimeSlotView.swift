//
//  TimeSlotView.swift
//  SnappyV2Study
//
//  Created by Henrik Gustavii on 16/06/2021.
//

import SwiftUI

struct TimeSlotView: View {
    @ScaledMetric var scale: CGFloat = 1 // Used to scale icon for accessibility options
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: TimeSlotViewModel
    @Binding var selectedTimeSlot: RetailStoreSlotDayTimeSlot?
    
    struct Constants {
        static let stackSpacing: CGFloat = 2
        static let textHeight: CGFloat = 16
        static let hPadding: CGFloat = 10
        static let cardHeight: CGFloat = 50
        static let cardWidth: CGFloat = 104
    }
    
    var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    var body: some View {
        Button(action: { selectedTimeSlot = viewModel.timeSlot }) {
            VStack(alignment: .leading, spacing: Constants.stackSpacing) {
                Text("\(viewModel.startTime) - \(viewModel.endTime)")
                    .font(.Body2.semiBold())
                    .foregroundColor(selectedTimeSlot?.slotId == viewModel.timeSlot.slotId ? colorPalette.typefaceInvert : colorPalette.typefacePrimary.opacity(viewModel.disabled ? 0.5 : 1.0))
                    .frame(height: Constants.textHeight * scale)
                Text(viewModel.cost)
                    .font(.Body2.regular())
                    .foregroundColor(selectedTimeSlot?.slotId == viewModel.timeSlot.slotId ? colorPalette.typefaceInvert : colorPalette.textGrey1.opacity(viewModel.disabled ? 0.5 : 1.0))
                    .frame(height: Constants.textHeight * scale)
            }
            .padding(.horizontal, Constants.hPadding)
            .frame(width: Constants.cardWidth * scale, height: Constants.cardHeight * scale, alignment: .leading)
            .background(selectedTimeSlot?.slotId == viewModel.timeSlot.slotId ? colorPalette.primaryBlue : colorPalette.secondaryWhite)
            .standardCardFormat(container: viewModel.container)
        }.disabled(viewModel.disabled)
    }
}

#if DEBUG
struct TimeSlotView_Previews: PreviewProvider {
    static var previews: some View {
        TimeSlotView(viewModel: TimeSlotViewModel(container: .preview ,timeSlot: RetailStoreSlotDayTimeSlot(slotId: "1", startTime: Date(), endTime: Date(), daytime: "morning", info: RetailStoreSlotDayTimeSlotInfo(status: "", isAsap: false, price: 3.5, fulfilmentIn: ""))), selectedTimeSlot: .constant(nil))
            .previewLayout(.sizeThatFits)
            .padding()
            .previewCases()
    }
}
#endif
