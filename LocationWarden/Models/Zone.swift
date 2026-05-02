import Foundation
import UIKit

struct Zone: Codable, Identifiable, Equatable {
    let name: String
    let lat: Double
    let long: Double
    let radius: Double

    var id: String { name }

    enum CodingKeys: String, CodingKey {
        case name, lat, long
        case radius = "radius_meters"
    }
}

struct LocationEvent: Codable {
    let device_id: String
    let zone_name: String
    let event: String // "enter" or "exit"
    var timestamp: String?
    let lat: Double?
    let long: Double?

    init(zoneName: String, event: String, lat: Double? = nil, long: Double? = nil) {
        self.device_id = UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
        self.zone_name = zoneName
        self.event = event
        self.timestamp = ISO8601DateFormatter().string(from: Date())
        self.lat = lat
        self.long = long
    }
}
