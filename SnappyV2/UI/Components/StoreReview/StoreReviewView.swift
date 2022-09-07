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
        
        struct StoreReviewView {
            static let frameWidth: CGFloat = 300
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
                .frame(width: Constants.StoreReviewView.starWidth)
                .foregroundColor(viewModel.rating >= rating ? color : colorPalette.textGrey4)
        }
    }
    
    // MARK: - Main content
    var body: some View {
        ZStack {
            Color.black.opacity(Constants.StoreReviewView.opacity)
                .ignoresSafeArea()
            
            VStack(spacing: Constants.StoreReviewView.vStackSpacing) {
            
                Text(StoreReviewStrings.StaticText.instructions.localized)
                    .bold()
                    .frame(maxWidth: .infinity)
                
//                HStack {
//                    AsyncImage(urlString: viewModel.storeDetails.storeLogo?[AppV2Constants.API.imageScaleFactor]?.absoluteString, placeholder: {
//                        Image.Placeholders.productPlaceholder
//                            .resizable()
//                            .frame(width: Constants.Logo.size, height: Constants.Logo.size)
//                            .scaledToFill()
//                            .cornerRadius(Constants.Logo.cornerRadius)
//                    })
//                    .frame(width: Constants.Logo.size, height: Constants.Logo.size)
//                    .scaledToFit()
//                    .cornerRadius(Constants.Logo.cornerRadius)
//
//                    VStack(alignment: .leading) {
//                        Text(viewModel.storeDetails.storeName)
//                            .font(.Body1.semiBold())
//                            .foregroundColor(colorPalette.typefacePrimary)
//
//
//                        Text(viewModel.deliveryChargeString)
//                            .font(.Body2.semiBold())
//                            .foregroundColor(colorPalette.primaryBlue)
//                    }
//                    .multilineTextAlignment(.leading)
//                }
                
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
                    minHeight: 300
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
            .frame(width: Constants.StoreReviewView.frameWidth)
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
                notification: DisplayablePushNotification(
                    image: URL(string: "https://www.kevin2.dev.snappyshopper.co.uk/uploads/images/notifications/xxhdpi_3x/1574176411multibuy.png")!,
                    message: "Test push notification message.",
                    link: URL(string: "https://www.snappyshopper.co.uk")!,
                    telephone: "0333 900 1250"
                ),
                dismissPushNotificationViewHandler: {}
            )
        )
    }
}
#endif
