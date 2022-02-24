//
//  CheckoutDetailsView.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 27/01/2022.
//

import SwiftUI

struct CheckoutDetailsView: View {
    typealias AddDetailsStrings = Strings.CheckoutView.AddDetails
    typealias ProgressStrings = Strings.CheckoutView.Progress
    typealias TsAndCsStrings = Strings.CheckoutView.TsAndCs
    
    struct Constants {
        struct AddDetails {
            static let hPadding: CGFloat = 40
        }
        
        struct MarketingPreferences {
            static let titlePadding: CGFloat = 6
        }
        
        struct ContinueButton {
            static let padding: CGFloat = 10
            static let cornerRadius: CGFloat = 10
        }
    }
    
    @StateObject var viewModel: CheckoutDetailsViewModel
    @EnvironmentObject var checkoutViewModel: CheckoutViewModel
    
    var body: some View {
        ScrollView {
            checkoutProgressView()
                .background(Color.white)
            
            addDetails()
                .padding(.horizontal, Constants.AddDetails.hPadding)
                .padding(.top)
            
            marketingPreferences
                .padding([.top, .leading, .trailing])
            
            continueButton
                .padding([.top, .leading, .trailing])
            
            // MARK: NavigationLinks
            NavigationLink("", isActive: $viewModel.isContinueTapped) {
                CheckoutFulfilmentInfoView(viewModel: .init(container: viewModel.container))
                .environmentObject(checkoutViewModel)
            }
        }
    }
    
    // MARK: View Components
    func checkoutProgressView() -> some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                Image.Checkout.car
                    .font(.title2)
                    .foregroundColor(.snappyBlue)
                    .padding()
                
                VStack(alignment: .leading) {
                    Text(ProgressStrings.time.localized)
                        .font(.snappyCaption)
                        .foregroundColor(.gray)
                    
                    #warning("To replace with actual order time")
                    Text("Sun, 15 October, 10:30").bold()
                        .font(.snappyCaption)
                        .foregroundColor(.snappyBlue)
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text(ProgressStrings.orderTotal.localized)
                        .foregroundColor(.gray)
                    
                    HStack {
                    #warning("To replace with actual order value")
                        Text("£8.95")
                            .fontWeight(.semibold)
                            .foregroundColor(.snappyBlue)
                        
                        Image.General.bulletList
                            .foregroundColor(.snappyBlue)
                    }
                }
                .font(.snappyCaption)
                
            }
            .padding(.horizontal)
            
            ProgressBarView(value: 1, maxValue: 4, backgroundColor: .snappyBGFields1, foregroundColor: .snappyBlue)
                .frame(height: 6)
                .padding(.horizontal, -3)
        }
    }
    
    func addDetails() -> some View {
        VStack(alignment: .center) {
            Text(AddDetailsStrings.title.localized)
                .font(.snappyHeadline)
                .foregroundColor(.snappyBlue)
            
            TextFieldFloatingWithBorder(AddDetailsStrings.firstName.localized, text: $viewModel.firstname, hasWarning: $viewModel.firstNameHasWarning, background: Color.snappyBGMain)
            
            TextFieldFloatingWithBorder(AddDetailsStrings.lastName.localized, text: $viewModel.surname, hasWarning: $viewModel.surnameHasWarning, background: Color.snappyBGMain)
            
            TextFieldFloatingWithBorder(AddDetailsStrings.email.localized, text: $viewModel.email, hasWarning: $viewModel.emailHasWarning, background: Color.snappyBGMain)
            
            TextFieldFloatingWithBorder(AddDetailsStrings.phone.localized, text: $viewModel.phoneNumber, hasWarning: $viewModel.phoneNumberHasWarning, background: Color.snappyBGMain)
        }
    }
    
    func marketingPreference(type: MarketingPreferenceSettings) -> some View {
        HStack {
            if viewModel.marketingPreferencesAreLoading {
                ProgressView()
            } else {
                type.image
                    .font(.title)
                    .foregroundColor(.snappyBlue)
                    .onTapGesture {
                        type.action()
                    }
            }
            
            Text(type.text)
                .font(.snappyCaption)
        }
        .padding(.bottom)
    }
    
    var marketingPreferences: some View {
        VStack(alignment: .leading) {
            Text(Strings.CheckoutDetails.MarketingPreferences.title.localized)
                .font(.snappyHeadline)
                .padding(.bottom, Constants.MarketingPreferences.titlePadding)
            
            Text(Strings.CheckoutDetails.MarketingPreferences.prompt.localized)
                .font(.snappySubheadline)
                .foregroundColor(.snappyTextGrey1)
                .padding(.bottom)
            
            marketingPreference(type: viewModel.preferenceSettings(type: .email))
            marketingPreference(type: viewModel.preferenceSettings(type: .directMail))
            marketingPreference(type: viewModel.preferenceSettings(type: .notification))
            marketingPreference(type: viewModel.preferenceSettings(type: .telephone))
            marketingPreference(type: viewModel.preferenceSettings(type: .sms))
        }
    }
    
    var continueButton: some View {
        Button {
            viewModel.continueButtonTapped()
        } label: {
            Text(GeneralStrings.cont.localized)
                .font(.snappyTitle2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(Constants.ContinueButton.padding)
                .padding(.horizontal)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: Constants.ContinueButton.cornerRadius)
                        .fill(Color.snappyTeal)
                )
        }
    }
}

struct CheckoutDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutDetailsView(viewModel: .init(container: .preview))
            .environmentObject(CheckoutViewModel(container: .preview))
    }
}
