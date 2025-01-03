import Foundation
import SwiftData

@Model
final class VoiceMemo {
    var text: String
    var themeColor: String
    var createdAt: Date
    
    init(text: String, themeColor: String = "#000000", createdAt: Date = Date()) {
        self.text = text
        self.themeColor = themeColor
        self.createdAt = createdAt
    }
}
