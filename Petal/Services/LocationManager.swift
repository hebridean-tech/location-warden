import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private var lastPostedSignature: String?
    private var lastPostedAt: Date?
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
        post(event: event, signature: "test|\(zoneName)|enter", successMessage: "Test event posted successfully", failureMessage: "Test event failed to post")
    }

    private func shouldSuppress(signature: String, within seconds: TimeInterval = 30) -> Bool {
        guard let lastPostedSignature, let lastPostedAt else { return false }
        return lastPostedSignature == signature && Date().timeIntervalSince(lastPostedAt) < seconds
    }

    private func markPosted(signature: String) {
        lastPostedSignature = signature
        lastPostedAt = Date()
    }

    private func post(event: LocationEvent, signature: String, successMessage: String, failureMessage: String) {
        if shouldSuppress(signature: signature) {
            lastPostStatus = "Suppressed duplicate event: \(signature)"
            return
        }
        API.shared.sendEvent(event) { [weak self] success in
            if success {
                self?.markPosted(signature: signature)
                self?.lastPostStatus = successMessage
            } else {
                self?.lastPostStatus = failureMessage
            }
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
        currentZone = zoneName
        lastEvent = "Entered \(zoneName)"
        let event = LocationEvent(zoneName: zoneName, event: "enter")
        post(event: event, signature: "region|\(zoneName)|enter", successMessage: "Posted enter for \(zoneName)", failureMessage: "Failed to post enter for \(zoneName)")
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        let zoneName = region.identifier
        if currentZone == zoneName {
            currentZone = nil
        }
        lastEvent = "Exited \(zoneName)"
        let event = LocationEvent(zoneName: zoneName, event: "exit")
        post(event: event, signature: "region|\(zoneName)|exit", successMessage: "Posted exit for \(zoneName)", failureMessage: "Failed to post exit for \(zoneName)")
    }

    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("[Raphtalia] Monitoring failed for \(region?.identifier ?? "unknown"): \(error)")
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            isSyncingCurrentZone = false
            return
        }
        lastKnownCoordinate = String(format: "%.5f, %.5f", location.coordinate.latitude, location.coordinate.longitude)
        let previousZone = currentZone
        API.shared.syncCurrentZone(from: location.coordinate, zones: zones, previousZone: previousZone) { [weak self] zoneName, posted in
            self?.currentZone = zoneName
            self?.lastEvent = zoneName.map { "Currently in \($0)" } ?? "Not in a saved zone"
            if let zoneName {
                if posted {
                    self?.lastPostStatus = "Current zone sync posted"
                    self?.markPosted(signature: "sync|\(zoneName)|enter")
                } else {
                    self?.lastPostStatus = "Current zone unchanged, no duplicate posted"
                }
            } else {
                self?.lastPostStatus = "No matching zone for current location"
            }
            self?.isSyncingCurrentZone = false
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("[Raphtalia] Location request failed: \(error)")
        lastPostStatus = "Location request failed: \(error.localizedDescription)"
        isSyncingCurrentZone = false
    }
}
