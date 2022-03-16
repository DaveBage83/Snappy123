//
//  CreateAccountCard.swift
//  SnappyV2
//
//  Created by David Bage on 01/03/2022.
//

import SwiftUI

struct CreateAccountCard: View {
    typealias CreateAccountStrings = Strings.CreateAccount
    
    struct Constants {
        struct General {
            static let cornerRadius: CGFloat = 15
        }
        
        struct Option {
            static let iconSize: CGFloat = 30
            static let iconPadding: CGFloat = 3
            static let width: CGFloat = 120
        }
    }
    
    @StateObject var viewModel: LoginViewModel
    
    var body: some View {
        VStack {
            Text(CreateAccountStrings.create.localized)
                .font(.snappyTitle2)
                .foregroundColor(.snappyBlue)
                .fontWeight(.bold)
                .padding()
            
            memberBenefitsView
                .frame(maxWidth: .infinity)
            
            LoginButton(action: {
                viewModel.createAccountTapped()
            }, text: CreateAccountStrings.title.localized, icon: nil)
                .buttonStyle(SnappyPrimaryButtonStyle())
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: Constants.General.cornerRadius))
        .snappyShadow()
    }
    
    var memberBenefitsView: some View {
        HStack {
            memberBenefit(title: CreateAccountStrings.refer.localized, icon: Image.General.thumbsUp)
            memberBenefit(title: CreateAccountStrings.checkout.localized, icon: Image.Checkout.cart)
            memberBenefit(title: CreateAccountStrings.deals.localized, icon: Image.General.savings)
        }
    }
    
    func memberBenefit(title: String, icon: Image) -> some View {
        VStack {
            icon
                .foregroundColor(.snappyRed)
                .font(.system(size: Constants.Option.iconSize))
                .padding(.bottom, Constants.Option.iconPadding)
            
            Text(title)
                .font(.snappyBody2)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: Constants.Option.width)
    }
}

struct CreateAccountCard_Previews: PreviewProvider {
    static var previews: some View {
        CreateAccountCard(viewModel: .init(container: .preview))
    }
}
