import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var zones: [Zone] = []
    @Published var lastEvent: String = "None"
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.distanceFilter = 50
        manager.allowsBackgroundLocationUpdates = true
    }

    func requestPermission() {
        manager.requestAlwaysAuthorization()
    }

    func startMonitoring(zones: [Zone]) {
        // Remove old regions first
        manager.monitoredRegions.forEach { manager.stopMonitoring(for: $0) }

        for zone in zones {
            let center = CLLocationCoordinate2D(latitude: zone.lat, longitude: zone.long)
            let region = CLCircularRegion(center: center, radius: zone.radius, identifier: zone.name)
            region.notifyOnEntry = true
            region.notifyOnExit = true
            manager.startMonitoring(for: region)
        }
        self.zones = zones
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard let zoneName = region.identifier as String? else { return }
        let event = LocationEvent(zoneName: zoneName, event: "enter")
        API.shared.sendEvent(event)
        lastEvent = "Entered \(zoneName)"
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        guard let zoneName = region.identifier as String? else { return }
        let event = LocationEvent(zoneName: zoneName, event: "exit")
        API.shared.sendEvent(event)
        lastEvent = "Exited \(zoneName)"
    }

    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("[Location Warden] Monitoring failed for \(region?.identifier ?? "unknown"): \(error)")
    }
}
