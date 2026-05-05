import SwiftUI

struct TodoDetailView: View {
    @ObservedObject var taskService: TaskService
    let todo: VeritosTodo
    @Environment(\.presentationMode) var presentationMode

    @State private var isEditing = false
    @State private var editTitle: String = ""
    @State private var editDescription: String = ""
    @State private var editUrgency: Int = 3
    @State private var editDueDate: Date = Date()
    @State private var editHasDueDate: Bool = false

    private var currentTodo: VeritosTodo {
        taskService.todos.first(where: { $0.id == todo.id }) ?? todo
    }

    var body: some View {
        List {
            // Title & completion
            Section {
                HStack(spacing: 14) {
                    Button(action: { taskService.toggleCompleted(currentTodo) }) {
                        Image(systemName: currentTodo.completed ? "checkmark.circle.fill" : "circle")
                            .font(.title)
                            .foregroundColor(currentTodo.completed ? .green : .secondary)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(currentTodo.title)
                            .font(.headline)
                            .strikethrough(currentTodo.completed)
                        HStack(spacing: 8) {
                            Text(currentTodo.urgencyEmoji)
                            Text(currentTodo.urgencyLabel)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            if currentTodo.isWant == true {
                                Text("Want")
                                    .font(.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.purple.opacity(0.15))
                                    .foregroundColor(.purple)
                                    .cornerRadius(4)
                            }
                        }
                    }

                    Spacer()
                }
                .padding(.vertical, 4)
            }

            // Details
            Section("Details") {
                if !currentTodo.descriptionLines.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Description")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        ForEach(Array(currentTodo.descriptionLines.enumerated()), id: \.offset) { _, line in
                            Text(line)
                                .font(.subheadline)
                        }
                    }
                }

                if let due = currentTodo.formattedDueDate {
                    LabeledContent("Due", value: due)
                }

                if !currentTodo.tagList.isEmpty {
                    FlowLayout(tags: currentTodo.tagList) { tag in
                        Text(tag)
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(6)
                    }
                    .padding(.vertical, 2)
                }

                if let created = currentTodo.createdAt {
                    LabeledContent("Created", value: formatISO(created))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // Subtasks
            if let subtasks = currentTodo.subtasks, !subtasks.isEmpty {
                let totalTarget = subtasks.reduce(0) { $0 + $1.targetCount }
                let totalDone = subtasks.reduce(0) { $0 + $1.completedCount }

                Section("Subtasks (\(totalDone)/\(totalTarget))") {
                    // Overall progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.15))
                            RoundedRectangle(cornerRadius: 4)
                                .fill(currentTodo.progressFraction >= 1.0 ? Color.green : Color.blue)
                                .frame(width: geo.size.width * currentTodo.progressFraction)
                        }
                    }
                    .frame(height: 6)
                    .padding(.vertical, 4)

                    ForEach(subtasks) { subtask in
                        SubtaskRow(
                            subtask: subtask,
                            onIncrement: { taskService.incrementSubtask(todoId: currentTodo.id, subtask: subtask) },
                            onDecrement: { taskService.decrementSubtask(todoId: currentTodo.id, subtask: subtask) }
                        )
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Task #\(currentTodo.id)")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(isEditing ? "Save" : "Edit") {
                    if isEditing {
                        saveEdits()
                    } else {
                        startEditing()
                    }
                }
            }
            if isEditing {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isEditing = false
                    }
                }
            }
        }
        .sheet(isPresented: $isEditing) {
            TodoEditSheet(todo: currentTodo) { title, description, urgency, dueDate in
                saveEdit(title: title, description: description, urgency: urgency, dueDate: dueDate)
            }
        }
    }

    private func startEditing() {
        isEditing = true
    }

    private func saveEdits() {}

    private func saveEdit(title: String, description: String, urgency: Int, dueDate: Date?) {
        var body: [String: Any] = [
            "title": title,
            "description": description,
            "urgency": urgency
        ]

        if let due = dueDate {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime]
            body["due_at"] = formatter.string(from: due)
        } else {
            body["due_at"] = ""
        }

        taskService.updateTodo(todoId: currentTodo.id, body: body)
        isEditing = false
    }

    private func formatISO(_ iso: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: iso) {
            let display = DateFormatter()
            display.dateStyle = .medium
            display.timeStyle = .short
            return display.string(from: date)
        }
        formatter.formatOptions = [.withInternetDateTime]
        if let date = formatter.date(from: iso) {
            let display = DateFormatter()
            display.dateStyle = .medium
            display.timeStyle = .short
            return display.string(from: date)
        }
        return iso
    }
}

