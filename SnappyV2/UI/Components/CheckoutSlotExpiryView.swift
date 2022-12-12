//
//  CheckoutSlotExpiryView.swift
//  SnappyV2
//
//  Created by David Bage on 09/12/2022.
//

import SwiftUI
import Foundation

struct CheckoutSlotExpiryView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.mainWindowSize) var mainWindowSize
    
    struct Constants {
        static let hSpacing: CGFloat = 4
        static let editIconWidth: CGFloat = 13
        static let padding: CGFloat = 7
    }
    
    @StateObject var viewModel: CheckoutSlotExpiryViewModel
    
    private var colorPalette: ColorPalette {
        .init(container: viewModel.container, colorScheme: colorScheme)
    }
    
    var body: some View {
        HStack {
            Spacer()
            HStack(spacing: Constants.hSpacing) {
                Text(viewModel.timeRemainingString)
                
                Image.Icons.Pen.penCircle
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: Constants.editIconWidth)
                    .foregroundColor(viewModel.expiryState.editIconColor(colorPalette: colorPalette))
            }
            .padding(Constants.padding)
            .background(viewModel.expiryState.color(colorPalette: colorPalette).withOpacity(viewModel.expiryState.pillOpacity))
            .foregroundColor(viewModel.expiryState.textColor(colorPalette: colorPalette))
            .standardPillFormat(outlineColor: viewModel.expiryState.color(colorPalette: colorPalette))
            
            NavigationLink("", isActive: $viewModel.fulfilmentTimeSlotSelectionPresented) {
                FulfilmentTimeSlotSelectionView(viewModel: .init(container: viewModel.container, isInCheckout: true, state: .changeTimeSlot, timeslotSelectedAction: {
                    viewModel.fulfilmentTimeSlotSelectionPresented = false
                }))
            }
            
        }
        .frame(maxWidth: .infinity)
        .animation(.default)
        .onTapGesture {
            viewModel.fulfilmentTimeSlotSelectionPresented = true
        }
        .onReceive(viewModel.timer) { _ in
            viewModel.configureTimeRemaining()
        }
    }
}

#if DEBUG
struct CheckoutSlotExpiryView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutSlotExpiryView(viewModel: .init(
            container: .preview,
            basketSlot: .init(
                todaySelected: nil,
                start: Date(),
                end: Date(),
                expires: Date())))
    }
}
#endif
