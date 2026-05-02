import Foundation
import CoreLocation

class API {
    static let shared = API()

    private let baseURL = "https://arch.projectveritos.com"
    private let tokenKey = "location_warden_token"

    private var token: String? {
        get { UserDefaults.standard.string(forKey: tokenKey) }
        set { UserDefaults.standard.set(newValue, forKey: tokenKey) }
    }

    private func headers() -> [String: String] {
        guard let token else { return [:] }
        return ["Authorization": "Bearer \(token)", "Content-Type": "application/json"]
    }

    func authenticate(serverURL: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(serverURL)/token") else {
            completion(false)
            return
        }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: String],
                  let token = json["token"] else {
                DispatchQueue.main.async { completion(false) }
                return
            }
            self.token = token
            DispatchQueue.main.async { completion(true) }
        }.resume()
    }

    func fetchZones(completion: @escaping (Result<[Zone], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/location/zones") else { return }
        var req = URLRequest(url: url)
        headers().forEach { req.setValue($1, forHTTPHeaderField: $0) }
        URLSession.shared.dataTask(with: req) { data, _, error in
            if let data, let zones = try? JSONDecoder().decode([Zone].self, from: data) {
                DispatchQueue.main.async { completion(.success(zones)) }
            } else {
                DispatchQueue.main.async { completion(.failure(error ?? NSError(domain: "API", code: -1))) }
            }
        }.resume()
    }

    func createZone(_ zone: Zone, completion: @escaping (Bool) -> Void) {
        saveZone(zone, completion: completion)
    }

    func saveZone(_ zone: Zone, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/location/zones") else { return }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        headers().forEach { req.setValue($1, forHTTPHeaderField: $0) }
        req.httpBody = try? JSONEncoder().encode(zone)
        URLSession.shared.dataTask(with: req) { _, response, _ in
            let success = (response as? HTTPURLResponse)?.statusCode == 200
            DispatchQueue.main.async { completion(success) }
        }.resume()
    }

    func deleteZone(name: String, completion: @escaping (Bool) -> Void) {
        let encoded = name.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? name
        guard let url = URL(string: "\(baseURL)/location/zones/\(encoded)") else { return }
        var req = URLRequest(url: url)
        req.httpMethod = "DELETE"
        headers().forEach { req.setValue($1, forHTTPHeaderField: $0) }
        URLSession.shared.dataTask(with: req) { _, response, _ in
            let success = (response as? HTTPURLResponse)?.statusCode == 200
            DispatchQueue.main.async { completion(success) }
        }.resume()
    }

    func sendEvent(_ event: LocationEvent, completion: ((Bool) -> Void)? = nil) {
        guard let url = URL(string: "\(baseURL)/location/event") else {
            completion?(false)
            return
        }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        headers().forEach { req.setValue($1, forHTTPHeaderField: $0) }
        req.httpBody = try? JSONEncoder().encode(event)
        URLSession.shared.dataTask(with: req) { _, response, _ in
            let success = (response as? HTTPURLResponse)?.statusCode == 200
            DispatchQueue.main.async { completion?(success) }
        }.resume()
    }

    func syncCurrentZone(from location: CLLocationCoordinate2D, zones: [Zone], completion: @escaping (String?) -> Void) {
        let matchingZone = zones.first { zone in
            let zoneLocation = CLLocation(latitude: zone.lat, longitude: zone.long)
            let currentLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
            return currentLocation.distance(from: zoneLocation) <= zone.radius
        }

        guard let zone = matchingZone else {
            completion(nil)
            return
        }

        let event = LocationEvent(zoneName: zone.name, event: "enter", lat: location.latitude, long: location.longitude)
        sendEvent(event) { success in
            completion(success ? zone.name : nil)
        }
    }
}
