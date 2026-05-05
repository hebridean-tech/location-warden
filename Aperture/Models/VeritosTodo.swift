import Foundation

struct Subtask: Identifiable, Codable {
    let id: Int
    var title: String
    var completed: Bool
    var targetCount: Int
    var completedCount: Int
    var position: Int?

    var isIterative: Bool { targetCount > 1 }
    var isFullyComplete: Bool { completedCount >= targetCount }
    var progressText: String { "\(completedCount)/\(targetCount)" }

    enum CodingKeys: String, CodingKey {
        case id, title, completed, position
        case targetCount = "target_count"
        case completedCount = "completed_count"
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
        default: return "\(urgency)"
        }
    }

    var urgencyEmoji: String {
        switch urgency {
        case 1: return "🔴"
        case 2: return "🟠"
        case 3: return "🟡"
        case 4: return "🟢"
        default: return "⚪"
        }
    }

    var completedSubtaskCount: Int {
        subtasks?.filter(\.isFullyComplete).count ?? 0
    }

    var totalSubtaskCount: Int {
        subtasks?.count ?? 0
    }

    var progressFraction: CGFloat {
        guard let subs = subtasks, !subs.isEmpty else { return completed ? 1.0 : 0.0 }
        let total = subs.reduce(0) { $0 + $1.targetCount }
        let done = subs.reduce(0) { $0 + $1.completedCount }
        return total > 0 ? CGFloat(done) / CGFloat(total) : 0
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
        formatter.formatOptions = [.withInternetDateTime]
        if let date = formatter.date(from: dueStr) {
            let display = DateFormatter()
            display.dateStyle = .medium
            display.timeStyle = .short
            return display.string(from: date)
        }
        return dueStr
    }

    var parsedDueDate: Date? {
        guard let dueStr = dueAt, !dueStr.isEmpty else { return nil }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = formatter.date(from: dueStr) { return d }
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: dueStr)
    }

    var tagList: [String] {
        guard let tags, !tags.isEmpty else { return [] }
        return tags.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
    }

    var descriptionLines: [String] {
        guard let desc = description, !desc.isEmpty else { return [] }
        return desc.components(separatedBy: "\n")
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
