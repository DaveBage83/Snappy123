//
//  CreateAccountCard.swift
//  SnappyV2
//
//  Created by David Bage on 01/03/2022.
//

import SwiftUI

#warning("viewModel to be expanded when account creation done")
class CreateAccountCardViewModel: ObservableObject {
    @Published var password = ""
}

struct CreateAccountCard: View {
    typealias CreateAccountStrings = Strings.CreateAccountCard
    
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
    
    @State var viewModel: CreateAccountCardViewModel
    
    var body: some View {
        VStack {
            Text(CreateAccountStrings.title.localized)
                .font(.snappyTitle2)
                .foregroundColor(.snappyBlue)
                .fontWeight(.bold)
                .padding()
            
            memberBenefitsView
                .frame(maxWidth: .infinity)
            
            TextFieldFloatingWithBorder(GeneralStrings.Login.password.localized, text: $viewModel.password)
                .padding()
            
            Button {
            #warning("Replace with actual method to create account")
                print("Tapped")
            } label: {
                Text(CreateAccountStrings.buttonText.localized)
                    .fontWeight(.medium)
            }
            .buttonStyle(SnappyMainActionButtonStyle(isEnabled: true))
        }
        .padding()
        .background(Color.white)
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
        CreateAccountCard(viewModel: CreateAccountCardViewModel())
    }
}
