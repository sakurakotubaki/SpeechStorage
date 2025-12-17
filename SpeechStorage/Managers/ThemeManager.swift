import SwiftUI

@Observable
class ThemeManager {
    static let shared: ThemeManager = {
        let instance = ThemeManager()
        return instance
    }()

    private var storage: UserDefaults
    private(set) var storedThemeColor: String
    private(set) var currentTheme: Color

    private init() {
        let defaults = UserDefaults.standard
        let colorString = defaults.string(forKey: "themeColor") ?? "#007AFF"
        self.storage = defaults
        self.storedThemeColor = colorString
        self.currentTheme = Color(hex: colorString) ?? .blue
    }
    
    func updateTheme(_ color: Color) {
        currentTheme = color
        storedThemeColor = color.toHex() ?? "#007AFF"
        storage.set(storedThemeColor, forKey: "themeColor")
    }
}
