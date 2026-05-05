import SwiftUI

struct TasksView: View {
    @StateObject private var taskService = TaskService.shared
    @State private var showCompleted = false
    @State private var selectedTodo: VeritosTodo?

    private var activeTasks: [VeritosTodo] {
        taskService.todos.filter { !$0.completed }
            .sorted { $0.urgency < $1.urgency }
    }

    private var completedTasks: [VeritosTodo] {
        taskService.todos.filter { $0.completed }
    }

    var body: some View {
        List {
            Section {
                HStack {
                    Text("\(activeTasks.count) active")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    if taskService.isLoading {
                        ProgressView()
                            .scaleEffect(0.7)
                    }
                }

                if activeTasks.isEmpty && !taskService.isLoading {
                    Text("All clear ✨")
                        .foregroundColor(.secondary)
                        .italic()
                }

                ForEach(activeTasks) { todo in
                    NavigationLink(destination: todoDetail(for: todo)) {
                        TaskRow(todo: todo)
                    }
                }
            }

            if !completedTasks.isEmpty {
                Section {
                    Button {
                        withAnimation { showCompleted.toggle() }
                    } label: {
                        HStack {
                            Text("\(completedTasks.count) completed")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Image(systemName: showCompleted ? "chevron.up" : "chevron.down")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    if showCompleted {
                        ForEach(completedTasks) { todo in
                            NavigationLink(destination: todoDetail(for: todo)) {
                                TaskRow(todo: todo)
                            }
                        }
                    }
                }
            }

            if let error = taskService.lastError {
                Section {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
        }
        .navigationTitle("Tasks")
        .onAppear {
            if taskService.todos.isEmpty {
                taskService.fetchTodos()
            }
        }
        .refreshable {
            taskService.fetchTodos()
        }
    }

    @ViewBuilder
    private func todoDetail(for todo: VeritosTodo) -> some View {
        TodoDetailView(
            taskService: taskService,
            todo: todo
        )
    }
}

struct TaskRow: View {
    let todo: VeritosTodo

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: todo.completed ? "checkmark.circle.fill" : "circle")
                .foregroundColor(todo.completed ? .green : .secondary)
                .font(.title3)

            VStack(alignment: .leading, spacing: 3) {
                Text(todo.title)
                    .foregroundColor(todo.completed ? .secondary : .primary)
                    .strikethrough(todo.completed)
                    .lineLimit(2)

                HStack(spacing: 8) {
                    Text(todo.urgencyColor)
                    Text(todo.urgencyLabel)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    if todo.totalSubtaskCount > 0 {
                        Text("\(todo.completedSubtaskCount)/\(todo.totalSubtaskCount)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    if let due = todo.formattedDueDate {
                        Text("📅")
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary.opacity(0.5))
        }
    }
}
