import SwiftUI
import SwiftData

@main
struct SpeechStorageApp: App {
    let container: ModelContainer
    
    init() {
        do {
            let schema = Schema([VoiceMemo.self])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            container = try ModelContainer(for: schema, configurations: modelConfiguration)
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(container)
        }
    }
}
