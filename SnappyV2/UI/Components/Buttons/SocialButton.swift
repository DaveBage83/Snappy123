//
//  SocialButton.swift
//  SnappyV2
//
//  Created by David Bage on 06/05/2022.
//

import SwiftUI
import StoreKit

struct SocialButton: View {
    @ScaledMetric var scale: CGFloat = 1 // Used to scale icon for accessibility options

    enum Platform {
        case facebookLogin
        case googleLogin
        case googlePayLight
        case googlePayDark
        case buyWithGooglePayLight
        case buyWithGooglePayDark
        
        var icon: Image {
            switch self {
            case .facebookLogin:
                return Image.Social.facebook
            case .googleLogin, .googlePayLight, .googlePayDark, .buyWithGooglePayLight, .buyWithGooglePayDark:
                return Image.Social.google
            }
        }
        
        var iconSpacing: CGFloat {
            switch self {
            case .facebookLogin, .googleLogin:
                return 15
            case .googlePayLight, .googlePayDark, .buyWithGooglePayLight, .buyWithGooglePayDark:
                return 6.73
            }
        }
        
        var cornerRadius: CGFloat {
            switch self {
            case .facebookLogin, .googleLogin:
                return 10
            case .googlePayLight, .googlePayDark, .buyWithGooglePayLight, .buyWithGooglePayDark:
                return 4
            }
        }
        
        var buttonColor: Color {
            switch self {
            case .googleLogin:
                return .white
            case .facebookLogin:
                return .facebookBlue
            case .googlePayLight, .buyWithGooglePayLight:
                return .white
            case .googlePayDark, .buyWithGooglePayDark:
                return .black
            }
        }
        
        var fontColor: Color {
            switch self {
            case .facebookLogin:
                return .white
            case .googleLogin:
                return .googleFont
            case .googlePayLight, .buyWithGooglePayLight:
                return .googleFont
            case .googlePayDark, .buyWithGooglePayDark:
                return .white
            }
        }
        
        var title: String {
            switch self {
            case .facebookLogin:
                return GeneralStrings.Login.Customisable.loginWith.localizedFormat(GeneralStrings.Login.facebook.localized)
            case .googleLogin:
                return GeneralStrings.Login.Customisable.loginWith.localizedFormat(GeneralStrings.Login.google.localized)
            case .googlePayLight, .googlePayDark, .buyWithGooglePayLight, .buyWithGooglePayDark:
                return GeneralStrings.Login.pay.localized
            }
        }
        
        var preIconText: String? {
            switch self {
            case .facebookLogin, .googleLogin, .googlePayLight, .googlePayDark:
                return nil
            case .buyWithGooglePayLight, .buyWithGooglePayDark:
                return GeneralStrings.Login.buyWith.localized
            }
        }
    }
    
    enum Size {
        case large
        case small
        case medium
    }
    
    var font: Font {
        switch platform {
        case .facebookLogin:
            switch size {
            case .large:
                return .Social.Facebook.facebook1()
            case .medium:
                return .Social.Facebook.facebook2()
            case .small:
                return .Social.Facebook.facebook3()
            }
        case .googleLogin, .googlePayLight, .googlePayDark, .buyWithGooglePayLight, .buyWithGooglePayDark:
            switch size {
            case .large:
                return .Social.Google.google1()
            case .medium:
                return .Social.Google.google2()
            case .small:
                return .Social.Google.google3()
            }
        }
    }
    
    var vPadding: CGFloat {
        switch size {
        case .large:
            return 15
        case .medium:
            return 11
        case .small:
            return 12
        }
    }
    
    var iconHeight: CGFloat {
        switch platform {
        case .googleLogin, .facebookLogin:
            switch size {
            case .large:
                return 23 * scale
            case .medium, .small:
                return 20 * scale
            }
        case .googlePayLight, .googlePayDark, .buyWithGooglePayLight, .buyWithGooglePayDark:
            switch size {
            case .large:
                return 17.47 * scale
            case .medium, .small:
                return 14.47 * scale
            }
        }
    }

    let container: DIContainer
    let platform: Platform
    let size: Size
    @Binding var isLoading: Bool
    let action: () -> Void
    
    init(container: DIContainer, platform: Platform, size: Size, isLoading: Binding<Bool> = .constant(false), action: @escaping () -> Void) {
        self.container = container
        self.platform = platform
        self.size = size
        self._isLoading = isLoading
        self.action = action
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: platform.iconSpacing) {
                if let preIconText = platform.preIconText {
                    Text(preIconText)
                        .foregroundColor(platform.fontColor)
                        .font(font)
                        .padding(.vertical, vPadding)
                        .opacity(isLoading ? 0 : 1)
                }
                
                platform.icon
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: iconHeight)
                    .opacity(isLoading ? 0 : 1)

                Text(platform.title)
                    .foregroundColor(platform.fontColor)
                    .font(font)
                    .padding(.vertical, vPadding)
                    .opacity(isLoading ? 0 : 1)
            }
            .frame(maxWidth: .infinity)
        }
        .frame(width: nil)
        .background(platform.buttonColor)
        .cornerRadius(platform.cornerRadius)
        .snappyShadow()
        .modifier(LoadingModifier(isLoading: $isLoading, color: platform.fontColor))
        .disabled(isLoading)
    }
}

struct SocialButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SocialButton(container: .preview, platform: .buyWithGooglePayDark, size: .large, action: {})
                
            SocialButton(container: .preview, platform: .facebookLogin, size: .medium, action: {})
            
            SocialButton(container: .preview, platform: .facebookLogin, size: .small, action: {})
            
            SocialButton(container: .preview, platform: .googleLogin, size: .large, action: {})
            
            SocialButton(container: .preview, platform: .googleLogin, size: .medium, action: {})
            
            SocialButton(container: .preview, platform: .googleLogin, size: .small, action: {})
            
            SocialButton(container: .preview, platform: .buyWithGooglePayDark, size: .large, action: {})
                .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
        }
    }
}
