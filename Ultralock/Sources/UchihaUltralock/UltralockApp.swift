import SwiftUI

@main
struct UltralockApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .ignoresSafeArea(.container, edges: .all)
        }
    }
}
