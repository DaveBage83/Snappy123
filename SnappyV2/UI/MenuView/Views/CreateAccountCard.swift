//
//  CreateAccountCard.swift
//  SnappyV2
//
//  Created by David Bage on 01/03/2022.
//

import SwiftUI

struct CreateAccountCard: View {
    @ScaledMetric var scale: CGFloat = 1 // Used to scale icon for accessibility options
    @Environment(\.colorScheme) var colorScheme
    
    typealias CreateAccountStrings = Strings.CreateAccount
    
    struct Constants {
        struct General {
            static let cornerRadius: CGFloat = 15
            static let padding: CGFloat = 24
        }
        
        struct Option {
            static let iconSize: CGFloat = 24
            static let iconPadding: CGFloat = 10
            static let width: CGFloat = 120
        }
        
        struct Title {
            static let height: CGFloat = 28
            static let bottomPadding: CGFloat = 26
        }
        
        struct MemberBenefits {
            static let bottomPadding: CGFloat = 24
            static let spacing: CGFloat = 21
            static let titleWidth: CGFloat = 83
            static let titleHeight: CGFloat = 32
        }
    }
    
    @StateObject var viewModel: LoginViewModel
    
    var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Text(CreateAccountStrings.create.localized)
                .font(.heading3())
                .foregroundColor(colorPalette.typefacePrimary)
                .fontWeight(.bold)
                .padding()
                .frame(height: Constants.Title.height * scale)
                .padding(.bottom, Constants.Title.bottomPadding)
            
            memberBenefitsView
                .frame(maxWidth: .infinity)
                .padding(.bottom, Constants.MemberBenefits.bottomPadding)
            
            SnappyButton(container: viewModel.container, type: .primary, size: .large, title: CreateAccountStrings.title.localized, icon: nil) {
                viewModel.createAccountTapped()
            }
        }
        .padding(Constants.General.padding)
        .background(colorPalette.secondaryWhite)
        .standardCardFormat()
    }
    
    var memberBenefitsView: some View {
        HStack(spacing: Constants.MemberBenefits.spacing) {
            memberBenefit(title: CreateAccountStrings.refer.localized, icon: Image.Icons.ThumbsUp.standard)
            memberBenefit(title: CreateAccountStrings.checkout.localized, icon: Image.Icons.CartFast.standard)
            memberBenefit(title: CreateAccountStrings.deals.localized, icon: Image.Icons.Piggy.standard)
        }
    }
    
    func memberBenefit(title: String, icon: Image) -> some View {
        VStack(spacing: 0) {
            icon
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: Constants.Option.iconSize * scale)
                .foregroundColor(.snappyRed)
                .font(.system(size: Constants.Option.iconSize))
                .padding(.bottom, Constants.Option.iconPadding)
            
            Text(title)
                .font(.Body2.regular())
                .multilineTextAlignment(.center)
                .frame(width: Constants.MemberBenefits.titleWidth * scale, height: Constants.MemberBenefits.titleHeight * scale)
        }
    }
}

struct CreateAccountCard_Previews: PreviewProvider {
    static var previews: some View {
        CreateAccountCard(viewModel: .init(container: .preview))
            .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)

    }
}
