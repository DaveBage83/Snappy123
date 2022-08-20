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
    
    let month: [String] = ["12", "11", "10", "09", "08", "07", "06", "05", "04", "03", "02", "01"]
    var year = [String]()
    
    var expiryText: String {
        if expiryMonth.isEmpty && expiryYear.isEmpty { return "" }
        return "\(expiryMonth)/\(expiryYear)"
    }
    
    enum ExpiryMenuMode {
        case month
        case year
        case both
    }
    
    var showExpiryMenuMode: ExpiryMenuMode {
        if expiryMonth.isEmpty && expiryYear.isEmpty { return .month }
        if expiryMonth.isEmpty && !expiryYear.isEmpty { return .month }
        if !expiryMonth.isEmpty && expiryYear.isEmpty { return .year }
        return .both
    }
    
    init(expiryMonth: Binding<String>, expiryYear: Binding<String>) {
        self._expiryMonth = expiryMonth
        self._expiryYear = expiryYear
        self.year = createStringExpiryYears()
    }
    
    var body: some View {
        if showExpiryMenuMode == .month {
            Menu {
                expiryMonthMenu
                Text("Month...")
            } label: {
                SnappyTextfield(container: .preview, text: .constant(expiryText), hasError: .constant(false), labelText: "Expiry", largeTextLabelText: nil)
            }
        } else if showExpiryMenuMode == .year {
            Menu {
                expiryYearMenu
                Text("Year...")
            } label: {
                SnappyTextfield(container: .preview, text: .constant(expiryText), hasError: .constant(false), labelText: "Expiry", largeTextLabelText: nil)
            }
        } else if showExpiryMenuMode == .both {
            Menu {
                Menu("Year...") {
                    expiryYearMenu
                }
                Menu("Month...") {
                    expiryMonthMenu
                }
            } label: {
                SnappyTextfield(container: .preview, text: .constant(expiryText), hasError: .constant(false), labelText: "Expiry", largeTextLabelText: nil)
            }
        }
    }
    
    var expiryYearMenu: some View {
        ForEach(year, id:\.self) { year in
            Button {
                expiryYear = year
            } label: {
                Text(year)
            }
        }
    }
    
    var expiryMonthMenu: some View {
        ForEach(month, id:\.self) { month in
            Button {
                expiryMonth = month
            } label: {
                Text(month)
            }
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

struct ExpiryDateSelector_Previews: PreviewProvider {
    static var previews: some View {
        CardExpiryDateSelector(expiryMonth: .constant("03"), expiryYear: .constant("23"))
    }
}
