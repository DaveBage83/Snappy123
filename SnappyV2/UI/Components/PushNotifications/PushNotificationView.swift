//
//  PushNotificationView.swift
//  SnappyV2
//
//  Created by Kevin Palser on 17/08/2022.
//

import SwiftUI

struct PushNotificationView: View {
    
    // MARK: - Typealiases
    typealias PushNotificationsStrings = Strings.PushNotifications
    
    // MARK: - Environment objects
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.openURL) private var openURL
    
    // MARK: - Constants
    struct Constants {
        struct PushNotificationAlert {
            static let frameWidth: CGFloat = 300
            static let cornerRadius: CGFloat = 20
            static let vStackSpacing: CGFloat = 11
            static let opacity: CGFloat = 0.2
            static let buttonPadding: CGFloat = -10
            static let dividerHeight: CGFloat = 50
        }
    }
    
    // MARK: - View model
    @StateObject var viewModel: PushNotificationViewModel
    
    // MARK: - Colors
    private var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    // MARK: - Main content
    var body: some View {
        ZStack {
            Color.black.opacity(Constants.PushNotificationAlert.opacity)
                .ignoresSafeArea()
            
            VStack(spacing: Constants.PushNotificationAlert.vStackSpacing) {
                
                Group {
                    Text(PushNotificationsStrings.title.localized)
                        .bold()
                        .padding(.top)
                        .frame(maxWidth: .infinity)
                    
                    if let imageURL = viewModel.notification.image {
                        AsyncImage(
                            urlString: imageURL.absoluteString,
                            placeholder: {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                            }
                        )
                        .scaledToFit()
                    }
                    
                    Text(viewModel.notification.message)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Divider()
                }
                    
                ForEach(viewModel.options) { option in
                    Group {
                        Button(action: {
                            if let linkURL = option.linkURL {
                                openURL(linkURL) { accepted in
                                    option.action(false)
                                }
                            } else {
                                option.action(true)
                            }
                        }) {
                            Text(option.title)
                        }

                        Divider()
                    }
                }
                    
                Button(action: {
                    viewModel.dismissPushNotificationPrompt()
                }) {
                    Text(Strings.General.close.localized)
                        .bold()
                }
                .padding(.bottom)
            }
            .frame(width: Constants.PushNotificationAlert.frameWidth)
            .background(colorPalette.secondaryWhite)
            .cornerRadius(Constants.PushNotificationAlert.cornerRadius)

        }
        .font(.body)
//        .withAlertToast(container: viewModel.container, error: $viewModel.error)
        .alert(isPresented: $viewModel.showCallInformationAlert) {
            Alert(
                title: Text(Strings.PushNotifications.call.localized),
                message: Text(viewModel.showTelephoneNumber),
                dismissButton: .default(Text(Strings.General.close.localized))
            )
        }

    }
}

#if DEBUG
struct PushNotificationView_Previews: PreviewProvider {
    static var previews: some View {
        PushNotificationView(
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



