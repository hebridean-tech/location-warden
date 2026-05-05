import SwiftUI

struct TodoDetailView: View {
    let todo: VeritosTodo
    let onToggleComplete: () -> Void
    let onToggleSubtask: (Subtask) -> Void

    var body: some View {
        List {
            // Title & completion
            Section {
                HStack(spacing: 14) {
                    Button(action: onToggleComplete) {
                        Image(systemName: todo.completed ? "checkmark.circle.fill" : "circle")
                            .font(.title)
                            .foregroundColor(todo.completed ? .green : .secondary)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(todo.title)
                            .font(.headline)
                            .strikethrough(todo.completed)
                        HStack(spacing: 8) {
                            Text(todo.urgencyColor)
                            Text(todo.urgencyLabel)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            if todo.isWant == true {
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
                }
                .padding(.vertical, 4)
            }

            // Details
            Section("Details") {
                if let desc = todo.description, !desc.isEmpty {
                    Text(desc)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                if let due = todo.formattedDueDate {
                    LabeledContent("Due", value: due)
                }

                if let tags = todo.tags, !tags.isEmpty {
                    FlowLayout(tags: todo.tagList) { tag in
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

                if let created = todo.createdAt {
                    LabeledContent("Created", value: formatISO(created))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                if let updated = todo.updatedAt {
                    LabeledContent("Updated", value: formatISO(updated))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // Subtasks
            if let subtasks = todo.subtasks, !subtasks.isEmpty {
                Section("Subtasks (\(todo.completedSubtaskCount)/\(todo.totalSubtaskCount))") {
                    // Progress bar
                    if todo.hasProgress {
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.gray.opacity(0.15))
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.green)
                                    .frame(width: geo.size.width * todo.progressFraction)
                            }
                        }
                        .frame(height: 6)
                        .padding(.vertical, 4)
                    }

                    ForEach(subtasks) { subtask in
                        Button(action: { onToggleSubtask(subtask) }) {
                            HStack(spacing: 10) {
                                Image(systemName: subtask.completed ? "checkmark.square.fill" : "square")
                                    .foregroundColor(subtask.completed ? .green : .secondary)
                                Text(subtask.title)
                                    .foregroundColor(subtask.completed ? .secondary : .primary)
                                    .strikethrough(subtask.completed)
                                Spacer()
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Task #\(todo.id)")
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

// MARK: - Flow Layout for tags

struct FlowLayout: View {
    let tags: [String]
    let tagView: (String) -> some View

    @State private var totalHeight: CGFloat = 0

    var body: some View {
        VStack(spacing: 6) {
            GeometryReader { geo in
                generateContent(in: geo.size)
            }
            .frame(height: totalHeight)
        }
    }

    private func generateContent(in size: CGSize) -> some View {
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        return ZStack(alignment: .topLeading) {
            ForEach(Array(tags.enumerated()), id: \.offset) { _, tag in
                tagView(tag)
                    .alignmentGuide(.leading) { d in
                        if abs(x - d.width) > size.width {
                            x = 0
                            y += rowHeight
                            rowHeight = 0
                        }
                        let result = x
                        if tag == tags.last {
                            x = 0
                        } else {
                            x += d.width + 6
                        }
                        rowHeight = max(rowHeight, d.height)
                        return result
                    }
                    .alignmentGuide(.top) { d in
                        let result = y
                        if tag == tags.last {
                            y = 0
                        }
                        return result
                    }
            }
        }
        .background(GeometryReader { geo in
            Color.clear.preference(key: HeightKey.self, value: geo.size.height)
        })
        .onPreferenceChange(HeightKey.self) { h in
            totalHeight = h
        }
    }
}

private struct HeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
