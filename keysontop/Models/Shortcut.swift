import Foundation

struct Shortcut: Identifiable, Codable, Equatable {
    let id: String
    let key: String
    let description: String
    let category: String
    
    init(id: String = UUID().uuidString, key: String, description: String, category: String) {
        self.id = id
        self.key = key
        self.description = description
        self.category = category
    }
}

struct ShortcutGroup: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let shortcuts: [Shortcut]
    
    init(id: String = UUID().uuidString, title: String, shortcuts: [Shortcut]) {
        self.id = id
        self.title = title
        self.shortcuts = shortcuts
    }
}

struct ApplicationShortcuts: Codable {
    let applicationId: String
    let applicationName: String
    let version: String
    let groups: [ShortcutGroup]
}

extension ApplicationShortcuts {
    static let sample = ApplicationShortcuts(
        applicationId: "com.apple.finder",
        applicationName: "Finder",
        version: "1.0",
        groups: [
            ShortcutGroup(
                title: "Navigation",
                shortcuts: [
                    Shortcut(key: "⌘↑", description: "Go to parent folder", category: "navigation"),
                    Shortcut(key: "⌘↓", description: "Open selected item", category: "navigation"),
                    Shortcut(key: "⌘[", description: "Go back", category: "navigation"),
                    Shortcut(key: "⌘]", description: "Go forward", category: "navigation")
                ]
            ),
            ShortcutGroup(
                title: "File Operations",
                shortcuts: [
                    Shortcut(key: "⌘N", description: "New Finder window", category: "file"),
                    Shortcut(key: "⌘⇧N", description: "New folder", category: "file"),
                    Shortcut(key: "⌘D", description: "Duplicate", category: "file"),
                    Shortcut(key: "⌘⌫", description: "Move to Trash", category: "file")
                ]
            ),
            ShortcutGroup(
                title: "View",
                shortcuts: [
                    Shortcut(key: "⌘1", description: "Icon view", category: "view"),
                    Shortcut(key: "⌘2", description: "List view", category: "view"),
                    Shortcut(key: "⌘3", description: "Column view", category: "view"),
                    Shortcut(key: "⌘4", description: "Gallery view", category: "view")
                ]
            )
        ]
    )
}