//
//  InfoButtonWithText.swift
//  SnappyV2
//
//  Created by David Bage on 09/09/2022.
//

/// A tappable info button that will present any text injected as a custom pop up
import SwiftUI

struct InfoButtonWithText: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.mainWindowSize) var mainWindowSize
    
    struct Constants {
        struct Image {
            static let height: CGFloat = 18
        }
        
        struct Text {
            static let padding: CGFloat = 8
            static let maxWidth: CGFloat = 150
            static let textOffsetAdjustment: CGFloat = 8
            static let opacity: CGFloat = 0.000000001
            static let widthAndHeightDenominator: CGFloat = 2
        }
        
        struct TappableRectangle {
            static let widthAndHeightMultiplier: CGFloat = 2
        }
    }
    
    let container: DIContainer
    let text: String
    
    @State var showText: Bool = false
    @State var textHeight: CGFloat = 0
    @State var textWidth: CGFloat = 0
    
    private var colorPalette: ColorPalette {
        .init(container: container, colorScheme: colorScheme)
    }
    
    var body: some View {
        ZStack {
            Button {
                showText.toggle()
            } label: {
                Image.Icons.Info.filled
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: Constants.Image.height)
                    .foregroundColor(colorPalette.primaryBlue)
            }
            .fixedSize()
            
            if showText {
                Text(text)
                    .font(.Body2.regular())
                    .padding(Constants.Text.padding)
                    .frame(maxWidth: Constants.Text.maxWidth, alignment: .leading)
                    .background(colorPalette.secondaryWhite)
                    .standardCardFormat()
                    .overlay(GeometryReader { geo in
                        Text("")
                            .onAppear {
                                self.textHeight = geo.size.height
                                self.textWidth = geo.size.width
                            }
                    })
                    .offset(x: textWidth/Constants.Text.widthAndHeightDenominator, y: -(textHeight/Constants.Text.widthAndHeightDenominator) - Constants.Text.textOffsetAdjustment)
                Rectangle()
                    .fill(Color.white.opacity(Constants.Text.opacity)) // We cannot set to .clear or opacity to 0 as the rectangle then is no longer tappable 🤷‍♂️
                    .ignoresSafeArea()
                    .onTapGesture {
                        showText = false
                    }
                    .frame(width: mainWindowSize.width * Constants.TappableRectangle.widthAndHeightMultiplier, height: mainWindowSize.height * Constants.TappableRectangle.widthAndHeightMultiplier)
            }
        }
    }
}

#if DEBUG
struct InfoButtonWithText_Previews: PreviewProvider {
    static var previews: some View {
        InfoButtonWithText(container: .preview, text: "sdasdasdasdasdasdasdasdasd")
    }
}
#endif
