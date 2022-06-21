//
//  DriverMapViewModel.swift
//  SnappyV2
//
//  Created by Kevin Palser on 25/05/2022.
//

import Combine
import Foundation
import OSLog
import MapKit

// 3rd party
import PusherSwift

@MainActor
class DriverMapViewModel: ObservableObject {

    let container: DIContainer
    private let mapParameters: DriverLocationMapParameters
    private let dismissDriverMapHandler: () -> Void
    
    @Published var driverName: String?
    @Published var mapRegion: MKCoordinateRegion = MKCoordinateRegion()
    @Published var locations: [DriverMapLocation] = []
    @Published var showCompletedAlert = false
    @Published var canCallStore = false
    @Published var completedDeliveryAlertTitle = ""
    @Published var completedDeliveryAlertMessage = ""
    @Published var placedOrderFetch: Loadable<PlacedOrder> = .notRequested
    
    private var pusher: Pusher?
    private var pusherCallbackId: String?
    
    // values uses for managing the map markers
    private let driverLocationId: UUID = UUID()
    private let deliveryLocationId: UUID = UUID()
    private var driversCurrentDisplayPosition: CLLocationCoordinate2D?
    private var driversLastDisplayPosition: CLLocationCoordinate2D?
    private var destinationDisplayPosition: CLLocationCoordinate2D?
    private var currentBearing: Double = 0

    // used when multiple points are returned
    private var animateDriverLocationTimer: Timer?
    private var smoothDriverPinMovementTimer: Timer?
    
    // used to manually fetch the position or order state in case there
    // is a problem with the Pusher service
    private var refreshTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    var placedOrder: PlacedOrder?

    private var storeContactNumber: String? {
        var rawTelephone: String?
        if let telephone = mapParameters.placedOrder?.store.telephone {
            rawTelephone = telephone
        } else if let telephone = mapParameters.lastDeliveryOrder?.storeContactNumber {
            rawTelephone = telephone
        }
        // strip non digit characters
        let digits = Set("0123456789")
        guard let rawTelephone = rawTelephone else { return nil }
        let telephone = String(rawTelephone.filter{ digits.contains($0) })
        guard telephone.isEmpty == false else { return nil }
        return telephone
    }
    
    init(container: DIContainer, mapParameters: DriverLocationMapParameters, dismissDriverMapHandler: @escaping () -> Void) {
        self.container = container
        self.mapParameters = mapParameters
        self.dismissDriverMapHandler = dismissDriverMapHandler
        
        driverName = mapParameters.driverLocation.driver?.name
        
        setupMap()
        setupPusher()
        setupRefresh()
        setupPlacedOrderFetch()
        
        container.eventLogger.sendEvent(
            for: .viewScreen,
            with: .appsFlyer,
            params: ["screen_reference": "driver_location_map"]
        )
    }
    
    // Struct used to represent points on the map
    
    enum DriverMapLocationType {
        case driver
        case destination
        case store // future extension
    }
    
    struct DriverMapLocation: Identifiable {
        let id: UUID
        let type: DriverMapLocationType
        let name: String?
        let coordinate: CLLocationCoordinate2D
        let bearing: Double
    }
    
    // Structs used to decode the Pusher response
    
    struct DriverLocationPusherMovementUpdate: Decodable {
        let lg: Double
        let lt: Double
    }
    
    struct DriverLocationPusherUpdate: Decodable {
        // last location of the driver
        let lg: Double?
        let lt: Double?
        // movement to reach the last location
        let mov: [DriverLocationPusherMovementUpdate]?
        // driver order status:
        // 0: unassigned
        // 1: assigned
        // 2: delivered (completed)
        // 3: unable to deliver (effectively completed)
        // 4: declined by the driver (should get reassigned)
        // 5: en route (when the map should be displayed)
        // 6: handled by third party delivery company (effectively completed)
        // 7: third party delivery pending
        // 8: third party delivery error
        // 9: returning to store (probably to give to other driver)
        // 10: delivered to store (continuation of 9)
        let s: Int?
    }
    
