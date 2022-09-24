//
//  StoreReviewView.swift
//  SnappyV2
//
//  Created by Kevin Palser on 06/09/2022.
//

import SwiftUI

struct StoreReviewView: View {
    
    // MARK: - Typealiases
    typealias StoreReviewStrings = Strings.StoreReview
    
    // MARK: - Environment objects
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.openURL) private var openURL
    
    // MARK: - Constants
    struct Constants {
        
        struct Logo {
            static let size: CGFloat = 96
            static let cornerRadius: CGFloat = 8
            static let reviewPillYOffset: CGFloat = 9
        }
        
        struct Address {
            static let vStackSpacing: CGFloat = 2
        }
        
        struct Star {
            static let topBottomPadding: CGFloat = 5
            static let width: CGFloat = 38
        }
        
        struct StoreReviewView {
            static let padding: CGFloat = 20
            static let maxframeWidth: CGFloat = 350
            static let cornerRadius: CGFloat = 10
            static let vStackSpacing: CGFloat = 11
            static let opacity: CGFloat = 0.2
            static let starWidth: CGFloat = 38
            static let commentsMinHeight: CGFloat = 100
        }
        
        struct ActionRequired {
            static let spacing: CGFloat = 16
            static let iconHeight: CGFloat = 16
            static let fontPadding: CGFloat = 12
            static let externalPadding: CGFloat = 32
            static let lineLimit = 5
        }
        
        struct CloseButton {
            static let offset: CGFloat = 8
            static let height: CGFloat = 15
        }
    }
    
    // MARK: - View model
    @StateObject var viewModel: StoreReviewViewModel
    
    // MARK: - Colors
    private var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    private var color: Color {
        switch viewModel.rating {
        case 1, 2: return colorPalette.twoStar
        case 3: return colorPalette.threeStar
        case 4: return colorPalette.fourStar
        case 5: return colorPalette.fiveStar
        default: return colorPalette.textGrey4
        }
    }
    
    private func starView(rating: Int) -> some View {
        Button(action: {
            viewModel.tappedStar(rating: rating)
        }) {
            Image.Icons.star
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .fixedSize(horizontal: false, vertical: true)
                .frame(width: Constants.Star.width)
                .foregroundColor(viewModel.rating >= rating ? color : colorPalette.textGrey4)
                .padding([.top, .bottom], Constants.Star.topBottomPadding)
        }
        .disabled(viewModel.submittingReview)
    }
    
    // MARK: - Main content
    var body: some View {
        ZStack {
            
            Color.black.opacity(Constants.StoreReviewView.opacity)
                .edgesIgnoringSafeArea(.all)
        
            ZStack(alignment: .topTrailing) {
                
                
                VStack(alignment: .leading, spacing: Constants.StoreReviewView.vStackSpacing) {
                    
                    Text(viewModel.instructions)
                        .fixedSize(horizontal: false, vertical: true)
                        .font(.heading3())
                        .foregroundColor(colorPalette.primaryBlue)
                    
                    HStack {
                        Spacer()
                        AsyncImage(urlString: viewModel.review.logo?.absoluteString, placeholder: {
                            Image.Placeholders.productPlaceholder
                                .resizable()
                                .frame(width: Constants.Logo.size, height: Constants.Logo.size)
                                .scaledToFill()
                                .cornerRadius(Constants.Logo.cornerRadius)
                        })
                        .frame(width: Constants.Logo.size, height: Constants.Logo.size)
                        .scaledToFit()
                        .cornerRadius(Constants.Logo.cornerRadius)
                        
                        VStack(alignment: .leading, spacing: Constants.Address.vStackSpacing) {
                            Text(viewModel.review.name)
                                .font(.Body1.semiBold())
                                .foregroundColor(colorPalette.typefacePrimary)
                            
                            Text(viewModel.review.address)
                                .font(.Body2.regular())
                                .foregroundColor(colorPalette.typefacePrimary)
                        }
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                        Spacer()
                    }
                    
                    Divider()
                        .fixedSize(horizontal: false, vertical: true)
                    
                    HStack {
                        Spacer()
                        starView(rating: 1)
                        starView(rating: 2)
                        starView(rating: 3)
                        starView(rating: 4)
                        starView(rating: 5)
                        Spacer()
                    }
                    
                    Divider()
                        .fixedSize(horizontal: false, vertical: true)
                    
                    SnappyMultilineTextField(
                        container: viewModel.container,
                        placeholder: viewModel.commentsPlaceholder,
                        text: $viewModel.comments,
                        minHeight: Constants.StoreReviewView.commentsMinHeight
                    ) {
                        
                    }
                    
                    if viewModel.showMissingWarning {
                        HStack(alignment: .top, spacing: Constants.ActionRequired.spacing) {
                            
                            Text(viewModel.missingWarning)
                            
                            Image.Icons.Triangle.filled
                                .renderingMode(.template)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: Constants.ActionRequired.iconHeight)
                                .foregroundColor(colorPalette.primaryRed)
                        }
                        .padding(.vertical, Constants.ActionRequired.fontPadding)
                        .font(.subheadline)
                        .foregroundColor(colorPalette.primaryRed)
                        .background(colorPalette.secondaryWhite)
                        
                    } else {
                        SnappyButton(
                            container: viewModel.container,
                            type: .primary,
                            size: .large,
                            title: Strings.General.submit.localized,
                            largeTextTitle: nil,
                            icon: nil,
                            isLoading: $viewModel.submittingReview
                        ) {
                            Task {
                                await viewModel.tappedSubmitReview()
                            }
                        }
                    }
                    
                }
                .padding(Constants.StoreReviewView.padding)
                .frame(maxWidth: Constants.StoreReviewView.maxframeWidth)
                .background(colorPalette.secondaryWhite)
                .cornerRadius(Constants.StoreReviewView.cornerRadius)
                
                Button(action: {
                    viewModel.tappedClose()
                }) {
                    Image.Icons.Xmark.heavy
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: Constants.CloseButton.height)
                        .foregroundColor(colorPalette.primaryBlue)
                        .offset(x: -Constants.CloseButton.offset, y: Constants.CloseButton.offset)
                }
                .disabled(viewModel.submittingReview)
            }
        }
        .withAlertToast(container: viewModel.container, error: $viewModel.error)

    }
}

