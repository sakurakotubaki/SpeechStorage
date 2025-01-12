import SwiftUI

class ThemeManager: ObservableObject {
    static let shared: ThemeManager = {
        let instance = ThemeManager()
        return instance
    }()
    
    private var storage: UserDefaults
    private(set) var storedThemeColor: String
    @Published private(set) var currentTheme: Color
    
    private init() {
        self.storage = UserDefaults.standard
        self.storedThemeColor = storage.string(forKey: "themeColor") ?? "#007AFF"
        let color = Color(hex: storedThemeColor) ?? .blue
        self._currentTheme = Published(initialValue: color)
    }
    
    func updateTheme(_ color: Color) {
        currentTheme = color
        storedThemeColor = color.toHex() ?? "#007AFF"
        storage.set(storedThemeColor, forKey: "themeColor")
    }
}
