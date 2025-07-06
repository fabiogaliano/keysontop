import Foundation

class ShortcutDatabase: ObservableObject {
    @Published var shortcuts: [String: ApplicationShortcuts] = [:]
    
    private let documentsDirectory: URL
    
    init() {
        documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        loadBuiltInShortcuts()
    }
    
    func loadShortcuts(for bundleId: String) -> [ShortcutGroup]? {
        return shortcuts[bundleId]?.groups
    }
    
    func importShortcuts(from json: Data) throws {
        let decoder = JSONDecoder()
        let applicationShortcuts = try decoder.decode(ApplicationShortcuts.self, from: json)
        
        shortcuts[applicationShortcuts.applicationId] = applicationShortcuts
        
        // Save to disk
        try saveShortcuts(applicationShortcuts)
    }
    
    func importShortcuts(from url: URL) throws {
        let data = try Data(contentsOf: url)
        try importShortcuts(from: data)
    }
    
    private func saveShortcuts(_ applicationShortcuts: ApplicationShortcuts) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        let data = try encoder.encode(applicationShortcuts)
        let filename = "\(applicationShortcuts.applicationId).json"
        let fileURL = documentsDirectory.appendingPathComponent("KeysOnTop").appendingPathComponent(filename)
        
        // Create directory if it doesn't exist
        try FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        
        try data.write(to: fileURL)
    }
    
    private func loadBuiltInShortcuts() {
        // Load sample Finder shortcuts
        shortcuts[ApplicationShortcuts.sample.applicationId] = ApplicationShortcuts.sample
        
        // Add more built-in shortcuts here
        loadSafariShortcuts()
        loadChromeShortcuts()
    }
    
    private func loadSafariShortcuts() {
        let safariShortcuts = ApplicationShortcuts(
            applicationId: "com.apple.Safari",
            applicationName: "Safari",
            version: "1.0",
            groups: [
                ShortcutGroup(
                    title: "Navigation",
                    shortcuts: [
                        Shortcut(key: "⌘L", description: "Focus address bar", category: "navigation"),
                        Shortcut(key: "⌘R", description: "Reload page", category: "navigation"),
                        Shortcut(key: "⌘[", description: "Go back", category: "navigation"),
                        Shortcut(key: "⌘]", description: "Go forward", category: "navigation"),
                        Shortcut(key: "⌘T", description: "New tab", category: "navigation"),
                        Shortcut(key: "⌘W", description: "Close tab", category: "navigation"),
                        Shortcut(key: "⌘⇧T", description: "Reopen closed tab", category: "navigation"),
                        Shortcut(key: "⌘⇧]", description: "Next tab", category: "navigation"),
                        Shortcut(key: "⌘⇧[", description: "Previous tab", category: "navigation")
                    ]
                ),
                ShortcutGroup(
                    title: "Bookmarks",
                    shortcuts: [
                        Shortcut(key: "⌘D", description: "Add bookmark", category: "bookmarks"),
                        Shortcut(key: "⌘⌥B", description: "Show bookmarks", category: "bookmarks"),
                        Shortcut(key: "⌘⇧B", description: "Show bookmarks bar", category: "bookmarks"),
                        Shortcut(key: "⌘⌥1", description: "Show favorites", category: "bookmarks")
                    ]
                ),
                ShortcutGroup(
                    title: "Search & Find",
                    shortcuts: [
                        Shortcut(key: "⌘F", description: "Find on page", category: "search"),
                        Shortcut(key: "⌘G", description: "Find next", category: "search"),
                        Shortcut(key: "⌘⇧G", description: "Find previous", category: "search"),
                        Shortcut(key: "⌘E", description: "Use selection for find", category: "search")
                    ]
                ),
                ShortcutGroup(
                    title: "View",
                    shortcuts: [
                        Shortcut(key: "⌘+", description: "Zoom in", category: "view"),
                        Shortcut(key: "⌘-", description: "Zoom out", category: "view"),
                        Shortcut(key: "⌘0", description: "Actual size", category: "view"),
                        Shortcut(key: "⌘⇧R", description: "Reader view", category: "view"),
                        Shortcut(key: "⌃⌘F", description: "Enter full screen", category: "view")
                    ]
                ),
                ShortcutGroup(
                    title: "Developer",
                    shortcuts: [
                        Shortcut(key: "⌘⌥I", description: "Web Inspector", category: "developer"),
                        Shortcut(key: "⌘⌥C", description: "Console", category: "developer"),
                        Shortcut(key: "⌘⌥U", description: "View Source", category: "developer"),
                        Shortcut(key: "⌘⌥J", description: "JavaScript Console", category: "developer")
                    ]
                ),
                ShortcutGroup(
                    title: "History",
                    shortcuts: [
                        Shortcut(key: "⌘Y", description: "Show history", category: "history"),
                        Shortcut(key: "⌘⇧⌫", description: "Clear history", category: "history")
                    ]
                )
            ]
        )
        
        shortcuts[safariShortcuts.applicationId] = safariShortcuts
    }
    
    private func loadChromeShortcuts() {
        let chromeShortcuts = ApplicationShortcuts(
            applicationId: "com.google.Chrome",
            applicationName: "Google Chrome",
            version: "1.0",
            groups: [
                ShortcutGroup(
                    title: "File",
                    shortcuts: [
                        Shortcut(key: "⌘T", description: "New Tab", category: "file"),
                        Shortcut(key: "⌘N", description: "New Window", category: "file"),
                        Shortcut(key: "⌘⇧N", description: "New Incognito Window", category: "file"),
                        Shortcut(key: "⌘⇧T", description: "Re-open Closed Tab", category: "file"),
                        Shortcut(key: "⌘O", description: "Open File...", category: "file"),
                        Shortcut(key: "⌘L", description: "Open Location...", category: "file"),
                        Shortcut(key: "⌘W", description: "Close Window", category: "file"),
                        Shortcut(key: "⌘⇧W", description: "Close All", category: "file"),
                        Shortcut(key: "⌘W", description: "Close Tab", category: "file"),
                        Shortcut(key: "⌘S", description: "Save Page As...", category: "file"),
                        Shortcut(key: "⌘P", description: "Print...", category: "file"),
                        Shortcut(key: "⌘⇧P", description: "Print Using System Dial...", category: "file")
                    ]
                ),
                ShortcutGroup(
                    title: "Edit",
                    shortcuts: [
                        Shortcut(key: "⌘Z", description: "Undo", category: "edit"),
                        Shortcut(key: "⌘⇧Z", description: "Redo", category: "edit"),
                        Shortcut(key: "⌘X", description: "Cut", category: "edit"),
                        Shortcut(key: "⌘C", description: "Copy", category: "edit"),
                        Shortcut(key: "⌘V", description: "Paste", category: "edit"),
                        Shortcut(key: "⌘⇧V", description: "Paste and Match Style", category: "edit"),
                        Shortcut(key: "⌘⌥V", description: "Paste and Match Style", category: "edit"),
                        Shortcut(key: "⌘A", description: "Select All", category: "edit"),
                        Shortcut(key: "⌥E", description: "Emoji & Symbols", category: "edit")
                    ]
                ),
                ShortcutGroup(
                    title: "View",
                    shortcuts: [
                        Shortcut(key: "⌘R", description: "Reload This Page", category: "view"),
                        Shortcut(key: "⌘⇧R", description: "Force Reload This Page", category: "view"),
                        Shortcut(key: "⌃F", description: "Enter Full Screen", category: "view"),
                        Shortcut(key: "⌃F", description: "Enter Full Screen", category: "view"),
                        Shortcut(key: "⌘0", description: "Actual Size", category: "view"),
                        Shortcut(key: "⌘+", description: "Zoom In", category: "view"),
                        Shortcut(key: "⌘-", description: "Zoom Out", category: "view")
                    ]
                ),
                ShortcutGroup(
                    title: "History",
                    shortcuts: [
                        Shortcut(key: "⌘H", description: "Home", category: "history"),
                        Shortcut(key: "⌘[", description: "Back", category: "history"),
                        Shortcut(key: "⌘]", description: "Forward", category: "history"),
                        Shortcut(key: "⌘Y", description: "Show full history", category: "history")
                    ]
                ),
                ShortcutGroup(
                    title: "Bookmarks",
                    shortcuts: [
                        Shortcut(key: "⌘⇧B", description: "Bookmark Manager", category: "bookmarks"),
                        Shortcut(key: "⌘D", description: "Bookmark This Tab...", category: "bookmarks"),
                        Shortcut(key: "⌘⇧D", description: "Bookmark All Tabs...", category: "bookmarks")
                    ]
                ),
                ShortcutGroup(
                    title: "Tab",
                    shortcuts: [
                        Shortcut(key: "⌘⇧]", description: "Select Next Tab", category: "tab"),
                        Shortcut(key: "⌘⇧[", description: "Select Previous Tab", category: "tab"),
                        Shortcut(key: "⌘⇧D", description: "Duplicate tab", category: "tab"),
                        Shortcut(key: "⌘⇧A", description: "Search Tabs...", category: "tab")
                    ]
                ),
                ShortcutGroup(
                    title: "Window",
                    shortcuts: [
                        Shortcut(key: "⌘M", description: "Minimise", category: "window"),
                        Shortcut(key: "⌘⇧M", description: "Minimise All", category: "window"),
                        Shortcut(key: "⌘⇧J", description: "Downloads", category: "window")
                    ]
                ),
                ShortcutGroup(
                    title: "Developer",
                    shortcuts: [
                        Shortcut(key: "⌘⇧U", description: "View Source", category: "developer"),
                        Shortcut(key: "⌘⇧I", description: "Developer Tools", category: "developer"),
                        Shortcut(key: "⌘⇧C", description: "Inspect elements", category: "developer"),
                        Shortcut(key: "⌘⇧J", description: "JavaScript Console", category: "developer")
                    ]
                )
            ]
        )
        
        shortcuts[chromeShortcuts.applicationId] = chromeShortcuts
    }
}