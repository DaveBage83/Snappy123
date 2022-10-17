//
//  MemberDashboardView.swift
//  SnappyV2
//
//  Created by David Bage on 18/03/2022.
//

import SwiftUI

// 3rd party
import DriverInterface

struct MemberDashboardView: View {
    typealias MemberStrings = Strings.MemberDashboard
    typealias CustomMemberStrings = Strings.CustomMemberDashboard
    
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.tabViewHeight) var tabViewHeight
    @Environment(\.presentationMode) var presentation

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
        struct MinimalLayoutView {
            static let topPadding: CGFloat = 30
        }
    }
    
    @StateObject var viewModel: MemberDashboardViewModel
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    var body: some View {
        if viewModel.isFromInitialView {
            VStack(spacing: 0) {
                Divider()
                ScrollView(showsIndicators: false) {
                    if viewModel.noMemberFound {
                        mainContent
                    } else {
                        mainContent
                            .dismissableNavBar(presentation: presentation, color: colorPalette.primaryBlue)
                    }
                }
            }
            .background(colorPalette.backgroundMain)
            .edgesIgnoringSafeArea(.bottom)
        } else {
            NavigationView {
                VStack(spacing: 0) {
                    Divider()
                    mainContent
                }
                .background(colorPalette.backgroundMain)
                .edgesIgnoringSafeArea(.bottom)
            }
        }
    }
    
    @ViewBuilder private var mainContent: some View {
        GeometryReader { geo in
            ScrollView(showsIndicators: false) {
                if viewModel.noMemberFound && viewModel.isFromInitialView {
                    LoginView(loginViewModel: .init(container: viewModel.container), socialLoginViewModel: .init(container: viewModel.container, isInCheckout: false))
                } else {
                    VStack {
                        if viewModel.noMemberFound {
                            LoginView(loginViewModel: .init(container: viewModel.container), socialLoginViewModel: .init(container: viewModel.container, isInCheckout: false))
                            
                        } else {
                            
                            VStack {
                                dashboardHeaderView
                                Spacer()
                                mainContentView
                            }
                            .frame(minHeight: geo.size.height)
                            .padding(.horizontal)
                            .padding(.top)
                            .onAppear {
                                viewModel.onAppearSendEvent()
                            }
                        }
                    }
                    .background(colorPalette.backgroundMain)
                    .withLoadingToast(loading: $viewModel.loading)
                    .fullScreenCover(
                        item: $viewModel.driverDependencies,
                        content: { driverDependencies in
                            DriverInterfaceView(driverDependencies: driverDependencies)
                        }
                    )
                    .navigationViewStyle(.stack)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar(content: {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            SettingsButton(viewModel: .init(container: viewModel.container))
                        }
                    })
                    .toolbar(content: {
                        ToolbarItem(placement: .principal) {
                            SnappyLogo()
                        }
                    })
                    }
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
                viewModel.container.appState.value.errors.append(error)
            }, setIsLoading: { isLoading in
                viewModel.loading = isLoading
            })
        case .profile:
            MemberDashboardProfileView(viewModel: .init(container: viewModel.container), didSetError: { error in
                viewModel.container.appState.value.errors.append(error)
            }, didSucceed: { message in
                viewModel.container.appState.value.successToastStrings.append(message)
            })
        case .loyalty:
            LoyaltyView(viewModel: .init(container: viewModel.container, profile: viewModel.profile))
                .padding()
        case .logOut:
            minimalMemberOptionsView(
                titleText: GeneralStrings.Logout.verify.localized,
                buttonText: GeneralStrings.Logout.title.localized,
                loading: $viewModel.loggingOut) {
                    Task {
                        await viewModel.logOut()
                    }
                }
        case .startDriverShift:
            minimalMemberOptionsView(
                titleText: GeneralStrings.DriverInterface.startShift.localized,
                buttonText: GeneralStrings.start.localized,
                loading: $viewModel.driverSettingsLoading) {
                    Task {
                        await viewModel.startDriverShiftTapped()
                    }
                }
            
        case .verifyAccount:
            minimalMemberOptionsView(
                titleText: Strings.MemberDashboard.Options.verifyAccountBody.localized,
                buttonText: Strings.MemberDashboard.Options.verifyAccount.localized,
                loading: $viewModel.requestingVerifyCode) {
                    Task {
                        await viewModel.verifyAccountTapped()
                    }
                }
        }
    }

    @ViewBuilder private func minimalMemberOptionsView(titleText: String, buttonText: String, loading: Binding<Bool>, buttonAction: @escaping () -> Void) -> some View {
        VStack(spacing: Constants.MinimalLayoutView.topPadding) {
            Text(titleText)
                .font(.Body1.regular())
                .foregroundColor(colorPalette.textGrey1)
            
            Spacer()
            
            SnappyButton(
                container: viewModel.container,
                type: .primary,
                size: .large,
                title: buttonText,
                largeTextTitle: nil,
                icon: nil,
                isLoading: loading) {
                    buttonAction()
                }
                .padding()
                .padding(.bottom, tabViewHeight)
        }
        .padding(.top)
        .frame(maxHeight: .infinity)
    }
}

#if DEBUG
struct MemberDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        MemberDashboardView(viewModel: .init(container: .preview))
    }
}
#endif
