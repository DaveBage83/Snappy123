//
//  ClipboardReferralCodeField.swift
//  SnappyV2
//
//  Created by David Bage on 18/03/2022.
//

import SwiftUI

class ClipboardReferralCodeFieldViewModel: ObservableObject {
    let code: String
    
    init(code: String) {
        self.code = code
    }
    
    func copyCodeButtonPressed() {
        UIPasteboard.general.string = code
    }
}

struct ClipboardReferralCodeField: View {
    typealias ClipboardFieldStrings = Strings.MemberDashboard.Loyalty
    
    struct Constants {
        static let fieldVSpacing: CGFloat = 5
        static let copyItemSize: CGFloat = 25
        static let cornerRadius: CGFloat = 10
        static let mainVSpacing: CGFloat = 10
    }
    
    @ObservedObject var viewModel: ClipboardReferralCodeFieldViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.mainVSpacing) {
            Text(ClipboardFieldStrings.explanation.localized)
                .font(.snappyBody)
            HStack {
                VStack(alignment: .leading, spacing: Constants.fieldVSpacing) {
                    Text(Strings.MemberDashboard.Loyalty.title.localized)
                        .font(.snappyCaption)
                        .foregroundColor(.snappyBlue)
                    Text(viewModel.code)
                        .font(.snappyBody)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                Button(action: {
                    viewModel.copyCodeButtonPressed()
                }) {
                    Image.MemberDashboard.Loyalty.copyToClipboard
                        .font(.system(size: Constants.copyItemSize))
                        .foregroundColor(.snappyBlue)
                }
            }
            .padding()
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
            .snappyShadow()
            
            Text(ClipboardFieldStrings.condition.localized)
                .font(.snappyCaption)
        }
    }
}

#if DEBUG
struct ClipboardReferralCodeField_Previews: PreviewProvider {
    static var previews: some View {
        ClipboardReferralCodeField(viewModel: .init(code: "ALANSHEARER2022"))
    }
}
#endif
