//
//  CheckoutView.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 26/01/2022.
//

import SwiftUI

struct CheckoutView: View {
    @Environment(\.presentationMode) var presentation
    @Environment(\.colorScheme) var colorScheme
    
    typealias RetailMembershipIdWarningStrings = Strings.CheckoutView.RetailMembershipIdWarning
    typealias AccountLoginStrings = Strings.CheckoutView.LoginToAccount
    typealias ProgressStrings = Strings.CheckoutView.Progress
    typealias PaymentStrings = Strings.CheckoutView.Payment
    
    @ObservedObject var viewModel: CheckoutRootViewModel
    
    struct Constants {
        static let buttonSpacing: CGFloat = 16
        
        struct RetailMembershipIdWarning {
            static let spacing: CGFloat = 16
            static let iconHeight: CGFloat = 16
            static let fontPadding: CGFloat = 12
            static let bottomPadding: CGFloat = 4
            static let lineLimit = 6
        }
    }
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    init(viewModel: CheckoutRootViewModel) {
        self._viewModel = .init(wrappedValue: viewModel)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: Constants.buttonSpacing) {

                Button(action: { viewModel.loginToAccountTapped() }) {
                    UserStatusCard(container: viewModel.container, actionType: .login)
                }
                
                Button(action: { viewModel.createAccountTapped() }) {
                    UserStatusCard(container: viewModel.container, actionType: .createAccount)
                }
                
                // Decision from Product Manager to move guest check option last as it is the option
                // the business would prefer customers not use.
                
                if viewModel.showGuestCheckoutButton {
                    Button(action: { viewModel.guestCheckoutTapped() } ) {
                        UserStatusCard(container: viewModel.container, actionType: .guestCheckout)
                    }
                    
                    retailMembershipIdWarning
                }
            }
            .padding()
        }
    }
    
    @ViewBuilder private var retailMembershipIdWarning: some View {
        if viewModel.showRetailMembershipIdWarning {
            HStack(alignment: .top, spacing: 0) {
                Text(RetailMembershipIdWarningStrings.prefix.localized)
                    .font(.Body2.regular().bold()) +
                Text(RetailMembershipIdWarningStrings.cannotAssociateStart.localized) +
                Text(viewModel.retailMembershipIdName)
                    .font(.Body2.regular().bold()) +
                Text(RetailMembershipIdWarningStrings.cannotAssociateEnd.localized)
                
                Spacer()
                
                Image.Icons.Triangle.filled
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: Constants.RetailMembershipIdWarning.iconHeight)
                    .foregroundColor(colorPalette.alertSuccess)
            }
            .fixedSize(horizontal: false, vertical: true)
            .lineLimit(Constants.RetailMembershipIdWarning.lineLimit)
            .font(.Body2.regular())
            .foregroundColor(colorPalette.alertSuccess)
            .padding(Constants.RetailMembershipIdWarning.fontPadding)
            .background(colorPalette.secondaryWhite)
            .standardCardFormat()
        }
    }
}

#if DEBUG
struct CheckoutView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutView(viewModel: .init(container: .preview))
    }
}
#endif
