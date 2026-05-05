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

        URLSession.shared.dataTask(with: req) { [weak self] data, response, _ in
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

    func toggleCompleted(_ todo: VeritosTodo) {
        updateTodo(todoId: todo.id, body: [
            "completed": !todo.completed,
            "urgency": todo.urgency,
            "is_want": todo.isWant ?? false
        ])
    }

    func toggleSubtask(todoId: Int, subtask: Subtask) {
        guard var subtasks = todos.first(where: { $0.id == todoId })?.subtasks else { return }

        // Build the subtasks array with the toggled one
        let updatedSubtasks: [[String: Any]] = subtasks.map { s in
            [
                "id": s.id,
                "title": s.title,
                "completed": s.id == subtask.id ? !s.completed : s.completed
            ]
        }

        updateTodo(todoId: todoId, body: [
            "subtasks": updatedSubtasks
        ])
    }

    func updateTodo(todoId: Int, body: [String: Any]) {
        guard let url = URL(string: "\(baseURL)/my/todos/\(todoId)") else { return }

        var req = URLRequest(url: url)
        req.httpMethod = "PUT"
        if let token = UserDefaults.standard.string(forKey: "location_warden_token") {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Merge with existing fields if needed
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: req) { [weak self] _, _, _ in
            DispatchQueue.main.async {
                self?.fetchTodos()
            }
        }.resume()
    }
}