    func calculateIntermediatePointAndBearing(point1: CLLocationCoordinate2D, point2: CLLocationCoordinate2D, percentage: Double) -> (CLLocationCoordinate2D, Double) {
        
        // Adapted from: https://stackoverflow.com/questions/33907276/calculate-point-between-two-coordinates-based-on-a-percentage
        
        //const φ1 = this.lat.toRadians(), λ1 = this.lon.toRadians();
        //const φ2 = point.lat.toRadians(), λ2 = point.lon.toRadians();
        let lat1 = Measurement(value: point1.latitude, unit: UnitAngle.degrees).converted(to: .radians).value
        let lng1 = Measurement(value: point1.longitude, unit: UnitAngle.degrees).converted(to: .radians).value
        let lat2 = Measurement(value: point2.latitude, unit: UnitAngle.degrees).converted(to: .radians).value
        let lng2 = Measurement(value: point2.longitude, unit: UnitAngle.degrees).converted(to: .radians).value

        //const Δφ = φ2 - φ1;
        //const Δλ = λ2 - λ1;
        let deltaLat = lat2 - lat1
        let deltaLng = lng2 - lng1

        //const a = Math.sin(Δφ/2) * Math.sin(Δφ/2) + Math.cos(φ1) * Math.cos(φ2) * Math.sin(Δλ/2) * Math.sin(Δλ/2);
        //const δ = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
        let calcA = sin(deltaLat / 2) * sin(deltaLat / 2) + cos(lat1) * cos(lat2) * sin(deltaLng / 2) * sin(deltaLng / 2)
        let calcB = 2 * atan2(sqrt(calcA), sqrt(1 - calcA))

        //const A = Math.sin((1-fraction)*δ) / Math.sin(δ);
        //const B = Math.sin(fraction*δ) / Math.sin(δ);
        let A = sin((1 - percentage) * calcB) / sin(calcB)
        let B = sin(percentage * calcB) / sin(calcB)

        //const x = A * Math.cos(φ1) * Math.cos(λ1) + B * Math.cos(φ2) * Math.cos(λ2);
        //const y = A * Math.cos(φ1) * Math.sin(λ1) + B * Math.cos(φ2) * Math.sin(λ2);
        //const z = A * Math.sin(φ1) + B * Math.sin(φ2);
        let x = A * cos(lat1) * cos(lng1) + B * cos(lat2) * cos(lng2)
        let y = A * cos(lat1) * sin(lng1) + B * cos(lat2) * sin(lng2)
        let z = A * sin(lat1) + B * sin(lat2)

        //const φ3 = Math.atan2(z, Math.sqrt(x*x + y*y));
        //const λ3 = Math.atan2(y, x);
        let lat3 = atan2(z, sqrt(x * x + y * y))
        let lng3 = atan2(y, x)

        // bearings adapted from: https://stackoverflow.com/questions/26998029/calculating-bearing-between-two-cllocation-points-in-swift
        let yBearing = sin(deltaLng) * cos(lat2)
        let xBearing = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(deltaLng)
        let radiansBearing = atan2(yBearing, xBearing)
        
        return (
            CLLocationCoordinate2D(
                latitude: Measurement(value: lat3, unit: UnitAngle.radians).converted(to: .degrees).value,
                longitude: Measurement(value: lng3, unit: UnitAngle.radians).converted(to: .degrees).value
            ),
            Measurement(value: radiansBearing, unit: UnitAngle.radians).converted(to: .degrees).value
        )
    }
    
