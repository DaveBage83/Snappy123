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
        static let mainPadding: CGFloat = 30
    }
    
    @StateObject var viewModel: MarketingPreferencesViewModel
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }

    var body: some View {
        VStack(spacing: Constants.mainSpacing) {
            Text(Strings.CheckoutDetails.MarketingPreferences.title.localized)
                .font(.heading4())
                .foregroundColor(colorPalette.primaryBlue)
            
            Text(viewModel.marketingIntroText)
                .font(.Body2.regular())
                .foregroundColor(colorPalette.typefacePrimary)
            
            VStack(alignment: .leading) {
                marketingPreference(type: .email)
                marketingPreference(type: .directMail)
                marketingPreference(type: .notification)
                marketingPreference(type: .sms)
                marketingPreference(type: .telephone)
            }
            .padding(.horizontal, Constants.mainPadding)
        }
        .onAppear(perform: {
            Task {
                await viewModel.getMarketingPreferences() // cannot call async method from init so use inAppear instead
            }
        })
        
        .displayError(viewModel.error)
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
                        checkmarkIcon(checked: viewModel.emailMarketingEnabled)

                    case .notification:
                        checkmarkIcon(checked: viewModel.notificationMarketingEnabled)
  
                    case .sms:
                        checkmarkIcon(checked: viewModel.smsMarketingEnabled)
                        
                    case .telephone:
                        checkmarkIcon(checked: viewModel.telephoneMarketingEnabled)
                        
                    case .directMail:
                        checkmarkIcon(checked: viewModel.directMailMarketingEnabled)
                    }
                }
                .foregroundColor(.snappyBlue)
            }
            Text(type.title())
                .font(.Body2.regular())
                .foregroundColor(colorPalette.typefacePrimary)
            Spacer()
        }
        .padding(.bottom, Constants.bottomPadding)
    }
    
    private func checkmarkIcon(checked: Bool) -> some View {
        (checked ? Image.Icons.CircleCheck.filled : Image.Icons.Circle.standard)
            .renderingMode(.template)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: Constants.checkmarkWidth)
            .foregroundColor(colorPalette.primaryBlue)
    }
}

#if DEBUG
struct MarketingPreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        MarketingPreferencesView(viewModel: .init(container: .preview, isCheckout: false))
    }
}
#endif

extension Bool {
    func opted() -> UserMarketingOptionState {
        self ? .in : .out
    }
}
