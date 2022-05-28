//
//  DriverMapView.swift
//  SnappyV2
//
//  Created by Kevin Palser on 25/05/2022.
//

import SwiftUI
import MapKit

struct DriverMapView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: DriverMapViewModel
    
    var body: some View {
        NavigationView {
            Map(coordinateRegion: $viewModel.mapRegion, annotationItems: viewModel.locations) { location in
                MapAnnotation(coordinate: location.coordinate) {
                    Circle()
                        .stroke(.red, lineWidth: 3)
                        .frame(width: 44, height: 44)
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
