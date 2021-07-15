//
//  CheckoutView.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 15/07/2021.
//

import SwiftUI

struct CheckoutView: View {
    @State var email: String = ""
    @State var password: String = ""
    
    var body: some View {
        ScrollView {
            VStack {
                checkoutProgressView()
                    .padding(.bottom)
                
                deliveryBanner()
                    .padding(.bottom)
                
                guestCheckoutCard()
                    .padding(.bottom)
                
                loginToAccountCard()
                    .padding(.bottom)
                
                createAccountCard()
            }
            .padding()
        }
    }
    
    func checkoutProgressView() -> some View {
        VStack {
            HStack {
                Spacer()
                Text("Checkout")
                Spacer()
                Text("Address")
                    .foregroundColor(.gray)
                Spacer()
                Text("Payment")
                    .foregroundColor(.gray)
                Spacer()
                Text("Success")
                    .foregroundColor(.gray)
                Spacer()
            }
            .font(.snappyCaption)
            
            ProgressBarView(value: 1, maxValue: 4, foregroundColor: .snappyBlue)
                .frame(height: 6)
                .padding(.horizontal)
        }
    }
    
    func deliveryBanner() -> some View {
        HStack(alignment: .top) {
            Image(systemName: "car")
                .font(.title2)
                .foregroundColor(.snappyBlue)
            
            Spacer()
            
            VStack(alignment: .leading) {
                Text("Delivery date and time")
                    .font(.snappyCaption)
                    .foregroundColor(.gray)
                
                Text("Sunday, 15 October, Morning, 10:30").bold()
                    .font(.snappySubheadline)
                    .foregroundColor(.snappyBlue)
                
                HStack {
                    Text("Order Total")
                        .foregroundColor(.gray)
                    Text("£8.95")
                        .foregroundColor(.snappyBlue)
                }
                .font(.snappyBody)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(6)
        .shadow(.grey16, x: 0, y: 5)
    }
    
    func guestCheckoutCard() -> some View {
        HStack {
            Image(systemName: "figure.walk")
                .font(.title2)
                .foregroundColor(.snappyBlue)
            
            Spacer()
            
            VStack(alignment: .leading) {
                Text("Checkout as Guest")
                    .font(.snappyHeadline)
                Text("No ties and just one-off orders")
                    .font(.snappyCaption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: "circle")
        }
        .padding()
        .background(Color.white)
        .cornerRadius(6)
        .shadow(.grey16, x: 0, y: 5)
    }
    
    func loginToAccountCard() -> some View {
        VStack(alignment: .center) {
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
                
                Image(systemName: "circle")
            }
            
            TextField("Email", text: $email)
                .font(.snappyBody)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            SecureField("Password", text: $password)
                .font(.snappyBody)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button(action: {}) {
                Text("Login")
                    .font(.snappyTitle2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(10)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.snappyDark)
                    )
            }
            .padding(.top)
            
            Text("OR")
                .font(.snappyBody)
                .foregroundColor(.gray)
            
            Button(action: {}) {
                Label("Login with Facebook", systemImage: "number.circle.fill")
                    .font(.snappyTitle3)
                    .foregroundColor(.black)
                    .padding(10)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.snappyDark)
                    )
            }
            .padding(.bottom)
            
            Button(action: {}) {
                Label("Login with Apple", systemImage: "applelogo")
                    .font(.snappyTitle3)
                    .foregroundColor(.black)
                    .padding(10)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.snappyDark)
                    )
            }
            .padding(.bottom)
            
            Button(action: {}) {
                Text("Forgot your password?")
                    .font(.snappyBody)
                    .foregroundColor(.gray)
            }
            
        }
        .padding()
        .background(Color.white)
        .cornerRadius(6)
        .shadow(.grey16, x: 0, y: 5)
    }
    
    func createAccountCard() -> some View {
        HStack {
            Image(systemName: "person.fill.badge.plus")
                .font(.title2)
                .foregroundColor(.snappyBlue)
            
            Spacer()
            
            VStack(alignment: .leading) {
                Text("Create an account")
                    .font(.snappyHeadline)
                Text("Save everything and earn points")
                    .font(.snappyCaption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: "circle")
        }
        .padding()
        .background(Color.white)
        .cornerRadius(6)
        .shadow(.grey16, x: 0, y: 5)
    }
}

struct CheckoutView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutView()
            .previewCases()
    }
}
