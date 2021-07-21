//
//  OptionsCardView.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 21/07/2021.
//

import SwiftUI

struct OptionsCardView: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.snappyHeadline)
                    .fontWeight(.regular)
                    .foregroundColor(.snappyDark)
                Text(subtitle)
                    .font(.snappySubheadline)
                    .foregroundColor(.snappyTextGrey2)
            }
            
            Spacer()
            
            Image(systemName: "plus.circle")
                .font(.title)
                .foregroundColor(.snappyDark)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(6)
        .snappyShadow()
    }
}

struct OptionsCardView_Previews: PreviewProvider {
    static var previews: some View {
        OptionsCardView(title: "Mushrooms", subtitle: "Fungi galore!")
            .previewLayout(.sizeThatFits)
            .padding()
            .previewCases()
    }
}
