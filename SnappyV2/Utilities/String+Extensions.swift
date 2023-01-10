//
//  String+Extensions.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 02/12/2021.
//

import Foundation

// Copied from https://www.hackingwithswift.com/example-code/strings/how-to-capitalize-the-first-letter-of-a-string
extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    // For use with non mutatable constants
    var firstLetterCapitalized: String {
        return self.capitalizingFirstLetter()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    
    var trueDate: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = AppV2Constants.Business.standardDateOnlyStringFormat
        return formatter.date(from: self)?.trueDate
    }
    
    var stringToDateOnly: Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = AppV2Constants.Business.standardDateOnlyStringFormat
        return dateFormatter.date(from: self)
    }
    
    var stringToHoursMinsAndSecondsOnly: Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = AppV2Constants.Business.hourAndMinutesAndSecondsStringFormat
        return dateFormatter.date(from: self)
    }
    
    func toTelephoneString() -> String? {
        let digits = Set("0123456789")
        let telephone = self.filter { digits.contains($0) }
        
        guard telephone.isEmpty == false else { return nil }
        return telephone
    }
    
    /// Unlike capitalizingFirstLetter(), this method first transforms the string to lowercase and then capitalizes
    /// the first letter ensuring strings which have multiple words capitalized will only have the first letter of the
    /// first word capitalized after transformation
    func capitalizingFirstLetterOnly() -> String {
        return self.lowercased().capitalizingFirstLetter()
    }
}

extension String {
    var isEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: self)
    }
}

extension String {
    func isPostcode(rules: [PostcodeRule]) -> Bool {
        // when given no rules allow a match
        guard rules.count > 0 else { return true }
        let trimmedString = self.trimmingCharacters(in: CharacterSet.whitespaces)
        for rule in rules {
            if #available(iOS 16.0, *) {
                if (try? Regex(rule.regex).wholeMatch(in: trimmedString)) != nil {
                    return true
                }
            } else {
                let wholeRange = trimmedString.startIndex..<trimmedString.endIndex
                if trimmedString.range(of: rule.regex, options: .regularExpression) == wholeRange {
                    return true
                }
            }
        }
        return false
    }
}

// Adapted from https://stackoverflow.com/questions/34454532/how-add-separator-to-string-at-every-n-characters-in-swift
// Allows us to divide card string into batches of 4
extension String {
    var cardNumberFormat: String {
        let numberOfCharacters = self.count
        
        guard numberOfCharacters > 4 else {
            return self
        }
        
        let newString = String(repeating: "∗", count: numberOfCharacters - 4)
        let last4 = self.suffix(4)
        return newString.appending(last4).unfoldSubSequences(limitedTo: 4).joined(separator: " ")
    }
}

extension String {
    var telephoneNumber: String {
        return "tel://\(self)"
    }
}

extension String {
    func replace(string:String, replacement:String) -> String {
        return self.replacingOccurrences(of: string, with: replacement, options: NSString.CompareOptions.literal, range: nil)
    }

    func removeWhitespace() -> String {
        return self.replace(string: " ", replacement: "")
    }
  }

extension String {
    func condenseWhitespace(withoutEmbeddedSpaces removeEmbedded: Bool = false) -> String {
        let components = self.components(separatedBy: CharacterSet.whitespacesAndNewlines).filter({!$0.isEmpty})
        
        if removeEmbedded {
            return components.joined()
        } else {
            return components.joined(separator: " ")
        }
        
    }
    
