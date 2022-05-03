//
//  Colours.swift
//  SnappyV2Study
//
//  Created by Henrik Gustavii on 28/06/2021.
//

import SwiftUI

public extension Color {
    
    // MARK: Primary
    
    static let snappyBlue = Color(red: 20/255, green: 86/255, blue: 158/255)
    static let snappyRed = Color(red: 228/255, green: 32/255, blue: 52/255)
    static let snappyTeal = Color(red: 0/255, green: 160/255, blue: 190/255)
    
    // MARK: Status
    
    static let snappyDark = Color(red: 39/255, green: 40/255, blue: 65/255)
    static let snappySuccess = Color(red: 81/255, green: 179/255, blue: 155/255)
    static let snappyOfferBasket = Color(red: 73/255, green: 20/255, blue: 158/255)
    static let snappyAmberBasket = Color(red: 216/255, green: 138/255, blue: 51/255)
    static let snappyWarning = Color(red: 233/255, green: 35/255, blue: 24/255)
    static let snappyHighlight = Color(red: 64/255, green: 68/255, blue: 252/255)
    
    #warning("to be replaced with proper snappy grey")
    static let snappyGrey = Color.gray
    
    // MARK: Backgrounds
    
    static let snappyBGMain = Color(red: 245/255, green: 248/255, blue: 251/255)
    static let snappyBGFields1 = Color(red: 241/255, green: 244/255, blue: 255/255)
    static let snappyBGFields2 = Color(red: 230/255, green: 233/255, blue: 255/255)
    
    // MARK: Text Colours
    
    static let snappyTextGrey1 = Color(red: 48/255, green: 56/255, blue: 67/255)
    static let snappyTextGrey2 = Color(red: 127/255, green: 134/255, blue: 149/255)
    static let snappyTextGrey3 = Color(red: 199/255, green: 202/255, blue: 209/255)
    static let snappyTextGrey4 = Color(red: 213/255, green: 213/255, blue: 213/255)
    
}

struct ColorsPreviewSection: View {
  let title: String
  let colors: [Color]

  var body: some View {
    Section(header: Text(title)) {
      HStack {
        ForEach(colors, id: \.self) { color in
          RoundedRectangle(cornerRadius: 12)
            .fill(color)
        }
      }
    }
  }
}

struct SnappyColours_Previews: PreviewProvider {
    static let primaryColours: [Color] = [.snappyBlue, .snappyRed, .snappyTeal]
    static let statusColours1: [Color] = [.snappyDark, .snappySuccess, .snappyOfferBasket]
    static let statusColours2: [Color] = [.snappyAmberBasket, .snappyWarning, .snappyHighlight]
    static let backgroundColours: [Color] = [.snappyBGMain, .snappyBGFields1, .snappyBGFields2]
    static let textColours: [Color] = [.snappyTextGrey1, .snappyTextGrey2, .snappyTextGrey3, .snappyTextGrey4]
    
    static var previews: some View {
        NavigationView {
            List {
                ColorsPreviewSection(title: "Primary", colors: self.primaryColours)
                ColorsPreviewSection(title: "Status Colours 1", colors: self.statusColours1)
                ColorsPreviewSection(title: "Status Colours 2", colors: self.statusColours2)
                ColorsPreviewSection(title: "Background Colours", colors: self.backgroundColours)
                ColorsPreviewSection(title: "Text Colours", colors: self.textColours)
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Colours")
        }
        
        NavigationView {
            List {
                ColorsPreviewSection(title: "Primary", colors: self.primaryColours)
                ColorsPreviewSection(title: "Status Colours 1", colors: self.statusColours1)
                ColorsPreviewSection(title: "Status Colours 2", colors: self.statusColours2)
                ColorsPreviewSection(title: "Background Colours", colors: self.backgroundColours)
                ColorsPreviewSection(title: "Text Colours", colors: self.textColours)
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Colours")
        }
        .preferredColorScheme(.dark)
    }
}

extension Color {
    // This method converts a hex string to a Color, returning nil if the string is invalid
    init?(hex: String?) {
        guard let hex = hex else {
            return nil
        }

        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0

        let length = hexSanitized.count

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0

        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0

        } else {
            return nil
        }

        self.init(red: r, green: g, blue: b, opacity: a)
    }
}

