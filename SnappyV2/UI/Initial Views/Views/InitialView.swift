//
//  InitialView.swift
//  SnappyV2Study
//
//  Created by Henrik Gustavii on 21/06/2021.
//

import SwiftUI

struct InitialView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: InitialViewModel
    
    init(viewModel: InitialViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            Image("screen")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack(alignment: .center) {
                
                Spacer()
                
                Image("snappy-logo-white")
                    .resizable()
                    .scaledToFit()
                
                Text("local store to door")
                    .foregroundColor(.white)
                    .font(.snappyTitle)
                    .padding(.top, -15)
                
                postcodeSearchBarView()
                    .padding(.top, 20)
                
                Spacer()
                
                if viewModel.loginButtonPressed {
                    loginOptions()
                } else {
                    Button(action: { viewModel.loginButtonPressed = true } ) {
                        Text("Login or Signup")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(width: 300, height: 55)
                            .foregroundColor(.white)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.blue)
                            )
                    }
                    
                    Spacer()
                }
                
            }
            .animation(Animation.linear(duration: 0.2))
            .frame(width: 300)
            
            VStack {
                HStack {
                    Image("snappy-logo-white")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 50)
                        .padding(.leading, 2)
                    
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
    }
    
    func loginOptions() -> some View {
        VStack {
            Button(action: { viewModel.tapLoadRetailStores() } ) {
                Text("Login with email")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .frame(width: 300, height: 55)
                    .foregroundColor(.white)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.blue)
                    )
                    .padding(.top, 40)
                    .padding(.bottom, 4)
            }
            
            Button(action: {} ) {
                Label("Login with Apple", systemImage: "applelogo")
                    .font(.title2)
                    .frame(width: 300, height: 55)
                    .foregroundColor(.white)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.black)
                    )
                    .padding(.bottom, 4)
            }
            
            Button(action: {} ) {
                Text("Login with Facebook")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .frame(width: 300, height: 55)
                    .foregroundColor(.white)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.blue)
                    )
                    .padding(.bottom, 15)
            }
            
            Button(action: {} ) {
                Text("Create an Account")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .frame(width: 300, height: 55)
                    .foregroundColor(.white)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.blue)
                    )
                    .padding(.bottom, 4)
            }
            
            Button(action: { viewModel.loginButtonPressed = false } ) {
                Image(systemName: "xmark.circle")
                    .font(.title)
                    .foregroundColor(colorScheme == .dark ? .black : .white)
            }
            
        }
    }
    
    func postcodeSearchBarView() -> some View {
        VStack {
                        TextField("Enter your postcode", text: $viewModel.postcode)
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
            Text("Search Local Stores")
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
