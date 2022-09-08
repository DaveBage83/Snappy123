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
            static let horizontalViewPadding: CGFloat = 20
            static let maxframeWidth: CGFloat = 350
            static let cornerRadius: CGFloat = 10
            static let vStackSpacing: CGFloat = 11
            static let opacity: CGFloat = 0.2
            static let buttonPadding: CGFloat = -10
            static let dividerHeight: CGFloat = 50
            static let starWidth: CGFloat = 38
        }
    }
    
    // MARK: - View model
    @StateObject var viewModel: StoreReviewViewModel
    @State var frameWidth: CGFloat = Constants.StoreReviewView.maxframeWidth
    
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
    }
    
    private func widthDependepentView(width: CGFloat) -> some View {
        let widthWithPadding = width - (Constants.StoreReviewView.horizontalViewPadding * 2)
        if widthWithPadding > Constants.StoreReviewView.maxframeWidth {
            frameWidth = Constants.StoreReviewView.maxframeWidth
        } else {
            frameWidth = widthWithPadding
        }
        return Color.black.opacity(Constants.StoreReviewView.opacity)
    }
    
    // MARK: - Main content
    var body: some View {
        ZStack {
            
            GeometryReader { geometry in
                widthDependepentView(width: geometry.size.width)
            }.ignoresSafeArea()
            
            VStack(spacing: Constants.StoreReviewView.vStackSpacing) {
            
                Text(viewModel.instructions)
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.snappyHeadline)
                    //.frame(maxWidth: .infinity)
                    .foregroundColor(colorPalette.primaryBlue)
                
                HStack {
                    AsyncImage(urlString: /*viewModel.storeDetails.storeLogo?[AppV2Constants.API.imageScaleFactor]?.absoluteString*/viewModel.review.logo?.absoluteString, placeholder: {
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
                }
                
                Divider()
                
                HStack {
                    starView(rating: 1)
                    starView(rating: 2)
                    starView(rating: 3)
                    starView(rating: 4)
                    starView(rating: 5)
                }
                
                Divider()
                
                SnappyMultilineTextField(
                    container: viewModel.container,
                    placeholder: viewModel.commentsPlaceholder,
                    text: $viewModel.comments,
                    minHeight: 100
                ) {
                        
                }
                    
                SnappyButton(
                    container: viewModel.container,
                    type: .primary,
                    size: .large,
                    title: Strings.General.submit.localized,
                    largeTextTitle: nil,
                    icon: nil,
                    isLoading: $viewModel.submittingReview
                ) {
                        viewModel.dismissPushNotificationPrompt()
                }
                
            }
            .padding()
            .frame(width: frameWidth)
            .background(colorPalette.secondaryWhite)
            .cornerRadius(Constants.StoreReviewView.cornerRadius)

        }
        .font(.body)
        .withAlertToast(container: viewModel.container, error: $viewModel.error)
        .alert(isPresented: $viewModel.showSubmittedConfirmation) {
            Alert(
                title: Text(Strings.PushNotifications.call.localized),
                message: Text(viewModel.showTelephoneNumber),
                dismissButton: .default(Text(Strings.General.close.localized))
            )
        }

    }
}

#if DEBUG
struct StoreReviewView_Previews: PreviewProvider {
    static var previews: some View {
        
        StoreReviewView(
            viewModel: .init(
                container: .preview,
                review: RetailStoreReview(
                    logo: nil,
                    name: "Coop, Newhaven Rd",
                    address: "Address line1, address line 2, Town name, PA344AG"
                ),
                dismissPushNotificationViewHandler: {}
            )
        )
            .previewDevice(PreviewDevice(rawValue: "iPod touch (7th generation)"))
            .previewDisplayName("iPod Touch")
        
        StoreReviewView(
            viewModel: .init(
                container: .preview,
                review: RetailStoreReview(
                    logo: nil,
                    name: "Test Store",
                    address: "Some address"
                ),
                dismissPushNotificationViewHandler: {}
            )
        )
            .previewDevice(PreviewDevice(rawValue: "iPhone 12"))
            .previewDisplayName("iPhone 12")
        
        StoreReviewView(
            viewModel: .init(
                container: .preview,
                review: RetailStoreReview(
                    logo: nil,
                    name: "Test Store",
                    address: "Some address"
                ),
                dismissPushNotificationViewHandler: {}
            )
        )
            .previewDevice(PreviewDevice(rawValue: "iPhone 12 Max"))
            .previewDisplayName("iPhone 12 Max")
        
        
    }
}
#endif
