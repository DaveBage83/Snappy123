//
//  CreateAccountCard.swift
//  SnappyV2
//
//  Created by David Bage on 01/03/2022.
//

import SwiftUI
import Combine
import OSLog

enum QuickCreateAccountError: Swift.Error {
    case passwordEmpty
}

extension QuickCreateAccountError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .passwordEmpty:
            return Strings.SuccessView.noPassword.localized
        }
    }
}

@MainActor
class CreateAccountCardViewModel: ObservableObject {
    let container: DIContainer
    let isInCheckout: Bool
    @Published var password = ""
    @Published var passwordHasError = false
    @Published var creatingAccount = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init(container: DIContainer, isInCheckout: Bool) {
        self.container = container
        self.isInCheckout = isInCheckout
        setupPasswordHasError()
    }
    
    private func setupPasswordHasError() {
        $password
            .dropFirst()
            .receive(on: RunLoop.main)
            .map { password in
                return password.isEmpty
            }
            .assignWeak(to: \.passwordHasError, on: self)
            .store(in: &cancellables)
    }
    
    func createAccountTapped() async {
        passwordHasError = password.isEmpty
        
        guard passwordHasError == false else {
            container.appState.value.errors.append(QuickCreateAccountError.passwordEmpty)
            return
        }
        
        guard let basket = container.appState.value.userData.successCheckoutBasket,
              let address = basket.addresses?.first(where: { $0.type == "billing" }),
              let firstName = address.firstName,
              let lastName = address.lastName,
              let email = address.email,
              let phone = address.telephone
        else {
            // We should never get here as all above params are required to complete an order
            container.appState.value.errors.append(GenericError.somethingWrong)
            return
        }
        
        creatingAccount = true
        
        let member = MemberProfileRegisterRequest(
            firstname: firstName,
            lastname: lastName,
            emailAddress: email,
            referFriendCode: nil,
            mobileContactNumber: phone,
            defaultBillingDetails: nil,
            savedAddresses: nil
        )
        
        do {
            try await self.container.services.memberService.register(
                member: member,
                password: password,
                referralCode: nil,
                marketingOptions: nil,
                atCheckout: isInCheckout
            )
            // Once registered go to account tab
            creatingAccount = false
            container.appState.value.routing.selectedTab = .account
            Logger.member.log("Successfully registered member")
        } catch {
            container.appState.value.errors.append(error)
            creatingAccount = false
            Logger.member.error("Failed to register member.")
        }
    }
}

struct CreateAccountCard: View {
    @ScaledMetric var scale: CGFloat = 1 // Used to scale icon for accessibility options
    @Environment(\.colorScheme) var colorScheme
    
    typealias CreateAccountStrings = Strings.CreateAccount
    
    struct Constants {
        struct General {
            static let padding: CGFloat = 24
        }
        
        struct Option {
            static let iconSize: CGFloat = 24
            static let iconPadding: CGFloat = 10
        }
        
        struct Title {
            static let height: CGFloat = 28
            static let bottomPadding: CGFloat = 26
        }
        
        struct MemberBenefits {
            static let bottomPadding: CGFloat = 24
            static let spacing: CGFloat = 21
            static let titleWidth: CGFloat = 83
            static let titleHeight: CGFloat = 32
        }
    }
    
    @StateObject var viewModel: CreateAccountCardViewModel
    
    var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Text(CreateAccountStrings.create.localized)
                .font(.heading3())
                .foregroundColor(colorPalette.typefacePrimary)
                .fontWeight(.bold)
                .padding()
                .frame(height: Constants.Title.height * scale)
                .padding(.bottom, Constants.Title.bottomPadding)
            
            memberBenefitsView
                .frame(maxWidth: .infinity)
                .padding(.bottom, Constants.MemberBenefits.bottomPadding)
            
            SnappyTextfield(container: viewModel.container, text: $viewModel.password, hasError: $viewModel.passwordHasError, labelText: GeneralStrings.Login.password.localized, largeTextLabelText: nil, fieldType: .secureTextfield)
                .padding(.bottom)
            
            SnappyButton(container: viewModel.container, type: .primary, size: .large, title: CreateAccountStrings.title.localized, largeTextTitle: nil, icon: nil, isLoading: $viewModel.creatingAccount) {
                Task {
                    await viewModel.createAccountTapped()
                }
                
            }
        }
        .padding(Constants.General.padding)
        .background(colorPalette.secondaryWhite)
        .standardCardFormat()
    }
    
    var memberBenefitsView: some View {
        HStack(spacing: Constants.MemberBenefits.spacing) {
            memberBenefit(title: CreateAccountStrings.refer.localized, icon: Image.Icons.ThumbsUp.standard)
            memberBenefit(title: CreateAccountStrings.checkout.localized, icon: Image.Icons.CartFast.standard)
            memberBenefit(title: CreateAccountStrings.deals.localized, icon: Image.Icons.Piggy.standard)
        }
    }
    
    func memberBenefit(title: String, icon: Image) -> some View {
        VStack(spacing: 0) {
            icon
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: Constants.Option.iconSize * scale)
                .foregroundColor(.snappyRed)
                .font(.system(size: Constants.Option.iconSize))
                .padding(.bottom, Constants.Option.iconPadding)
            
            Text(title)
                .font(.Body2.regular())
                .multilineTextAlignment(.center)
                .frame(width: Constants.MemberBenefits.titleWidth * scale, height: Constants.MemberBenefits.titleHeight * scale)
        }
    }
}

#if DEBUG
struct CreateAccountCard_Previews: PreviewProvider {
    static var previews: some View {
        CreateAccountCard(viewModel: .init(container: .preview, isInCheckout: false))
            .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)

    }
}
#endif
