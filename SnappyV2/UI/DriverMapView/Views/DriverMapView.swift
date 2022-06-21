//
//  DriverMapView.swift
//  SnappyV2
//
//  Created by Kevin Palser on 25/05/2022.
//

import SwiftUI
import MapKit

struct DriverMapView: View {
    
    // MARK: - Environment objects
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentation
    
    // MARK: - View model
    @StateObject var viewModel: DriverMapViewModel
    
    // MARK: - Constants
    private struct Constants {
        struct MapIcons {
            static let size: CGFloat = 88
        }
        
        struct Title {
            static let backgroundColor = Color.yellow.opacity(0.1)
        }
    }
        
    // MARK: - Computed variables
    private var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    // MARK: - Properties
    private let dismissType: NavigationDismissType
    
    // MARK: - Init
    init(viewModel: DriverMapViewModel, dismissType: NavigationDismissType = .back) {
        self._viewModel = .init(wrappedValue: viewModel)
        self.dismissType = dismissType
    }

    // MARK: - Main view
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                mapTitle
                
                // adopt the more modern alert style sytnax pattern where the OS allows
                if #available(iOS 15.0, *) {
                    
                    //completedDeliveryAlertTitle = ""
                    //@Published var completedDeliveryAlertMessage
                    
                    driverMapView
                        .alert(viewModel.completedDeliveryAlertTitle, isPresented: $viewModel.showCompletedAlert, actions: {
                            if viewModel.canCallStore {
                                Button(Strings.General.callStore.localized) {
                                    viewModel.callStoreAndDismissMap()
                                }
                            }
                            Button(Strings.General.close.localized, role: .cancel) {
                                viewModel.dismissMap()
                            }
                        }, message: {
                            Text(verbatim: viewModel.completedDeliveryAlertMessage)
                        })
                } else {
                    driverMapView
                        .alert(isPresented: $viewModel.showCompletedAlert) {
                            
                            if viewModel.canCallStore {
                                
                                return Alert(
                                    title: Text(viewModel.completedDeliveryAlertTitle),
                                    message: Text(viewModel.completedDeliveryAlertMessage),
                                    primaryButton: .default(
                                        Text(Strings.General.callStore.localized),
                                        action: { viewModel.callStoreAndDismissMap() }
                                    ),
                                    secondaryButton: .default(
                                        Text(Strings.General.close.localized),
                                        action: { viewModel.dismissMap() }
                                    )
                                )
                                
                            } else {
                                
                                return Alert(
                                    title: Text(viewModel.completedDeliveryAlertTitle),
                                    message: Text(viewModel.completedDeliveryAlertMessage),
                                    dismissButton: .default(
                                        Text(Strings.General.close.localized),
                                        action: {
                                            viewModel.dismissMap()
                                        }
                                    )
                                )
                                
                            }
                        }
                }
            }
            if let placedOrder = viewModel.placedOrder {
                OrderSummaryCard(container: viewModel.container, order: placedOrder, includeNavigation: false)
                    .padding()
            }
        }
        .dismissableNavBar(presentation: presentation, color: colorPalette.primaryBlue, title: Strings.DriverMap.title.localized, navigationDismissType: dismissType)
    }
    
    // MARK: - Title view
    private var mapTitle: some View {
        Group {
            if let driverName = viewModel.driverName {
                Text(Strings.DriverMap.InformationBar.withDriverNamePrefix.localized) +
                Text(driverName).font(.Body1.semiBold()) +
                Text(Strings.DriverMap.InformationBar.withDriverNameSuffix.localized)
            } else {
                Text(Strings.DriverMap.InformationBar.withoutDriverName.localized)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Constants.Title.backgroundColor)
        .font(.Body1.regular())
    }
    
    // MARK: - Map view
    @ViewBuilder
    private var driverMapView: some View {
        Map(coordinateRegion: $viewModel.mapRegion, annotationItems: viewModel.locations) { location in
            MapAnnotation(coordinate: location.coordinate) {
                driverMapAnnotationView(type: location.type, bearing: location.bearing)
            }
        }
    }
    
    // MARK: - Annotation view
    @ViewBuilder
    private func driverMapAnnotationView(type: DriverMapViewModel.DriverMapLocationType, bearing: Double) -> some View {
        if type == .destination {
            ZStack {
                PinShape()
                    .fill(colorPalette.primaryBlue)
                    .frame(width: Constants.MapIcons.size, height: Constants.MapIcons.size)
                HomeShape()
                    .fill(colorPalette.secondaryWhite)
                    .frame(width: Constants.MapIcons.size, height: Constants.MapIcons.size)
            }
        } else {
            ZStack {
                PinShape()
                    .fill(colorPalette.alertSuccess)
                    .frame(width: Constants.MapIcons.size, height: Constants.MapIcons.size)
                if bearing < 0 {
                    TruckLeftShape()
                        .fill(colorPalette.secondaryWhite)
                        .frame(width: Constants.MapIcons.size, height: Constants.MapIcons.size)
                } else {
                    TruckRightShape()
                        .fill(colorPalette.secondaryWhite)
                        .frame(width: Constants.MapIcons.size, height: Constants.MapIcons.size)
                }
            }
        }
    }
}

struct DriverMapView_Previews: PreviewProvider {
    static var previews: some View {
        DriverMapView(
            viewModel: .init(
                container: .preview,
                mapParameters: DriverLocationMapParameters(
                    businessOrderId: 0,
                    driverLocation: DriverLocation(
                        orderId: 1966430,
                        pusher: PusherConfiguration(
                            clusterServer: "eu",
                            appKey: "dd1506734a87e7be40d9"
                        ),
                        store: StoreLocation(
                            latitude: 56.4087526,
                            longitude: -5.487593
                        ),
                        delivery: OrderDeliveryLocationAndStatus(
                            latitude: 56.410598,
                            longitude: -5.47583,
                            status: 5
                        ),
                        driver: DeliveryDriverLocationAndName(
                            name: "Test",
                            latitude: 56.497526,
                            longitude: -5.47783
                        )
                    ),
                    lastDeliveryOrder: LastDeliveryOrderOnDevice(
                        businessOrderId: 12345,
                        storeName: "Master Test",
                        storeContactNumber: "01381 12345456",
                        deliveryPostcode: "PA34 4AG"
                    ),
                    placedOrder: nil
                ),
                dismissDriverMapHandler: {}
            )
        )
    }
}
