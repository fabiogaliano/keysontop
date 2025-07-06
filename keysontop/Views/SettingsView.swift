import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var overlayController: OverlayController
    @EnvironmentObject private var permissionsManager: PermissionsManager
    @StateObject private var shortcutConfigManager = ShortcutConfigManager()
    @State private var selectedTab: Int = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom tab bar
            HStack(spacing: 0) {
                TabButton(title: "General", icon: "gear", isSelected: selectedTab == 0) {
                    selectedTab = 0
                }
                TabButton(title: "Permissions", icon: "lock.shield", isSelected: selectedTab == 1) {
                    selectedTab = 1
                }
                TabButton(title: "Shortcuts", icon: "keyboard", isSelected: selectedTab == 2) {
                    selectedTab = 2
                }
                TabButton(title: "JSON Guide", icon: "doc.text", isSelected: selectedTab == 3) {
                    selectedTab = 3
                }
            }
            .background(.regularMaterial)
            
            Divider()
            
            // Content area
            Group {
                switch selectedTab {
                case 0:
                    GeneralSettingsView(shortcutConfigManager: shortcutConfigManager)
                case 1:
                    PermissionsSettingsView()
                case 2:
                    ShortcutsManagementView()
                case 3:
                    JSONFormatGuideView()
                default:
                    GeneralSettingsView(shortcutConfigManager: shortcutConfigManager)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(minWidth: 600, idealWidth: 700, maxWidth: 1000, minHeight: 500, idealHeight: 600, maxHeight: 800)
    }
}

struct GeneralSettingsView: View {
    @ObservedObject var shortcutConfigManager: ShortcutConfigManager
    @State private var showingShortcutConfig = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("General Settings")
                .font(.title2)
                .fontWeight(.bold)
            
