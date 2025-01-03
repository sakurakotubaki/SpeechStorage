import Foundation
import SwiftData

@Model
final class AudioMemo {
    let id: UUID
    var audioURL: URL
    var themeColor: String
    var createdAt: Date
    
    init(audioURL: URL, themeColor: String) {
        self.id = UUID()
        self.audioURL = audioURL
        self.themeColor = themeColor
        self.createdAt = Date()
    }
}
