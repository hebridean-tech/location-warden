import Foundation

struct VeritosTodo: Identifiable, Codable {
    let id: Int
    var title: String
    var description: String?
    var tags: String?
    var completed: Bool
    var urgency: Int
    var isWant: Bool?
    var dueAt: String?
    var createdAt: String?
    var updatedAt: String?

    var urgencyLabel: String {
        switch urgency {
        case 1: return "Critical"
        case 2: return "High"
        case 3: return "Normal"
        case 4: return "Low"
        default: return "—"
        }
    }

    var urgencyColor: String {
        switch urgency {
        case 1: return "🔴"
        case 2: return "🟠"
        case 3: return "🟡"
        case 4: return "🟢"
        default: return "⚪"
        }
    }

    enum CodingKeys: String, CodingKey {
        case id, title, description, tags, completed, urgency
        case isWant = "is_want"
        case dueAt = "due_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
