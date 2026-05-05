import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                LocationView()
            }
            .tabItem {
                Label("Location", systemImage: "location")
            }
            .tag(0)

            NavigationView {
                ChatView()
            }
            .tabItem {
                Label("Tasks", systemImage: "checklist")
            }
            .tag(1)

            NavigationView {
                ChatView()
            }
            .tabItem {
                Label("Rune", systemImage: "bubble.left")
            }
            .tag(2)
        }
    }
}
