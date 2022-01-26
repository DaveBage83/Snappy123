//
//  CheckoutView.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 15/07/2021.
//

import SwiftUI

class CheckoutViewModel: ObservableObject {
    @Published var progressState: CheckoutProgress = .details
    
    @Published var firstname = ""
    @Published var surname = ""
    @Published var email = ""
    @Published var phoneNumber = ""
    
    @Published var postcode = ""
    @Published var address1 = ""
    @Published var address2 = ""
    @Published var city = ""
    @Published var country = ""
    
    @Published var termsIsSelected = false
    @Published var emailMarketingIsSelected = false
    @Published var smslMarketingIsSelected = false
    
    enum CheckoutProgress: Int {
        case checkout = 1
        case details
        case payment
        case success
    }
}

struct CheckoutView: View {
    /// Typealiases for concise String reference
    typealias LoginStrings = Strings.General.Login
    typealias ProgressStrings = Strings.CheckoutView.Progress
    typealias GuestCheckoutStrings = Strings.CheckoutView.GuestCheckoutCard
    typealias AccountLoginStrings = Strings.CheckoutView.LoginToAccount
    typealias AddDetailsStrings = Strings.CheckoutView.AddDetails
    typealias AddressStrings = Strings.CheckoutView.AddAddress
    typealias TsAndCsStrings = Strings.CheckoutView.TsAndCs

    @State var email: String = ""
    @State var password: String = ""
    
    @StateObject var viewModel = CheckoutViewModel()
    
    var body: some View {
        
        VStack {
            checkoutProgressView()
                .background(Color.white)
            ScrollView {
                progressStageViews
            }
        }
        .background(Color.snappyBGMain)
//        .ignoresSafeArea()
    }
    
    @ViewBuilder var progressStageViews: some View {
        switch viewModel.progressState {
        case .checkout:
            checkoutStage()
        case .details:
            detailsStage()
        default:
            checkoutStage()
        }
    }
    
    func checkoutStage() -> some View {
        VStack {
            guestCheckoutCard()
                .padding(.bottom)
            
            loginToAccountCard()
            
            Divider()
                .padding()
            
            signInWithAppleCard()
                .padding(.bottom)
            
            loginWithFacebookCard()
        }
        .padding()
    }
    
    func detailsStage() -> some View {
        VStack {
            addDetails()
            
            addAddress()
            
            termsAndConditions()
            
            nextButton()
        }
        .padding()
    }
    
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
            
            ProgressBarView(value: Double(viewModel.progressState.rawValue), maxValue: 4, backgroundColor: .snappyBGFields1, foregroundColor: .snappyBlue)
                .frame(height: 6)
                .padding(.horizontal, -3)
        }
    }
    
    func guestCheckoutCard() -> some View {
        HStack {
            Image.Checkout.leave
                .font(.title2)
                .foregroundColor(.snappyBlue)
            
            Spacer()
            
            VStack(alignment: .leading) {
                Text(GuestCheckoutStrings.guest.localized)
                    .font(.snappyHeadline)
                Text(GuestCheckoutStrings.noTies.localized)
                    .font(.snappyCaption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image.Navigation.chevronRight
        }
        .padding()
        .background(Color.white)
        .cornerRadius(6)
        .snappyShadow()
    }
    
    func loginToAccountCard() -> some View {
        HStack {
            Image.Login.User.square
                .font(.title2)
                .foregroundColor(.snappyBlue)
            
            Spacer()
            
            VStack(alignment: .leading) {
                Text(AccountLoginStrings.login.localized)
                    .font(.snappyHeadline)
                Text(AccountLoginStrings.earnPoints.localized)
                    .font(.snappyCaption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image.Navigation.chevronRight
        }
        .padding()
        .background(Color.white)
        .cornerRadius(6)
        .snappyShadow()
    }
    
    func signInWithAppleCard() -> some View {
        HStack {
            Image.Login.Methods.apple
                .font(.title2)
                .foregroundColor(.snappyBlue)
            
            Spacer()
            
            VStack(alignment: .leading) {
                Text(LoginStrings.Customisable.signInWith.localizedFormat(LoginStrings.apple.localized))
                    .font(.snappyHeadline)
            }
            
            Spacer()
            
            Image.Navigation.chevronRight
        }
        .padding()
        .background(Color.white)
        .cornerRadius(6)
        .snappyShadow()
    }
    
    func loginWithFacebookCard() -> some View {
        HStack {
            Image.General.Number.filledCircle
                .font(.title2)
                .foregroundColor(.snappyBlue)
            
            Spacer()
            
            VStack(alignment: .leading) {
                Text(LoginStrings.Customisable.loginWith.localizedFormat(LoginStrings.facebook.localized))
                    .font(.snappyHeadline)
            }
            
            Spacer()
            
            Image.Navigation.chevronRight
        }
        .padding()
        .background(Color.white)
        .cornerRadius(6)
        .snappyShadow()
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
        .padding()
    }
    
    func addAddress() -> some View {
        VStack(alignment: .leading) {
            Text(AddressStrings.title.localized)
                .font(.snappyHeadline)
            SnappyTextField(title: AddressStrings.findAddress.localized, fieldString: $viewModel.postcode)
            
            SnappyTextField(title: AddressStrings.line1.localized, fieldString: $viewModel.address1)
            
            SnappyTextField(title: AddressStrings.line2.localized, fieldString: $viewModel.address2)
            
            SnappyTextField(title: AddressStrings.postcode.localized, fieldString: $viewModel.postcode)
            
            SnappyTextField(title: AddressStrings.city.localized, fieldString: $viewModel.city)
            
            SnappyTextField(title: AddressStrings.country.localized, fieldString: $viewModel.country) // is country neccessary?
        }
        .padding()
    }
    
    func termsAndConditions() -> some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: viewModel.termsIsSelected ? "checkmark.circle.fill" : "checkmark.circle")
                    .font(.title)
                    .foregroundColor(.snappyBlue)
                
                Text(TsAndCsStrings.confirm.localized)
                    .font(.snappyCaption)
                +
                Text(TsAndCsStrings.title.localized).bold()
                    .font(.snappyCaption)
            }
            .padding(.bottom)
            
            HStack {
                Image(systemName: viewModel.emailMarketingIsSelected ? "checkmark.circle.fill" : "checkmark.circle")
                    .font(.title)
                    .foregroundColor(.snappyBlue)
                
                Text(TsAndCsStrings.emailMarketing.localized)
                    .font(.snappyCaption)
            }
            .padding(.bottom)
            
            HStack {
                Image(systemName: viewModel.termsIsSelected ? "checkmark.circle.fill" : "checkmark.circle")
                    .font(.title)
                    .foregroundColor(.snappyBlue)
                
                Text(TsAndCsStrings.emailMarketing.localized)
                    .font(.snappyCaption)
            }
            .padding(.bottom)
        }
    }
    
    func nextButton() -> some View {
        Button(action: {}) {
            Text(Strings.General.next.localized)
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
}

struct CheckoutView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutView()
            .previewCases()
    }
}
