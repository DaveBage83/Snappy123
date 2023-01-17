//
//  LocationLoadingIndicator.swift
//  SnappyV2
//
//  Created by David Bage on 11/01/2023.
//

import SwiftUI

struct LocationLoadingIndicator: View {
    enum LocationIndicatorType {
        case whole
        case half
        
        var image: Image {
            switch self {
            case .half:
                return Image.LocationIndicator.halfDot
            case .whole:
                return Image.LocationIndicator.wholeDot
            }
        }
    }
    
    @Environment(\.colorScheme) var colorScheme
    
    struct Constants {
        static let durationAndDelay: CGFloat = 0.7
        static let backgroundOpacity: CGFloat = 0.3
        static let alertSize: CGFloat = 250
        static let locationDotHeight: CGFloat = 100
    }
    
    @StateObject var viewModel: LocationLoadingIndicatorViewModel
    
    private var colorPalette: ColorPalette {
        .init(container: viewModel.container, colorScheme: colorScheme)
    }
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.black.opacity(Constants.backgroundOpacity))
            ZStack {
                VStack(spacing: 15) {
                    ZStack {
                        redLocation
                        
                        if viewModel.blue2Flipped == false {
                            halfLocationBlue
                        }
                        
                        if viewModel.blueFlipped == false {
                            halfLocationRed
                        }
                        
                        halfLocationBlue
                            .rotation3DEffect(Angle(degrees: viewModel.blueDegree), axis: (x: 0, y: 1, z: 0))
                            .animation(.easeOut(duration: Constants.durationAndDelay), value: viewModel.blueDegree)
                        
                        if viewModel.blueFlipped {
                            halfLocationRed
                                .rotation3DEffect(Angle(degrees: viewModel.redDegree), axis: (x: 0, y: 1, z: 0))
                                .animation(.easeOut(duration: Constants.durationAndDelay), value: viewModel.redDegree)
                        }
                        
                        if viewModel.blue2Flipped {
                            halfLocationBlue
                                .rotation3DEffect(Angle(degrees: viewModel.blue2Degree), axis: (x: 0, y: 1, z: 0))
                                .animation(.easeOut(duration: Constants.durationAndDelay), value: viewModel.blue2Degree)
                        }
                    }
                    
                    Text(Strings.LocationIndicator.gettingLocation.localized)
                        .font(.Body1.semiBold())
                        .foregroundColor(colorPalette.primaryBlue)
                }
            }
            .frame(width: Constants.alertSize, height: Constants.alertSize)
            .background(Image.LocationIndicator.streetMap.resizable().scaledToFill())
            .clipShape(Circle())
            .shadow(color: .cardShadow, radius: 9, x: 0, y: 0)
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    private func locationIndicator(type: LocationIndicatorType, color: Color) -> some View {
        VStack {
            type.image
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: Constants.locationDotHeight)
                .foregroundColor(color)
        }
    }
    
    private var redLocation: some View {
        locationIndicator(type: .whole, color: colorPalette.primaryRed)
    }
    
    private var halfLocationBlue: some View {
        locationIndicator(type: .half, color: colorPalette.primaryBlue)
    }
    
    
    private var halfLocationRed: some View {
        locationIndicator(type: .half, color: colorPalette.primaryRed)
    }
}

#if DEBUG
struct LoactionLoadingIndicator_Previews: PreviewProvider {
    static var previews: some View {
        LocationLoadingIndicator(viewModel: .init(container: .preview))
    }
}
#endif
