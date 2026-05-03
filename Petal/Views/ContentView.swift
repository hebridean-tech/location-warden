import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                HomeView()
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(0)

            NavigationView {
                TasksView()
            }
            .tabItem {
                Label("Tasks", systemImage: "checklist")
            }
            .tag(1)

            NavigationView {
                BodyView()
            }
            .tabItem {
                Label("Body", systemImage: "heart.fill")
            }
            .tag(2)

            NavigationView {
                ProgressView()
            }
            .tabItem {
                Label("Progress", systemImage: "chart.line.uptrend.xyaxis")
            }
            .tag(3)

            NavigationView {
                ChatView()
            }
            .tabItem {
                Label("Chat", systemImage: "bubble.left.fill")
            }
            .tag(4)
        }
        .tint(Color.raphAccent)
    }
}
