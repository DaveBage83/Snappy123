//
//  Shadows.swift
//  SnappyV2Study
//
//  Created by Henrik Gustavii on 02/07/2021.
//

import SwiftUI


public enum snappyShadow {
  case grey16
  case grey24

  var color: Color {
    switch self {
    case .grey16:
      return Color(red: 75 / 255, green: 79 / 255, blue: 84 / 255).opacity(0.16)
    case .grey24:
      return Color(red: 75 / 255, green: 79 / 255, blue: 84 / 255).opacity(0.24)
    }
  }

  var radius: CGFloat {
    switch self {
    case .grey16:
      return 16
    case .grey24:
      return 24
    }
  }
}

public extension View {
  func shadow(_ shadow: snappyShadow, x: CGFloat, y: CGFloat) -> some View {
    self.shadow(color: shadow.color, radius: shadow.radius, x: x, y: y)
  }

    func snappyShadow() -> some View {
        let shadow: snappyShadow = .grey16
        return self.shadow(color: shadow.color, radius: shadow.radius, x: 0, y: 5)
    }
}

#if DEBUG
struct Shadows_Previews: PreviewProvider {
  static var previews: some View {
    HStack(spacing: 16) {
      RoundedRectangle(cornerRadius: 8)
        .fill(Color.white)
        .shadow(.grey16, x: 0, y: 5)
      
      RoundedRectangle(cornerRadius: 8)
        .fill(Color.white)
        .shadow(.grey24, x: 0, y: 5)
    }
    .frame(height: 100)
    .padding(30)
    .previewLayout(.sizeThatFits)
    .previewCases()
  }
}
#endif
