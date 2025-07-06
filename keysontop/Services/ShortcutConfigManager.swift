import Foundation
import Combine

class ShortcutConfigManager: ObservableObject {
    @Published var globalShortcut: String = "⌘?"
    
    private let userDefaults = UserDefaults.standard
    private let shortcutKey = "GlobalShortcutKey"
    
    init() {
        loadShortcut()
    }
    
    func saveShortcut(_ shortcut: String) {
        globalShortcut = shortcut
        userDefaults.set(shortcut, forKey: shortcutKey)
        
        // Post notification to update hotkey monitor
        NotificationCenter.default.post(
            name: .shortcutChanged,
            object: nil,
            userInfo: ["shortcut": shortcut]
        )
    }
    
    private func loadShortcut() {
        if let saved = userDefaults.string(forKey: shortcutKey) {
            globalShortcut = saved
        }
    }
}

extension Notification.Name {
    static let shortcutChanged = Notification.Name("shortcutChanged")
}