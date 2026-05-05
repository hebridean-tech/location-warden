import Foundation

struct Subtask: Identifiable, Codable {
    let id: Int
    var title: String
    var completed: Bool

    enum CodingKeys: String, CodingKey {
        case id, title, completed
    }
}

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
    var subtasks: [Subtask]?

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

    var completedSubtaskCount: Int {
        subtasks?.filter(\.completed).count ?? 0
    }

    var totalSubtaskCount: Int {
        subtasks?.count ?? 0
    }

    var hasProgress: Bool {
        guard let subs = subtasks, !subs.isEmpty else { return false }
        return subs.contains(where: { !$0.completed })
    }

    var progressFraction: CGFloat {
        guard let subs = subtasks, !subs.isEmpty else { return 0 }
        let done = subs.filter(\.completed).count
        return CGFloat(done) / CGFloat(subs.count)
    }

    var formattedDueDate: String? {
        guard let dueStr = dueAt, !dueStr.isEmpty else { return nil }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: dueStr) {
            let display = DateFormatter()
            display.dateStyle = .medium
            display.timeStyle = .short
            return display.string(from: date)
        }
        // Try without fractional seconds
        formatter.formatOptions = [.withInternetDateTime]
        if let date = formatter.date(from: dueStr) {
            let display = DateFormatter()
            display.dateStyle = .medium
            display.timeStyle = .short
            return display.string(from: date)
        }
        return dueStr
    }

    var tagList: [String] {
        guard let tags, !tags.isEmpty else { return [] }
        return tags.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
    }

    enum CodingKeys: String, CodingKey {
        case id, title, description, tags, completed, urgency
        case isWant = "is_want"
        case dueAt = "due_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case subtasks
    }
}
