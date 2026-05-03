import Foundation

/// Real HTTP transport for Rune chat via the Aperture backend.
/// Messages are POSTed to /chat/send; replies are polled from /chat/messages/{device_id}.
class RealChatTransport: ChatTransport {
    private let api = API.shared
    private let deviceID: String

    init(deviceID: String = Zone.deviceID) {
        self.deviceID = deviceID
    }

    func send(text: String, to agentId: String, completion: @escaping (ChatMessage?) -> Void) {
        // 1. POST the user message to backend
        postUserMessage(text) { [weak self] success in
            guard success, let self else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            // 2. Poll for agent replies with exponential backoff
            self.pollForReply(since: Date().timeIntervalSince1970, attempt: 0, completion: completion)
        }
    }

    // MARK: - Send user message

    private func postUserMessage(_ text: String, completion: @escaping (Bool) -> Void) {
        let baseURL = "https://arch.projectveritos.com"
        guard let url = URL(string: "\(baseURL)/chat/send") else {
            completion(false)
            return
        }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = UserDefaults.standard.string(forKey: "location_warden_token") {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        let body: [String: String] = ["device_id": deviceID, "text": text]
        req.httpBody = try? JSONEncoder().encode(body)
        URLSession.shared.dataTask(with: req) { _, response, _ in
            let ok = (response as? HTTPURLResponse)?.statusCode == 200
            DispatchQueue.main.async { completion(ok) }
        }.resume()
    }

    // MARK: - Poll for reply

    private func pollForReply(since: Double, attempt: Int, completion: @escaping (ChatMessage?) -> Void) {
        guard attempt < 8 else {
            // Give up after ~15s of polling
            DispatchQueue.main.async {
                completion(ChatMessage(text: "Message sent. I'll reply as soon as I can. 🖤", isFromUser: false))
            }
            return
        }

        let delay = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0][min(attempt, 7)]
        DispatchQueue.global().asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.fetchMessages(since: since) { messages in
                // Look for the first agent (non-user) message after our timestamp
                if let reply = messages.first(where: { !$0.isFromUser }) {
                    DispatchQueue.main.async { completion(reply) }
                } else {
                    self?.pollForReply(since: since, attempt: attempt + 1, completion: completion)
                }
            }
        }
    }

    // MARK: - Fetch messages

    private func fetchMessages(since: Double, completion: @escaping ([ChatMessage]) -> Void) {
        let baseURL = "https://arch.projectveritos.com"
        var components = URLComponents(string: "\(baseURL)/chat/messages/\(deviceID)")
        components?.queryItems = [
            URLQueryItem(name: "since", value: String(since)),
            URLQueryItem(name: "limit", value: "20")
        ]
        guard let url = components?.url else {
            completion([])
            return
        }
        var req = URLRequest(url: url)
        if let token = UserDefaults.standard.string(forKey: "location_warden_token") {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: req) { data, _, _ in
            guard let data,
                  let rows = try? JSONDecoder().decode([BackendChatRow].self, from: data) else {
                DispatchQueue.main.async { completion([]) }
                return
            }
            let messages = rows.map { ChatMessage(
                text: $0.text,
                isFromUser: $0.is_from_user == 1
            )}
            DispatchQueue.main.async { completion(messages) }
        }.resume()
    }
}

/// Matches the backend response shape for /chat/messages/{device_id}
private struct BackendChatRow: Decodable {
    let id: Int
    let device_id: String
    let text: String
    let is_from_user: Int
    let created_at: Double
}
