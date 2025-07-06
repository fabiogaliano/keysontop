import Foundation

struct Shortcut: Identifiable, Codable, Equatable {
    let key: String
    let description: String
    
    // Use the key as the identifier since it should be unique within a group
    var id: String { key }
    
    init(key: String, description: String) {
        self.key = key
        self.description = description
    }
}

struct ShortcutGroup: Identifiable, Codable, Equatable {
    let title: String
    let category: String?
    let shortcuts: [Shortcut]
    
    // Use the title as the identifier since it should be unique within an app
    var id: String { title }
    
    init(title: String, category: String? = nil, shortcuts: [Shortcut]) {
        self.title = title
        self.category = category
        self.shortcuts = shortcuts
    }
}

struct ApplicationShortcuts: Codable {
    let applicationId: String
    let applicationName: String
    let version: String?
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
                category: "navigation",
                shortcuts: [
                    Shortcut(key: "⌘↑", description: "Go to parent folder"),
                    Shortcut(key: "⌘↓", description: "Open selected item"),
                    Shortcut(key: "⌘[", description: "Go back"),
                    Shortcut(key: "⌘]", description: "Go forward")
                ]
            ),
            ShortcutGroup(
                title: "File Operations",
                category: "file",
                shortcuts: [
                    Shortcut(key: "⌘N", description: "New Finder window"),
                    Shortcut(key: "⌘⇧N", description: "New folder"),
                    Shortcut(key: "⌘D", description: "Duplicate"),
                    Shortcut(key: "⌘⌫", description: "Move to Trash")
                ]
            ),
            ShortcutGroup(
                title: "View",
                category: "view",
                shortcuts: [
                    Shortcut(key: "⌘1", description: "Icon view"),
                    Shortcut(key: "⌘2", description: "List view"),
                    Shortcut(key: "⌘3", description: "Column view"),
                    Shortcut(key: "⌘4", description: "Gallery view")
                ]
            )
        ]
    )
}