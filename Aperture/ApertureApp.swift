import SwiftUI

@main
struct ApertureApp: App {
    init() {
        ChatService.warmUp()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
