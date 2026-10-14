import SwiftUI

@main
struct LegadoApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .onAppear {
                    appState.initialize()
                }
        }
    }
}

class AppState: ObservableObject {
    @Published var isInitialized = false

    func initialize() {
        // 初始化 KMP SDK
        isInitialized = true
    }
}
