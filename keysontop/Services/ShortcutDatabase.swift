import Foundation

class ShortcutDatabase: ObservableObject {
    @Published var shortcuts: [String: ApplicationShortcuts] = [:]
    
    private let documentsDirectory: URL
    
    init() {
        documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        loadBuiltInShortcuts()
        loadSavedShortcuts()
    }
    
    func loadShortcuts(for bundleId: String) -> [ShortcutGroup]? {
        let lowercaseBundleId = bundleId.lowercased()
        print("🔍 Looking for: '\(bundleId)' (lowercase: '\(lowercaseBundleId)')")
        
        for (key, value) in shortcuts {
            let lowercaseKey = key.lowercased()
            print("🔑 Checking: '\(key)' (lowercase: '\(lowercaseKey)')")
            if lowercaseKey == lowercaseBundleId {
                print("✅ Match found! Returning \(value.groups.count) groups")
                return value.groups
            }
        }
        print("❌ No match found")
        return nil
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
    
    func deleteShortcuts(for bundleId: String) throws {
        // Remove from memory
        shortcuts.removeValue(forKey: bundleId)
        
        // Remove from disk
        let filename = "\(bundleId).json"
        let fileURL = documentsDirectory.appendingPathComponent("KeysOnTop").appendingPathComponent(filename)
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            try FileManager.default.removeItem(at: fileURL)
        }
    }
    
    func isBuiltInApp(_ bundleId: String) -> Bool {
        // Built-in apps that come with the app
        let builtInApps = [
            "com.apple.finder",
            "com.apple.Safari", 
            "com.google.Chrome"
        ]
        return builtInApps.contains(bundleId)
    }
    
