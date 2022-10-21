//
//  DriverMapView.swift
//  SnappyV2
//
//  Created by Kevin Palser on 25/05/2022.
//

import SwiftUI
import MapKit

struct DriverMapView: View {
    
    @State var driverMapViewHeight: CGFloat?
    @State var orderCardHeight: CGFloat?
    
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
        
        struct OrderCard {
            static let heightAdjustmentForPadding: CGFloat = 16
        }
    }
    
    // MARK: - Computed variables
    private var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    // MARK: - Properties
    private let isModal: Bool
    
    private var dismissType: NavigationDismissType {
        isModal ? .cancel : .back
    }
    
    // MARK: - Init
    init(viewModel: DriverMapViewModel, isModal: Bool = false) {
        self._viewModel = .init(wrappedValue: viewModel)
        self.isModal = isModal
    }
    
    // MARK: - Main view
    var body: some View {
        if isModal {
            NavigationView {
                mainContent
            }
        } else {
            mainContent
                .onTapGesture {
                    viewModel.showCompletedAlert = true
                }
        }
    }
    
    private var orderCardVerticalHeightProportion: CGFloat? {
        if
            let driverMapViewHeight = driverMapViewHeight,
            let orderCardHeight = orderCardHeight,
            driverMapViewHeight > 0
        {
            return orderCardHeight / driverMapViewHeight
        }
        return nil
    }
    
    private var mainContent: some View {
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
            
            if let placedOrder = viewModel.placedOrderSummary {
                OrderSummaryCard(container: viewModel.container, order: placedOrder, basket: nil, includeNavigation: false)
                    .padding()
                    .overlay(GeometryReader { geo in
                        Text("")
                            .onAppear {
                                orderCardHeight = geo.size.height + Constants.OrderCard.heightAdjustmentForPadding
                                if let orderCardVerticalHeightProportion = orderCardVerticalHeightProportion {
                                    viewModel.setOrderCardVerticalUsage(to: orderCardVerticalHeightProportion)
                                }
                            }
                    })
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
        }.overlay(GeometryReader { geo in
            Text("")
                .onAppear {
                    driverMapViewHeight = geo.size.height
                    if let orderCardVerticalHeightProportion = orderCardVerticalHeightProportion {
                        viewModel.setOrderCardVerticalUsage(to: orderCardVerticalHeightProportion)
                    }
                }
        })
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

#if DEBUG
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
#endif
