//
//  PreviewCases.swift
//  SnappyV2Study
//
//  Created by Henrik Gustavii on 02/07/2021.
//

import SwiftUI

private struct PreviewProviderModifier: ViewModifier {

  @ViewBuilder
  func body(content: Content) -> some View {
    content
      .previewDisplayName("Light Mode")

    content
      .previewDisplayName("Dark Mode")
      .preferredColorScheme(.dark)

    content
      .previewDisplayName("Large Text")
      .environment(\.sizeCategory, .accessibilityExtraExtraLarge)
      
      content
        .previewDisplayName("Right To Left")
        .environment(\.layoutDirection, .rightToLeft)
  }
}

extension View {
  func previewCases() -> some View {
    modifier(PreviewProviderModifier())
  }
}