            GroupBox("Global Hotkey") {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Current shortcut:")
                        
                        Button(action: { showingShortcutConfig = true }) {
                            Text(shortcutConfigManager.globalShortcut)
                                .font(.system(.body, design: .monospaced))
                                .fontWeight(.bold)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.blue.opacity(0.2))
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                        .buttonStyle(.plain)
                        
                        Spacer()
                        
                        Button("Configure") {
                            showingShortcutConfig = true
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    Text("Click the shortcut or Configure button to change the global hotkey.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
            
            GroupBox("Overlay Behavior") {
                VStack(alignment: .leading, spacing: 12) {
                    Toggle("Stay on top of all windows", isOn: .constant(true))
                        .disabled(true)
                    
                    Toggle("Show across all spaces", isOn: .constant(true))
                        .disabled(true)
                    
                    Text("These settings ensure the overlay remains visible and accessible.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
            
            Spacer()
        }
        .padding()
        .sheet(isPresented: $showingShortcutConfig) {
            ShortcutConfigView(
                shortcutKey: $shortcutConfigManager.globalShortcut,
                onSave: { newShortcut in
                    shortcutConfigManager.saveShortcut(newShortcut)
                    showingShortcutConfig = false
                }
            )
            .frame(width: 400, height: 350)
        }
    }
}

struct PermissionsSettingsView: View {
    @EnvironmentObject private var permissionsManager: PermissionsManager
    @State private var permissionCheckTimer: Timer?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Permissions")
                .font(.title2)
                .fontWeight(.bold)
            
            GroupBox("Accessibility Permissions") {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: permissionsManager.hasAccessibilityPermissions ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                            .foregroundColor(permissionsManager.hasAccessibilityPermissions ? .green : .orange)
                            .font(.title2)
                        
                        VStack(alignment: .leading) {
                            Text("Accessibility Access")
                                .font(.headline)
                            
                            Text(permissionsManager.hasAccessibilityPermissions ? 
                                 "✓ Granted - Global hotkeys are working" : 
                                 "⚠ Required for global hotkey monitoring")
                                .font(.subheadline)
                                .foregroundColor(permissionsManager.hasAccessibilityPermissions ? .green : .orange)
                        }
                        
                        Spacer()
                        
                        if !permissionsManager.hasAccessibilityPermissions {
                            Button("Grant Access") {
                                permissionsManager.requestAccessibilityPermissions()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    
                    if !permissionsManager.hasAccessibilityPermissions {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("To enable global hotkeys:")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            Text("1. Click 'Grant Access' above")
                            Text("2. In System Preferences, go to Security & Privacy")
                            Text("3. Click the Privacy tab")
                            Text("4. Select Accessibility from the list")
                            Text("5. Check the box next to KeysOnTop")
                            
                            Button("Open System Preferences") {
                                permissionsManager.openSystemPreferences()
                            }
                            .buttonStyle(.bordered)
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                    }
                }
                .padding()
            }
            
            Spacer()
        }
        .padding()
        .onAppear {
            permissionsManager.checkPermissions()
            // Set up periodic permission checking
            permissionCheckTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
                permissionsManager.checkPermissions()
            }
        }
        .onDisappear {
            permissionCheckTimer?.invalidate()
            permissionCheckTimer = nil
        }
    }
}

struct ShortcutsManagementView: View {
    @StateObject private var shortcutDatabase = ShortcutDatabase()
    @State private var selectedApp: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Shortcuts Database")
                .font(.title2)
                .fontWeight(.bold)
            
            HStack {
                // App list
                VStack(alignment: .leading) {
                    Text("Applications")
                        .font(.headline)
                    
                    List(Array(shortcutDatabase.shortcuts.keys), id: \.self, selection: $selectedApp) { bundleId in
                        if let appShortcuts = shortcutDatabase.shortcuts[bundleId] {
                            VStack(alignment: .leading) {
                                Text(appShortcuts.applicationName)
                                    .font(.subheadline)
                                Text(bundleId)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .frame(minWidth: 200)
                }
                
                Divider()
                
                // Shortcut details
                VStack(alignment: .leading) {
                    if let selectedApp = selectedApp,
                       let appShortcuts = shortcutDatabase.shortcuts[selectedApp] {
                        Text(appShortcuts.applicationName)
                            .font(.headline)
                        
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 12) {
                                ForEach(appShortcuts.groups) { group in
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(group.title)
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                        
                                        ForEach(group.shortcuts) { shortcut in
                                            HStack {
                                                Text(shortcut.key)
                                                    .font(.system(.caption, design: .monospaced))
                                                    .padding(.horizontal, 6)
                                                    .padding(.vertical, 2)
                                                    .background(Color.gray.opacity(0.2))
                                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                                                
                                                Text(shortcut.description)
                                                    .font(.caption)
                                                
                                                Spacer()
                                            }
                                        }
                                    }
                                    .padding(.bottom, 8)
                                }
                            }
                        }
                    } else {
                        Text("Select an application to view its shortcuts")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            
            HStack {
                Button("Import Shortcuts...") {
                    // File import functionality
                    let panel = NSOpenPanel()
                    panel.allowedContentTypes = [.json]
                    panel.allowsMultipleSelection = false
                    
                    if panel.runModal() == .OK, let url = panel.url {
                        do {
                            try shortcutDatabase.importShortcuts(from: url)
                        } catch {
                            print("Failed to import shortcuts: \(error)")
                        }
                    }
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Text("\(shortcutDatabase.shortcuts.count) applications")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
}

struct JSONFormatGuideView: View {
    @State private var selectedExample = 0
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
            Text("JSON Format Guide")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Create custom shortcut files to import into KeysOnTop. Copy the JSON format below and modify it for your applications.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // Example selector
            Picker("Example", selection: $selectedExample) {
                Text("Basic Application").tag(0)
                Text("Complex Application").tag(1)
                Text("Developer Tools").tag(2)
            }
            .pickerStyle(.segmented)
            
            // JSON Example
            GroupBox("JSON Format") {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Example JSON:")
                                .font(.headline)
                            
                            Spacer()
                            
                            Button("Copy to Clipboard") {
                                copyJSONToClipboard()
                            }
                            .buttonStyle(.bordered)
                        }
                        
                        Text(jsonExample)
                            .font(.system(.body, design: .monospaced))
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.quaternary)
                            )
                            .textSelection(.enabled)
                    }
                }
                .frame(minHeight: 200, maxHeight: 400)
            }
            
            // Symbol Guide
            GroupBox("Keyboard Symbols") {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 8) {
                    SymbolRow(symbol: "⌘", description: "Command")
                    SymbolRow(symbol: "⌥", description: "Option")
                    SymbolRow(symbol: "⇧", description: "Shift")
                    SymbolRow(symbol: "⌃", description: "Control")
                    SymbolRow(symbol: "⎋", description: "Escape")
                    SymbolRow(symbol: "⌫", description: "Delete")
                    SymbolRow(symbol: "⌦", description: "Forward Delete")
                    SymbolRow(symbol: "↩", description: "Return")
                    SymbolRow(symbol: "↑↓←→", description: "Arrows")
                    SymbolRow(symbol: "⇥", description: "Tab")
                    SymbolRow(symbol: "Space", description: "Space")
                    SymbolRow(symbol: "F1-F12", description: "Function Keys")
                }
                .padding()
            }
            
            // Instructions
            GroupBox("How to Import") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("1. Copy the JSON format above")
                    Text("2. Modify the applicationId, applicationName, and shortcuts")
                    Text("3. Save as a .json file")
                    Text("4. Go to Shortcuts tab and click 'Import Shortcuts...'")
                    Text("5. Select your JSON file")
                }
                .font(.subheadline)
                .padding()
            }
            
            }
            .padding()
        }
    }
    
    private var jsonExample: String {
        switch selectedExample {
        case 0:
            return basicApplicationJSON
        case 1:
            return complexApplicationJSON
        case 2:
            return developerToolsJSON
        default:
            return basicApplicationJSON
        }
    }
    
    private func copyJSONToClipboard() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(jsonExample, forType: .string)
        
        // Show temporary feedback
        // You could add a toast notification here
    }
    
    private var basicApplicationJSON: String {
        """
{
  "applicationId": "com.example.myapp",
  "applicationName": "My Application",
  "version": "1.0",
  "groups": [
    {
      "title": "File Operations",
      "shortcuts": [
        {
          "key": "⌘N",
          "description": "New document",
          "category": "file"
        },
        {
          "key": "⌘O",
          "description": "Open document",
          "category": "file"
        },
        {
          "key": "⌘S",
          "description": "Save document",
          "category": "file"
        }
      ]
    },
    {
      "title": "Edit Operations",
      "shortcuts": [
        {
          "key": "⌘Z",
          "description": "Undo",
          "category": "edit"
        },
        {
          "key": "⌘⇧Z",
          "description": "Redo",
          "category": "edit"
        }
      ]
    }
  ]
}
"""
    }
    
    private var complexApplicationJSON: String {
        """
{
  "applicationId": "com.adobe.photoshop",
  "applicationName": "Adobe Photoshop",
  "version": "1.0",
  "groups": [
    {
      "title": "Tools",
      "shortcuts": [
        {
          "key": "V",
          "description": "Move tool",
          "category": "tool"
        },
        {
          "key": "B",
          "description": "Brush tool",
          "category": "tool"
        },
        {
          "key": "E",
          "description": "Eraser tool",
          "category": "tool"
        }
      ]
    },
    {
      "title": "Layers",
      "shortcuts": [
        {
          "key": "⌘⇧N",
          "description": "New layer",
          "category": "layer"
        },
        {
          "key": "⌘J",
          "description": "Duplicate layer",
          "category": "layer"
        },
        {
          "key": "⌘E",
          "description": "Merge down",
          "category": "layer"
        }
      ]
    },
    {
      "title": "View",
      "shortcuts": [
        {
          "key": "⌘0",
          "description": "Fit to screen",
          "category": "view"
        },
        {
          "key": "⌘+",
          "description": "Zoom in",
          "category": "view"
        },
        {
          "key": "⌘-",
          "description": "Zoom out",
          "category": "view"
        }
      ]
    }
  ]
}
"""
    }
    
    private var developerToolsJSON: String {
        """
{
  "applicationId": "com.microsoft.VSCode",
  "applicationName": "Visual Studio Code",
  "version": "1.0",
  "groups": [
    {
      "title": "Navigation",
      "shortcuts": [
        {
          "key": "⌘P",
          "description": "Quick open file",
          "category": "navigation"
        },
        {
          "key": "⌘⇧P",
          "description": "Command palette",
          "category": "navigation"
        },
        {
          "key": "⌘B",
          "description": "Toggle sidebar",
          "category": "navigation"
        }
      ]
    },
    {
      "title": "Editing",
      "shortcuts": [
        {
          "key": "⌘D",
          "description": "Select next occurrence",
          "category": "edit"
        },
        {
          "key": "⌥↑",
          "description": "Move line up",
          "category": "edit"
        },
        {
          "key": "⌥↓",
          "description": "Move line down",
          "category": "edit"
        }
      ]
    },
    {
      "title": "Debug",
      "shortcuts": [
        {
          "key": "F5",
          "description": "Start debugging",
          "category": "debug"
        },
        {
          "key": "F9",
          "description": "Toggle breakpoint",
          "category": "debug"
        },
        {
          "key": "F10",
          "description": "Step over",
          "category": "debug"
        }
      ]
    }
  ]
}
"""
    }
}

struct SymbolRow: View {
    let symbol: String
    let description: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(symbol)
                .font(.system(.body, design: .monospaced))
                .fontWeight(.bold)
            
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
    }
}

extension Notification.Name {
    static let showSettings = Notification.Name("showSettings")
}

#Preview {
    SettingsView()
        .environmentObject(OverlayController())
        .environmentObject(PermissionsManager())
}