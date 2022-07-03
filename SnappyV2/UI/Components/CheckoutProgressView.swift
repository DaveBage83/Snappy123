//
//  CheckoutProgressView.swift
//  SnappyV2
//
//  Created by David Bage on 06/06/2022.
//

import SwiftUI

class CheckoutProgressViewModel: ObservableObject {
    enum ProgressState: Int, CaseIterable {
        case notStarted
        case details = 1
        case payment
        case completeSuccess
        case completeError
        
        var title: String? {
            switch self {
            case .details:
                return "Your details"
            case .payment:
                return "Payment"
            default:
                return nil
            }
        }
        
        var maxValue: Int {
            ProgressState.completeError.rawValue
        }
    }

    let container: DIContainer
    let progressState: ProgressState
    
    var maxProgress: Double {
        Double(progressState.maxValue - 2) // We remove notStarted, completeSucces and completeError and add 1
    }
    
    var currentProgress: Double {
        if Double(progressState.rawValue) > maxProgress {
            return maxProgress
        }
        return Double(progressState.rawValue)
    }
    
    init(container: DIContainer, progressState: ProgressState) {
        self.container = container
        self.progressState = progressState
    }
    
    func stepIsActive(step: ProgressState) -> Bool {
        return progressState.rawValue >= step.rawValue
    }
    
    func stepIsComplete(step: ProgressState) -> Bool {
        return progressState.rawValue > step.rawValue
    }
}

struct CheckoutProgressView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: CheckoutProgressViewModel
    
    private struct Constants {
        static let progressBarHeight: CGFloat = 6
        static let checkmarkHeight: CGFloat = 12
    }

    private var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    private var overrideColor: Color? {
        if viewModel.progressState == .completeError {
            return colorPalette.alertWarning
        } else if viewModel.progressState == .completeSuccess {
            return colorPalette.alertSuccess
        }
        return nil
    }
    
    private var overridingIcon: Image? {
        if viewModel.progressState == .completeError || viewModel.progressState == .completeSuccess {
            return Image.Icons.CircleCheck.standard
        }
        return nil
    }
    
    func icon(step: CheckoutProgressViewModel.ProgressState) -> Image {
        if let overridingIcon = overridingIcon {
            return overridingIcon
        } else if viewModel.stepIsComplete(step: step) {
            return Image.Icons.CircleCheck.standard
        } else {
            return Image.Icons.Circle.standard
        }
    }
    
    var progressBarColor: Color {
        if let overrideColor = overrideColor {
            return overrideColor
        }
        return colorPalette.primaryBlue
    }
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                checkoutProgressStep(step: .details)
                Spacer()
                checkoutProgressStep(step: .payment)
                Spacer()
            }
            ProgressBarView(value: viewModel.currentProgress, maxValue: viewModel.maxProgress, backgroundColor: colorPalette.secondaryDark.withOpacity(.twenty), foregroundColor: progressBarColor)
                .frame(height: Constants.progressBarHeight)
        }
    }
    
    private func checkoutProgressStep(step: CheckoutProgressViewModel.ProgressState) -> some View {
        HStack {
            icon(step: step)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: Constants.checkmarkHeight)
            
            Text(step.title ?? "")
                .font(.Caption1.semiBold())
        }
        .foregroundColor(overrideColor ?? (viewModel.stepIsActive(step: step) ? colorPalette.primaryBlue : colorPalette.secondaryDark.withOpacity(.twenty))) // If we are in success or error mode we use green / red, otherwise we default to injected colour
    }
}

#if DEBUG
struct CheckoutProgressView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutProgressView(viewModel: .init(container: .preview, progressState: .completeError))
            .padding()
    }
}
#endif