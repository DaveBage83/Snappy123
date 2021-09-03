//
//  CheckoutView.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 15/07/2021.
//

import SwiftUI

class CheckoutViewModel: ObservableObject {
    @Published var progressState: CheckoutProgress = .checkout
    
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
        ScrollView {
            VStack {
                checkoutProgressView()
                    .background(Color.white)
                
                progressStateViews
            }
        }
        .background(Color.snappyBGMain)
    }
    
    @ViewBuilder var progressStateViews: some View {
        switch viewModel.progressState {
        case .checkout:
            checkoutStage()
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
    
    func checkoutProgressView() -> some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                Image(systemName: "car")
                    .font(.title2)
                    .foregroundColor(.snappyBlue)
                    .padding()
                
                VStack(alignment: .leading) {
                    Text("Delivery date and time")
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
}

struct CheckoutView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutView()
            .previewCases()
    }
}
