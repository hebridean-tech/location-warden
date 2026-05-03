import Foundation

/// Protocol for chat transport — swap implementations for mock vs real backend.
protocol ChatTransport {
    func send(text: String, to agentId: String, completion: @escaping (ChatMessage?) -> Void)
}

/// Mock transport kept for fallback/testing.
class MockChatTransport: ChatTransport {
    func send(text: String, to agentId: String, completion: @escaping (ChatMessage?) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.8) {
            let replies = [
                "Got it, sir. I'll look into that. 🥀",
                "On it. Let me check and get back to you.",
                "Noted. Anything else you need?",
                "I'll take care of that right away.",
                "Understood. I'll keep you posted.",
            ]
            let reply = ChatMessage(
                text: replies.randomElement() ?? "Received.",
                isFromUser: false
            )
            DispatchQueue.main.async { completion(reply) }
        }
    }
}

/// Manages a single conversation thread with Madame Sévérine.
@MainActor
class ChatService: ObservableObject {
    static let shared = ChatService()

    @Published var messages: [ChatMessage] = []
    @Published var isSending = false

    private let transport: ChatTransport

    private static var _eager: ChatService?

    /// Eagerly initialize at app launch so first tab tap is instant.
    static func warmUp() {
        if _eager == nil {
            _eager = shared
        }
    }

    init(transport: ChatTransport = RealChatTransport()) {
        self.transport = transport
        loadMessages()
    }

    func send(_ text: String) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        let userMsg = ChatMessage(text: text, isFromUser: true)
        messages.append(userMsg)
        persistMessages()
        isSending = true

        transport.send(text: text, to: "madame") { [weak self] reply in
            guard let self else { return }
            if let reply {
                self.messages.append(reply)
                self.persistMessages()
            }
            self.isSending = false
        }
    }

    // MARK: - Persistence

    private static let storageKey = "aperture_chat_madame_messages"

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
