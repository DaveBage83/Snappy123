//
//  DigitalHighstreet.swift
//  SnappyV2
//
//  Created by David Bage on 30/01/2023.
//

import SwiftUI
import Combine

struct DigitalHighstreet: View {
    // MARK: - Environment
    @Environment(\.colorScheme) var colorScheme
    
    // MARK: - Constants
    struct Constants {
        struct PillView {
            static let hSpacing: CGFloat = 12
        }
        
        struct StoreTypeCard {
            static let cornerRadius: CGFloat = 8
            static let textPadding: CGFloat = 8
            static let height: CGFloat = 104
        }
        
        struct Chevron {
            static let width: CGFloat = 20
        }
        
        struct CategoryPill {
            static let padding: CGFloat = 8
            static let vPadding: CGFloat = 3
        }
    }
    
    // MARK: - View model
    // ObservedObject rather than StateObject here as StoresView has ownership of this viewModel
    @ObservedObject var viewModel: StoresViewModel
    
    // MARK: - Grid layout
    private let columns = [
        GridItem(.flexible(), alignment: .center),
        GridItem(.flexible(), alignment: .center)
    ]
    
    // MARK: - Colours
    private var colorPalette: ColorPalette {
        .init(container: viewModel.container, colorScheme: colorScheme)
    }
        
    // MARK: - Main body
    var body: some View {
        VStack {
            ZStack(alignment: .topTrailing) {
                HStack {
                    Text(Strings.DigitalHighstreet.selectStore.localized)
                        .font(.Body2.semiBold())
                        .foregroundColor(colorPalette.typefacePrimary)
                    
                    +
                    
                    Text(Strings.DigitalHighstreet.buildAndPay.localized)
                        .font(.Body2.semiBold())
                        .foregroundColor(colorPalette.textGrey2)
                }
                .frame(maxWidth: .infinity)
                
                Button {
                    withAnimation {
                        viewModel.showDigitalHighstreetView.toggle()
                    }
                    
                } label: {
                    (viewModel.showDigitalHighstreetView ? Image.Icons.Chevrons.Up.heavy : Image.Icons.Chevrons.Down.heavy)
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: Constants.Chevron.width)
                        .foregroundColor(colorPalette.primaryBlue)
                }
            }
            .padding(.horizontal)
            
            if viewModel.showDigitalHighstreetView {
                VStack {
                    if let heroStoreType = viewModel.heroStoreType {
                        storeTypeCard(storeType: heroStoreType)
                            .frame(maxWidth: .infinity)
                    }
                    
                    LazyVGrid(columns: columns, content: {
                        ForEach(viewModel.standardStoreTypes, id: \.id) { storeType in
                            storeTypeCard(storeType: storeType)
                        }
                    })
                }
                .padding(.horizontal)
                .transition(.scale(scale: 0.0, anchor: .top))
            } else {
                pillView
                    .animation(Animation.default.delay(viewModel.pillCarouselAnimationDelay))
                    .transition(.slide)
            }
        }
    }
    
    // MARK: - Store types - card
    private func storeTypeCard(storeType: RetailStoreProductType) -> some View {
        Button {
            withAnimation {
                viewModel.selectStoreType(type: storeType.id)
            }
        } label: {
            ZStack(alignment: .topLeading) {
                Rectangle()
                    .fill(Color.clear)
                    .cornerRadius(Constants.StoreTypeCard.cornerRadius)
                
                Text(storeType.name)
                    .font(.heading4())
                    .foregroundColor(.white)
                    .padding(Constants.StoreTypeCard.textPadding)
                    .transition(.scale)
            }
            .background(
                AsyncImage(
                    container: viewModel.container,
                    urlString: storeType.image?[AppV2Constants.API.imageScaleFactor]?.absoluteString)
                .aspectRatio(contentMode: .fill)
            )
            .frame(height: Constants.StoreTypeCard.height)
            .cornerRadius(Constants.StoreTypeCard.cornerRadius)
        }
    }
    
    // MARK: - Store types - pill carousel
    private var pillView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            ScrollViewReader { value in
                HStack(spacing: Constants.PillView.hSpacing) {
                    Button(action: {
                        viewModel.selectStoreType(type: nil)
                    }) {
                        categoryPill(
                            text: Strings.DigitalHighstreet.allStores.localized,
                            isSelected: viewModel.allStoresSelected)
                    }
                    
                    if let storeTypes = viewModel.retailStoreTypes {
                        ForEach(storeTypes, id: \.self) { storeType in
                            Button(action: {
                                viewModel.selectStoreType(type: storeType.id)
                            }) {
                                categoryPill(
                                    text: storeType.name,
                                    isSelected: viewModel.isSelectedStoreType(storeTypeID: storeType.id))
                            }
                            .id(storeType.id)
                        }
                    }
                }
                .padding(.horizontal)
                .onAppear {
                    withAnimation {
                        value.scrollTo(viewModel.selectedStoreTypeID, anchor: .center)
                    }
                }
            }
        }
    }
    
    // MARK: - Store types - individual pill factory
    @ViewBuilder private func categoryPill(text: String, isSelected: Bool) -> some View {
        Text(text)
            .font(.Body2.semiBold())
            .foregroundColor(isSelected ? .white : colorPalette.typefacePrimary)
            .padding(Constants.CategoryPill.padding)
            .background(isSelected ? colorPalette.secondaryDark : colorPalette.typefaceInvert)
            .standardPillFormat(outlineColor: colorPalette.typefacePrimary)
            .padding(.vertical, Constants.CategoryPill.vPadding)
    }
}

#if DEBUG
struct DigitalHighstreet_Previews: PreviewProvider {
    static var previews: some View {
        DigitalHighstreet(viewModel: .init(container: .preview))
    }
}
#endif
