//
//  MarketingPreferencesView.swift
//  SnappyV2
//
//  Created by David Bage on 14/03/2022.
//

import SwiftUI
import Combine

struct MarketingPreferencesView: View {
    struct Constants {
        static let bottomPadding: CGFloat = 4
    }
    
    @ObservedObject var viewModel: MarketingPreferencesViewModel

    var body: some View {
        VStack(alignment: .leading) {
            marketingPreference(type: .email)
            marketingPreference(type: .directMail)
            marketingPreference(type: .notification)
            marketingPreference(type: .sms)
            marketingPreference(type: .telephone)
        }
        .displayError(viewModel.error)
    }
    
    func marketingPreference(type: MarketingOptions) -> some View {
        HStack {
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
                        viewModel.emailMarketingEnabled ? Image.General.Checkbox.checked : Image.General.Checkbox.unChecked
                    case .notification:
                        viewModel.notificationMarketingEnabled ? Image.General.Checkbox.checked : Image.General.Checkbox.unChecked
                    case .sms:
                        viewModel.smsMarketingEnabled ? Image.General.Checkbox.checked : Image.General.Checkbox.unChecked
                    case .telephone:
                        viewModel.telephoneMarketingEnabled ? Image.General.Checkbox.checked : Image.General.Checkbox.unChecked
                    case .directMail:
                        viewModel.directMailMarketingEnabled ? Image.General.Checkbox.checked : Image.General.Checkbox.unChecked
                    }
                }
                .font(.snappyTitle2)
                .foregroundColor(.snappyBlue)
            }
            Text(type.title())
                .font(.snappyCaption)
                .foregroundColor(.snappyTextGrey1)
            Spacer()
        }
        .padding(.bottom, Constants.bottomPadding)
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
