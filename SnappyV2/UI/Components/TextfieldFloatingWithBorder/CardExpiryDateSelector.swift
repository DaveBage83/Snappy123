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
    let month: [String] = ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"]
    var year = [String]()
    let reverseOrder: Bool
    
    var expiryText: String {
        if expiryMonth.isEmpty && expiryYear.isEmpty { return "" }
        return "\(expiryMonth)/\(expiryYear)"
    }
    
    init(expiryMonth: Binding<String>, expiryYear: Binding<String>, hasError: Binding<Bool>, reverseOrder: Bool = false) {
        self._expiryMonth = expiryMonth
        self._expiryYear = expiryYear
        self._hasError = hasError
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.reverseOrder = false
        } else {
            self.reverseOrder = reverseOrder
        }
        self.year = createStringExpiryYears()
    }
    
    var body: some View {
        if reverseOrder {
            Menu {
                Menu("Year...") {
                    ForEach(year.reversed(), id:\.self) { year in
                        Button {
                            expiryYear = year
                        } label: {
                            Text(year)
                        }
                    }
                }
                Menu("Month...") {
                    ForEach(month.reversed(), id:\.self) { month in
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
        } else {
            Menu {
                Menu("Month...") {
                    ForEach(month, id:\.self) { month in
                        Button {
                            expiryMonth = month
                        } label: {
                            Text(month)
                        }
                    }
                }
                Menu("Year...") {
                    ForEach(year, id:\.self) { year in
                        Button {
                            expiryYear = year
                        } label: {
                            Text(year)
                        }
                    }
                }
            } label: {
                SnappyTextfield(container: .preview, text: .constant(expiryText), hasError: $hasError, labelText: "Expiry", largeTextLabelText: nil)
            }
            #warning("Once iOS 16 is out, add this. This will fix menu order regardless of where on screen")
//          .environment(\.menuOrder, .fixed)
        }
    }
    
    func createStringExpiryYears() -> [String] {
        var expiryYears = [Int]()
        let currentYear = Calendar(identifier: .gregorian).dateComponents([.year], from: Date()).year ?? Calendar.current.component(.year, from: Date())
        let currentTwoDigitYear = currentYear%100
        let range = (currentTwoDigitYear ... currentTwoDigitYear + 20)
        expiryYears.append(contentsOf: range)
        return expiryYears.map { String($0) }
    }
}

#if DEBUG
struct ExpiryDateSelector_Previews: PreviewProvider {
    static var previews: some View {
        CardExpiryDateSelector(expiryMonth: .constant("03"), expiryYear: .constant("23"), hasError: .constant(false))
    }
}
#endif
