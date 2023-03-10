//
//  MemberDashboardSettingsView.swift
//  SnappyV2
//
//  Created by David Bage on 28/07/2022.
//

import SwiftUI

struct MemberDashboardSettingsView: View {
    @Environment(\.colorScheme) var colorScheme
    
    typealias TermsStrings = Strings.Terms
    typealias SettingsStrings = Strings.Settings
    
    struct Constants {
        static let mainSpacing: CGFloat = 24.5
        static let vPadding: CGFloat = 24
        static let mainPadding: CGFloat = 24
        
        struct MainStack {
            static let vSpacing: CGFloat = 36
        }
        
        struct UsefulInfo {
            static let vSpacing: CGFloat = 24
        }
        
        struct Terms {
            static let spacing: CGFloat = 8
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
        ScrollView(showsIndicators: false) {
            VStack(spacing: Constants.MainStack.vSpacing) {
                
                PushNotificationSettingsView(viewModel: pushNotificationsMarketingPreferenceViewModel)
                    .padding(.top)
                
                
                storeMenuSetting
                
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
                .padding()
                
                if let appVersion = AppV2Constants.Client.appVersion,
                   let bundleVersion = AppV2Constants.Client.bundleVersion
                {
                    Button(action: {
                        Task {
                            await viewModel.versionTapped(
                                debugInformationCopied: {
                                    let message = SettingsStrings.DebugInformation.copiedMessage.localized
                                    viewModel.container.appState.value.successToasts.append(SuccessToast(subtitle: message))
                                }
                            )
                        }
                    }) {
                        Text(GeneralStrings.Custom.version.localizedFormat(appVersion, bundleVersion))
                            .font(.Caption1.semiBold())
                            .padding(.bottom)
                    }.buttonStyle(.plain)
                }
            }
            .background(colorPalette.secondaryWhite)
            .standardCardFormat(container: viewModel.container)
            .padding()
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
    
    private var storeMenuSetting: some View {
        VStack(alignment: .leading, spacing: Constants.mainSpacing) {
            Text(SettingsStrings.StoreMenu.title.localized)
                .font(.heading4())
                .foregroundColor(colorPalette.primaryBlue)
                .padding(.horizontal, Constants.vPadding)
            
            if UIDevice.current.userInterfaceIdiom == .phone {
                Toggle(isOn: $viewModel.showHorizontalItemCards) {
                    Text(SettingsStrings.StoreMenu.horizontalCard.localized)
                        .font(.Body2.regular())
                        .foregroundColor(colorPalette.typefacePrimary)
                }
                .padding(.horizontal, Constants.mainPadding)
            }
            
            Toggle(isOn: $viewModel.showDropdownCategoryMenu) {
                Text(SettingsStrings.StoreMenu.dropdownRootCategoryMenu.localized)
                    .font(.Body2.regular())
                    .foregroundColor(colorPalette.typefacePrimary)
            }
            .padding(.horizontal, Constants.mainPadding)
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
            pushNotificationsMarketingPreferenceViewModel: .init(container: .preview, viewContext: .settings),
            dismissViewHandler: {}
        )
    }
}
#endif