    func internationalCountryCallingCode(likelyCountry: String?, defaultCountry: String) -> String? {
            let countryPrefixes: [String: String] = [
                "AF": "93",
                "AL": "355",
                "DZ": "213",
                "AS": "1",
                "AD": "376",
                "AO": "244",
                "AI": "1",
                "AQ": "672",
                "AG": "1",
                "AR": "54",
                "AM": "374",
                "AW": "297",
                "AU": "61",
                "AT": "43",
                "AZ": "994",
                "BS": "1",
                "BH": "973",
                "BD": "880",
                "BB": "1",
                "BY": "375",
                "BE": "32",
                "BZ": "501",
                "BJ": "229",
                "BM": "1",
                "BT": "975",
                "BA": "387",
                "BW": "267",
                "BR": "55",
                "IO": "246",
                "BG": "359",
                "BF": "226",
                "BI": "257",
                "KH": "855",
                "CM": "237",
                "CA": "1",
                "CV": "238",
                "KY": "345",
                "CF": "236",
                "TD": "235",
                "CL": "56",
                "CN": "86",
                "CX": "61",
                "CO": "57",
                "KM": "269",
                "CG": "242",
                "CK": "682",
                "CR": "506",
                "HR": "385",
                "CU": "53",
                "CY": "537",
                "CZ": "420",
                "DK": "45",
                "DJ": "253",
                "DM": "1",
                "DO": "1",
                "EC": "593",
                "EG": "20",
                "SV": "503",
                "GQ": "240",
                "ER": "291",
                "EE": "372",
                "ET": "251",
                "FO": "298",
                "FJ": "679",
                "FI": "358",
                "FR": "33",
                "GF": "594",
                "PF": "689",
                "GA": "241",
                "GM": "220",
                "GE": "995",
                "DE": "49",
                "GH": "233",
                "GI": "350",
                "GR": "30",
                "GL": "299",
                "GD": "1",
                "GP": "590",
                "GU": "1",
                "GT": "502",
                "GN": "224",
                "GW": "245",
                "GY": "595",
                "HT": "509",
                "HN": "504",
                "HU": "36",
                "IS": "354",
                "IN": "91",
                "ID": "62",
                "IQ": "964",
                "IE": "353",
                "IL": "972",
                "IT": "39",
                "JM": "1",
                "JP": "81",
                "JO": "962",
                "KZ": "77",
                "KE": "254",
                "KI": "686",
                "KW": "965",
                "KG": "996",
                "LV": "371",
                "LB": "961",
                "LS": "266",
                "LR": "231",
                "LI": "423",
                "LT": "370",
                "LU": "352",
                "MG": "261",
                "MW": "265",
                "MY": "60",
                "MV": "960",
                "ML": "223",
                "MT": "356",
                "MH": "692",
                "MQ": "596",
                "MR": "222",
                "MU": "230",
                "YT": "262",
                "MX": "52",
                "MC": "377",
                "MN": "976",
                "ME": "382",
                "MS": "1",
                "MA": "212",
                "MM": "95",
                "NA": "264",
                "NR": "674",
                "NP": "977",
                "NL": "31",
                "AN": "599",
                "NC": "687",
                "NZ": "64",
                "NI": "505",
                "NE": "227",
                "NG": "234",
                "NU": "683",
                "NF": "672",
                "MP": "1",
                "NO": "47",
                "OM": "968",
                "PK": "92",
                "PW": "680",
                "PA": "507",
                "PG": "675",
                "PY": "595",
                "PE": "51",
                "PH": "63",
                "PL": "48",
                "PT": "351",
                "PR": "1",
                "QA": "974",
                "RO": "40",
                "RW": "250",
                "WS": "685",
                "SM": "378",
                "SA": "966",
                "SN": "221",
                "RS": "381",
                "SC": "248",
                "SL": "232",
                "SG": "65",
                "SK": "421",
                "SI": "386",
                "SB": "677",
                "ZA": "27",
                "GS": "500",
                "ES": "34",
                "LK": "94",
                "SD": "249",
                "SR": "597",
                "SZ": "268",
                "SE": "46",
                "CH": "41",
                "TJ": "992",
                "TH": "66",
                "TG": "228",
                "TK": "690",
                "TO": "676",
                "TT": "1",
                "TN": "216",
                "TR": "90",
                "TM": "993",
                "TC": "1",
                "TV": "688",
                "UG": "256",
                "UA": "380",
                "AE": "971",
                "GB": "44",
                "UK": "44", // Sometimes "UK" is used instead of "GB"
                "US": "1",
                "UY": "598",
                "UZ": "998",
                "VU": "678",
                "WF": "681",
                "YE": "967",
                "ZM": "260",
                "ZW": "263",
                "BO": "591",
                "BN": "673",
                "CC": "61",
                "CD": "243",
                "CI": "225",
                "FK": "500",
                "GG": "44",
                "VA": "379",
                "HK": "852",
                "IR": "98",
                "IM": "44",
                "JE": "44",
                "KP": "850",
                "KR": "82",
                "LA": "856",
                "LY": "218",
                "MO": "853",
                "MK": "389",
                "FM": "691",
                "MD": "373",
                "MZ": "258",
                "PS": "970",
                "PN": "872",
                "RE": "262",
                "RU": "7",
                "BL": "590",
                "SH": "290",
                "KN": "1",
                "LC": "1",
                "MF": "590",
                "PM": "508",
                "VC": "1",
                "ST": "239",
                "SO": "252",
                "SJ": "47",
                "SY": "963",
                "TW": "886",
                "TZ": "255",
                "TL": "670",
                "VE": "58",
                "VN": "84",
                "VG": "284",
                "VI": "340",
                "EH": "121"
            ]

            // code that might follow "+" or "00" based on
            // something like the associated billing address
            let likelyCountryCode: String?
            if
                let likelyCountry = likelyCountry,
                let countryCode = countryPrefixes[likelyCountry]
            {
                likelyCountryCode = countryCode
            } else {
                likelyCountryCode = nil
            }

            // code to use if no "+" or "00" prefix
            guard let defaultCountrCode = countryPrefixes[defaultCountry] else {
                return nil
            }

            var removePrefix: String?
            if prefix(1) == "+" {
                let index = index(self.startIndex, offsetBy: 1)
                removePrefix = String(self[index...]).condenseWhitespace()
            } else if prefix(2) == "00" {
                let index = index(self.startIndex, offsetBy: 2)
                removePrefix = String(self[index...]).condenseWhitespace()
            }

            if let removePrefix = removePrefix {
                if
                    let likelyCountryCode = likelyCountryCode,
                    removePrefix.hasPrefix(likelyCountryCode)
                {
                    return likelyCountryCode
                } else if removePrefix.hasPrefix(defaultCountrCode) {
                    return defaultCountrCode
                }
                // prefix but not matching the expected
                return nil
            } else {
                // no prefixes so should be safe to go with default
                return defaultCountrCode
            }
        }
}

extension String {
    func versionUpToDate(_ otherVersion: String) -> Bool {
        let comparisonResult = self.compare(otherVersion, options: .numeric)
        return comparisonResult != .orderedAscending
    }
}

extension String {
    var condensedWhitespace: String {
        let components = self.components(separatedBy: NSCharacterSet.whitespacesAndNewlines)
        return components.filter { !$0.isEmpty }.joined(separator: " ")
    }
}
