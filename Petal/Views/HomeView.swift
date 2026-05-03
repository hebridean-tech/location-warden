import SwiftUI

// MARK: - Theme

extension Color {
    static let raphAccent = Color(red: 0.72, green: 0.60, blue: 0.65) // dusty rose
    static let raphSage = Color(red: 0.72, green: 0.78, blue: 0.69)  // sage green
    static let raphBackground = Color(red: 0.97, green: 0.96, blue: 0.95)
    static let raphCard = Color.white
    static let raphTextPrimary = Color(red: 0.20, green: 0.20, blue: 0.22)
    static let raphTextSecondary = Color(red: 0.55, green: 0.55, blue: 0.57)
}

// MARK: - HomeView

struct HomeView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var isConnected = false
    @State private var currentZone: String? = nil

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Good morning" }
        if hour < 17 { return "Good afternoon" }
        return "Good evening"
    }

    private var todayFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: Date())
    }

    private var todayWeekday: String {
        let formatter = DateFormatter()
        formatter.weekdaySymbol = nil
        formatter.dateFormat = "EEEE"
        return formatter.string(from: Date())
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text(todayWeekday)
                        .font(.subheadline)
                        .foregroundColor(.raphTextSecondary)
                    Text(todayFormatted)
                        .font(.title3)
                        .foregroundColor(.raphTextSecondary)
                    Text("\(greeting) ✿")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.raphTextPrimary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

                // Location card
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "location.circle.fill")
                            .foregroundColor(.raphAccent)
                        Text("Location")
                            .font(.headline)
                            .foregroundColor(.raphTextPrimary)
                        Spacer()
                        Circle()
                            .fill(isConnected ? Color.raphSage : Color.red.opacity(0.6))
                            .frame(width: 8, height: 8)
                    }
                    if let zone = currentZone {
                        Text(zone)
                            .font(.subheadline)
                            .foregroundColor(.raphTextSecondary)
                    } else {
                        Text("Not in a monitored zone")
                            .font(.subheadline)
                            .foregroundColor(.raphTextSecondary)
                    }
                }
                .padding()
                .background(Color.raphCard)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
                .padding(.horizontal)

                // Chores summary card
                let remaining = ChoreService.shared.chores.filter { !$0.isCompleted }.count
                let total = ChoreService.shared.chores.count
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "checklist")
                            .foregroundColor(.raphSage)
                        Text("Tasks")
                            .font(.headline)
                            .foregroundColor(.raphTextPrimary)
                        Spacer()
                        Text("\(remaining) remaining")
                            .font(.subheadline)
                            .foregroundColor(remaining == 0 ? .raphSage : .raphAccent)
                    }
                    if remaining == 0 {
                        Text("All done for today 🌸")
                            .font(.subheadline)
                            .foregroundColor(.raphTextSecondary)
                    } else {
                        ProgressView(value: Double(total - remaining), total: Double(total))
                            .tint(.raphSage)
                    }
                }
                .padding()
                .background(Color.raphCard)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
                .padding(.horizontal)

                Spacer(minLength: 40)
            }
            .padding(.top)
        }
        .background(Color.raphBackground)
        .navigationTitle("Raphtalia")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            connect()
        }
    }

    private func connect() {
        API.shared.authenticate(serverURL: "https://arch.projectveritos.com") { ok in
            isConnected = ok
            if ok {
                locationManager.requestPermission()
                loadZones()
            }
        }
    }

    private func loadZones() {
        API.shared.fetchZones { result in
            if case .success(let z) = result {
                locationManager.startMonitoring(zones: z)
            }
        }
    }
}
