//
//  InitialView.swift
//  SnappyV2Study
//
//  Created by Henrik Gustavii on 21/06/2021.
//

import SwiftUI

struct InitialView: View {
    typealias ViewStrings = Strings.InitialView
    typealias LoginStrings = Strings.General.Login
    
    struct Constants {
        struct LoginButtons {
            static let width: CGFloat = 150
            static let vPadding: CGFloat = 10
            static let cornerRadius: CGFloat = 8
        }
        
        struct General {
            static let animationDuration: CGFloat = 0.2
            static let width: CGFloat = 300
        }
        
        struct Logo {
            static let width: CGFloat = 100
            static let height: CGFloat = 50
            static let padding: CGFloat = 2
        }
    }
    
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: InitialViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                Image.InitialView.screenBackground
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                if viewModel.showFirstView {
                    VStack(alignment: .center) {
                        
                        Spacer()
                        
                        Image.SnappyLogos.snappyLogoWhite
                            .resizable()
                            .scaledToFit()
                        
                        Text(Strings.InitialView.tagline.localized)
                            .foregroundColor(.white)
                            .font(.snappyTitle)
                            .padding(.top, -15)
                        
                        postcodeSearchBarView()
                            .padding(.top, 20)
                        
                        Spacer()
                        
                        // If user is logged in we do not show the log in options
                        if viewModel.isUserSignedIn {
                        #warning("Unsure yet if this will be sign out button or some kind of view profile button. TBC")
                            logoutButton
                        } else {
                            loginButtons
                        }
                        
                        NavigationLink(destination: LoginView(loginViewModel: .init(container: viewModel.container), facebookButtonViewModel: .init(container: viewModel.container)), tag: InitialViewModel.NavigationDestination.login, selection: $viewModel.viewState) { EmptyView() }
                        
                        NavigationLink(destination: CreateAccountView(viewModel: .init(container: viewModel.container), facebookButtonViewModel: .init(container: viewModel.container)), tag: InitialViewModel.NavigationDestination.create, selection: $viewModel.viewState) { EmptyView() }
                    }
                    .animation(Animation.linear(duration: Constants.General.animationDuration))
                    .frame(width: Constants.General.width)
                }
                
                VStack {
                    HStack {
                        Image.SnappyLogos.snappyLogoWhite
                            .resizable()
                            .scaledToFit()
                            .frame(width: Constants.Logo.width, height: Constants.Logo.height)
                            .padding(.leading, Constants.Logo.padding)
                        
                        Spacer()
                    }
                    Spacer()
                }
                .frame(width: UIScreen.main.bounds.width)
                
            }
            .onAppear {
                AppDelegate.orientationLock = .portrait
            }
            .onDisappear {
                AppDelegate.orientationLock = .all
            }
            .navigationBarHidden(true)
            .alert(isPresented: $viewModel.showFailedBusinessProfileLoading) {
                Alert(title: Text(Strings.InitialView.businessProfileAlertTitle.localized), message: Text(Strings.InitialView.businessProfileAlertMessage.localized), dismissButton: .default(Text(Strings.General.retry.localized), action: {
                    viewModel.loadBusinessProfile()
                }))
            }
        }
        .navigationViewStyle(.stack)
    }
    
    #warning("Temp button with no functionality - awaiting designs")
    private var logoutButton: some View {
        Button {
            print("Sign out")
        } label: {
            Text("Sign out")
                .frame(maxWidth: .infinity)
                .padding(Constants.LoginButtons.vPadding)
        }
        .buttonStyle(SnappyPrimaryButtonStyle())
    }
    
    // Login and signup buttons stacked together as will always appear or be hidden together
    private var loginButtons: some View {
        HStack {
            loginButton(
                icon: Image.Login.User.standard,
                text: LoginStrings.login.localized,
                action: viewModel.loginTapped)
                .buttonStyle(SnappyPrimaryButtonStyle())
            
            loginButton(
                icon: Image.Login.signup,
                text: LoginStrings.signup.localized,
                action: viewModel.signUpTapped)
                // standard SnappySecondaryButtonStyle has clear background which does not work here due to bg images
                .background(Color.white)
                .cornerRadius(Constants.LoginButtons.cornerRadius)
                .buttonStyle(SnappySecondaryButtonStyle())
        }
    }
    
    private func loginButton(icon: Image, text: String, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            HStack {
                icon
                Text(text)
                    .padding(.vertical, Constants.LoginButtons.vPadding)
            }
            .frame(width: Constants.LoginButtons.width)
        }
    }
    
    func postcodeSearchBarView() -> some View {
        VStack {
            TextField(ViewStrings.postcodeSearch.localized, text: $viewModel.postcode)
                .frame(width: 272, height: 55)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(.horizontal, 14)
                .background(colorScheme == .dark ? Color.black : Color.white)
                .cornerRadius(15)
                .autocapitalization(.allCharacters)
                .disableAutocorrection(true)
            
            Button(action: { viewModel.tapLoadRetailStores() } ) {
                searchButton
            }
            .disabled(viewModel.postcode.isEmpty)
        }
    }
    
    @ViewBuilder var searchButton: some View {
        if viewModel.isLoading {
            ProgressView()
                .frame(width: 300, height: 55)
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.blue)
                )
        } else {
            Text(ViewStrings.storeSearch.localized)
                .font(.title2)
                .fontWeight(.semibold)
                .frame(width: 300, height: 55)
                .foregroundColor(.white)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(viewModel.postcode.isEmpty ? Color.gray : Color.blue)
                )
        }
    }
}

struct InitialView_Previews: PreviewProvider {
    static var previews: some View {
        InitialView(viewModel: .init(container: .preview))
            .previewCases()
    }
}
