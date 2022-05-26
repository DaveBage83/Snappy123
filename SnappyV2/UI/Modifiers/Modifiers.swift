//
//  Modifiers.swift
//  SnappyV2
//
//  Created by David Bage on 07/05/2022.
//

import SwiftUI

struct LoadingModifier: ViewModifier {
    @Binding var isLoading: Bool
    let color: Color
    
    func body(content: Content) -> some View {
        
        content
            .overlay(Group { // We need to wrap in a group as <iOS15 has no way of directly including conditions in overlays
                if isLoading {
                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: color))
                }
            }, alignment: .center)
    }
}

struct StandardCardFormat: ViewModifier {
    func body(content: Content) -> some View {
        content
            .cornerRadius(8)
            .shadow(color: .cardShadow, radius: 9, x: 0, y: 0)
    }
}

struct StandardPillCornerRadius: ViewModifier {
    func body(content: Content) -> some View {
        content
            .cornerRadius(24)
    }
}

struct SizePreferenceKey: PreferenceKey {
  static var defaultValue: CGSize = .zero

  static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
    value = nextValue()
  }
}

struct MeasureSizeModifier: ViewModifier {
  func body(content: Content) -> some View {
    content.background(GeometryReader { geometry in
      Color.clear.preference(key: SizePreferenceKey.self,
                             value: geometry.size)
    })
  }
}

struct CardOnImageViewModifier: ViewModifier {
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.presentationMode) var presentation
    
    struct Constants {
        struct Frame {
            static let largeDeviceWidth: CGFloat = UIScreen.screenWidth * 0.7
        }
        
        struct InternalPadding {
            static let standard: CGFloat = 16
            static let largeDevice: CGFloat = 32
        }
        
        struct ExternalPadding {
            static let standard: CGFloat = UIScreen.screenHeight * 0.05
            static let largeDevice: CGFloat = UIScreen.screenHeight * 0.2
        }
    }
    
    private var externalPadding: CGFloat {
        sizeClass == .compact ? Constants.ExternalPadding.standard : Constants.ExternalPadding.largeDevice
    }
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: sizeClass == .compact ? .infinity : Constants.Frame.largeDeviceWidth)
            .padding(sizeClass == .compact ? Constants.InternalPadding.standard : Constants.InternalPadding.largeDevice)
            .background(Color.white)
            .standardCardFormat()
            .padding(.top, externalPadding)
            .simpleBackButtonNavigation(presentation: presentation, color: .white)
            .padding(.horizontal)
    }
}

extension View {
    func withLoadingView(isLoading: Binding<Bool>, color: Color) -> some View {
        modifier(LoadingModifier(isLoading: isLoading, color: color))
    }
}

extension View {
    func standardPillCornerRadius() -> some View {
        modifier(StandardPillCornerRadius())
    }
}

extension View {
    func standardCardFormat() -> some View {
        modifier(StandardCardFormat())
    }
}

extension View {
  func measureSize(perform action: @escaping (CGSize) -> Void) -> some View {
    self.modifier(MeasureSizeModifier())
      .onPreferenceChange(SizePreferenceKey.self, perform: action)
  }
}

extension View {
    func cardOnImageFormat() -> some View {
        modifier(CardOnImageViewModifier())
    }
}