// MARK: - Edit Sheet

struct TodoEditSheet: View {
    let todo: VeritosTodo
    let onSave: (String, String, Int, Date?) -> Void

    @Environment(\.presentationMode) var presentationMode
    @State private var title: String
    @State private var description: String
    @State private var urgency: Int
    @State private var dueDate: Date
    @State private var hasDueDate: Bool

    init(todo: VeritosTodo, onSave: @escaping (String, String, Int, Date?) -> Void) {
        self.todo = todo
        self.onSave = onSave
        _title = State(initialValue: todo.title)
        _description = State(initialValue: todo.description ?? "")
        _urgency = State(initialValue: todo.urgency)
        _hasDueDate = State(initialValue: todo.parsedDueDate != nil)
        _dueDate = State(initialValue: todo.parsedDueDate ?? Date())
    }

    private let urgencyOptions = [(1, "🔴 Critical"), (2, "🟠 High"), (3, "🟡 Normal"), (4, "🟢 Low"), (5, "⚪ Minimal")]

    var body: some View {
        NavigationView {
            Form {
                Section("Task") {
                    TextField("Title", text: $title)
                    TextEditor(text: $description)
                        .frame(minHeight: 100)
                }

                Section("Priority") {
                    Picker("Urgency", selection: $urgency) {
                        ForEach(urgencyOptions, id: \.0) { level, label in
                            Text(label).tag(level)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section("Due Date") {
                    Toggle("Set due date", isOn: $hasDueDate)
                    if hasDueDate {
                        DatePicker("Due", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                    }
                }
            }
            .navigationTitle("Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { presentationMode.wrappedValue.dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(title, description, urgency, hasDueDate ? dueDate : nil)
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

// MARK: - Subtask Row with Iteration Support

struct SubtaskRow: View {
    let subtask: Subtask
    let onIncrement: () -> Void
    let onDecrement: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Completion indicator
            if subtask.isFullyComplete {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            } else {
                Image(systemName: subtask.isIterative ? "arrow.triangle.2.circlepath" : "circle")
                    .foregroundColor(.secondary)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(subtask.title)
                    .foregroundColor(subtask.isFullyComplete ? .secondary : .primary)
                    .strikethrough(subtask.isFullyComplete)

                if subtask.isIterative {
                    // Iterative subtask: show counter with +/- buttons
                    HStack(spacing: 8) {
                        Button(action: onDecrement) {
                            Image(systemName: "minus.circle")
                                .font(.body)
                                .foregroundColor(subtask.completedCount > 0 ? .red : .gray.opacity(0.3))
                        }
                        .disabled(subtask.completedCount <= 0)

                        Text("\(subtask.completedCount) / \(subtask.targetCount)")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(subtask.isFullyComplete ? .green : .secondary)
                            .frame(minWidth: 50)

                        Button(action: onIncrement) {
                            Image(systemName: "plus.circle")
                                .font(.body)
                                .foregroundColor(subtask.isFullyComplete ? .gray.opacity(0.3) : .blue)
                        }
                        .disabled(subtask.isFullyComplete)
                    }

                    // Mini progress bar for iterative
                    if subtask.targetCount > 1 {
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.gray.opacity(0.15))
                                let fraction = CGFloat(subtask.completedCount) / CGFloat(subtask.targetCount)
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(fraction >= 1.0 ? Color.green : Color.blue)
                                    .frame(width: geo.size.width * fraction)
                            }
                        }
                        .frame(height: 4)
                    }
                }
            }

            Spacer()

            if !subtask.isIterative && !subtask.isFullyComplete {
                // Simple checkbox tap for non-iterative
                Button(action: onIncrement) {
                    Image(systemName: "square")
                        .foregroundColor(.secondary.opacity(0.3))
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Flow Layout for tags

struct FlowLayout<V: View>: View {
    let tags: [String]
    let tagView: (String) -> V

    var body: some View {
        let rows = computeRows()
        VStack(alignment: .leading, spacing: 6) {
            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                HStack(spacing: 6) {
                    ForEach(row, id: \.self) { tag in
                        tagView(tag)
                    }
                }
            }
        }
    }

    private func computeRows() -> [[String]] {
        var rows: [[String]] = [[]]
        for tag in tags {
            if rows[rows.count - 1].count >= 3 {
                rows.append([tag])
            } else {
                rows[rows.count - 1].append(tag)
            }
        }
        return rows
    }
}
