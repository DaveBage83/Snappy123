//
//  StoreUnavailableView.swift
//  SnappyV2
//
//  Created by David Bage on 09/06/2022.
//

import SwiftUI

///Used for creating the UI in the FulfilmentTimeSlotSelectionView if a store is either closed or on holiday for a selected date
struct StoreUnavailableView: View {
    typealias TimeslotStrings = Strings.FulfilmentTimeSlotSelection
    
    struct Constants {
        static let vSpacing: CGFloat = 20
        static let iconSize: CGFloat = 24
        static let vPadding: CGFloat = 10
    }
    
    enum StoreUnavailableStatus {
        case paused
        case closed
        
        var headlineText: (standard: String, short: String) {
            switch self {
            case .paused:
                return (TimeslotStrings.StoreUnavailableHeadline.paused.localized, TimeslotStrings.StoreUnavailableHeadline.pausedShort.localized)
            case .closed:
                return (TimeslotStrings.StoreUnavailableHeadline.closed.localized, TimeslotStrings.StoreUnavailableHeadline.closedShort.localized)
            }
        }
        
        var icon: Image {
            switch self {
            case .paused:
                return Image.Icons.pause
            case .closed:
                return Image.Icons.Store.closed
            }
        }
    }
    
    // MARK: - Environment objects
    @Environment(\.colorScheme) var colorScheme
    
    // MARK: - Properties
    let container: DIContainer
    let message: String
    let storeUnavailableStatus: StoreUnavailableStatus
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: container, colorScheme: colorScheme)
    }
    
    // MARK: - Main view
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.vSpacing) {
            Text(TimeslotStrings.Main.noSlots.localized)
                .font(.Body1.semiBold())
                .foregroundColor(colorPalette.primaryBlue)
            
            HStack {
                storeUnavailableStatus.icon
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: Constants.iconSize)
                
                AdaptableText(
                    text: storeUnavailableStatus.headlineText.standard,
                    altText: storeUnavailableStatus.headlineText.short,
                    threshold: nil)
                .font(.Body1.semiBold())
                
            }
            .frame(maxWidth: .infinity)
            .foregroundColor(.white)
            .padding(.vertical, Constants.vPadding)
            .background(colorPalette.primaryRed)
            .standardPillFormat()
            
            ExpandableText(viewModel: .init(
                container: container,
                title: TimeslotStrings.StoreUnavailableMain.closed.localized,
                shortTitle: TimeslotStrings.StoreUnavailableMain.closedShort.localized,
                text: message,
                shortText: message))
        }
    }
}

#if DEBUG
struct OrdersPausedView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            StoreUnavailableView(container: .preview, message: "A very interesting message about the store being closed, which is quite sad but it will be open again soon", storeUnavailableStatus: .paused)
            
            StoreUnavailableView(container: .preview, message: "A very interesting message about the store being closed, which is quite sad but it will be open again soon", storeUnavailableStatus: .closed)
        }
    }
}
#endif
