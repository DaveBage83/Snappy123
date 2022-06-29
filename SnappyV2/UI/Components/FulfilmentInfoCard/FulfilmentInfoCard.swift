//
//  FulfilmentInfoCard.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 15/02/2022.
//

import SwiftUI

struct FulfilmentInfoCard: View {
    // MARK: - Environment objects
    @Environment(\.colorScheme) var colorScheme
    @ScaledMetric var scale: CGFloat = 1 // Used to scale icon for accessibility options
    @Environment(\.sizeCategory) var sizeCategory: ContentSizeCategory
    @Environment(\.horizontalSizeClass) var sizeClass
    
    // MARK: - Constants
    private struct Constants {
        static let minimalLayoutThreshold: Int = 7
        
        struct Logo {
            static let size: CGFloat = 56
            static let cornerRadius: CGFloat = 8
            static let lineWidth: CGFloat = 1
            static let padding: CGFloat = 4
        }
        
        struct Main {
            static let spacing: CGFloat = 10
        }
        
        struct FulfilmentIcon {
            static let height: CGFloat = 13
        }
        
        struct FulfilmentSlotExpired {
            static let hPadding: CGFloat = 8
            static let vPadding: CGFloat = 4
        }
        
        struct FulfilmentSlot {
            static let spacing: CGFloat = 2
        }
        
        struct EditButton {
            static let width: CGFloat = 60
        }
    }
    
    // MARK: - View Model
    @StateObject var viewModel: FulfilmentInfoCardViewModel
    
    // MARK: - Computed variables
    private var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    private var fulfilmentIcon: Image {
        if viewModel.container.appState.value.userData.selectedFulfilmentMethod == .delivery {
            return Image.Icons.Truck.standard
        } else {
            return Image.Icons.BagShopping.standard
        }
    }
    
    private var changeFulfilmentIcon: Image {
        if viewModel.container.appState.value.userData.selectedFulfilmentMethod == .delivery {
            return Image.Icons.BagShopping.standard
        } else {
            return Image.Icons.Truck.standard
        }
    }
    
    private var changeSlotText: String {
        if viewModel.container.appState.value.userData.selectedFulfilmentMethod == .delivery {
            return Strings.FulfilmentInfoCard.editDelivery.localized
        }
        
        return Strings.FulfilmentInfoCard.editCollection.localized
    }
    
    private var changeFulfilmentTypeText: String {
        if viewModel.container.appState.value.userData.selectedFulfilmentMethod == .delivery {
            return Strings.FulfilmentInfoCard.changeToCollect.localized
        }
        
        return Strings.FulfilmentInfoCard.changeToDeliver.localized
    }
    
    private var minimalLayout: Bool {
        sizeCategory.size > Constants.minimalLayoutThreshold && sizeClass == .compact
    }
    
    // MARK: - Main view
    var body: some View {
        HStack(spacing: Constants.Main.spacing) {
            
            if minimalLayout == false {
                storeLogo
            }
            
            fulfilmentSlot
            
            Spacer()
            
            editTimeSlotButton
            
            // Fulfilment slot selection
            NavigationLink("", isActive: $viewModel.isFulfilmentSlotSelectShown) {
                FulfilmentTimeSlotSelectionView(viewModel: .init(container: viewModel.container, isInCheckout: viewModel.isInCheckout, state: .changeTimeSlot, timeslotSelectedAction: {
                    viewModel.isFulfilmentSlotSelectShown = false
                }))
            }
        }
        .padding()
        .background(viewModel.isSlotExpired ? colorPalette.primaryRed.withOpacity(.twenty) : colorPalette.secondaryWhite)
        .standardCardFormat()
    }
    
    // MARK: - Selected store logo
    private var storeLogo: some View {
        AsyncImage(urlString: viewModel.selectedStore?.storeLogo?[AppV2Constants.API.imageScaleFactor]?.absoluteString, placeholder: {
            Image.Placeholders.productPlaceholder
                .resizable()
                .frame(width: Constants.Logo.size, height: Constants.Logo.size)
                .scaledToFill()
                .cornerRadius(Constants.Logo.cornerRadius)
        })
        .frame(width: Constants.Logo.size, height: Constants.Logo.size)
        .scaledToFit()
        .cornerRadius(Constants.Logo.cornerRadius)
        .padding(Constants.Logo.padding)
        .overlay(
            RoundedRectangle(cornerRadius: Constants.Logo.cornerRadius)
                .stroke(colorPalette.typefacePrimary.withOpacity(.ten), lineWidth: 1)
        )
    }
    
    // MARK: - Fulfilment slot
    private var fulfilmentSlot: some View {
            
            VStack(alignment: .leading, spacing: Constants.FulfilmentSlot.spacing) {
                Text(viewModel.selectedStore?.nameWithAddress1 ?? "")
                    .font(.Body2.semiBold())
                    .foregroundColor(colorPalette.typefacePrimary)
                
                HStack {
                    if minimalLayout == false {
                        fulfilmentIcon
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: Constants.FulfilmentIcon.height * scale)
                            .foregroundColor(colorPalette.primaryBlue)
                    }
                    
                    if viewModel.isSlotExpired {
                        Text(Strings.BasketView.slotExpired.localized)
                            .font(.Caption2.semiBold())
                            .foregroundColor(.white)
                            .padding(.horizontal, Constants.FulfilmentSlotExpired.hPadding)
                            .padding(.vertical, Constants.FulfilmentSlotExpired.vPadding)
                            .background(colorPalette.primaryRed)
                            .standardPillFormat()
                        
                    } else {
                        Text(viewModel.fulfilmentTimeString)
                            .font(.Body2.semiBold())
                            .foregroundColor(colorPalette.primaryBlue)
                    }
                }
            }
    }

    // MARK: - Edit time slot button
    private var editTimeSlotButton: some View {
        SnappyButton(
            container: viewModel.container,
            type: .outline,
            size: .medium,
            title: GeneralStrings.edit.localized,
            largeTextTitle: nil,
            icon: Image.Icons.Pen.standard) {
                viewModel.showFulfilmentSelectView()
            }
            .frame(width: Constants.EditButton.width)
    }
}

#if DEBUG
struct DeliveryInfoCard_Previews: PreviewProvider {
    static var previews: some View {
        FulfilmentInfoCard(viewModel: .init(container: .preview))
            .previewLayout(.sizeThatFits)
            .padding()
            .previewCases()
    }
}
#endif
