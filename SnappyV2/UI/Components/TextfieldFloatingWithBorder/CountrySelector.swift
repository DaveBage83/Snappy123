//
//  CountrySelector.swift
//  SnappyV2
//
//  Created by David Bage on 26/07/2022.
//

import SwiftUI

struct CountrySelector: View {
    @StateObject var viewModel: CountrySelectorViewModel
    
    var body: some View {
        Menu {
            ForEach(viewModel.selectionCountries, id: \.self) { country in
                Button {
                    viewModel.selectCountry(country: country)
                } label: {
                    Text(country.countryName)
                }
            }
        } label: {
            SnappyTextfield(
                container: viewModel.container,
                text: $viewModel.countryText,
                hasError: .constant(false),
                labelText: Strings.PostCodeSearch.Address.country.localized,
                largeTextLabelText: nil,
                fieldType: .label)
        }
    }
}

#if DEBUG
struct CountrySelector_Previews: PreviewProvider {
    static var previews: some View {
        CountrySelector(viewModel: .init(container: .preview, countrySelected: { country in
            print("Country selected")
        }))
    }
}
#endif
