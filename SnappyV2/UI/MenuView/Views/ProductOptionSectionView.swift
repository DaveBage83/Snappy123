//
//  ProductOptionSectionView.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 09/08/2021.
//

import SwiftUI

struct ProductOptionSectionView: View {
    @EnvironmentObject var optionsViewModel: ProductOptionsViewModel
    @StateObject var viewModel: ProductOptionSectionViewModel
    
    var body: some View {
        LazyVStack(spacing: 0) {
            sectionHeading(title: viewModel.title)
            
            optionSectionTypeViews
        }
        .padding(.bottom, 5)
        .bottomSheet(item: $viewModel.bottomSheetValues) { values in
            bottomSheetView()
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
                OptionValueCardView(viewModel: optionsViewModel.makeOptionValueCardViewModel(optionValue: value, optionID: viewModel.optionID, optionsType: viewModel.optionsType), maxiumReached: $viewModel.maximumReached)
                    .padding([.top, .horizontal])
            }
            
            Button(action: { viewModel.showBottomSheet() }) {
                OptionValueCardView(viewModel: optionsViewModel.makeOptionValueCardViewModel(optionValue: MenuItemOptionValue(id: 0, name: "Add \(viewModel.title)", extraCost: nil, default: nil, sizeExtraCost: nil), optionID: viewModel.optionID, optionsType: .manyMore), maxiumReached: $viewModel.maximumReached)
                    .padding([.top, .horizontal])
            }
        }
        .padding(.bottom, 5)
    }
    
    func optionSection() -> some View {
        ForEach(viewModel.optionValues) { value in
            OptionValueCardView(viewModel: optionsViewModel.makeOptionValueCardViewModel(optionValue: value, optionID: viewModel.optionID, optionsType: viewModel.optionsType), maxiumReached: $viewModel.maximumReached)
                .padding([.top, .horizontal])
                .padding(.bottom, 5)
        }
    }
    
    func sizesSection() -> some View {
        ForEach(viewModel.sizeValues) { size in
            OptionValueCardView(viewModel: optionsViewModel.makeOptionValueCardViewModel(size: size), maxiumReached: $viewModel.maximumReached)
                .padding([.top, .horizontal])
                .padding(.bottom, 5)
        }
    }
    
    func sectionHeading(title: String) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Choose")
                Text(title).bold()
                Spacer()
            }
            .font(.snappyBody)
            .foregroundColor(.snappyTextGrey2)
            
            
            Text(viewModel.optionLimitationsSubtitle)
                .font(.snappyCaption)
                .foregroundColor(.snappyRed)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.snappyTextGrey4)
    }
    
    func bottomSheetView() -> some View {
        ScrollView {
            VStack {
                sectionBottomSheetHeading(title: viewModel.title)
                
                ForEach(viewModel.optionValues) { value in
                    VStack {
                        OptionValueCardView(viewModel: optionsViewModel.makeOptionValueCardViewModel(optionValue: value, optionID: viewModel.optionID, optionsType: viewModel.optionsType), maxiumReached: $viewModel.maximumReached)
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
    
    func sectionBottomSheetHeading(title: String) -> some View {
        VStack {
            HStack {
                Text("Choose ")
                Text(title).bold()
                Spacer()
            }
            .font(.snappyBody)
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white)
            
            Text(viewModel.optionLimitationsSubtitle)
                .font(.snappyBody)
                .foregroundColor(.snappyRed)
        }
    }
}

struct ProductOptionSectionView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ProductOptionSectionView(viewModel: ProductOptionSectionViewModel(itemOption: MockData.drinks, optionID: 123, optionController: OptionController()))
                .environmentObject(ProductOptionsViewModel(item: MockData.item))
                .previewDisplayName("ManyMore with BottomSheet")
            
            ProductOptionSectionView(viewModel: ProductOptionSectionViewModel(itemOption: MockData.makeAMeal, optionID: 123, optionController: OptionController()))
                .environmentObject(ProductOptionsViewModel(item: MockData.item))
                .previewDisplayName("Dependent Options")

            ProductOptionSectionView(viewModel: ProductOptionSectionViewModel(itemSizes: [MockData.sizeS, MockData.sizeM, MockData.sizeL], optionController: OptionController()))
                .environmentObject(ProductOptionsViewModel(item: MockData.item))
                .previewDisplayName("Radio")
            
            ProductOptionSectionView(viewModel: ProductOptionSectionViewModel(itemOption: MockData.toppings, optionID: 123, optionController: OptionController()))
                .environmentObject(ProductOptionsViewModel(item: MockData.item))
                .previewDisplayName("CheckBox")
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }
}