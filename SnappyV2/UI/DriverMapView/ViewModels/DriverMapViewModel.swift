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
final class DriverMapViewModel: ObservableObject {

    let container: DIContainer
    private let dismissDriverMapHandler: () -> Void
    
    private(set) var showing = false
    
    @Published var driverName: String?
    @Published var mapRegion: MKCoordinateRegion = MKCoordinateRegion()
    @Published var locations: [DriverMapLocation] = []
    @Published var showCompletedAlert = false
    @Published var canCallStore = false
    @Published var completedDeliveryAlertTitle = ""
    @Published var completedDeliveryAlertMessage = ""
    @Published var orderStatus: Int?
    
    private var mapParameters: DriverLocationMapParameters?
    private var pusher: Pusher?
    private var pusherCallbackId: String?
    
    // values uses for managing the map markers
    private let driverLocationId: UUID = UUID()
    private let deliveryLocationId: UUID = UUID()
    
    // position of driver to be rendered to the map
    private var driversCurrentDisplayPosition: CLLocationCoordinate2D?
    
    // previous position used as their orgin for the current animation
    // between two points and to also determine the drivers bearing
    private var driversLastDisplayPosition: CLLocationCoordinate2D?
    
    // customer's chosen delivery location
    private var destinationDisplayPosition: CLLocationCoordinate2D?
    
    // used to display the driver pin icon to face the correct direction
    private var currentBearing: Double = 0
    private var orderCardVerticalUsageProportion: Double = 0

    // used when multiple points are returned
    private var pinMovementCount = 1
    private var locationIndex = 1
    private var animateDriverLocationTimer: Timer?
    
    // used to manually fetch the position or order state in case there
    // is a problem with the Pusher service
    private var refreshTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    var placedOrder: PlacedOrder? {
        mapParameters?.placedOrder
    }
    
    var placedOrderSummary: PlacedOrderSummary? {
        if let placedOrder {
            return mapToPlacedOrderSummary(placedOrder)
        }
        return nil
    }

    private var storeContactNumber: String? {
        var rawTelephone: String?
        if let telephone = mapParameters?.placedOrder?.store.telephone {
            rawTelephone = telephone
        } else if let telephone = mapParameters?.lastDeliveryOrder?.storeContactNumber {
            rawTelephone = telephone
        }
        // strip non digit characters
        guard let rawTelephone = rawTelephone else { return nil }
        return rawTelephone.toTelephoneString()
    }
    
    private func mapToPlacedOrderSummary(_ placedOrder: PlacedOrder) -> PlacedOrderSummary {
        .init(
            id: placedOrder.id,
            businessOrderId: placedOrder.businessOrderId,
            store: placedOrder.store,
            status: placedOrder.status,
            statusText: placedOrder.statusText,
            fulfilmentMethod: placedOrder.fulfilmentMethod,
            totalPrice: placedOrder.totalPrice)
    }
    
