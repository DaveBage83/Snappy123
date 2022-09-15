//
//  InfoButtonWithText.swift
//  SnappyV2
//
//  Created by David Bage on 09/09/2022.
//

import SwiftUI

struct InfoButtonWithText: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.mainWindowSize) var mainWindowSize
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
                    .frame(height: 18)
                    .foregroundColor(colorPalette.primaryBlue)
            }
            .fixedSize()
            
            if showText {
                Text(text)
                    .font(.Body2.regular())
                    .padding(8)
                    .frame(maxWidth: 150, alignment: .leading)
                    .background(colorPalette.secondaryWhite)
                    .standardCardFormat()
                    .overlay(GeometryReader { geo in
                        Text("")
                            .onAppear {
                                self.textHeight = geo.size.height
                                self.textWidth = geo.size.width
                            }
                    })
                    .offset(x: textWidth/2, y: -(textHeight/2) - 8)
                Rectangle()
                    .fill(Color.white.opacity(0.00000001))
                    .ignoresSafeArea()
                    .onTapGesture {
                        showText = false
                    }
                    .frame(width: mainWindowSize.width * 2, height: mainWindowSize.height * 2)
            }
        }
    }
}

struct InfoButtonWithText_Previews: PreviewProvider {
    static var previews: some View {
        InfoButtonWithText(container: .preview, text: "sdasdasdasdasdasdasdasdasd")
    }
}
