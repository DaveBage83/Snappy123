//
//  ItemDetailsView.swift
//  SnappyV2
//
//  Created by David Bage on 04/08/2022.
//

import SwiftUI

enum ItemDetailsElementType: String {
    case bullet
    case table
    case text
}

class ItemDetailsViewModel: ObservableObject {
    let container: DIContainer
    let itemDetails: ItemDetails
    
    var header: String? {
        itemDetails.header
    }
    
    var bulletElements: [ItemDetailElement]? {
        itemDetails.elements?.filter { $0.type == ItemDetailsElementType.bullet.rawValue || $0.type == nil }
    }
    
    var tableElements: [ItemDetailElement]? {
        itemDetails.elements?.filter { $0.type == ItemDetailsElementType.table.rawValue }
    }
    
    var textElements: [ItemDetailElement]? {
        itemDetails.elements?.filter { $0.type == ItemDetailsElementType.text.rawValue }
    }
    
    var elements: [ItemDetailElement]? {
        itemDetails.elements
    }

    var hasElements: Bool {
        elements != nil && elements?.isEmpty == false
    }
    
    init(container: DIContainer, itemDetails: ItemDetails) {
        self.container = container
        self.itemDetails = itemDetails
    }
}

struct ItemDetailsView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: ItemDetailsViewModel
    
    private struct Constants {
        static let mainSpacing: CGFloat = 16
        static let gridSpacing: CGFloat = 20
        static let bulletWidth: CGFloat = 3
    }
    
    let columns = [
        GridItem(.flexible(), alignment: .leading),
        GridItem(.flexible(), alignment: .trailing)
    ]
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.mainSpacing) {
            if let header = viewModel.header {
                Text(header)
                    .font(.heading4())
                    .foregroundColor(colorPalette.primaryBlue)
            }
            
            elements            
        }
    }
    
    @ViewBuilder private var elements: some View {
        VStack(alignment: .leading) {
            if let elements = viewModel.elements {
                ForEach(elements, id: \.self) { element in
                    if element.type == ItemDetailsElementType.bullet.rawValue, let text = element.text {
                        bullet(text: text)
                    }
                    
                    if element.type == ItemDetailsElementType.text.rawValue, let text = element.text {
                        Text(text)
                            .font(.Body1.regular())
                            .foregroundColor(colorPalette.typefacePrimary)
                    }
                    
                    if element.type == ItemDetailsElementType.table.rawValue, let rows = element.rows  {
                        ForEach(rows, id: \.self) { row in
                            if let elementColumns = row.columns {
                                LazyVGrid(columns: columns, spacing: Constants.gridSpacing) {
                                    ForEach(elementColumns, id: \.self) { item in
                                       
                                                Text(item)
                                                    .font(.Body1.regular())
                                                    .foregroundColor(colorPalette.typefacePrimary)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private func bullet(text: String) -> some View {
        HStack(alignment: .top) {
            
            Text("\u{25CF}").foregroundColor(colorPalette.textGrey1) + Text("   ") + Text(text)
        }
        .font(.Body1.regular())
        .foregroundColor(colorPalette.typefacePrimary)
    }
}

#if DEBUG
struct ItemDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        ItemDetailsView(viewModel: .init(container: .preview, itemDetails: ItemDetails(
            header: "Test Details",
            elements: [
                ItemDetailElement(
                    type: "bullet",
                    text: "Interesting bullet point",
                    rows: nil),
                ItemDetailElement(
                    type: "bullet",
                    text: "another interesting bullet point",
                    rows: nil)
            ])))
    }
}
#endif
