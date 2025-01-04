import SwiftUI
import SwiftData

@main
struct SpeechStorageApp: App {
    let container: ModelContainer
    
    init() {
        do {
            let schema = Schema([VoiceMemo.self])
            let config = ModelConfiguration("speech-storage", schema: schema)
            container = try ModelContainer(for: schema, configurations: config)
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
