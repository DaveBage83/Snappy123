//
//  ProductOptionSectionView.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 09/08/2021.
//

import SwiftUI

class ProductOptionSectionViewModel: ObservableObject {
    let title: String = ""
    
}

struct ProductOptionSectionView: View {
    @EnvironmentObject var optionsViewModel: ProductOptionsViewModel
    @StateObject var viewModel = ProductOptionSectionViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            sectionHeading(title: "Choose \(viewModel.title)")
            
            VStack {
                Button(action: {  }) {
                    OptionsCardView(option: <#T##MenuItemOption#>)
                }
            }
            .padding()
            
            Button(action: {}) {
                Text("Next")
                    .fontWeight(.semibold)
            }
            .buttonStyle(SnappyMainActionButtonStyle(isEnabled: true))
            .padding(.bottom)
        }
    }
    
    func sectionHeading(title: String) -> some View {
        HStack {
            Text("Choose")
            Text(title).bold()
            Spacer()
        }
        .font(.snappyBody)
        .foregroundColor(.snappyTextGrey2)
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.snappyTextGrey4)
    }
}

struct OptionsSectionView_Previews: PreviewProvider {
    static var previews: some View {
        ProductOptionSectionView()
    }
}
