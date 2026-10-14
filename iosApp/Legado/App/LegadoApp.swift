import SwiftUI
import SwiftData

@main
struct LegadoApp: App {
    @StateObject private var settings = AppSettings.shared
    private let storage = StorageManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(settings)
                .environment(\.modelContext, storage.context)
                .preferredColorScheme(settings.effectiveColorScheme)
        }
    }
}
