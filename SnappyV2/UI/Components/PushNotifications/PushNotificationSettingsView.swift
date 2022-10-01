//
//  PushNotificationsMarketingPreferenceView.swift
//  SnappyV2
//
//  Created by Kevin Palser on 22/08/2022.
//

import SwiftUI
import Combine

struct PushNotificationSettingsView: View {
    @Environment(\.colorScheme) var colorScheme
    private typealias PushNotificationSettingsStrings = Strings.Settings.PushNotifications
    
    struct Constants {
        static let bottomPadding: CGFloat = 4
        static let checkmarkWidth: CGFloat = 24
        static let hSpacing: CGFloat = 16
        static let mainSpacing: CGFloat = 24.5
        static let mainPadding: CGFloat = 24
        static let vPadding: CGFloat = 24
    }
    
    @ObservedObject var viewModel: PushNotificationSettingsViewModel
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.mainSpacing) {
            Text(PushNotificationSettingsStrings.title.localized)
                .font(viewModel.useLargeTitles ? .heading2 : .heading4())
                .foregroundColor(colorPalette.primaryBlue)
                .padding(.horizontal, Constants.vPadding)
            
            if viewModel.pushNotificationsDisabled {
            
                SnappyButton(
                    container: viewModel.container,
                    type: .outline,
                    size: .large,
                    title: PushNotificationSettingsStrings.enable.localized,
                    largeTextTitle: nil,
                    icon: nil) {
                        withAnimation {
                            viewModel.enableNotificationsTapped()
                        }
                    }
                    .padding(.horizontal)
                
            } else {
                
                Toggle(isOn: $viewModel.allowPushNotificationMarketing) {
                    Text(viewModel.pushNotificationMarketingText)
                        .font(.Body2.regular())
                        .foregroundColor(colorPalette.typefacePrimary)
                }
                .padding(.horizontal, Constants.mainPadding)
                
            }
        }
        .displayError(viewModel.error)
    }
}

#if DEBUG
struct PushNotificationsMarketingPreferenceView_Previews: PreviewProvider {
    static var previews: some View {
        PushNotificationSettingsView(viewModel: .init(container: .preview, viewContext: .checkout, hideAcceptedMarketingOptions: false))
    }
}
#endif
