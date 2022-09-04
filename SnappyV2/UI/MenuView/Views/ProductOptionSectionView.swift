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
    
    @StateObject var viewModel: ProductOptionSectionViewModel
    @ObservedObject var optionsViewModel: ProductOptionsViewModel
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            sectionHeading(title: viewModel.title)
            
            optionSectionTypeViews
        }
        .padding(.bottom, 5)
        .bottomSheet(container: optionsViewModel.container, item: $viewModel.bottomSheetValues, title: nil, windowSize: mainWindowSize) { values in
            bottomSheetView()
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
            ForEach(viewModel.selectedOptionValues) { value in
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
        .padding(.bottom, 5)
    }
    
    func optionSection() -> some View {
        ForEach(viewModel.optionValues) { value in
            OptionValueCardView(viewModel: optionsViewModel.makeOptionValueCardViewModel(optionValue: value, optionID: viewModel.optionID, optionsType: viewModel.optionsType), maximumReached: $viewModel.maximumReached)
                .padding([.top, .horizontal])
                .padding(.bottom, 5)
        }
    }
    
    func sizesSection() -> some View {
        ForEach(viewModel.sizeValues) { size in
            OptionValueCardView(viewModel: optionsViewModel.makeOptionValueCardViewModel(size: size), maximumReached: $viewModel.maximumReached)
                .padding([.top, .horizontal])
                .padding(.bottom, 5)
        }
    }
    
    func sectionHeading(title: String) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title).bold()
                Spacer()
            }
            .font(.heading4())
            .foregroundColor(.black)
            
            if viewModel.showOptionLimitationsSubtitle {
                Text(viewModel.optionLimitationsSubtitle)
                    .font(.Body1.regular())
                    .foregroundColor(viewModel.minimumReached ? .black : colorPalette.alertWarning)
            }
        }
        .frame(maxWidth: .infinity)
        .padding([.horizontal, .top])
    }
    
    func bottomSheetView() -> some View {
        ScrollView {
            VStack {
                sectionHeading(title: viewModel.title)
                
                ForEach(viewModel.optionValues) { value in
                    VStack {
                        OptionValueCardView(viewModel: optionsViewModel.makeOptionValueCardViewModel(optionValue: value, optionID: viewModel.optionID, optionsType: viewModel.optionsType), maximumReached: $viewModel.maximumReached)
                    }
                    .padding()
                }
                
                Button(action: { viewModel.dismissBottomSheet() }) {
                    Text("Done")
                        .fontWeight(.semibold)
                }
                .buttonStyle(SnappyMainActionButtonStyle(isEnabled: true))
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