    private func updateDriverMarker(overDuration: TimeInterval = 0) {
        if let driversCurrentDisplayPosition = driversCurrentDisplayPosition {
            
            if
                overDuration > 0.5,
                let driversLastDisplayPosition = driversLastDisplayPosition
            {
                var pinMovementCount = 1
                
                self.smoothDriverPinMovementTimer = Timer.scheduledTimer(
                    withTimeInterval: overDuration / TimeInterval(AppV2Constants.Driver.animationRenderPoints),
                    repeats: true
                ) { [weak self] timer in
                    guard let self = self else { return }
                    
                    if pinMovementCount < AppV2Constants.Driver.animationRenderPoints {
                        // move the pin % along based on pinMovementCount
                        let displayPointBearing = self.calculateIntermediatePointAndBearing(
                            point1: driversLastDisplayPosition,
                            point2: driversCurrentDisplayPosition,
                            percentage: (Double(pinMovementCount) / Double(AppV2Constants.Driver.animationRenderPoints))
                        )
                        
                        self.driversCurrentDisplayPosition = displayPointBearing.0
                        self.currentBearing = displayPointBearing.1
                        
                        self.updateDriverMarker()
                    } else {
                        // finish the animation
                        timer.invalidate()
                        self.smoothDriverPinMovementTimer = nil
                        // move to the final position
                        self.driversCurrentDisplayPosition = driversCurrentDisplayPosition
                        self.updateDriverMarker()
                    }
                    
                    pinMovementCount += 1
                }
                
            } else {
                
                let newDriverLocation = DriverMapLocation(
                    id: driverLocationId,
                    type: .driver,
                    name: mapParameters.driverLocation.driver?.name,
                    coordinate: driversCurrentDisplayPosition,
                    bearing: currentBearing
                )
                
                // replace the current driver location if found otherwise insert it
                if let index = locations.firstIndex(where: { location in
                    location.id == driverLocationId
                }) {
                    locations[index] = newDriverLocation
                } else {
                    locations.append(newDriverLocation)
                }

                driversLastDisplayPosition = driversCurrentDisplayPosition
            }
        }
    }
    
    private func calculateDisplayRegion() -> MKCoordinateRegion {
        
        var coordinates: [CLLocationCoordinate2D] = []
        if let driversCurrentDisplayPosition = driversCurrentDisplayPosition {
            coordinates.append(driversCurrentDisplayPosition)
        }
        if let driversCurrentDisplayPosition = destinationDisplayPosition {
            coordinates.append(driversCurrentDisplayPosition)
        }
        
        // based on https://gist.github.com/robmooney/923301
        
        var minLat: CLLocationDegrees = 90.0
        var maxLat: CLLocationDegrees = -90.0
        var minLon: CLLocationDegrees = 180.0
        var maxLon: CLLocationDegrees = -180.0
        
        for coordinate in coordinates {
            let lat = Double(coordinate.latitude)
            let long = Double(coordinate.longitude)
            if lat < minLat {
                minLat = lat
            }
            if long < minLon {
                minLon = long
            }
            if lat > maxLat {
                maxLat = lat
            }
            if long > maxLon {
                maxLon = long
            }
        }
        
        let span = MKCoordinateSpan(latitudeDelta: (maxLat - minLat) * 2.0, longitudeDelta: (maxLon - minLon) * 2.0)
        
        return MKCoordinateRegion(
            center: CLLocationCoordinate2DMake(maxLat - span.latitudeDelta / 4, maxLon - span.longitudeDelta / 4),
            span: span
        )
    }
    
    private func stopPusher() {
        if
            let pusher = pusher,
            pusherCallbackId != nil
        {
            pusher.unbindAll()
            pusher.unsubscribeAll()
            pusher.disconnect()
            pusherCallbackId = nil
        }
    }
    
    private func getPlacedOrder() {
        Task {
            await self.container.services.userService.getPlacedOrder(orderDetails: self.loadableSubject(\.placedOrderFetch), businessOrderId: mapParameters.businessOrderId)
        }
    }
    
    private func setupPlacedOrderFetch() {
        $placedOrderFetch
            .sink { [weak self] order in
                guard let self = self else { return }
                self.placedOrder = order.value
            }
            .store(in: &cancellables)
    }
    
