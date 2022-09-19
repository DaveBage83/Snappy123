//
//  ExpandableContentView.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 15/09/2022.
//

import SwiftUI

class ExpandableContentViewModel: ObservableObject {
    
    // MARK: - Properties
    let container: DIContainer
    let title: String?
    let shortTitle: String?
    @Published var showExpandableContent: Bool
    
    // MARK: - Init
    init(container: DIContainer, title: String?, shortTitle: String?, showExpandableContent: Bool = false) {
        self.container = container
        self.title = title
        self.shortTitle = shortTitle
        self.showExpandableContent = showExpandableContent
    }
    
    func toggleLineLimit() {
        self.showExpandableContent.toggle()
    }
}

struct ExpandableContentView<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    @ScaledMetric var scale: CGFloat = 1 // Used to scale icon for accessibility options
    
    // MARK: - View model
    @StateObject var viewModel: ExpandableContentViewModel
    @ViewBuilder let content: Content
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    // MARK: - Main view
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let title = viewModel.title {
                HStack {
                    AdaptableText(
                        text: title,
                        altText: viewModel.shortTitle ?? title,
                        threshold: nil)
                    .font(.heading4())
                    .foregroundColor(.black)
                    
                    Spacer()
                    
                    expandTextButton
                    
                }
            }
            
            if viewModel.showExpandableContent {
                content
            }
        }
        .padding(.horizontal)
        .padding(.trailing, 10)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 8).strokeBorder(style: StrokeStyle(lineWidth: 0, dash: [2])).foregroundColor(colorPalette.typefacePrimary.withOpacity(.twenty)))
        .animation(.default)
    }
    
    // MARK: - Expand text button
    private var expandTextButton: some View {
        Button {
            viewModel.toggleLineLimit()
        } label: {
            (viewModel.showExpandableContent ? Image.Icons.Chevrons.Up.medium : Image.Icons.Chevrons.Down.medium )
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 14 * scale)
                .foregroundColor(colorPalette.primaryBlue)
        }
    }
}

#if DEBUG
struct ExpandableContentView_Previews: PreviewProvider {
    static var previews: some View {
        ExpandableContentView(viewModel: ExpandableContentViewModel(container: .preview, title: "The Main Title", shortTitle: "Short"), content: { Text("Hello World!!!") })
    }
}
#endif
