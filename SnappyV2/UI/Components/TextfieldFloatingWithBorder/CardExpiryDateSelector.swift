//
//  ExpiryDateSelector.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 06/08/2022.
//

import SwiftUI

struct CardExpiryDateSelector: View {
    @Binding var expiryMonth: String
    @Binding var expiryYear: String
    @Binding var hasError: Bool
    let month: [String] = ["12", "11", "10", "09", "08", "07", "06", "05", "04", "03", "02", "01"]
    var year = [String]()
    
    var expiryText: String {
        if expiryMonth.isEmpty && expiryYear.isEmpty { return "" }
        return "\(expiryMonth)/\(expiryYear)"
    }
    
    init(expiryMonth: Binding<String>, expiryYear: Binding<String>, hasError: Binding<Bool>) {
        self._expiryMonth = expiryMonth
        self._expiryYear = expiryYear
        self._hasError = hasError
        self.year = createStringExpiryYears()
    }
    
    var body: some View {
        Menu {
            Menu("Year...") {
                ForEach(year, id:\.self) { year in
                    Button {
                        expiryYear = year
                    } label: {
                        Text(year)
                    }
                }
            }
            Menu("Month...") {
                ForEach(month, id:\.self) { month in
                    Button {
                        expiryMonth = month
                    } label: {
                        Text(month)
                    }
                }
            }
        } label: {
            SnappyTextfield(container: .preview, text: .constant(expiryText), hasError: $hasError, labelText: "Expiry", largeTextLabelText: nil)
        }
    }
    
    func createStringExpiryYears() -> [String] {
        var expiryYears = [Int]()
        let currentYear = Calendar(identifier: .gregorian).dateComponents([.year], from: Date()).year ?? Calendar.current.component(.year, from: Date())
        let currentTwoDigitYear = currentYear%100
        let range = (currentTwoDigitYear ... currentTwoDigitYear + 20)
        expiryYears.append(contentsOf: range)
        let stringExpiryYears = expiryYears.reversed().map { String($0) }
        return stringExpiryYears
    }
}

#if DEBUG
struct ExpiryDateSelector_Previews: PreviewProvider {
    static var previews: some View {
        CardExpiryDateSelector(expiryMonth: .constant("03"), expiryYear: .constant("23"), hasError: .constant(false))
    }
}
#endif
