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
            static let spacing: CGFloat = 10
        }
        
        struct ContinueButton {
            static let padding: CGFloat = 10
            static let cornerRadius: CGFloat = 10
        }
        
        struct General {
            static let vPadding: CGFloat = 30
        }
    }
    
    @StateObject var viewModel: CheckoutDetailsViewModel
    @StateObject var marketingPreferencesViewModel: MarketingPreferencesViewModel
    
    init(container: DIContainer) {
        self._viewModel = .init(wrappedValue: .init(container: container))
        self._marketingPreferencesViewModel = .init(wrappedValue: .init(container: container, isCheckout: true))
    }
    
    var body: some View {
        ScrollView {
            checkoutProgressView()
                .background(Color.white)
            
            VStack(spacing: Constants.General.vPadding) {
                addDetails()
                    .padding(.top)
                
                marketingPreferencSelectionView()
                
                continueButton
                    .padding([.top, .leading, .trailing])
                
                // MARK: NavigationLinks
                NavigationLink("", isActive: $viewModel.isContinueTapped) {
                    CheckoutFulfilmentInfoView(viewModel: .init(container: viewModel.container))
                }
            }
            .padding(Constants.General.vPadding)
        }
        .alert(isPresented: $viewModel.showCantSetContactDetailsAlert) {
            Alert(
                title: Text(Strings.CheckoutView.AddDetails.alertTitle.localized),
                message: Text(Strings.CheckoutView.AddDetails.Customisable.alertMessage.localizedFormat(viewModel.errorMessage)),
                primaryButton: .cancel(Text(Strings.General.cancel.localized)),
                secondaryButton: .default(Text(Strings.General.retry.localized), action: {
                    Task {
                        await viewModel.continueButtonTapped {
                            try await marketingPreferencesViewModel.updateMarketingPreferences()
                        }
                    }
                    
                })
            )
        }
    }
    
    func marketingPreferencSelectionView() -> some View {
        VStack(alignment: .leading, spacing: Constants.MarketingPreferences.spacing) {
            Text(Strings.CheckoutDetails.MarketingPreferences.title.localized)
                .font(.snappyBody)
                .fontWeight(.bold)
            
            Text(Strings.CheckoutDetails.MarketingPreferences.prompt.localized)
                .font(.snappyCaption)
            
            MarketingPreferencesView(viewModel: marketingPreferencesViewModel)
        }
    }
    
    // MARK: View Components
    func checkoutProgressView() -> some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                Image.Checkout.delivery
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
                .font(.snappyBody)
                .fontWeight(.bold)
                .foregroundColor(.snappyBlue)
            
            TextFieldFloatingWithBorder(GeneralStrings.firstName.localized, text: $viewModel.firstname, hasWarning: $viewModel.firstNameHasWarning, background: Color.snappyBGMain)
            
            TextFieldFloatingWithBorder(GeneralStrings.lastName.localized, text: $viewModel.surname, hasWarning: $viewModel.surnameHasWarning, background: Color.snappyBGMain)
            
            TextFieldFloatingWithBorder(AddDetailsStrings.email.localized, text: $viewModel.email, hasWarning: $viewModel.emailHasWarning, background: Color.snappyBGMain, keyboardType: .emailAddress)
            
            TextFieldFloatingWithBorder(AddDetailsStrings.phone.localized, text: $viewModel.phoneNumber, hasWarning: $viewModel.phoneNumberHasWarning, background: Color.snappyBGMain, keyboardType: .numberPad)
        }
    }
    
    var continueButton: some View {
        Button {
            Task {
                await viewModel.continueButtonTapped {
                    try await marketingPreferencesViewModel.updateMarketingPreferences()
                }
            }
        } label: {
            if viewModel.handlingContinueUpdates {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .padding(Constants.ContinueButton.padding)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: Constants.ContinueButton.cornerRadius)
                            .fill(Color.snappyTeal)
                    )
            } else {
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
        .disabled(viewModel.handlingContinueUpdates)
    }
}

struct CheckoutDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutDetailsView(container: .preview)
    }
}