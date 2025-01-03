import SwiftData
import SwiftUI

@Model
class VoiceMemo {
    var text: String
    var createdAt: Date
    var themeColor: String // Hex string for color
    
    init(text: String, themeColor: String) {
        self.text = text
        self.createdAt = Date()
        self.themeColor = themeColor
    }
}
