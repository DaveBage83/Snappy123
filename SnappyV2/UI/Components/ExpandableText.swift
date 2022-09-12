//
//  ExpandableText.swift
//  SnappyV2
//
//  Created by David Bage on 09/06/2022.
//

import SwiftUI

class ExpandableTextViewModel: ObservableObject {
    
    // MARK: - Properties
    let container: DIContainer
    let title: String?
    let shortTitle: String?
    let text: String
    let shortText: String?
    let isComplexItem: Bool
    /// Defaulted to 2 but can be optionally amended via init
    private let initialLineLimit: Int
    
    // MARK: - Publishers
    @Published var lineLimit: Int?
    
    // MARK: - Init
    init(container: DIContainer, title: String?, shortTitle: String?, text: String, shortText: String?, initialLineLimit: Int = 2, isComplexItem: Bool = false) {
        self.container = container
        self.title = title
        self.shortTitle = shortTitle
        self.text = text
        self.shortText = shortText
        self.initialLineLimit = initialLineLimit
        self.lineLimit = initialLineLimit
        self.isComplexItem = isComplexItem
    }
    
    func toggleLineLimit() {
        self.lineLimit = lineLimit == nil ? initialLineLimit : nil
    }
}

struct ExpandableText: View {
    @Environment(\.colorScheme) var colorScheme
    @ScaledMetric var scale: CGFloat = 1 // Used to scale icon for accessibility options
    
    // MARK: - View model
    @StateObject var viewModel: ExpandableTextViewModel
    
    // MARK: - Constants
    struct Constants {
        struct Border {
            static let borderRadius: CGFloat = 8
            static let borderLineWidth: CGFloat = 1
            static let borderLineStroke: CGFloat = 2
        }
        
        struct Main {
            static let spacing: CGFloat = 16
            static let additionalTrailingPadding: CGFloat = 10
        }
        
        struct Button {
            static let size: CGFloat = 14
        }
    }
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    // MARK: - Main view
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Main.spacing) {
            if let title = viewModel.title {
                HStack {
                    AdaptableText(
                        text: title,
                        altText: viewModel.shortTitle ?? title,
                        threshold: nil)
                    .font(viewModel.isComplexItem ? .heading4() : .Body1.semiBold())
                    .foregroundColor(viewModel.isComplexItem ? .black : colorPalette.primaryBlue)
                    
                    Spacer()
                    
                    expandTextButton
                }
            }
            
            AdaptableText(
                text: viewModel.text,
                altText: viewModel.shortText ?? viewModel.text,
                threshold: nil)
            .lineLimit(viewModel.lineLimit ?? nil)
            .font(.Body1.regular())
            .foregroundColor(colorPalette.typefacePrimary)
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(viewModel.isComplexItem ? .horizontal : .all)
        .padding(.trailing, Constants.Main.additionalTrailingPadding)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: Constants.Border.borderRadius).strokeBorder(style: StrokeStyle(lineWidth: viewModel.isComplexItem ? 0 : Constants.Border.borderLineWidth, dash: [Constants.Border.borderLineStroke])).foregroundColor(colorPalette.typefacePrimary.withOpacity(.twenty)))
        .animation(.default)
    }
    
    // MARK: - Expand text button
    private var expandTextButton: some View {
        Button {
            viewModel.toggleLineLimit()
        } label: {
            (viewModel.lineLimit == nil ? Image.Icons.Chevrons.Up.medium : Image.Icons.Chevrons.Down.medium )
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: Constants.Button.size * scale)
                .foregroundColor(colorPalette.primaryBlue)
        }
    }
}

#if DEBUG
struct ExpandableText_Previews: PreviewProvider {
    static var previews: some View {
        ExpandableText(viewModel: .init(container: .preview, title: "The is a title", shortTitle: "Short title", text: "This is some interesting text sdsdsdsdsdsdsddssdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsds", shortText: "Short text"))
    }
}
#endif