    private func setupMap() {
        
        // starting driver location before the Pusher starts
        driversCurrentDisplayPosition = CLLocationCoordinate2D(
            latitude: mapParameters.driverLocation.driver?.latitude ?? 0,
            longitude: mapParameters.driverLocation.driver?.longitude ?? 0
        )
        
        // the source of the desitination varies depending on whether
        // the app was opened for foreground transition or because
        // an option from the order detail
        let destinationName: String?
        if let lastDeliveryOrder = mapParameters.lastDeliveryOrder {
            destinationName = lastDeliveryOrder.deliveryPostcode
            getPlacedOrder()
            
        } else if let placedOrder = mapParameters.placedOrder {
            destinationName = placedOrder.fulfilmentMethod.address?.postcode
        } else {
            destinationName = nil
        }
        
        if let delivery = mapParameters.driverLocation.delivery {
            destinationDisplayPosition = CLLocationCoordinate2D(latitude: delivery.latitude, longitude: delivery.longitude)
        } else if
            let placedOrder = mapParameters.placedOrder,
            let location = placedOrder.fulfilmentMethod.address?.location
        {
            destinationDisplayPosition = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        } else {
            destinationDisplayPosition = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        }
        
//        destinationDisplayPosition = CLLocationCoordinate2D(latitude: 37.3302, longitude: -122.0232)
        
        if let destinationDisplayPosition = destinationDisplayPosition {
            locations = [
                DriverMapLocation(
                    id: deliveryLocationId,
                    type: .destination,
                    name: destinationName,
                    coordinate: destinationDisplayPosition,
                    bearing: 0
                )
            ]
        }
        
        mapRegion = calculateDisplayRegion()
        
        updateDriverMarker()
    }

    private func setupPusher() {
        guard let pusherConfiguration = mapParameters.driverLocation.pusher else {
            return
        }
        
        let pusher = Pusher(
            key: pusherConfiguration.appKey,
            options: PusherClientOptions(host: .cluster(pusherConfiguration.clusterServer))
        )
        pusher.connect()
        
        let pusherChannel = pusher.subscribe("order_\(mapParameters.driverLocation.orderId)")
        
        pusherCallbackId = pusherChannel.bind(
            eventName: "driver_location_update",
            eventCallback: { [weak self] event -> Void in
                
                guard
                    let self = self,
                    let jsonString = event.data,
                    let jsonData = jsonString.data(using: .utf8)
                else {
                    Logger.driverMap.error("Pusher event callback response missing JSON string")
                    return
                }

                do {
                
                    let driverLocation = try JSONDecoder().decode(DriverLocationPusherUpdate.self, from: jsonData)
                    
                    if
                        let longitude = driverLocation.lg,
                        let latitude = driverLocation.lt
                    {
                        self.animateDriverLocationTimer?.invalidate()
                        self.animateDriverLocationTimer = nil
                        self.smoothDriverPinMovementTimer?.invalidate()
                        self.smoothDriverPinMovementTimer = nil
                        
                        if
                            let movement = driverLocation.mov,
                            movement.isEmpty == false
                        {
                            
                            // Based on the frequency that the driver is sending data divide the time to render the points.
                            // Notes:
                            // - "* 0.98" stops a stutter where new incoming points might catch up
                            // - "movement.count + 1" because there is an extra final point represented by longitude and longitude
                            let frequencyBetweenMapUpdates = (AppV2Constants.Driver.locationSendInterval * 0.98) / TimeInterval(movement.count + 1)
                            
                            self.driversCurrentDisplayPosition = CLLocationCoordinate2D(
                                latitude: movement[0].lt,
                                longitude: movement[0].lg
                            )
                            self.updateDriverMarker(overDuration: frequencyBetweenMapUpdates)

                            // start from position 1 because position 0 is already displayed immediately above
                            var locationIndex = 1

                            self.animateDriverLocationTimer = Timer.scheduledTimer(
                                withTimeInterval: frequencyBetweenMapUpdates,
                                repeats: true
                            ) { timer in

                                if locationIndex < movement.count {

                                    self.driversCurrentDisplayPosition = CLLocationCoordinate2D(
                                        latitude: movement[locationIndex].lt,
                                        longitude: movement[locationIndex].lg
                                    )
                                    self.updateDriverMarker(overDuration: frequencyBetweenMapUpdates)

                                } else if locationIndex == movement.count {

                                    self.driversCurrentDisplayPosition = CLLocationCoordinate2D(
                                        latitude: latitude,
                                        longitude: longitude
                                    )
                                    self.updateDriverMarker(overDuration: frequencyBetweenMapUpdates)

                                    // last point to move region in case it has come to close to
                                    // the edge of the displayed map
                                    self.mapRegion = self.calculateDisplayRegion()
                                    timer.invalidate()

                                }

                                locationIndex += 1
                            }

                        } else {

                            self.driversCurrentDisplayPosition = CLLocationCoordinate2D(
                                latitude: latitude,
                                longitude: longitude
                            )

                            //self.updateMap(driverUpdate: true)
                            self.updateDriverMarker()
                            self.mapRegion = self.calculateDisplayRegion()

                        }
                    }

                    if let status = driverLocation.s {
                        Task {
                            do {
                                try await self.processDriverOrderDeliverStatus(status: status)
                            } catch {
                                Logger.driverMap.error("Processing state error: \(error.localizedDescription)")
                            }
                        }
                        // reset the refresh timer because of this resent data
                        self.setupRefresh()
                    }

                } catch {
                    Logger.driverMap.error("Pusher event callback JSON response string: \"\(jsonString)\" decoding error: \(error.localizedDescription)")
                }
            }
        )
        
        self.pusher = pusher
    }
    
