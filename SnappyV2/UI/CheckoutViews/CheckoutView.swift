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
                Image(systemName: "car")
                    .font(.title2)
                    .foregroundColor(.snappyBlue)
                    .padding()
                
                VStack(alignment: .leading) {
                    Text("Delivery date & time")
                        .font(.snappyCaption)
                        .foregroundColor(.gray)
                    
                    Text("Sun, 15 October, 10:30").bold()
                        .font(.snappyCaption)
                        .foregroundColor(.snappyBlue)
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("Order Total")
                        .foregroundColor(.gray)
                    
                    HStack {
                        Text("£8.95")
                            .fontWeight(.semibold)
                            .foregroundColor(.snappyBlue)
                        
                        Image(systemName: "list.bullet.rectangle")
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
            Image(systemName: "figure.walk")
                .font(.title2)
                .foregroundColor(.snappyBlue)
            
            Spacer()
            
            VStack(alignment: .leading) {
                Text("Continue as Guest")
                    .font(.snappyHeadline)
                Text("No ties and just one-off orders")
                    .font(.snappyCaption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
        }
        .padding()
        .background(Color.white)
        .cornerRadius(6)
        .snappyShadow()
    }
    
    func loginToAccountCard() -> some View {
        HStack {
            Image(systemName: "person.crop.square")
                .font(.title2)
                .foregroundColor(.snappyBlue)
            
            Spacer()
            
            VStack(alignment: .leading) {
                Text("Login to your account")
                    .font(.snappyHeadline)
                Text("Save everything and earn points")
                    .font(.snappyCaption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
        }
        .padding()
        .background(Color.white)
        .cornerRadius(6)
        .snappyShadow()
    }
    
    func signInWithAppleCard() -> some View {
        HStack {
            Image(systemName: "applelogo")
                .font(.title2)
                .foregroundColor(.snappyBlue)
            
            Spacer()
            
            VStack(alignment: .leading) {
                Text("Sign in with Apple")
                    .font(.snappyHeadline)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
        }
        .padding()
        .background(Color.white)
        .cornerRadius(6)
        .snappyShadow()
    }
    
    func loginWithFacebookCard() -> some View {
        HStack {
            Image(systemName: "number.circle.fill")
                .font(.title2)
                .foregroundColor(.snappyBlue)
            
            Spacer()
            
            VStack(alignment: .leading) {
                Text("Login with Facebook")
                    .font(.snappyHeadline)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
        }
        .padding()
        .background(Color.white)
        .cornerRadius(6)
        .snappyShadow()
    }
    
    func addDetails() -> some View {
        VStack(alignment: .leading) {
            Text("Add your details")
                .font(.snappyHeadline)
            
            SnappyTextField(title: "First Name", fieldString: $viewModel.firstname)
            
            SnappyTextField(title: "Last Name", fieldString: $viewModel.surname)
            
            SnappyTextField(title: "Email", fieldString: $viewModel.email)
            
            SnappyTextField(title: "Phone number", fieldString: $viewModel.phoneNumber)
            
            
        }
        .padding()
    }
    
    func addAddress() -> some View {
        VStack(alignment: .leading) {
            Text("Add your delivery address")
                .font(.snappyHeadline)
            SnappyTextField(title: "Add your postcode to quickly find your address", fieldString: $viewModel.postcode)
            
            SnappyTextField(title: "Addess line 1", fieldString: $viewModel.address1)
            
            SnappyTextField(title: "Address line 2", fieldString: $viewModel.address2)
            
            SnappyTextField(title: "Postcode", fieldString: $viewModel.postcode)
            
            SnappyTextField(title: "City", fieldString: $viewModel.city)
            
            SnappyTextField(title: "Country", fieldString: $viewModel.country) // is country neccessary?
        }
        .padding()
    }
    
    func termsAndConditions() -> some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: viewModel.termsIsSelected ? "checkmark.circle.fill" : "checkmark.circle")
                    .font(.title)
                    .foregroundColor(.snappyBlue)
                
                Text("I confirm with the ")
                    .font(.snappyCaption)
                +
                Text("terms and conditions").bold()
                    .font(.snappyCaption)
            }
            .padding(.bottom)
            
            HStack {
                Image(systemName: viewModel.emailMarketingIsSelected ? "checkmark.circle.fill" : "checkmark.circle")
                    .font(.title)
                    .foregroundColor(.snappyBlue)
                
                Text("I wish to receive email marketing with the latest offers from Snappy Shopper")
                    .font(.snappyCaption)
            }
            .padding(.bottom)
            
            HStack {
                Image(systemName: viewModel.termsIsSelected ? "checkmark.circle.fill" : "checkmark.circle")
                    .font(.title)
                    .foregroundColor(.snappyBlue)
                
                Text("I wish to receive email marketing with the latest offers from Snappy Shopper")
                    .font(.snappyCaption)
            }
            .padding(.bottom)
        }
    }
    
    func nextButton() -> some View {
        Button(action: {}) {
            Text("Next")
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
