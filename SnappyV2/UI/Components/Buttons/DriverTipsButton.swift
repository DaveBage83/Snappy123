//
//  DriverTipsButton.swift
//  SnappyV2
//
//  Created by David Bage on 09/05/2022.
//

import SwiftUI

struct DriverTipsButton: View {
    @Environment(\.colorScheme) var colorScheme
    @ScaledMetric var scale: CGFloat = 1 // Used to scale icon for accessibility options
    
    @ObservedObject var viewModel: BasketViewModel
    
    struct Constants {
        static let spacing: CGFloat = 8
    }
    
    var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    var foreverAnimation: Animation {
        Animation.linear(duration: 0.25)
            .repeatForever(autoreverses: false)
    }
    
    enum Size {
        case standard
        case large
        
        var height: CGFloat {
            switch self {
            case .standard:
                return 16
            case .large:
                return 24
            }
        }
    }
    
    enum ButtonType {
        case increment
        case decrement
        
        var icon: Image {
            switch self {
            case .increment:
                return Image.Icons.CirclePlus.filled
            case .decrement:
                return Image.Icons.CircleMinus.filled
            }
        }
        
        func disabled(tipLevel: Double, tipUpdating: Bool) -> Bool {
            switch self {
            case .increment:
                return tipUpdating
            case .decrement:
                return (tipLevel == 0 || tipUpdating) ? true : false
            }
        }
    }
    
    let size: Size
    @State var isAnimating = false
    
    var body: some View {
        HStack(spacing: Constants.spacing) {
            incrementDecrementButton(.decrement)
            
            if viewModel.updatingTip {
                viewModel.tipLevel.image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size.height * scale)
                    .rotationEffect(Angle(degrees: isAnimating ? 360 : 0.0))
                    .animation(foreverAnimation)
                    .onAppear {
                        isAnimating = true
                    }

            } else {
                viewModel.tipLevel.image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size.height * scale)
                    .animation(.none)
                    .onAppear {
                        isAnimating = false
                    }
            }
            
            incrementDecrementButton(.increment)
        }
    }
    
    func incrementDecrementButton(_ type: ButtonType) -> some View {
        Button {
            switch type {
            case .increment:
                viewModel.increaseTip()
            case .decrement:
                viewModel.decreaseTip()
            }
        } label: {
            type.icon
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(type.disabled(tipLevel: viewModel.driverTip, tipUpdating: viewModel.updatingTip) ? colorPalette.textGrey3 : colorPalette.primaryBlue)
                .disabled(type.disabled(tipLevel: viewModel.driverTip, tipUpdating: viewModel.updatingTip))
                .frame(width: size.height * scale)
        }
    }
}

#if DEBUG
struct DriverTipsButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DriverTipsButton(viewModel: .init(container: .preview), size: .large)
            
            DriverTipsButton(viewModel: .init(container: .preview), size: .standard)
            
            DriverTipsButton(viewModel: .init(container: .preview), size: .large)
                .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
        }
    }
}
#endif
