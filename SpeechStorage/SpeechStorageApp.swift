//
//  SpeechStorageApp.swift
//  SpeechStorage
//
//  Created by 橋本純一 on 2025/01/03.
//

import SwiftUI
import SwiftData

@main
struct SpeechStorageApp: App {
    let container: ModelContainer
    
    init() {
        do {
            container = try ModelContainer(for: VoiceMemo.self)
        } catch {
            fatalError("Could not initialize ModelContainer")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
