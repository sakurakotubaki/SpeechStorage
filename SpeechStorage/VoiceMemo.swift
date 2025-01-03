import SwiftData
import SwiftUI

@Model
class VoiceMemo {
    let id: String
    var text: String
    var createdAt: Date
    var themeColor: String // Hex string for color
    
    init(text: String, themeColor: String) {
        self.id = UUID().uuidString
        self.text = text
        self.createdAt = Date()
        self.themeColor = themeColor
    }
}
