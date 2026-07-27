import SwiftUI

@main
struct UltralockApp: App {
    init() {
        disableDebugger()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .ignoresSafeArea(.container, edges: .all)
        }
    }
}
