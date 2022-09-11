//
//  PushNotificationsEnablePromptView.swift
//  SnappyV2
//
//  Created by Kevin Palser on 17/08/2022.
//

import SwiftUI

struct PushNotificationsEnablePromptView: View {
    
    // MARK: - Typealiases
    typealias PushNotificationsStrings = Strings.PushNotifications
    
    // MARK: - Environment objects
    @Environment(\.colorScheme) private var colorScheme
    
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
    @StateObject var viewModel: PushNotificationsEnablePromptViewModel
    
    // MARK: - Colors
    private var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    @ViewBuilder var includeMarketingButton: some View {
        Button(action: {
            viewModel.includeMarketingTapped()
        }) {
            Text(viewModel.includingMarketingButtonTitle)
                .bold()
        }
    }
    
    // MARK: - Main content
    var body: some View {
        ZStack {
            Color.black.opacity(Constants.PushNotificationAlert.opacity)
                .ignoresSafeArea()
            
            VStack(spacing: Constants.PushNotificationAlert.vStackSpacing) {
                
                Text(viewModel.introductionText)
                    .multilineTextAlignment(.center)
                    .padding([.horizontal, .top])
                
                Divider()
                
                Button(action: {
                    viewModel.ordersOnlyTapped()
                }) {
                    Text(viewModel.ordersOnlyButtonTitle)
                        .bold()
                }
                
                Divider()
                
                if viewModel.noNotificationsButtonRequired {
                    
                    includeMarketingButton
                    
                    Divider()
                    
                    Button(action: {
                        viewModel.noNotificationsTapped()
                    }) {
                        // unlike the other buttons we want this not be bold
                        // so that the user sees this as the less compelling
                        // or typical option
                        Text(viewModel.nonNotificationsButtonTitle)
                    }.padding(.bottom)
                    
                } else {
                    
                    includeMarketingButton
                        .padding(.bottom)
                    
                }
                
            }
            .frame(width: Constants.PushNotificationAlert.frameWidth)
            .background(colorPalette.secondaryWhite)
            .cornerRadius(Constants.PushNotificationAlert.cornerRadius)

        }
        .font(.body)
        .withAlertToast(container: viewModel.container, error: $viewModel.error)
        
    }
}

#if DEBUG
struct PushNotificationsEnablePromptView_Previews: PreviewProvider {
    static var previews: some View {
        PushNotificationsEnablePromptView(
            viewModel: .init(
                container: .preview,
                dismissPushNotificationViewHandler: {}
            )
        )
    }
}
#endif
