import Foundation

/// Stub service for future Raphtalia backend integration.
/// Currently provides mock data for dashboard state.
class RaphtaliaService {
    static let shared = RaphtaliaService()

    private init() {}

    // Stub: fetch dashboard state from backend
    func fetchDashboard(completion: @escaping (Result<[String: Any], Error>) -> Void) {
        // TODO: Replace with real API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            completion(.success([
                "choresCompleted": 0,
                "streakDays": 1,
                "lastActive": ISO8601DateFormatter().string(from: Date()),
            ]))
        }
    }
}
