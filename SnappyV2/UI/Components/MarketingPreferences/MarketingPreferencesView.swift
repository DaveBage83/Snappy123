//
//  MarketingPreferencesView.swift
//  SnappyV2
//
//  Created by David Bage on 14/03/2022.
//

import SwiftUI
import Combine

struct MarketingPreferencesView: View {
    @Environment(\.colorScheme) var colorScheme
    
    struct Constants {
        static let bottomPadding: CGFloat = 4
        static let checkmarkWidth: CGFloat = 24
        static let hSpacing: CGFloat = 16
        static let mainSpacing: CGFloat = 24.5
        static let mainPadding: CGFloat = 24
    }
    
    @ObservedObject var viewModel: MarketingPreferencesViewModel
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.mainSpacing) {
            Text(Strings.CheckoutDetails.MarketingPreferences.title.localized)
                .font(viewModel.useLargeTitles ? .heading2 : .heading4())
                .foregroundColor(colorPalette.primaryBlue)
            
            if viewModel.showMarketingPrefsPrompt {
                Text(viewModel.marketingIntroText)
                    .font(.Body2.regular())
                    .foregroundColor(colorPalette.typefacePrimary)
            }
            
            if viewModel.showAllowMarketingToggle {
                overrideToggle
            }
            
            if viewModel.showMarketingPreferencesSubtitle {
                Text(Strings.Settings.MarketingPrefs.subtitle.localized)
                    .font(.heading3())
                    .foregroundColor(colorPalette.primaryBlue)
            }
            
            VStack(alignment: .leading) {
                marketingPreference(type: .email)
                marketingPreference(type: .directMail)
                marketingPreference(type: .notification)
                marketingPreference(type: .sms)
                marketingPreference(type: .telephone)
            }
        }
        .padding(.horizontal, Constants.mainPadding)
    }
    
    func marketingPreference(type: MarketingOptions) -> some View {
        HStack(spacing: Constants.hSpacing) {
            if viewModel.marketingPreferencesAreLoading {
                ProgressView()
            } else {
                Button {
                    switch type {
                    case .email:
                        viewModel.emailMarketingEnabled.toggle()
                    case .notification:
                        viewModel.notificationMarketingEnabled.toggle()
                    case .sms:
                        viewModel.smsMarketingEnabled.toggle()
                    case .telephone:
                        viewModel.telephoneMarketingEnabled.toggle()
                    case .directMail:
                        viewModel.directMailMarketingEnabled.toggle()
                    }
                    
                } label: {
                    switch type {
                    case .email:
                        checkmarkIcon(checked: viewModel.emailMarketingEnabled, disabled: viewModel.marketingOptionsDisabled)

                    case .notification:
                        checkmarkIcon(checked: viewModel.notificationMarketingEnabled, disabled: viewModel.marketingOptionsDisabled)
  
                    case .sms:
                        checkmarkIcon(checked: viewModel.smsMarketingEnabled, disabled: viewModel.marketingOptionsDisabled)
                        
                    case .telephone:
                        checkmarkIcon(checked: viewModel.telephoneMarketingEnabled, disabled: viewModel.marketingOptionsDisabled)
                        
                    case .directMail:
                        checkmarkIcon(checked: viewModel.directMailMarketingEnabled, disabled: viewModel.marketingOptionsDisabled)
                    }
                }
                .foregroundColor(colorPalette.primaryBlue)
                .disabled(viewModel.marketingOptionsDisabled)
            }
            Text(type.title())
                .font(.Body2.regular())
                .foregroundColor(viewModel.marketingOptionsDisabled ? colorPalette.typefacePrimary.withOpacity(.thirty) : colorPalette.typefacePrimary)
            Spacer()
        }
        .padding(.bottom, Constants.bottomPadding)
    }
    
    private func checkmarkIcon(checked: Bool, disabled: Bool) -> some View {
        (checked ? Image.Icons.CircleCheck.filled : Image.Icons.Circle.standard)
            .renderingMode(.template)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: Constants.checkmarkWidth)
            .foregroundColor(disabled ? colorPalette.textGrey3 : colorPalette.primaryBlue)
    }
    
    private var overrideToggle: some View {
        Toggle(isOn: $viewModel.allowMarketing) {
            Text(Strings.Settings.MarketingPrefs.overrideTitle.localized)
                .font(.Body2.regular())
                .foregroundColor(colorPalette.typefacePrimary)
        }
    }
}

#if DEBUG
struct MarketingPreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        MarketingPreferencesView(viewModel: .init(container: .preview, viewContext: .checkout, hideAcceptedMarketingOptions: false))
    }
}
#endif

extension Bool {
    func opted() -> UserMarketingOptionState {
        self ? .in : .out
    }
}
