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
    @Environment(\.tabViewHeight) var tabViewHeight

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
                    VStack {
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
                    .padding(.bottom, tabViewHeight)
                }
                .background(colorPalette.backgroundMain)
                .withAlertToast(container: viewModel.container, error: $viewModel.error)
                .withSuccessToast(container: viewModel.container, toastText: $viewModel.successMessage)
                .toast(isPresenting: $viewModel.loading) {
                    AlertToast(displayMode: .alert, type: .loading)
                }
                
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(content: {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            viewModel.settingsTapped()
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
                        SnappyLogo()
                    }
                })
            }
        }
        .navigationViewStyle(.stack)
        .sheet(isPresented: $viewModel.showSettings) {
            NavigationView {
                MemberDashboardSettingsView(
                    viewModel: .init(container: viewModel.container),
                    marketingPreferencesViewModel: .init(container: viewModel.container, viewContext: .settings, hideAcceptedMarketingOptions: false),
                    pushNotificationsMarketingPreferenceViewModel: .init(container: viewModel.container, viewContext: .settings, hideAcceptedMarketingOptions: false),
                    dismissViewHandler: {
                    viewModel.dismissSettings()
                })
            }
        }
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
            MemberDashboardProfileView(viewModel: .init(container: viewModel.container), didSetError: { error in
                viewModel.error = error
            }, didSucceed: { message in
                viewModel.successMessage = message
            })
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
}

#if DEBUG
struct MemberDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        MemberDashboardView(viewModel: .init(container: .preview))
    }
}
#endif
