//
//  MemberDashboardSettingsView.swift
//  SnappyV2
//
//  Created by David Bage on 28/07/2022.
//

import SwiftUI

class MemberDashboardSettingsViewModel: ObservableObject {
    let container: DIContainer
    
    var showMarketingPreferences: Bool {
        container.appState.value.userData.memberProfile != nil
    }
    
    init(container: DIContainer) {
        self.container = container
    }
}

struct MemberDashboardSettingsView: View {
    @Environment(\.colorScheme) var colorScheme
    
    typealias TermsStrings = Strings.Terms
    typealias SettingsStrings = Strings.Settings
    
    struct Constants {
        struct MainStack {
            static let vSpacing: CGFloat = 36
            static let vPadding: CGFloat = 24
        }
        
        struct UsefulInfo {
            static let vSpacing: CGFloat = 24
        }
        
        struct Terms {
            static let spacing: CGFloat = 8
            static let hPadding: CGFloat = 32
        }
    }
    
    @StateObject var viewModel: MemberDashboardSettingsViewModel
    @StateObject var marketingPreferencesViewModel: MarketingPreferencesViewModel
    @StateObject var pushNotificationsMarketingPreferenceViewModel: PushNotificationSettingsViewModel
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    let dismissViewHandler: () -> ()
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            ScrollView(showsIndicators: false) {
                VStack(spacing: Constants.MainStack.vSpacing) {
                    
                    PushNotificationSettingsView(viewModel: pushNotificationsMarketingPreferenceViewModel)
                    
                    if viewModel.showMarketingPreferences {
                        MarketingPreferencesView(viewModel: marketingPreferencesViewModel)
                            .onDisappear {
                                Task {
                                    await marketingPreferencesViewModel.updateMarketingPreferences()
                                }
                            }
                    }
                    
                    VStack(alignment: .leading, spacing: Constants.UsefulInfo.vSpacing) {
                        Text(SettingsStrings.UsefulInfo.title.localized)
                            .font(.heading3())
                            .foregroundColor(colorPalette.primaryBlue)
                        
                        termsView
                    }
                    .padding(.horizontal, Constants.MainStack.vPadding)
                }
                .padding(.vertical, Constants.MainStack.vPadding)
                .background(colorPalette.secondaryWhite)
                .standardCardFormat()
            }
            .background(colorPalette.backgroundMain)
            .edgesIgnoringSafeArea(.bottom)
            .dismissableNavBar(
                presentation: nil,
                color: colorPalette.primaryBlue,
                title: SettingsStrings.Main.title.localized,
                navigationDismissType: .done,
                backButtonAction: {
                    dismissViewHandler()
                })
        }
    }
    
    private var termsView: some View {
        HStack {
            VStack(alignment: .leading, spacing: Constants.Terms.spacing) {
                if let termsUrl = AppV2Constants.Business.termsAndConditionsURL {
                    Link(destination: termsUrl, label: {
                        Text(TermsStrings.terms.localized.capitalizingFirstLetter())
                            .underline()
                    })
                }
                
                if let privacyUrl = AppV2Constants.Business.privacyURL {
                    Link(destination: privacyUrl, label: {
                        Text(TermsStrings.privacy.localized.capitalizingFirstLetter())
                            .underline()
                    })
                }
                
                if let contactUsUrl = AppV2Constants.Business.contactUsURL {
                    Link(destination: contactUsUrl, label: {
                        Text(TermsStrings.contactUs.localized.capitalizingFirstLetter())
                            .underline()
                    })
                }
            }
            .font(.hyperlink2())
            .foregroundColor(colorPalette.primaryBlue)
            .multilineTextAlignment(.center)
            Spacer()
        }
    }
}

#if DEBUG
struct MemberDashboardSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        MemberDashboardSettingsView(
            viewModel: .init(container: .preview),
            marketingPreferencesViewModel: .init(container: .preview, viewContext: .settings, hideAcceptedMarketingOptions: false),
            pushNotificationsMarketingPreferenceViewModel: .init(container: .preview, viewContext: .settings, hideAcceptedMarketingOptions: false),
            dismissViewHandler: {}
        )
    }
}
#endif
