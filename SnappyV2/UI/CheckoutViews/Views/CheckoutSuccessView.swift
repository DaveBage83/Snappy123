//
//  CheckoutSuccessView.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 28/01/2022.
//

import SwiftUI
import Combine

class CheckoutSuccessViewModel: ObservableObject {
    let container: DIContainer
    let businessOrderID: Int
    private var cancellables = Set<AnyCancellable>()
    
    @Published var showDriverMap = false
    @Published var driverMapParameters: DriverLocationMapParameters = DriverLocationMapParameters(businessOrderId: 0, driverLocation: DriverLocation(orderId: 0, pusher: nil, store: nil, delivery: nil, driver: nil), lastDeliveryOrder: nil, placedOrder: nil)
    
    init(container: DIContainer, businessOrderID: Int) {
        self.container = container
        self.businessOrderID = businessOrderID
    }
    
    func setDriverParameters() async throws {
        guard let driverLocation = try await self.container.services.checkoutService.getLastDeliveryOrderDriverLocation() else {
            print("Driver location not found") // currently ending up here
            return
        }
        
        if driverLocation.driverLocation.delivery?.status == 5 {
            // display map
            showDriverMap = true
            
        } else {
            print(driverLocation) // currently returning nil as order not en route
            print("Driver not en route")
        }
    }
    
    func setupDriverLocation() async throws {
        
        if let driverMapParameters = try await self.container.services.checkoutService.getLastDeliveryOrderDriverLocation() {
            self.driverMapParameters = driverMapParameters
//            self.displayDriverMap = true
        }
    }
}

struct CheckoutSuccessView: View {
    @Environment(\.colorScheme) var colorScheme

    typealias ProgressStrings = Strings.CheckoutView.Progress
    
    @StateObject var viewModel: CheckoutSuccessViewModel
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    var body: some View {
        VStack {
            CheckoutProgressView(viewModel: .init(container: viewModel.container, progressState: .completeSuccess))
                .padding(.horizontal, 30)

            ScrollView {
                successBanner()
                    .padding([.top, .leading, .trailing])

                OrderSummaryCard(container: viewModel.container, order: TestPastOrder.order)
                    .padding()
                
                VStack(spacing: 16) {
                    Text("Need help with your order?")
                        .font(.Body1.semiBold())
                        .foregroundColor(colorPalette.typefacePrimary)
                    
                    Text("Call the store direct or check out our FAQs section for more information.")
                        .font(.hyperlink1())
                        .frame(width: UIScreen.screenWidth * 0.7)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 16) {
                    SnappyButton(
                        container: viewModel.container,
                        type: .primary,
                        size: .large,
                        title: "Track your order",
                        largeTextTitle: "Track",
                        icon: Image.Icons.LocationCrosshairs.standard) {
                            Task {
                                do {
                                    try await viewModel.setDriverParameters()
                                    viewModel.showDriverMap = true
                                } catch {
                                    print("*** \(error)")
                                }
                            }
                        }
                    
                    SnappyButton(
                        container: viewModel.container,
                        type: .outline,
                        size: .large,
                        title: "Call store",
                        largeTextTitle: "Call",
                        icon: Image.Icons.Phone.filled) {
                            print("Call")
                        }
                }
                .padding()
            }
            .background(colorPalette.backgroundMain)
            .simpleBackButtonNavigation(
                presentation: nil,
                color: colorPalette.typefacePrimary,
                title: "Secure Checkout")
        }
        
        NavigationLink("", isActive: $viewModel.showDriverMap) {
            DriverMapView(viewModel: .init(
                container: viewModel.container,
                mapParameters: viewModel.driverMapParameters,
                dismissDriverMapHandler: {
                    viewModel.showDriverMap = false
                }))
        }
    }

    
    func successBanner() -> some View {
        HStack(spacing: 16) {
            Image.CheckoutView.success
                .resizable()
                .scaledToFit()
                .frame(height: 75)
            
            Text("Your order is successful")
                .font(.heading2)
                .foregroundColor(colorPalette.alertSuccess)
                .multilineTextAlignment(.center)
        }
    }
}

#if DEBUG
struct CheckoutSuccessView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutSuccessView(viewModel: .init(container: .preview, businessOrderID: 123))
            .environmentObject(CheckoutViewModel(container: .preview))
    }
}
#endif