    init(container: DIContainer, dismissDriverMapHandler: @escaping () -> Void) {
        self.container = container
        self.dismissDriverMapHandler = dismissDriverMapHandler
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
    
    // methods called by the timers
    
    @objc private func animateMovement(timer: Timer) {
        
        guard
            let context = timer.userInfo as? [String: Any],
            let movement = context["movement"] as? [DriverMapViewModel.DriverLocationPusherMovementUpdate]
        else { return }
        
        if pinMovementCount == AppV2Constants.Driver.animationRenderPoints {
            
            driversLastDisplayPosition = CLLocationCoordinate2D(latitude: movement[locationIndex].lt, longitude: movement[locationIndex].lg)
            
            locationIndex += 1
            pinMovementCount = 0
            
            if locationIndex == movement.count {
                // last point to move region in case it has come to close to
                // the edge of the displayed map
                calculateDisplayRegion()
                timer.invalidate()
                
                // indicates that the timer finished processing all the points before
                // a new batch was received
                animateDriverLocationTimer = nil
                return
            }
        }
        
        if let driversLastDisplayPosition = driversLastDisplayPosition {
            // move the pin % along based on pinMovementCount
            let displayPointBearing = self.calculateIntermediatePointAndBearing(
                point1: driversLastDisplayPosition,
                point2: CLLocationCoordinate2D(latitude: movement[locationIndex].lt, longitude: movement[locationIndex].lg),
                percentage: (Double(pinMovementCount) / Double(AppV2Constants.Driver.animationRenderPoints))
            )
            
            driversCurrentDisplayPosition = displayPointBearing.0
            currentBearing = displayPointBearing.1
            
            updateDriverMarker()
        }
        
        pinMovementCount += 1
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
    
    private func clearActiveResources() {
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
        
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
    
    private func updateDriverMarker() {
        if let driversCurrentDisplayPosition = driversCurrentDisplayPosition {
            
            let newDriverLocation = DriverMapLocation(
                id: driverLocationId,
                type: .driver,
                name: mapParameters?.driverLocation.driver?.name,
                coordinate: driversCurrentDisplayPosition,
                bearing: currentBearing
            )
            
            DispatchQueue.main.async(execute: { [weak self] in
                guard let self = self else { return }
                // replace the current driver location if found otherwise insert it
                if let index = self.locations.firstIndex(where: { location in
                    location.id == self.driverLocationId
                }) {
                    self.locations[index] = newDriverLocation
                } else {
                    self.locations.append(newDriverLocation)
                }
            })

        }
    }
    
    private func calculateDisplayRegion() {
        
        var coordinates: [CLLocationCoordinate2D] = []
        if let driversCurrentDisplayPosition = driversCurrentDisplayPosition {
            coordinates.append(driversCurrentDisplayPosition)
        }
        if let driversCurrentDisplayPosition = destinationDisplayPosition {
            coordinates.append(driversCurrentDisplayPosition)
        }
        
        var returnRegion: MKCoordinateRegion?
        if let region = MKCoordinateRegion(coordinates: coordinates) {
            // when the card is displayed another coordinate is required below the
            // others to increase the vertical buffering zone
            if coordinates.isEmpty == false && placedOrder != nil && orderCardVerticalUsageProportion.isZero == false {
                let minLat = coordinates.min { $0.latitude < $1.latitude }!.latitude
                let newMinLat = minLat - region.span.latitudeDelta * orderCardVerticalUsageProportion
                if newMinLat < -90 {
                    // If at the Antarctic we can stick with the calculated region
                    returnRegion = region
                } else {
                    coordinates.append(CLLocationCoordinate2D(latitude: newMinLat, longitude: coordinates[0].longitude))
                    if let region = MKCoordinateRegion(coordinates: coordinates) {
                        returnRegion = region
                    }
                }
            } else {
                returnRegion = region
            }
        }
        
        if let returnRegion = returnRegion {
            // Given that the class uses @MainActor this should not be required but a separate thread is needed to overcome:
            // "Publishing changes from within view updates is not allowed, this will cause undefined behavior."
            DispatchQueue.main.async(execute: { [weak self] in
                guard let self = self else { return }
                self.mapRegion = returnRegion
            })
        }
    }

    private func setupMap() {
        guard let mapParameters = mapParameters else { return }
        
        // starting driver location before the Pusher starts
        driversCurrentDisplayPosition = CLLocationCoordinate2D(
            latitude: mapParameters.driverLocation.driver?.latitude ?? 0,
            longitude: mapParameters.driverLocation.driver?.longitude ?? 0
        )
        
        driversLastDisplayPosition = driversCurrentDisplayPosition
        
        // the source of the desitination varies depending on whether
        // the app was opened for foreground transition or because
        // an option from the order detail
        let destinationName: String?
        if let lastDeliveryOrder = mapParameters.lastDeliveryOrder {
            destinationName = lastDeliveryOrder.deliveryPostcode
            
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
        
        calculateDisplayRegion()
        updateDriverMarker()
    }
        
    private func processPusherDriverLocationUpdate(update: DriverLocationPusherUpdate) {
        
        if
            let longitude = update.lg,
            let latitude = update.lt
        {
            if animateDriverLocationTimer != nil {
                // still finishing off animation from the previous update so peform some
                // of the tidy up points that would have been missed:
                
                // reposition map in case driver icon moved out of window
                calculateDisplayRegion()
                
                // avoid any jitter by displaying from a previous driversLastDisplayPosition
                // start point which will most likely have already been animated away from
                driversLastDisplayPosition = driversCurrentDisplayPosition
            }
            
            animateDriverLocationTimer?.invalidate()
            animateDriverLocationTimer = nil
            
            if
                let movement = update.mov,
                movement.isEmpty == false
            {
                
                // Based on the frequency that the driver is sending data divide the time to render the points.
                // Notes:
                // - "* 0.98" stops a stutter where new incoming points might catch up
                // - "movement.count + 1" because there is an extra final point represented by longitude and longitude
                let frequencyBetweenMapUpdates = (AppV2Constants.Driver.locationSendInterval * 0.98) / TimeInterval(movement.count + 1) / TimeInterval(AppV2Constants.Driver.animationRenderPoints)
                
                locationIndex = 0
                pinMovementCount = 0
                
                let context: [String: Any] = [
                    // append the final movement to the list
                    "movement": movement + [DriverLocationPusherMovementUpdate(lg: longitude, lt: latitude)]
                ]
                
                animateDriverLocationTimer = Timer(
                    timeInterval: frequencyBetweenMapUpdates,
                    target: self,
                    selector: #selector(self.animateMovement),
                    userInfo: context,
                    repeats: true
                )
                
                // Use .common as it allows our timers to fire even when the UI is being used.
                // https://www.hackingwithswift.com/articles/117/the-ultimate-guide-to-timer
                if let animateDriverLocationTimer = animateDriverLocationTimer {
                    RunLoop.current.add(animateDriverLocationTimer, forMode: .common)
                }

            } else {

                self.driversCurrentDisplayPosition = CLLocationCoordinate2D(
                    latitude: latitude,
                    longitude: longitude
                )

                updateDriverMarker()
                calculateDisplayRegion()

            }
        }
        
        if let status = update.s {
            Task {
                do {
                    try await self.processDriverOrderDeliverStatus(status: status)
                } catch {
                    Logger.driverMap.error("Processing state error: \(error.localizedDescription)")
                }
            }
            // reset the refresh timer because of this resent data
            setupRefresh()
        }
    }

    private func setupPusher() {
        guard
            let mapParameters = mapParameters,
            let pusherConfiguration = mapParameters.driverLocation.pusher
        else {
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
                    
                    self.processPusherDriverLocationUpdate(update: driverLocation)

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
            clearActiveResources()
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
            if mapParameters?.lastDeliveryOrder != nil {
                try await container.services.checkoutService.clearLastDeliveryOrderOnDevice()
            }
        }
    }
    
    private func getDriverLocationAndStatus() async {
        if let businessOrderId = mapParameters?.businessOrderId {
            do {
                let driverLocation = try await container.services.checkoutService.getDriverLocation(businessOrderId: businessOrderId)
                
                if
                    let driverLatitude = driverLocation.driver?.latitude,
                    let driverLongitude = driverLocation.driver?.longitude
                {
                    driversCurrentDisplayPosition = CLLocationCoordinate2D(
                        latitude: driverLatitude,
                        longitude: driverLongitude
                    )
                    
                    updateDriverMarker()
                    calculateDisplayRegion()
                }
                
                if let status = driverLocation.delivery?.status {
                    try await processDriverOrderDeliverStatus(status: status)
                }
                
            } catch {
                Logger.driverMap.error("Fetching driver location or processing state error: \(error.localizedDescription)")
            }
        }
    }
    
    private func setupRefresh() {
        refreshTimer?.invalidate()
        refreshTimer = Timer(
            timeInterval: AppV2Constants.Driver.refreshInterval,
            repeats: true,
            block: { [weak self] (timer) in
                guard let self = self else { return }
                Task {
                    await self.getDriverLocationAndStatus()
                }
            }
        )
        
        // Use .common as it allows our timers to fire even when the UI is being used.
        // https://www.hackingwithswift.com/articles/117/the-ultimate-guide-to-timer
        if let refreshTimer = refreshTimer {
            RunLoop.current.add(refreshTimer, forMode: .common)
        }
    }
    
    private func setupPushNotificationBinding(with appState: Store<AppState>) {
        appState
            .map(\.pushNotifications.driverMapNotification)
            .filter { $0 != nil }
            .sink { _ in
                Task {
                    await self.getDriverLocationAndStatus()
                }
            }
            .store(in: &cancellables)
    }
    
    func setOrderCardVerticalUsage(to proportion: Double) {
        orderCardVerticalUsageProportion = proportion
        calculateDisplayRegion()
    }
    
    private func closeView() {
        clearActiveResources()
        dismissDriverMapHandler()
    }
    
    func dismissMap() {
        closeView()
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
        closeView()
    }
    
    func viewShown() {
        showing = true
        setupPushNotificationBinding(with: container.appState)
        
        if let displayedDriverLocation = container.appState.value.routing.displayedDriverLocation {
            mapParameters = displayedDriverLocation
            driverName = displayedDriverLocation.driverLocation.driver?.name
            orderStatus = displayedDriverLocation.driverLocation.delivery?.status
            setupMap()
            setupPusher()
            setupRefresh()
        }
        
        // uncomment when needing to development testing when no live driver server data
        // testPushUpdatesHandling()
        
        container.eventLogger.sendEvent(
            for: .viewScreen(.outside, .driverLocationMap),
            with: .appsFlyer,
            params: [:]
        )
    }
    
    func viewRemoved() {
        showing = false
    }
    
    deinit {
        // Cannot use the clearActiveResources method in deinit because of the error:
        // "Call to main actor-isolated instance method 'clearActiveResources()' in a synchronous nonisolated context"
        // self.clearActiveResources()
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

        refreshTimer?.invalidate()
        refreshTimer = nil
    }
    
    // Keep the following - it is particularly useful for testing without real driver movement
    // from the server
    
//    let testPusherData: [DriverLocationPusherUpdate] = [
//        DriverLocationPusherUpdate(lg: -122.03556217, lt: 37.3345628, mov: [
//            SnappyV2.DriverMapViewModel.DriverLocationPusherMovementUpdate(lg: -122.03432425000003, lt: 37.334676379999976),
//            SnappyV2.DriverMapViewModel.DriverLocationPusherMovementUpdate(lg: -122.03455441999999, lt: 37.33464561000002),
//            SnappyV2.DriverMapViewModel.DriverLocationPusherMovementUpdate(lg: -122.03478726999995, lt: 37.334619459999985),
//            SnappyV2.DriverMapViewModel.DriverLocationPusherMovementUpdate(lg: -122.03503469999995, lt: 37.334603159999986),
//            SnappyV2.DriverMapViewModel.DriverLocationPusherMovementUpdate(lg: -122.03529395000005, lt: 37.334585639999986)
//        ], s: 5),
//        DriverLocationPusherUpdate(lg: -122.03753997000004, lt: 37.334536520000015, mov: [
//            SnappyV2.DriverMapViewModel.DriverLocationPusherMovementUpdate(lg: -122.03583307999997, lt: 37.3345597),
//            SnappyV2.DriverMapViewModel.DriverLocationPusherMovementUpdate(lg: -122.03611285999996, lt: 37.33454847),
//            SnappyV2.DriverMapViewModel.DriverLocationPusherMovementUpdate(lg: -122.03638578000005, lt: 37.334542179999985),
//            SnappyV2.DriverMapViewModel.DriverLocationPusherMovementUpdate(lg: -122.03666775000006, lt: 37.334542349999985),
//            SnappyV2.DriverMapViewModel.DriverLocationPusherMovementUpdate(lg: -122.03695223, lt: 37.334538489999986),
//            SnappyV2.DriverMapViewModel.DriverLocationPusherMovementUpdate(lg: -122.03724626000005, lt: 37.33453874000001)
//        ], s: 5),
//        DriverLocationPusherUpdate(lg: -122.0397398, lt: 37.334476219999985, mov: [
//            SnappyV2.DriverMapViewModel.DriverLocationPusherMovementUpdate(lg: -122.03783265999998, lt: 37.33452613000001),
//            SnappyV2.DriverMapViewModel.DriverLocationPusherMovementUpdate(lg: -122.03813826999995, lt: 37.33451917000002),
//            SnappyV2.DriverMapViewModel.DriverLocationPusherMovementUpdate(lg: -122.03845141000006, lt: 37.334512840000016),
//            SnappyV2.DriverMapViewModel.DriverLocationPusherMovementUpdate(lg: -122.03875937000002, lt: 37.33450379000002),
//            SnappyV2.DriverMapViewModel.DriverLocationPusherMovementUpdate(lg: -122.03908048000005, lt: 37.33449629000002),
//            SnappyV2.DriverMapViewModel.DriverLocationPusherMovementUpdate(lg: -122.03941089000003, lt: 37.33448791)
//        ], s: 5),
//        DriverLocationPusherUpdate(lg: -122.04187567000004, lt: 37.33444603999999, mov: [
//            SnappyV2.DriverMapViewModel.DriverLocationPusherMovementUpdate(lg: -122.04007348000005, lt: 37.33447068000002),
//            SnappyV2.DriverMapViewModel.DriverLocationPusherMovementUpdate(lg: -122.04041596999994, lt: 37.33446519000001),
//            SnappyV2.DriverMapViewModel.DriverLocationPusherMovementUpdate(lg: -122.04077831, lt: 37.33445839999999),
//            SnappyV2.DriverMapViewModel.DriverLocationPusherMovementUpdate(lg: -122.04113765, lt: 37.33445282999998),
//            SnappyV2.DriverMapViewModel.DriverLocationPusherMovementUpdate(lg: -122.04149923999996, lt: 37.334449899999996)
//        ], s: 5),
//        DriverLocationPusherUpdate(lg: -122.04681002000002, lt: 37.334362349999985, mov: [
//            SnappyV2.DriverMapViewModel.DriverLocationPusherMovementUpdate(lg: -122.04496062999999, lt: 37.334447630000014),
//            SnappyV2.DriverMapViewModel.DriverLocationPusherMovementUpdate(lg: -122.04534100000005, lt: 37.334442439999975),
//            SnappyV2.DriverMapViewModel.DriverLocationPusherMovementUpdate(lg: -122.04571727000003, lt: 37.33443657000001),
//            SnappyV2.DriverMapViewModel.DriverLocationPusherMovementUpdate(lg: -122.04607568000003, lt: 37.33441707999999),
//            SnappyV2.DriverMapViewModel.DriverLocationPusherMovementUpdate(lg: -122.04644120999998, lt: 37.33439469999999)
//        ], s: 5),
//        DriverLocationPusherUpdate(lg: -122.04921637999996, lt: 37.333906040000016, mov: [
//            SnappyV2.DriverMapViewModel.DriverLocationPusherMovementUpdate(lg: -122.04716524000006, lt: 37.334317970000015),
//            SnappyV2.DriverMapViewModel.DriverLocationPusherMovementUpdate(lg: -122.04751058, lt: 37.334269849999984),
//            SnappyV2.DriverMapViewModel.DriverLocationPusherMovementUpdate(lg: -122.04784191000003, lt: 37.33420970999998),
//            SnappyV2.DriverMapViewModel.DriverLocationPusherMovementUpdate(lg: -122.04818682999999, lt: 37.334142869999994),
//            SnappyV2.DriverMapViewModel.DriverLocationPusherMovementUpdate(lg: -122.04853007000001, lt: 37.33406324000002),
//            SnappyV2.DriverMapViewModel.DriverLocationPusherMovementUpdate(lg: -122.04886543000005, lt: 37.33398776)
//        ], s: 5),
//        DriverLocationPusherUpdate(lg: -122.05174034, lt: 37.33336510999999, mov: [
//            SnappyV2.DriverMapViewModel.DriverLocationPusherMovementUpdate(lg: -122.04956958999995, lt: 37.333828799999985),
//            SnappyV2.DriverMapViewModel.DriverLocationPusherMovementUpdate(lg: -122.04992665999995, lt: 37.333754449999994),
//            SnappyV2.DriverMapViewModel.DriverLocationPusherMovementUpdate(lg: -122.05028305999997, lt: 37.33367998),
//            SnappyV2.DriverMapViewModel.DriverLocationPusherMovementUpdate(lg: -122.05063995999998, lt: 37.333606930000016),
//            SnappyV2.DriverMapViewModel.DriverLocationPusherMovementUpdate(lg: -122.05100548999992, lt: 37.33352458),
//            SnappyV2.DriverMapViewModel.DriverLocationPusherMovementUpdate(lg: -122.05137546999995, lt: 37.333448890000014)
//        ], s: 5),
//        DriverLocationPusherUpdate(lg: -122.05391527000003, lt: 37.33290405999999, mov: [
//            SnappyV2.DriverMapViewModel.DriverLocationPusherMovementUpdate(lg: -122.05209672999995, lt: 37.333287869999985),
//            SnappyV2.DriverMapViewModel.DriverLocationPusherMovementUpdate(lg: -122.05246948000004, lt: 37.333211010000014),
//            SnappyV2.DriverMapViewModel.DriverLocationPusherMovementUpdate(lg: -122.05283635, lt: 37.33313410999998),
//            SnappyV2.DriverMapViewModel.DriverLocationPusherMovementUpdate(lg: -122.05318780999998, lt: 37.333056320000004),
//            SnappyV2.DriverMapViewModel.DriverLocationPusherMovementUpdate(lg: -122.0535463, lt: 37.332981049999994)
//        ], s: 3)
//    ]
//
//    private var testCount: Int = 0
//
//    @objc private func animateTestPoints(timer: Timer) {
//        if testCount < testPusherData.count {
//            processPusherDriverLocationUpdate(update: testPusherData[testCount])
//            testCount += 1
//        } else {
//            timer.invalidate()
//            testCount = 0
//        }
//    }
//
//    private func testPushUpdatesHandling() {
//        let testAnimationTimer = Timer(
//            timeInterval: AppV2Constants.Driver.locationSendInterval,
//            target: self,
//            selector: #selector(animateTestPoints),
//            userInfo: nil,
//            repeats: true
//        )
//
//        // Use .common as it allows our timers to fire even when the UI is being used.
//        // https://www.hackingwithswift.com/articles/117/the-ultimate-guide-to-timer
//        RunLoop.current.add(testAnimationTimer, forMode: .common)
//    }

}
