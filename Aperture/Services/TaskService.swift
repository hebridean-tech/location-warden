import Foundation

class TaskService: ObservableObject {
    static let shared = TaskService()

    @Published var todos: [VeritosTodo] = []
    @Published var isLoading = false
    @Published var lastError: String?

    private let baseURL = "https://arch.projectveritos.com"

    func fetchTodos() {
        guard !isLoading else { return }
        isLoading = true
        lastError = nil

        guard let url = URL(string: "\(baseURL)/my/todos") else {
            isLoading = false
            return
        }

        var req = URLRequest(url: url)
        if let token = UserDefaults.standard.string(forKey: "location_warden_token") {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: req) { [weak self] data, _, _ in
            DispatchQueue.main.async {
                self?.isLoading = false
                guard let data,
                      let json = try? JSONDecoder().decode([VeritosTodo].self, from: data) else {
                    self?.lastError = "Failed to load tasks"
                    return
                }
                self?.todos = json
            }
        }.resume()
    }

    func updateTodo(todoId: Int, body: [String: Any], completion: (() -> Void)? = nil) {
        guard let url = URL(string: "\(baseURL)/my/todos/\(todoId)") else { return }

        var req = URLRequest(url: url)
        req.httpMethod = "PUT"
        if let token = UserDefaults.standard.string(forKey: "location_warden_token") {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        req.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: req) { [weak self] _, _, _ in
            DispatchQueue.main.async {
                self?.fetchTodos()
                completion?()
            }
        }.resume()
    }

    func toggleCompleted(_ todo: VeritosTodo) {
        updateTodo(todoId: todo.id, body: [
            "completed": !todo.completed,
            "urgency": todo.urgency,
            "is_want": todo.isWant ?? false
        ])
    }

    func incrementSubtask(todoId: Int, subtask: Subtask) {
        guard let idx = todos.firstIndex(where: { $0.id == todoId }),
              let subIdx = todos[idx].subtasks?.firstIndex(where: { $0.id == subtask.id }) else { return }

        let updatedSub = todos[idx].subtasks![subIdx]
        let newCount = min(updatedSub.completedCount + 1, updatedSub.targetCount)
        let newCompleted = newCount >= updatedSub.targetCount

        let updatedSubtasks: [[String: Any]] = todos[idx].subtasks!.enumerated().map { i, s in
            if i == subIdx {
                return [
                    "id": s.id,
                    "title": s.title,
                    "completed": newCompleted,
                    "target_count": s.targetCount,
                    "completed_count": newCount,
                    "position": s.position ?? 0
                ]
            }
            return [
                "id": s.id,
                "title": s.title,
                "completed": s.completed,
                "target_count": s.targetCount,
                "completed_count": s.completedCount,
                "position": s.position ?? 0
            ]
        }

        updateTodo(todoId: todoId, body: ["subtasks": updatedSubtasks])
    }

    func decrementSubtask(todoId: Int, subtask: Subtask) {
        guard let idx = todos.firstIndex(where: { $0.id == todoId }),
              let subIdx = todos[idx].subtasks?.firstIndex(where: { $0.id == subtask.id }) else { return }

        let updatedSub = todos[idx].subtasks![subIdx]
        let newCount = max(updatedSub.completedCount - 1, 0)
        let newCompleted = newCount >= updatedSub.targetCount

        let updatedSubtasks: [[String: Any]] = todos[idx].subtasks!.enumerated().map { i, s in
            if i == subIdx {
                return [
                    "id": s.id,
                    "title": s.title,
                    "completed": newCompleted,
                    "target_count": s.targetCount,
                    "completed_count": newCount,
                    "position": s.position ?? 0
                ]
            }
            return [
                "id": s.id,
                "title": s.title,
                "completed": s.completed,
                "target_count": s.targetCount,
                "completed_count": s.completedCount,
                "position": s.position ?? 0
            ]
        }

        updateTodo(todoId: todoId, body: ["subtasks": updatedSubtasks])
    }

    func toggleSubtask(todoId: Int, subtask: Subtask) {
        if subtask.isFullyComplete {
            decrementSubtask(todoId: todoId, subtask: subtask)
        } else {
            incrementSubtask(todoId: todoId, subtask: subtask)
        }
    }
}
