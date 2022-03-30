//
//  CheckoutView.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 26/01/2022.
//

import SwiftUI

class CheckoutViewModel: ObservableObject {
    enum NavigationDestinations: Hashable {
        case login
        case details
    }
    
    let container: DIContainer
    @Published var isLoggedIn = false
    @Published var viewState: NavigationDestinations?
    
    init(container: DIContainer) {
        self.container = container
    }
    
    func guestCheckoutTapped() {
        viewState = .details
    }
    
    func loginToAccountTapped() {
        if isLoggedIn {
            viewState = .details
        } else {
            viewState = .login
        }
    }
}

struct CheckoutView: View {
    typealias GuestCheckoutStrings = Strings.CheckoutView.GuestCheckoutCard
    typealias AccountLoginStrings = Strings.CheckoutView.LoginToAccount
    typealias ProgressStrings = Strings.CheckoutView.Progress
    
    @StateObject var viewModel: CheckoutViewModel
    
    var body: some View {
        ScrollView {
            // MARK: Main View
            checkoutProgressView()
                .background(Color.white)
            
            Button(action: { viewModel.guestCheckoutTapped() } ) {
                guestCheckoutCard()
                    .padding([.top, .leading, .trailing])
            }
            
            Button(action: { viewModel.loginToAccountTapped() }) {
                loginToAccountCard()
                    .padding([.top, .leading, .trailing])
            }
            
            // MARK: NavigationLinks
            NavigationLink(
                destination: CheckoutDetailsView(container: viewModel.container),
                tag: CheckoutViewModel.NavigationDestinations.details,
                selection: $viewModel.viewState) { EmptyView() }
            NavigationLink(
                destination: CheckoutLoginView(viewModel: .init(container: viewModel.container)),
                tag: CheckoutViewModel.NavigationDestinations.login,
                selection: $viewModel.viewState) { EmptyView() }
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
    
    
}

struct CheckoutView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutView(viewModel: .init(container: .preview))
    }
}
