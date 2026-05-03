import Foundation

/// Direct HTTP transport for Rune chat via OpenClaw /v1/responses proxy.
/// One HTTP call, one response — no polling, no pending files.
class RealChatTransport: ChatTransport {
    private let serverURL = "https://arch.projectveritos.com"
    private let deviceID: String

    init(deviceID: String = Zone.deviceID) {
        self.deviceID = deviceID
    }

    func send(text: String, to agentId: String, completion: @escaping (ChatMessage?) -> Void) {
        let endpoint = "\(serverURL)/v1/responses"
        guard let url = URL(string: endpoint) else {
            completion(nil)
            return
        }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.timeoutInterval = 120
        if let token = UserDefaults.standard.string(forKey: "location_warden_token") {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let body: [String: Any] = [
            "input": text,
            "model": "openclaw",
            "stream": false,
        ]
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: req) { data, response, error in
            if let error {
                print("[Aperture] Chat request failed: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(ChatMessage(text: "Connection failed. Please try again. 🖤", isFromUser: false))
                }
                return
            }

            guard let data,
                  let httpResp = response as? HTTPURLResponse,
                  httpResp.statusCode == 200 else {
                let code = (response as? HTTPURLResponse)?.statusCode ?? 0
                print("[Aperture] Chat request returned status \(code)")
                DispatchQueue.main.async {
                    completion(ChatMessage(text: "Failed to get a response (error \(code)). 🖤", isFromUser: false))
                }
                return
            }

            let replyText = self.extractText(from: data)
            DispatchQueue.main.async {
                if replyText.isEmpty {
                    completion(ChatMessage(text: "I received your message but couldn't generate a reply. 🖤", isFromUser: false))
                } else {
                    completion(ChatMessage(text: replyText, isFromUser: false))
                }
            }
        }.resume()
    }

    // MARK: - Response parsing

    private func extractText(from data: Data) -> String {
        // OpenAI Responses format: { "output": [{ "type": "message", "content": [{ "type": "output_text", "text": "..." }] }] }
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let output = json["output"] as? [[String: Any]] else {
            // Fallback: maybe raw text
            if let raw = String(data: data, encoding: .utf8) {
                return raw
            }
            return ""
        }

        var parts: [String] = []
        for item in output {
            guard item["type"] as? String == "message",
                  let content = item["content"] as? [[String: Any]] else { continue }
            for part in content {
                if part["type"] as? String == "output_text",
                   let text = part["text"] as? String, !text.isEmpty {
                    parts.append(text)
                }
            }
        }
        return parts.joined(separator: "\n")
    }
}
