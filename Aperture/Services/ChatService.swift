import Foundation

/// Protocol for chat transport — swap implementations for mock vs real backend.
protocol ChatTransport {
    func send(text: String, to agentId: String, completion: @escaping (ChatMessage?) -> Void)
}

/// Mock transport for V1 development. Returns echo-style responses.
/// Replace with a real OpenClaw WebSocket/HTTP transport later.
class MockChatTransport: ChatTransport {
    func send(text: String, to agentId: String, completion: @escaping (ChatMessage?) -> Void) {
        // Simulate network delay
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.8) {
            let replies = [
                "Got it, sir. I'll look into that. 💕",
                "On it! Let me check and get back to you. ✨",
                "Noted. Anything else I can help with? 🖤",
                "I'll take care of that for you right away.",
                "Understood. I'll keep you posted. 🙇‍♀️",
            ]
            let reply = ChatMessage(
                text: replies.randomElement() ?? "Received! 🖤",
                isFromUser: false
            )
            DispatchQueue.main.async { completion(reply) }
        }
    }
}

/// Manages a single conversation thread. Designed to later support multiple agents.
@MainActor
class ChatService: ObservableObject {
    static let shared = ChatService()

    @Published var messages: [ChatMessage] = []
    @Published var isSending = false

    private let transport: ChatTransport

    init(transport: ChatTransport = MockChatTransport()) {
        self.transport = transport
        loadMessages()
    }

    func send(_ text: String) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        let userMsg = ChatMessage(text: text, isFromUser: true)
        messages.append(userMsg)
        persistMessages()
        isSending = true

        transport.send(text: text, to: "rune") { [weak self] reply in
            guard let self else { return }
            if let reply {
                self.messages.append(reply)
                self.persistMessages()
            }
            self.isSending = false
        }
    }

    // MARK: - Persistence

    private static let storageKey = "aperture_chat_rune_messages"

    private func persistMessages() {
        if let data = try? JSONEncoder().encode(messages) {
            UserDefaults.standard.set(data, forKey: Self.storageKey)
        }
    }

    private func loadMessages() {
        guard let data = UserDefaults.standard.data(forKey: Self.storageKey),
              let saved = try? JSONDecoder().decode([ChatMessage].self, from: data) else { return }
        messages = saved
    }

    func clearHistory() {
        messages.removeAll()
        UserDefaults.standard.removeObject(forKey: Self.storageKey)
    }
}
