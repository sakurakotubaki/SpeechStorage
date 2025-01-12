import SwiftUI
import SwiftData

@main
struct SpeechStorageApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    let container: ModelContainer
    
    init() {
        do {
            let schema = Schema([VoiceMemo.self])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            container = try ModelContainer(for: schema, configurations: modelConfiguration)
            
            // 画面の向きを縦向きに固定
            if #available(iOS 16.0, *) {
                UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.forEach { windowScene in
                    windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
                }
            }
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(container)
        }
        .windowResizability(.contentSize)
        .defaultSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    }
}
