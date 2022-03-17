//
//  MarketingPreferencesView.swift
//  SnappyV2
//
//  Created by David Bage on 14/03/2022.
//

import SwiftUI

struct MarketingPreferencesView: View {
    struct Constants {
        static let bottomPadding: CGFloat = 4
    }
    
    @Binding var preferencesAreLoading: Bool
    
    @Binding var emailMarketingEnabled: Bool
    @Binding var directMailMarketingEnabled: Bool
    @Binding var notificationMarketingEnabled: Bool
    @Binding var smsMarketingEnabled: Bool
    @Binding var telephoneMarketingEnabled: Bool
    
    let labelFont: Font
    let fontColor: Color
    
    
    var body: some View {
        VStack(alignment: .leading) {
            marketingPreference(type: .email)
            marketingPreference(type: .directMail)
            marketingPreference(type: .notification)
            marketingPreference(type: .sms)
            marketingPreference(type: .telephone)
        }
    }
    
    func marketingPreference(type: MarketingOptions) -> some View {
        HStack {
            if preferencesAreLoading {
                ProgressView()
            } else {
                Button {
                    switch type {
                    case .email:
                        emailMarketingEnabled.toggle()
                    case .notification:
                        notificationMarketingEnabled.toggle()
                    case .sms:
                        smsMarketingEnabled.toggle()
                    case .telephone:
                        telephoneMarketingEnabled.toggle()
                    case .directMail:
                        directMailMarketingEnabled.toggle()
                    }
                    
                } label: {
                    switch type {
                    case .email:
                        emailMarketingEnabled ? Image.General.Checkbox.checked : Image.General.Checkbox.unChecked
                    case .notification:
                        notificationMarketingEnabled ? Image.General.Checkbox.checked : Image.General.Checkbox.unChecked
                    case .sms:
                        smsMarketingEnabled ? Image.General.Checkbox.checked : Image.General.Checkbox.unChecked
                    case .telephone:
                        telephoneMarketingEnabled ? Image.General.Checkbox.checked : Image.General.Checkbox.unChecked
                    case .directMail:
                        directMailMarketingEnabled ? Image.General.Checkbox.checked : Image.General.Checkbox.unChecked
                    }
                }
                .font(.snappyTitle2)
                .foregroundColor(.snappyBlue)
            }
            Text(type.title())
                .font(labelFont)
                .foregroundColor(fontColor)
            Spacer()
        }
        .padding(.bottom, Constants.bottomPadding)
    }
}

struct MarketingPreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        MarketingPreferencesView(
            preferencesAreLoading: .constant(false),
            emailMarketingEnabled: .constant(true),
            directMailMarketingEnabled: .constant(true),
            notificationMarketingEnabled: .constant(true),
            smsMarketingEnabled: .constant(true),
            telephoneMarketingEnabled: .constant(true),
            labelFont: .snappyBody2,
            fontColor: .snappyTextGrey2
        )
    }
}
