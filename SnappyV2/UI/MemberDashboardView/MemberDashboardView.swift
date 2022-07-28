//
//  MemberDashboardView.swift
//  SnappyV2
//
//  Created by David Bage on 18/03/2022.
//

import SwiftUI

struct MemberDashboardView: View {
    typealias MemberStrings = Strings.MemberDashboard
    typealias CustomMemberStrings = Strings.CustomMemberDashboard
    
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.colorScheme) var colorScheme
    
    struct Constants {
        struct LogoutButton {
            static let padding: CGFloat = 10
        }
        
        struct Logo {
            static let width: CGFloat = 207.25
            static let largeScreenWidthMultiplier: CGFloat = 1.5
        }
        
        struct InternalView {
            static let topSpacing: CGFloat = 27
        }
        
        struct Settings {
            static let buttonHeight: CGFloat = 24
        }
    }
    
    @StateObject var viewModel: MemberDashboardViewModel
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                
                Divider()
                ScrollView(showsIndicators: false) {
                    if viewModel.noMemberFound {
                        LoginView(loginViewModel: .init(container: viewModel.container), socialLoginViewModel: .init(container: viewModel.container))
                        
                    } else {
                        
                        VStack {
                            dashboardHeaderView
                            mainContentView
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top)
                        .onAppear {
                            viewModel.onAppearSendEvent()
                        }
                    }
                }
                .background(colorPalette.backgroundMain)
                .withAlertToast(container: viewModel.container, error: $viewModel.error)
                .toast(isPresenting: $viewModel.loading) {
                    AlertToast(displayMode: .alert, type: .loading)
                }
                
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(content: {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            print("Go to setting")
                        } label: {
                            Image.Icons.Gears.heavy
                                .renderingMode(.template)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: Constants.Settings.buttonHeight)
                                .foregroundColor(colorPalette.primaryBlue)
                        }
                    }
                })
                .toolbar(content: {
                    ToolbarItem(placement: .principal) {
                        snappyLogo
                    }
                })
            }
        }
        .navigationViewStyle(.stack)
    }
    
    @ViewBuilder var dashboardHeaderView: some View {
        VStack(alignment: .leading) {
            if viewModel.firstNamePresent, let name = viewModel.profile?.firstname {
                Text(CustomMemberStrings.welcome.localizedFormat(name))
                    .font(.heading3())
                    .fontWeight(.semibold)
                    .foregroundColor(.snappyBlue)
                    .padding(.vertical)
            }
            
            MemberDashboardOptionsView(viewModel: viewModel)
        }
    }
    
    @ViewBuilder var mainContentView: some View {
        switch viewModel.viewState {
        case .dashboard:
            MemberDashboardOrdersView(viewModel: .init(container: viewModel.container))
                .padding(.top, Constants.InternalView.topSpacing)
            
        case .orders:
            MemberDashboardOrdersView(viewModel: .init(container: viewModel.container, categoriseOrders: true))
        case .myDetails:
            MemberDashboardMyDetailsView(viewModel: .init(container: viewModel.container), memberDashboardViewModel: viewModel, didSetError: { error in
                viewModel.error = error
            }, setIsLoading: { isLoading in
                viewModel.loading = isLoading
            })
        case .profile:
            MemberDashboardProfileView(container: viewModel.container)
        case .loyalty:
            LoyaltyView(viewModel: .init(container: viewModel.container, profile: viewModel.profile))
                .padding()
        case .logOut:
            VStack {
                Text(GeneralStrings.Logout.verify.localized)
                    .font(.snappyBody2)
                    .foregroundColor(.snappyTextGrey1)
                
                Spacer()
                
                Button {
                    Task {
                        await viewModel.logOut()
                    }
                } label: {
                    if viewModel.loggingOut {
                        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Constants.LogoutButton.padding)
                    } else {
                        Text(GeneralStrings.Logout.title.localized)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Constants.LogoutButton.padding)
                    }
                }
                .buttonStyle(SnappyPrimaryButtonStyle())
                
                Spacer()
            }
        }
    }
    
    // MARK: - Logo
    private var snappyLogo: some View {
        Image.Branding.Logo.inline
            .resizable()
            .scaledToFit()
            .frame(width: Constants.Logo.width * (sizeClass == .compact ? 1 : Constants.Logo.largeScreenWidthMultiplier))
    }
}

#if DEBUG
struct MemberDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        MemberDashboardView(viewModel: .init(container: .preview))
    }
}
#endif
