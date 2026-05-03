import Foundation

struct ChatMessage: Identifiable, Codable, Equatable {
    let id: UUID
    let agentId: String
    let text: String
    let timestamp: Date
    let isFromUser: Bool

    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }

    init(id: UUID = UUID(), agentId: String = "rune", text: String, timestamp: Date = Date(), isFromUser: Bool) {
        self.id = id
        self.agentId = agentId
        self.text = text
        self.timestamp = timestamp
        self.isFromUser = isFromUser
    }
}

struct AgentIdentity: Identifiable {
    let id: String
    let name: String
    let emoji: String
}
