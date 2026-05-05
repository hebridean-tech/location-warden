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
        guard let url = URL(string: "\(baseURL)/my/todos/\(todo.id)") else { return }

        var req = URLRequest(url: url)
        req.httpMethod = "PUT"
        if let token = UserDefaults.standard.string(forKey: "location_warden_token") {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "completed": !todo.completed,
            "urgency": todo.urgency,
            "is_want": todo.isWant ?? false
        ]
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: req) { [weak self] _, _, _ in
            DispatchQueue.main.async {
                self?.fetchTodos()
            }
        }.resume()
    }
}