    private func processDriverOrderDeliverStatus(status: Int) async throws {
        if status == 2 || status == 3 {
            // stop fetching new information
            stopPusher()
            refreshTimer?.invalidate()
            refreshTimer = nil
            // show the appropriate alert
            canCallStore = UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone && storeContactNumber != nil
            if status == 2 {
                completedDeliveryAlertTitle = Strings.Alerts.DeliveryCompleted.orderDeliveredTitle.localized
                completedDeliveryAlertMessage = Strings.Alerts.DeliveryCompleted.orderDeliveredMessage.localized
            } else {
                completedDeliveryAlertTitle = Strings.Alerts.DeliveryCompleted.orderNotDeliveredTitle.localized
                completedDeliveryAlertMessage = Strings.Alerts.DeliveryCompleted.orderNotDeliveredMessage.localized
            }
            showCompletedAlert = true
            // stop the automatic checking if it is the last delivery order case
            if mapParameters.lastDeliveryOrder != nil {
                try await container.services.checkoutService.clearLastDeliveryOrderOnDevice()
            }
        }
    }
    
    private func getDriverLocationAndStatus() async {
        do {
            let driverLocation = try await container.services.checkoutService.getDriverLocation(businessOrderId: mapParameters.businessOrderId)
            
            if
                let driverLatitude = driverLocation.driver?.latitude,
                let driverLongitude = driverLocation.driver?.longitude
            {
                driversCurrentDisplayPosition = CLLocationCoordinate2D(
                    latitude: driverLatitude,
                    longitude: driverLongitude
                )

                updateDriverMarker()
                mapRegion = self.calculateDisplayRegion()
            }
            
            if let status = driverLocation.delivery?.status {
                try await processDriverOrderDeliverStatus(status: status)
            }
            
        } catch {
            Logger.driverMap.error("Fetching driver location or processing state error: \(error.localizedDescription)")
        }
    }
    
    private func setupRefresh() {
        refreshTimer?.invalidate()
        refreshTimer = Timer.scheduledTimer(
            withTimeInterval: AppV2Constants.Driver.refreshInterval,
            repeats: true,
            block: { [weak self] (timer) in
                guard let self = self else { return }
                Task {
                    await self.getDriverLocationAndStatus()
                }
            }
        )
    }
    
    func dismissMap() {
        dismissDriverMapHandler()
    }
    
    func callStoreAndDismissMap() {
        if
            let storeContactNumber = storeContactNumber,
            let url = URL(string: "tel:" + storeContactNumber)
        {
            UIApplication.shared.open(url, completionHandler: { (success) in
                Logger.driverMap.info("Calling store success: \(success)")
            })
        }
        dismissDriverMapHandler()
    }
    
    deinit {
        // Cannot use the stopPusher method in deinit because of the error:
        // "Call to main actor-isolated instance method 'stopPusher()' in a synchronous nonisolated context"
        // self.stopPusher()
        if
            let pusher = pusher,
            pusherCallbackId != nil
        {
            pusher.unbindAll()
            pusher.unsubscribeAll()
            pusher.disconnect()
            pusherCallbackId = nil
        }
        
        animateDriverLocationTimer?.invalidate()
        animateDriverLocationTimer = nil
        
        smoothDriverPinMovementTimer?.invalidate()
        smoothDriverPinMovementTimer = nil
        
        refreshTimer?.invalidate()
        refreshTimer = nil
    }

}
