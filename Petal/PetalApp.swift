import SwiftUI

@main
struct RaphtaliaApp: App {
    init() {
        ChatService.warmUp()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
