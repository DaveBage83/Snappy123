//
//  ProductOptionSectionView.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 09/08/2021.
//

import SwiftUI

struct ProductOptionSectionView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.mainWindowSize) var mainWindowSize
    
    struct Constants {
        static let vStackSpacing: CGFloat = 0
        static let padding: CGFloat = 5
        
        struct RequiredPill {
            static let vPadding: CGFloat = 4
            static let hPadding: CGFloat = 12
        }
        
        struct SectionHeading {
            static let checkmarkWidth: CGFloat = 16
            static let vPadding: CGFloat = 12
        }
    }
    
    @StateObject var viewModel: ProductOptionSectionViewModel
    @ObservedObject var optionsViewModel: ProductOptionsViewModel
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    var body: some View {
        VStack(spacing: Constants.vStackSpacing) {
            sectionHeading(title: viewModel.title)
                .background(viewModel.minimumReached ? colorPalette.alertSuccess.withOpacity(.ten) : colorPalette.alertWarning.withOpacity(.ten))
                .padding(.top)
            
            optionSectionTypeViews
        }
        .padding(.bottom, Constants.padding)
        .snappyBottomSheet(container: optionsViewModel.container, item: $viewModel.bottomSheetValues, windowSize: mainWindowSize, omitCloseButton: true) { _ in
            ToastableViewContainer(content: {
                bottomSheetView
            }, viewModel: .init(container: viewModel.container, isModal: true))
        }
        .onDisappear {
            viewModel.removeMinimumReachedFromOptionController()
        }
    }
    
    @ViewBuilder var optionSectionTypeViews: some View {
        switch viewModel.sectionType {
        case .bottomSheet:
            bottomSheetEnableButton()
        case .options:
            optionSection()
        case .sizes:
            sizesSection()
        }
    }
    
    func bottomSheetEnableButton() -> some View {
        Group {
            ForEach(viewModel.selectedOptionValues, id: \.id) { value in
                OptionValueCardView(viewModel: optionsViewModel.makeOptionValueCardViewModel(optionValue: value, optionID: viewModel.optionID, optionsType: viewModel.optionsType), maximumReached: $viewModel.maximumReached)
                    .padding([.top, .horizontal])
            }
            
            Button(action: { viewModel.showBottomSheet() }) {
                OptionValueCardView(viewModel: optionsViewModel.makeOptionValueCardViewModel(optionValue: RetailStoreMenuItemOptionValue(
                    id: 0,
                    name: viewModel.title,
                    extraCost: 0,
                    defaultSelection: 0,
                    sizeExtraCost: nil), optionID: viewModel.optionID, optionsType: .manyMore), maximumReached: $viewModel.maximumReached)
                    .padding([.top, .horizontal])
            }
        }
        .padding(.bottom, Constants.padding)
    }
    
    func optionSection() -> some View {
        ForEach(viewModel.optionValues, id: \.id) { value in
            OptionValueCardView(viewModel: optionsViewModel.makeOptionValueCardViewModel(optionValue: value, optionID: viewModel.optionID, optionsType: viewModel.optionsType), maximumReached: $viewModel.maximumReached)
                .padding([.top, .horizontal])
                .padding(.bottom, Constants.padding)
        }
    }
    
    func sizesSection() -> some View {
        ForEach(viewModel.sizeValues, id: \.id) { size in
            OptionValueCardView(viewModel: optionsViewModel.makeOptionValueCardViewModel(size: size), maximumReached: $viewModel.maximumReached)
                .padding([.top, .horizontal])
                .padding(.bottom, Constants.padding)
        }
    }
    
    private var requiredPill: some View {
        Text(GeneralStrings.required.localized)
            .font(.Caption1.bold())
            .padding(.vertical, Constants.RequiredPill.vPadding)
            .padding(.horizontal, Constants.RequiredPill.hPadding)
            .background(colorPalette.alertWarning)
            .foregroundColor(.white)
            .standardPillFormat()
    }
    
    func sectionHeading(title: String, bottomSheet: Bool = false) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title)
                    .font(.Body1.semiBold())
                    .foregroundColor(colorPalette.typefacePrimary)
                if viewModel.minimumReached {
                    Image.Icons.CircleCheck.filled
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: Constants.SectionHeading.checkmarkWidth)
                        .foregroundColor(colorPalette.alertSuccess)
                } else {
                    requiredPill
                }

                Spacer()
            }
            .font(.Body1.semiBold())
            .foregroundColor(colorPalette.typefacePrimary)
            
            if viewModel.showOptionLimitationsSubtitle {
                Text(viewModel.optionLimitationsSubtitle)
                    .font(.Caption1.semiBold())
                    .foregroundColor(bottomSheet ? colorPalette.primaryBlue : (viewModel.minimumReached ? colorPalette.typefacePrimary : colorPalette.alertWarning))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
        .padding(.vertical, Constants.SectionHeading.vPadding)
    }
    
    var bottomSheetView: some View {
        ScrollView {
            VStack {
                sectionHeading(title: viewModel.title, bottomSheet: true)
                
                ForEach(viewModel.optionValues, id: \.id) { value in
                    VStack {
                        OptionValueCardView(viewModel: optionsViewModel.makeOptionValueCardViewModel(optionValue: value, optionID: viewModel.optionID, optionsType: viewModel.optionsType), maximumReached: $viewModel.maximumReached)
                    }
                    .padding([.top, .horizontal])
                }
                
                SnappyButton(container: viewModel.container, type: .primary, size: .large, title: Strings.General.done.localized, largeTextTitle: nil, icon: nil) {
                    viewModel.dismissBottomSheet()
                }
                .padding()
                .padding(.bottom)
            }
        }
    }
}

#if DEBUG
struct ProductOptionSectionView_Previews: PreviewProvider {
    @StateObject static var optionsViewModel = ProductOptionsViewModel(container: .preview, item: MockData.item)
    
    static var previews: some View {
        Group {
            ProductOptionSectionView(viewModel: ProductOptionSectionViewModel(container: .preview, itemOption: MockData.drinks, optionID: 123, optionController: OptionController()), optionsViewModel: optionsViewModel)
                .previewDisplayName("ManyMore with BottomSheet")
            
            ProductOptionSectionView(viewModel: ProductOptionSectionViewModel(container: .preview, itemOption: MockData.makeAMeal, optionID: 123, optionController: OptionController()), optionsViewModel: optionsViewModel)
                .previewDisplayName("Dependent Options")

            ProductOptionSectionView(viewModel: ProductOptionSectionViewModel(container: .preview, itemSizes: [MockData.sizeS, MockData.sizeM, MockData.sizeL], optionController: OptionController()), optionsViewModel: optionsViewModel)
                .previewDisplayName("Radio")
            
            ProductOptionSectionView(viewModel: ProductOptionSectionViewModel(container: .preview, itemOption: MockData.toppings, optionID: 123, optionController: OptionController()), optionsViewModel: optionsViewModel)
                .previewDisplayName("CheckBox")
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
#endif
