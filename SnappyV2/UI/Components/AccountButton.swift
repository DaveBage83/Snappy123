//
//  AccountButton.swift
//  SnappyV2
//
//  Created by David Bage on 18/03/2022.
//

import SwiftUI

struct AccountButton: View {
    struct Constants {
        struct Icon {
            static let size: CGFloat = 20
        }
        
        struct General {
            static let vSpacing: CGFloat = 2
        }
    }
    
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            VStack(spacing: Constants.General.vSpacing) {
                Image.Login.User.standard
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: Constants.Icon.size)
                    .foregroundColor(.snappyDark)
                Text(Strings.RootView.Tabs.account.localized)
                    .font(.snappyBody2)
                    .foregroundColor(.snappyDark)
                    .fontWeight(.semibold)
            }
        }
    }
}

struct AccountButton_Previews: PreviewProvider {
    static var previews: some View {
        AccountButton {
            print("Account pressed")
        }
    }
}
