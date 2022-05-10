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
        
        struct PostcodeSearch {
            static let topPadding: CGFloat = 20
            static let width: CGFloat = 272
            static let height: CGFloat = 55
            static let hPadding: CGFloat = 14
            static let cornerRadius: CGFloat = 15
        }
        
        struct Tagline {
            static let padding: CGFloat = -15
        }
        
        struct SearchButton {
            static let width: CGFloat = 300
            static let height: CGFloat = 55
            static let cornerRadius: CGFloat = 15
        }
    }
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.scenePhase) var scenePhase
    @StateObject var viewModel: InitialViewModel
    @State var text: String = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.showFirstView {
                    firstView
                }
            }
            .onAppear {
                AppDelegate.orientationLock = .portrait
            }
            .onDisappear {
                AppDelegate.orientationLock = .all
                viewModel.dismissLocationAlertTapped()
            }
            .onChange(of: scenePhase) { newPhase in
                if scenePhase == .background {
                    viewModel.dismissLocationAlertTapped()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    snappyToolbarImage
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    AccountButton {
                        viewModel.viewState = .memberDashboard
                    }
                }
            })
            .alert(isPresented: $viewModel.showFailedBusinessProfileLoading) {
                Alert(title: Text(Strings.InitialView.businessProfileAlertTitle.localized), message: Text(Strings.InitialView.businessProfileAlertMessage.localized), dismissButton: .default(Text(Strings.General.retry.localized), action: {
                    Task {
                      try await viewModel.loadBusinessProfile()
                    }
                }))
            }
            .alert(isPresented: $viewModel.showFailedMemberProfileLoading) {
                Alert(title: Text(Strings.InitialView.memberProfileAlertTitle.localized), message: Text(Strings.InitialView.memberProfileAlertMessage.localized), dismissButton: .default(Text(Strings.General.retry.localized), action: {
                    Task {
                        await viewModel.restoreLastUser()
                    }
                }))
            }
            if viewModel.loggingIn {
                LoadingView()
            }
        }
        .alert(isPresented: $viewModel.locationManager.showDeniedLocationAlert) {
            Alert(
                title: Text(Strings.Alerts.location.deniedLocationTitle.localized),
                message: Text(Strings.Alerts.location.deniedLocationMessage.localized),
                primaryButton:
                        .default(Text(Strings.General.settings.localized), action: {
                            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                        }),
                secondaryButton:
                        .cancel(Text(Strings.General.cancel.localized), action: {
                            viewModel.dismissLocationAlertTapped()
                        })
            )
        }
        .navigationViewStyle(.stack)
    }
    
    private var firstView: some View {
        VStack(alignment: .center) {
            Spacer()
            
            mainContentView
            
            Spacer()
            
            // If user is logged in we do not show the log in options
            if viewModel.showLoginButtons {
                loginButtons
                    .padding(.bottom)
                
            }
            
            navigationLinks
        }
        .animation(Animation.linear(duration: Constants.General.animationDuration))
    }
    
    private var navigationLinks: some View {
        HStack {
            NavigationLink(destination: LoginView(loginViewModel: .init(container: viewModel.container), facebookButtonViewModel: .init(container: viewModel.container)), tag: InitialViewModel.NavigationDestination.login, selection: $viewModel.viewState) { EmptyView() }
            
            NavigationLink(destination: CreateAccountView(viewModel: .init(container: viewModel.container), facebookButtonViewModel: .init(container: viewModel.container)), tag: InitialViewModel.NavigationDestination.create, selection: $viewModel.viewState) { EmptyView() }
            
            NavigationLink(destination: MemberDashboardView(viewModel: .init(container: viewModel.container)), tag: InitialViewModel.NavigationDestination.memberDashboard, selection: $viewModel.viewState) { EmptyView() }
        }
    }
    
    private var snappyToolbarImage: some View {
        Image.SnappyLogos.colouredLogo
            .resizable()
            .scaledToFit()
            .frame(width: Constants.Logo.width, height: Constants.Logo.height)
            .padding(.leading, Constants.Logo.padding)
    }
    
    private var mainContentView: some View {
        ZStack {
            Image.InitialView.screenBackground
                .resizable()
            
            VStack {
                snappyLogoView
                    .frame(maxWidth: .infinity)
                postcodeSearchBarView()
                    .padding(.top, Constants.PostcodeSearch.topPadding)
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    private var snappyLogoView: some View {
        VStack {
            Image.SnappyLogos.snappyLogoWhite
                .resizable()
                .scaledToFit()
            
            Text(Strings.InitialView.tagline.localized)
                .foregroundColor(.white)
                .font(.snappyTitle)
                .padding(.top, Constants.Tagline.padding)
        }
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
        HStack {
            Spacer()
            VStack {
                TextField(ViewStrings.postcodeSearch.localized, text: $viewModel.postcode)
                    .frame(width: Constants.PostcodeSearch.width, height: Constants.PostcodeSearch.height)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(.horizontal, Constants.PostcodeSearch.hPadding)
                    .background(colorScheme == .dark ? Color.black : Color.white)
                    .cornerRadius(Constants.PostcodeSearch.cornerRadius)
                    .autocapitalization(.allCharacters)
                    .disableAutocorrection(true)
                    .overlay(
                        HStack {
                            Spacer()
                            Button(action: { Task { await viewModel.searchViaLocationTapped() } }) {
                                Image(systemName: "location")
                            }
                            .foregroundColor(.black)
                            .padding()
                            .disabled(viewModel.isLoading)
                        }
                    )
                    .disabled(viewModel.isLoading || viewModel.locationIsLoading)
                
                Button(action: { Task { await viewModel.tapLoadRetailStores() } } ) {
                    searchButton
                }
                .disabled(viewModel.postcode.isEmpty || viewModel.isLoading || viewModel.locationIsLoading)
            }
            Spacer()
        }
    }
    
    @ViewBuilder var searchButton: some View {
        if viewModel.isLoading || viewModel.locationIsLoading {
            ProgressView()
                .frame(width: Constants.SearchButton.width, height: Constants.SearchButton.height)
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .background(
                    RoundedRectangle(cornerRadius: Constants.SearchButton.cornerRadius)
                        .fill(Color.blue)
                )
        } else {
            Text(ViewStrings.storeSearch.localized)
                .font(.snappyTitle2)
                .fontWeight(.semibold)
                .frame(width: Constants.SearchButton.width, height: Constants.SearchButton.height)
                .foregroundColor(.white)
                .background(
                    RoundedRectangle(cornerRadius: Constants.SearchButton.cornerRadius)
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
