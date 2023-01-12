//
//  LoactionLoadingIndicator.swift
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
                VStack {
                    ZStack {
                        redLocation
                        
                        if viewModel.yellowFlipped == false {
                            halfLocationGreen
                        }
                        
                        if viewModel.blueFlipped == false {
                            halfLocationYellow
                        }
                        
                        halfLocationBlue
                            .rotation3DEffect(Angle(degrees: viewModel.blueDegree), axis: (x: 0, y: 1, z: 0))
                            .animation(.easeOut(duration: Constants.durationAndDelay), value: viewModel.blueDegree)
                        
                        if viewModel.blueFlipped {
                            halfLocationYellow
                                .rotation3DEffect(Angle(degrees: viewModel.yellowDegree), axis: (x: 0, y: 1, z: 0))
                                .animation(.easeOut(duration: Constants.durationAndDelay), value: viewModel.yellowDegree)
                        }
                        
                        if viewModel.yellowFlipped {
                            halfLocationGreen
                                .rotation3DEffect(Angle(degrees: viewModel.greenDegree), axis: (x: 0, y: 1, z: 0))
                                .animation(.easeOut(duration: Constants.durationAndDelay), value: viewModel.greenDegree)
                        }
                    }
                    
                    Text(Strings.LocationIndicator.gettingLocation.localized)
                        .font(.Body1.semiBold())
                        .foregroundColor(Color.black)
                        .padding()
                }
            }
            .frame(width: Constants.alertSize, height: Constants.alertSize)
            .background(Image.LocationIndicator.streetMap.resizable().scaledToFill())
            .standardCardFormat()
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
    
    private var halfLocationYellow: some View {
        locationIndicator(type: .half, color: colorPalette.offer)
    }
    
    
    private var halfLocationGreen: some View {
        locationIndicator(type: .half, color: colorPalette.alertSuccess)
    }
    
    private var blueLocation: some View {
        locationIndicator(type: .half, color: colorPalette.primaryBlue)
    }
}

#if DEBUG
struct LoactionLoadingIndicator_Previews: PreviewProvider {
    static var previews: some View {
        LocationLoadingIndicator(viewModel: .init(container: .preview))
    }
}
#endif