    func printDebugInfo() {
        print("📊 Shortcuts Database Contents:")
        for (bundleId, appShortcuts) in shortcuts {
            print("  🍃 \(bundleId) → \(appShortcuts.applicationName) (\(appShortcuts.groups.count) groups)")
        }
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
                    category: "navigation",
                    shortcuts: [
                        Shortcut(key: "⌘L", description: "Focus address bar"),
                        Shortcut(key: "⌘R", description: "Reload page"),
                        Shortcut(key: "⌘[", description: "Go back"),
                        Shortcut(key: "⌘]", description: "Go forward"),
                        Shortcut(key: "⌘T", description: "New tab"),
                        Shortcut(key: "⌘W", description: "Close tab"),
                        Shortcut(key: "⌘⇧T", description: "Reopen closed tab"),
                        Shortcut(key: "⌘⇧]", description: "Next tab"),
                        Shortcut(key: "⌘⇧[", description: "Previous tab")
                    ]
                ),
                ShortcutGroup(
                    title: "Bookmarks",
                    category: "bookmarks",
                    shortcuts: [
                        Shortcut(key: "⌘D", description: "Add bookmark"),
                        Shortcut(key: "⌘⌥B", description: "Show bookmarks"),
                        Shortcut(key: "⌘⇧B", description: "Show bookmarks bar"),
                        Shortcut(key: "⌘⌥1", description: "Show favorites")
                    ]
                ),
                ShortcutGroup(
                    title: "Search & Find",
                    category: "search",
                    shortcuts: [
                        Shortcut(key: "⌘F", description: "Find on page"),
                        Shortcut(key: "⌘G", description: "Find next"),
                        Shortcut(key: "⌘⇧G", description: "Find previous"),
                        Shortcut(key: "⌘E", description: "Use selection for find")
                    ]
                ),
                ShortcutGroup(
                    title: "View",
                    category: "view",
                    shortcuts: [
                        Shortcut(key: "⌘+", description: "Zoom in"),
                        Shortcut(key: "⌘-", description: "Zoom out"),
                        Shortcut(key: "⌘0", description: "Actual size"),
                        Shortcut(key: "⌘⇧R", description: "Reader view"),
                        Shortcut(key: "⌃⌘F", description: "Enter full screen")
                    ]
                ),
                ShortcutGroup(
                    title: "Developer",
                    category: "developer",
                    shortcuts: [
                        Shortcut(key: "⌘⌥I", description: "Web Inspector"),
                        Shortcut(key: "⌘⌥C", description: "Console"),
                        Shortcut(key: "⌘⌥U", description: "View Source"),
                        Shortcut(key: "⌘⌥J", description: "JavaScript Console")
                    ]
                ),
                ShortcutGroup(
                    title: "History",
                    category: "history",
                    shortcuts: [
                        Shortcut(key: "⌘Y", description: "Show history"),
                        Shortcut(key: "⌘⇧⌫", description: "Clear history")
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
                    category: "file",
                    shortcuts: [
                        Shortcut(key: "⌘T", description: "New Tab"),
                        Shortcut(key: "⌘N", description: "New Window"),
                        Shortcut(key: "⌘⇧N", description: "New Incognito Window"),
                        Shortcut(key: "⌘⇧T", description: "Re-open Closed Tab"),
                        Shortcut(key: "⌘O", description: "Open File..."),
                        Shortcut(key: "⌘L", description: "Open Location..."),
                        Shortcut(key: "⌘W", description: "Close Tab"),
                        Shortcut(key: "⌘⇧W", description: "Close All"),
                        Shortcut(key: "⌘S", description: "Save Page As..."),
                        Shortcut(key: "⌘P", description: "Print...")
                    ]
                ),
                ShortcutGroup(
                    title: "Edit",
                    category: "edit",
                    shortcuts: [
                        Shortcut(key: "⌘Z", description: "Undo"),
                        Shortcut(key: "⌘⇧Z", description: "Redo"),
                        Shortcut(key: "⌘X", description: "Cut"),
                        Shortcut(key: "⌘C", description: "Copy"),
                        Shortcut(key: "⌘V", description: "Paste"),
                        Shortcut(key: "⌘⇧V", description: "Paste and Match Style"),
                        Shortcut(key: "⌘A", description: "Select All")
                    ]
                ),
                ShortcutGroup(
                    title: "View",
                    category: "view",
                    shortcuts: [
                        Shortcut(key: "⌘R", description: "Reload This Page"),
                        Shortcut(key: "⌘⇧R", description: "Force Reload This Page"),
                        Shortcut(key: "⌃F", description: "Enter Full Screen"),
                        Shortcut(key: "⌘0", description: "Actual Size"),
                        Shortcut(key: "⌘+", description: "Zoom In"),
                        Shortcut(key: "⌘-", description: "Zoom Out")
                    ]
                ),
                ShortcutGroup(
                    title: "History",
                    category: "history",
                    shortcuts: [
                        Shortcut(key: "⌘H", description: "Home"),
                        Shortcut(key: "⌘[", description: "Back"),
                        Shortcut(key: "⌘]", description: "Forward"),
                        Shortcut(key: "⌘Y", description: "Show full history")
                    ]
                ),
                ShortcutGroup(
                    title: "Bookmarks",
                    category: "bookmarks",
                    shortcuts: [
                        Shortcut(key: "⌘⇧B", description: "Bookmark Manager"),
                        Shortcut(key: "⌘D", description: "Bookmark This Tab..."),
                        Shortcut(key: "⌘⇧D", description: "Bookmark All Tabs...")
                    ]
                ),
                ShortcutGroup(
                    title: "Tab",
                    category: "tab",
                    shortcuts: [
                        Shortcut(key: "⌘⇧]", description: "Select Next Tab"),
                        Shortcut(key: "⌘⇧[", description: "Select Previous Tab"),
                        Shortcut(key: "⌘⇧A", description: "Search Tabs...")
                    ]
                ),
                ShortcutGroup(
                    title: "Window",
                    category: "window",
                    shortcuts: [
                        Shortcut(key: "⌘M", description: "Minimise"),
                        Shortcut(key: "⌘⇧M", description: "Minimise All"),
                        Shortcut(key: "⌘⇧J", description: "Downloads")
                    ]
                ),
                ShortcutGroup(
                    title: "Developer",
                    category: "developer",
                    shortcuts: [
                        Shortcut(key: "⌘⇧U", description: "View Source"),
                        Shortcut(key: "⌘⇧I", description: "Developer Tools"),
                        Shortcut(key: "⌘⇧C", description: "Inspect elements"),
                        Shortcut(key: "⌘⇧J", description: "JavaScript Console")
                    ]
                )
            ]
        )
        
        shortcuts[chromeShortcuts.applicationId] = chromeShortcuts
    }
    
    private func loadSavedShortcuts() {
        let keysOnTopDirectory = documentsDirectory.appendingPathComponent("KeysOnTop")
        
        // Check if directory exists
        guard FileManager.default.fileExists(atPath: keysOnTopDirectory.path) else {
            return
        }
        
        do {
            // Get all JSON files in the directory
            let files = try FileManager.default.contentsOfDirectory(at: keysOnTopDirectory, includingPropertiesForKeys: nil)
            let jsonFiles = files.filter { $0.pathExtension == "json" }
            
            // Load each JSON file
            for fileURL in jsonFiles {
                do {
                    let data = try Data(contentsOf: fileURL)
                    let decoder = JSONDecoder()
                    let applicationShortcuts = try decoder.decode(ApplicationShortcuts.self, from: data)
                    
                    // Add to shortcuts dictionary (this will override built-in shortcuts if same app ID)
                    shortcuts[applicationShortcuts.applicationId] = applicationShortcuts
                    
                    print("Loaded shortcuts for: \(applicationShortcuts.applicationName)")
                } catch {
                    print("Failed to load shortcuts from \(fileURL.lastPathComponent): \(error)")
                }
            }
        } catch {
            print("Failed to read KeysOnTop directory: \(error)")
        }
    }
}