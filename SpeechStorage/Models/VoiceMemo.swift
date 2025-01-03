import Foundation
import SwiftData

@Model
final class VoiceMemo {
    let id: UUID
    var text: String
    var themeColor: String
    var createdAt: Date
    
    init(text: String, themeColor: String) {
        self.id = UUID()
        self.text = text
        self.themeColor = themeColor
        self.createdAt = Date()
    }
}