#if DEBUG
struct StoreReviewView_Previews: PreviewProvider {
    static var previews: some View {
        
        StoreReviewView(
            viewModel: .init(
                container: .preview,
                review: RetailStoreReview(
                    orderId: 123456,
                    hash: "String",
                    logo: URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/xxhdpi_3x/1585850492Untitleddesign33.png")!,
                    name: "Coop, Newhaven Rd",
                    address: "Address line1\nPA344AG"
                ),
                dismissStoreReviewViewHandler: { _ in }
            )
        )
            .previewDevice(PreviewDevice(rawValue: "iPod touch (7th generation)"))
            .previewDisplayName("iPod Touch")
        
        StoreReviewView(
            viewModel: .init(
                container: .preview,
                review: RetailStoreReview(
                    orderId: 123456,
                    hash: "String",
                    logo: URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/xxhdpi_3x/1585850492Untitleddesign33.png")!,
                    name: "Coop, Newhaven Rd",
                    address: "Address line1\nPA344AG"
                ),
                dismissStoreReviewViewHandler: { _ in }
            )
        )
            .previewDevice(PreviewDevice(rawValue: "iPhone 12"))
            .previewDisplayName("iPhone 12")
        
        StoreReviewView(
            viewModel: .init(
                container: .preview,
                review: RetailStoreReview(
                    orderId: 123456,
                    hash: "String",
                    logo: URL(string: "https://www.snappyshopper.co.uk/uploads/images/stores/xxhdpi_3x/1585850492Untitleddesign33.png")!,
                    name: "Coop, Newhaven Rd",
                    address: "Address line1\nPA344AG"
                ),
                dismissStoreReviewViewHandler: { _ in }
            )
        )
            .previewDevice(PreviewDevice(rawValue: "iPhone 12 Max"))
            .previewDisplayName("iPhone 12 Max")
        
        
    }
}
#endif
