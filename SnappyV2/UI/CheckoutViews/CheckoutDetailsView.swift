//
//  CheckoutDetailsView.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 27/01/2022.
//

import SwiftUI

class CheckoutDetailsViewModel: ObservableObject {
    let container: DIContainer
    @Published var firstname = ""
    @Published var surname = ""
    @Published var email = ""
    @Published var phoneNumber = ""
    
    @Published var termsIsSelected = false
    @Published var emailMarketingIsSelected = false
    @Published var smslMarketingIsSelected = false
    
    @Published var isContinueTapped: Bool = false
    
    let memberSignedIn: Bool
    
    init(container: DIContainer) {
        self.container = container
        let appState = container.appState
        
        self.memberSignedIn = appState.value.userData.memberSignedIn
    }
}

struct CheckoutDetailsView: View {
    typealias AddDetailsStrings = Strings.CheckoutView.AddDetails
    typealias ProgressStrings = Strings.CheckoutView.Progress
    typealias TsAndCsStrings = Strings.CheckoutView.TsAndCs
    
    @StateObject var viewModel: CheckoutDetailsViewModel
    @EnvironmentObject var checkoutViewModel: CheckoutViewModel
    
    var body: some View {
        ScrollView {
            checkoutProgressView()
                .background(Color.white)
            
            addDetails()
                .padding([.top, .leading, .trailing])
            
            termsAndConditions()
                .padding([.top, .leading, .trailing])
            
            Button(action: { viewModel.isContinueTapped = true }) {
                continueButton()
                    .padding([.top, .leading, .trailing])
            }
            
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
        VStack(alignment: .leading) {
            Text(AddDetailsStrings.title.localized)
                .font(.snappyHeadline)
            
            TextFieldFloatingWithBorder(AddDetailsStrings.firstName.localized, text: $viewModel.firstname, background: Color.snappyBGMain)
                
                TextFieldFloatingWithBorder(AddDetailsStrings.lastName.localized, text: $viewModel.surname, background: Color.snappyBGMain)
                
                TextFieldFloatingWithBorder(AddDetailsStrings.email.localized, text: $viewModel.email, background: Color.snappyBGMain)
                
                TextFieldFloatingWithBorder(AddDetailsStrings.phone.localized, text: $viewModel.phoneNumber, background: Color.snappyBGMain)
        }
    }
    
    func termsAndConditions() -> some View {
        VStack(alignment: .leading) {
            Text("Marketing Preferences")
                .font(.snappyHeadline)
                .padding(.top)
            
            Text("How would you like us to keep in touch with you?")
                .font(.snappySubheadline)
                .padding(.bottom)
            
            HStack {
                Image(systemName: viewModel.termsIsSelected ? "checkmark.circle.fill" : "checkmark.circle")
                    .font(.title)
                    .foregroundColor(.snappyBlue)
                
                Text("Email")
                    .font(.snappyCaption)
            }
            .padding(.bottom)
            
            HStack {
                Image(systemName: viewModel.emailMarketingIsSelected ? "checkmark.circle.fill" : "checkmark.circle")
                    .font(.title)
                    .foregroundColor(.snappyBlue)
                
                Text("Direct Mail")
                    .font(.snappyCaption)
            }
            .padding(.bottom)
            
            HStack {
                Image(systemName: viewModel.termsIsSelected ? "checkmark.circle.fill" : "checkmark.circle")
                    .font(.title)
                    .foregroundColor(.snappyBlue)
                
                Text("Mobile Notifications")
                    .font(.snappyCaption)
            }
            .padding(.bottom)
            
            HStack {
                Image(systemName: viewModel.termsIsSelected ? "checkmark.circle.fill" : "checkmark.circle")
                    .font(.title)
                    .foregroundColor(.snappyBlue)
                
                Text("Telephone")
                    .font(.snappyCaption)
            }
            .padding(.bottom)
            
            HStack {
                Image(systemName: viewModel.termsIsSelected ? "checkmark.circle.fill" : "checkmark.circle")
                    .font(.title)
                    .foregroundColor(.snappyBlue)
                
                Text("SMS Text Message")
                    .font(.snappyCaption)
            }
            .padding(.bottom)
        }
    }
    
    func continueButton() -> some View {
        Text("Continue")
            .font(.snappyTitle2)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(10)
            .padding(.horizontal)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.snappyTeal)
            )
    }
}

struct CheckoutDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutDetailsView(viewModel: .init(container: .preview))
            .environmentObject(CheckoutViewModel(container: .preview))
    }
}
