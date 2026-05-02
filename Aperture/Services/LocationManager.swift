import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var zones: [Zone] = []
    @Published var lastEvent: String = "None"
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var currentZone: String? = nil
    @Published var isSyncingCurrentZone = false
    @Published var lastPostStatus: String = "No posts yet"
    @Published var lastKnownCoordinate: String = "Unknown"

    var deviceID: String { Zone.deviceID }
    var monitoredRegionNames: [String] {
        manager.monitoredRegions.map(\.identifier).sorted()
    }

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.distanceFilter = 50
        manager.allowsBackgroundLocationUpdates = true
    }

    func requestPermission() {
        manager.requestAlwaysAuthorization()
        manager.requestLocation()
    }

    func sendTestEvent() {
        let zoneName = currentZone ?? zones.first?.name ?? "Manual Test"
        let event = LocationEvent(zoneName: zoneName, event: "enter")
        API.shared.sendEvent(event) { [weak self] success in
            self?.lastPostStatus = success ? "Test event posted successfully" : "Test event failed to post"
        }
    }

    func startMonitoring(zones: [Zone]) {
        manager.monitoredRegions.forEach { manager.stopMonitoring(for: $0) }

        for zone in zones {
            let center = CLLocationCoordinate2D(latitude: zone.lat, longitude: zone.long)
            let region = CLCircularRegion(center: center, radius: zone.radius, identifier: zone.name)
            region.notifyOnEntry = true
            region.notifyOnExit = true
            manager.startMonitoring(for: region)
        }
        self.zones = zones
        syncCurrentZone()
    }

    func syncCurrentZone() {
        guard !zones.isEmpty else { return }
        isSyncingCurrentZone = true
        manager.requestLocation()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
            manager.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        let zoneName = region.identifier
        let event = LocationEvent(zoneName: zoneName, event: "enter")
        API.shared.sendEvent(event) { [weak self] success in
            self?.lastPostStatus = success ? "Posted enter for \(zoneName)" : "Failed to post enter for \(zoneName)"
        }
        currentZone = zoneName
        lastEvent = "Entered \(zoneName)"
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        let zoneName = region.identifier
        let event = LocationEvent(zoneName: zoneName, event: "exit")
        API.shared.sendEvent(event) { [weak self] success in
            self?.lastPostStatus = success ? "Posted exit for \(zoneName)" : "Failed to post exit for \(zoneName)"
        }
        if currentZone == zoneName {
            currentZone = nil
        }
        lastEvent = "Exited \(zoneName)"
    }

    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("[Aperture] Monitoring failed for \(region?.identifier ?? "unknown"): \(error)")
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            isSyncingCurrentZone = false
            return
        }
        lastKnownCoordinate = String(format: "%.5f, %.5f", location.coordinate.latitude, location.coordinate.longitude)
        API.shared.syncCurrentZone(from: location.coordinate, zones: zones) { [weak self] zoneName in
            self?.currentZone = zoneName
            self?.lastEvent = zoneName.map { "Currently in \($0)" } ?? "Not in a saved zone"
            self?.lastPostStatus = zoneName != nil ? "Current zone sync posted" : "No matching zone for current location"
            self?.isSyncingCurrentZone = false
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("[Aperture] Location request failed: \(error)")
        lastPostStatus = "Location request failed: \(error.localizedDescription)"
        isSyncingCurrentZone = false
    }
}
