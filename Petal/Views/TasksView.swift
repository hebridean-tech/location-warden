import SwiftUI

// MARK: - Chore Model

struct Chore: Identifiable, Codable {
    let id: UUID
    var title: String
    var isCompleted: Bool
    var completedAt: Date?

    init(id: UUID = UUID(), title: String, isCompleted: Bool = false, completedAt: Date? = nil) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.completedAt = completedAt
    }

    mutating func toggle() {
        isCompleted.toggle()
        completedAt = isCompleted ? Date() : nil
    }
}

// MARK: - Outfit Item Model

enum OutfitStatus: String, Codable {
    case available
    case dirty
    case clean
}

struct OutfitItem: Identifiable, Codable {
    let id: UUID
    var name: String
    var status: OutfitStatus

    init(id: UUID = UUID(), name: String, status: OutfitStatus = .available) {
        self.id = id
        self.name = name
        self.status = status
    }
}

// MARK: - ChoreService (mock data)

@MainActor
class ChoreService: ObservableObject {
    static let shared = ChoreService()

    @Published var chores: [Chore] = []
    @Published var outfits: [OutfitItem] = []

    private static let choresKey = "raphtalia_chores"
    private static let outfitsKey = "raphtalia_outfits"

    init() {
        loadChores()
        loadOutfits()
    }

    // MARK: - Chores

    private func loadChores() {
        if let data = UserDefaults.standard.data(forKey: Self.choresKey),
           let saved = try? JSONDecoder().decode([Chore].self, from: data) {
            chores = saved
        } else {
            chores = Self.mockChores()
            persistChores()
        }
    }

    private func persistChores() {
        if let data = try? JSONEncoder().encode(chores) {
            UserDefaults.standard.set(data, forKey: Self.choresKey)
        }
    }

    func toggleChore(_ chore: Chore) {
        if let idx = chores.firstIndex(where: { $0.id == chore.id }) {
            chores[idx].toggle()
            persistChores()
        }
    }

    func resetChores() {
        chores = Self.mockChores()
        persistChores()
    }

    static func mockChores() -> [Chore] {
        [
            Chore(title: "Make bed"),
            Chore(title: "Morning stretches"),
            Chore(title: "Take vitamins"),
            Chore(title: "Drink 2L water"),
            Chore(title: "Evening skincare"),
            Chore(title: "Journal entry"),
        ]
    }

    // MARK: - Outfits

    private func loadOutfits() {
        if let data = UserDefaults.standard.data(forKey: Self.outfitsKey),
           let saved = try? JSONDecoder().decode([OutfitItem].self, from: data) {
            outfits = saved
        } else {
            outfits = Self.mockOutfits()
            persistOutfits()
        }
    }

    private func persistOutfits() {
        if let data = try? JSONEncoder().encode(outfits) {
            UserDefaults.standard.set(data, forKey: Self.outfitsKey)
        }
    }

    func markWearing(_ item: OutfitItem) {
        if let idx = outfits.firstIndex(where: { $0.id == item.id }) {
            outfits[idx].status = .dirty
            persistOutfits()
        }
    }

    func laundryDone() {
        for idx in outfits.indices {
            outfits[idx].status = .clean
        }
        persistOutfits()
    }

    static func mockOutfits() -> [OutfitItem] {
        [
            OutfitItem(name: "Black dress", status: .available),
            OutfitItem(name: "White tee", status: .available),
            OutfitItem(name: "Jeans", status: .clean),
            OutfitItem(name: "Sage blouse", status: .available),
            OutfitItem(name: "Pencil skirt", status: .dirty),
            OutfitItem(name: "Sweater", status: .clean),
        ]
    }
}

// MARK: - TasksView

struct TasksView: View {
    @StateObject private var service = ChoreService.shared
    @State private var showOutfits = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Chores section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Today's Tasks")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.raphTextPrimary)
                        Spacer()
                        Button("Reset") {
                            service.resetChores()
                        }
                        .font(.caption)
                        .foregroundColor(.raphAccent)
                    }

                    let completed = service.chores.filter(\.isCompleted).count
                    let total = service.chores.count
                    if total > 0 {
                        Text("\(completed) of \(total)")
                            .font(.caption)
                            .foregroundColor(.raphTextSecondary)
                    }

                    ForEach(service.chores) { chore in
                        ChoreRow(chore: chore) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                service.toggleChore(chore)
                            }
                        }
                    }
                }
                .padding(.horizontal)

                Divider()
                    .padding(.horizontal)

                // Outfits section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Wardrobe")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.raphTextPrimary)
                        Spacer()
                        Button("Laundry Done ✓") {
                            withAnimation { service.laundryDone() }
                        }
                        .font(.caption)
                        .foregroundColor(.raphSage)
                    }

                    ForEach(service.outfits) { item in
                        OutfitRow(item: item) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                service.markWearing(item)
                            }
                        }
                    }
                }
                .padding(.horizontal)

                Spacer(minLength: 40)
            }
            .padding(.top, 8)
        }
        .background(Color.raphBackground)
        .navigationTitle("Tasks")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Chore Row

struct ChoreRow: View {
    let chore: Chore
    let action: () -> Void

    @State private var animating = false

    var body: some View {
        Button(action: {
            animating = true
            action()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { animating = false }
        }) {
            HStack(spacing: 12) {
                Image(systemName: chore.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(chore.isCompleted ? .raphSage : .raphTextSecondary.opacity(0.4))
                    .scaleEffect(animating ? 1.3 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.5), value: chore.isCompleted)

                Text(chore.title)
                    .font(.body)
                    .foregroundColor(chore.isCompleted ? .raphTextSecondary : .raphTextPrimary)
                    .strikethrough(chore.isCompleted, color: .raphTextSecondary)

                Spacer()
            }
            .padding()
            .background(Color.raphCard)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Outfit Row

struct OutfitRow: View {
    let item: OutfitItem
    let onWear: () -> Void

    private var statusColor: Color {
        switch item.status {
        case .available: return .raphSage
        case .dirty: return .raphAccent
        case .clean: return Color(red: 0.65, green: 0.75, blue: 0.85)
        }
    }

    private var statusLabel: String {
        switch item.status {
        case .available: return "Available"
        case .dirty: return "Dirty"
        case .clean: return "Clean"
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(statusColor)
                .frame(width: 10, height: 10)

            Text(item.name)
                .font(.body)
                .foregroundColor(.raphTextPrimary)

            Spacer()

            Text(statusLabel)
                .font(.caption)
                .foregroundColor(.raphTextSecondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(statusColor.opacity(0.15))
                .cornerRadius(8)

            if item.status != .dirty {
                Button("Wear") {
                    onWear()
                }
                .font(.caption)
                .foregroundColor(.raphAccent)
            }
        }
        .padding()
        .background(Color.raphCard)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 1)
    }
}
