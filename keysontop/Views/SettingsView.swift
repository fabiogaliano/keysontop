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
                                _ = permissionsManager.requestAccessibilityPermissions()
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
    @EnvironmentObject private var overlayController: OverlayController
    @State private var selectedApp: String?
    @State private var showingJSONInput = false
    @State private var editingApp: String? = nil
    
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
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(appShortcuts.applicationName)
                                        .font(.subheadline)
                                    Text(bundleId)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                // Show edit and delete buttons only for imported (non-built-in) apps
                                if !shortcutDatabase.isBuiltInApp(bundleId) {
                                    Button(action: {
                                        editingApp = bundleId
                                    }) {
                                        Image(systemName: "pencil")
                                            .foregroundColor(.blue)
                                    }
                                    .buttonStyle(.plain)
                                    .help("Edit shortcuts JSON")
                                    
                                    Button(action: {
                                        deleteApp(bundleId)
                                    }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                    }
                                    .buttonStyle(.plain)
                                    .help("Delete imported shortcuts")
                                }
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
                Button("Import from File...") {
                    // File import functionality
                    let panel = NSOpenPanel()
                    panel.allowedContentTypes = [.json]
                    panel.allowsMultipleSelection = false
                    
                    if panel.runModal() == .OK, let url = panel.url {
                        do {
                            try shortcutDatabase.importShortcuts(from: url)
                            overlayController.refreshCurrentShortcuts()
                        } catch {
                            print("Failed to import shortcuts: \(error)")
                        }
                    }
                }
                .buttonStyle(.bordered)
                
                Button("Import from JSON...") {
                    showingJSONInput = true
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Text("\(shortcutDatabase.shortcuts.count) applications")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .sheet(isPresented: $showingJSONInput) {
            JSONInputView(shortcutDatabase: shortcutDatabase)
        }
        .sheet(isPresented: .constant(editingApp != nil)) {
            if let bundleId = editingApp {
                JSONEditView(
                    shortcutDatabase: shortcutDatabase,
                    bundleId: bundleId,
                    onDismiss: { editingApp = nil }
                )
            }
        }
    }
    
    private func deleteApp(_ bundleId: String) {
        do {
            try shortcutDatabase.deleteShortcuts(for: bundleId)
            
            // Clear selection if we deleted the selected app
            if selectedApp == bundleId {
                selectedApp = nil
            }
            
            // Refresh overlay controller
            overlayController.refreshCurrentShortcuts()
            
        } catch {
            print("Failed to delete shortcuts for \(bundleId): \(error)")
        }
    }
}

struct JSONInputView: View {
    @ObservedObject var shortcutDatabase: ShortcutDatabase
    @EnvironmentObject private var overlayController: OverlayController
    @Environment(\.dismiss) private var dismiss
    @State private var jsonText = ""
    @State private var validationMessage = ""
    @State private var isValid = false
    @State private var importSuccess = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom header with buttons
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Text("Import JSON")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Import") {
                    importJSON()
                }
                .disabled(jsonText.isEmpty || !isValid)
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(.regularMaterial)
            
            Divider()
            
            VStack(alignment: .leading, spacing: 20) {
                Text("Import Shortcuts from JSON")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Paste your JSON shortcut data below. The format must match the expected structure.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                GroupBox("JSON Input") {
                    VStack(alignment: .leading, spacing: 12) {
                        ScrollView {
                            TextEditor(text: $jsonText)
                                .font(.system(.body, design: .monospaced))
                                .frame(minHeight: 200)
                        }
                        .frame(maxHeight: 300)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(.quaternary)
                        )
                        
                        if !validationMessage.isEmpty {
                            HStack {
                                Image(systemName: isValid ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                                    .foregroundColor(isValid ? .green : .orange)
                                Text(validationMessage)
                                    .font(.caption)
                                    .foregroundColor(isValid ? .green : .orange)
                            }
                        }
                    }
                    .padding()
                }
                
                if importSuccess {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Shortcuts imported successfully!")
                            .font(.subheadline)
                            .foregroundColor(.green)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.green.opacity(0.1))
                    )
                }
                
                Spacer()
            }
            .padding()
        }
        .frame(width: 600, height: 500)
        .onChange(of: jsonText) {
            validateJSON()
        }
    }
    
    private func validateJSON() {
        guard !jsonText.isEmpty else {
            validationMessage = ""
            isValid = false
            return
        }
        
        // Clean the JSON text first
        let cleanedJsonText = jsonText
            .replacingOccurrences(of: "\u{201C}", with: "\"")  // Replace left double quote
            .replacingOccurrences(of: "\u{201D}", with: "\"")  // Replace right double quote
            .replacingOccurrences(of: "\u{2012}", with: "-")   // Replace en dash with regular dash
            .replacingOccurrences(of: "\u{2014}", with: "-")   // Replace em dash with regular dash
        
        guard let jsonData = cleanedJsonText.data(using: .utf8) else {
            validationMessage = "Cannot convert text to data - check for invalid characters"
            isValid = false
            return
        }
        
        // First check if it's valid JSON at all
        do {
            _ = try JSONSerialization.jsonObject(with: jsonData)
        } catch {
            validationMessage = "Invalid JSON syntax: \(error.localizedDescription)"
            isValid = false
            return
        }
        
        do {
            let decoder = JSONDecoder()
            let applicationShortcuts = try decoder.decode(ApplicationShortcuts.self, from: jsonData)
            
            // Validate required fields
            if applicationShortcuts.applicationId.isEmpty {
                validationMessage = "Missing required field: applicationId"
                isValid = false
                return
            }
            
            if applicationShortcuts.applicationName.isEmpty {
                validationMessage = "Missing required field: applicationName"
                isValid = false
                return
            }
            
            if applicationShortcuts.groups.isEmpty {
                validationMessage = "At least one group is required"
                isValid = false
                return
            }
            
            // Validate each group and shortcut
            for group in applicationShortcuts.groups {
                if group.title.isEmpty {
                    validationMessage = "Group title is required"
                    isValid = false
                    return
                }
                
                if group.shortcuts.isEmpty {
                    validationMessage = "Each group must have at least one shortcut"
                    isValid = false
                    return
                }
                
                for shortcut in group.shortcuts {
                    if shortcut.key.isEmpty {
                        validationMessage = "Shortcut key is required"
                        isValid = false
                        return
                    }
                    
                    if shortcut.description.isEmpty {
                        validationMessage = "Shortcut description is required"
                        isValid = false
                        return
                    }
                }
            }
            
            validationMessage = "JSON is valid and ready to import"
            isValid = true
            
        } catch {
            if let decodingError = error as? DecodingError {
                switch decodingError {
                case .dataCorrupted(let context):
                    validationMessage = "Invalid JSON format: \(context.debugDescription)"
                case .keyNotFound(let key, let context):
                    validationMessage = "Missing required field '\(key.stringValue)' at \(context.codingPath.map(\.stringValue).joined(separator: "."))"
                case .typeMismatch(let type, let context):
                    validationMessage = "Type mismatch: expected \(type) at \(context.codingPath.map(\.stringValue).joined(separator: "."))"
                case .valueNotFound(let type, let context):
                    validationMessage = "Missing value: expected \(type) at \(context.codingPath.map(\.stringValue).joined(separator: "."))"
                @unknown default:
                    validationMessage = "JSON decoding error: \(error.localizedDescription)"
                }
            } else {
                validationMessage = "Invalid JSON format: \(error.localizedDescription)"
            }
            isValid = false
        }
    }
    
    private func importJSON() {
        guard isValid else { return }
        
        do {
            // Use the same cleaning logic as validation
            let cleanedJsonText = jsonText
                .replacingOccurrences(of: "\u{201C}", with: "\"")  // Replace left double quote
                .replacingOccurrences(of: "\u{201D}", with: "\"")  // Replace right double quote
                .replacingOccurrences(of: "\u{2012}", with: "-")   // Replace en dash with regular dash
                .replacingOccurrences(of: "\u{2014}", with: "-")   // Replace em dash with regular dash
            
            guard let jsonData = cleanedJsonText.data(using: .utf8) else {
                validationMessage = "Cannot convert text to data"
                isValid = false
                return
            }
            
            // Use the database's import method which handles both memory and disk persistence
            try shortcutDatabase.importShortcuts(from: jsonData)
            
            // Refresh the overlay controller so it picks up new shortcuts immediately
            overlayController.refreshCurrentShortcuts()
            
            importSuccess = true
            
            // Close after a brief delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                dismiss()
            }
            
        } catch {
            validationMessage = "Import failed: \(error.localizedDescription)"
            isValid = false
        }
    }
}

struct JSONEditView: View {
    @ObservedObject var shortcutDatabase: ShortcutDatabase
    @EnvironmentObject private var overlayController: OverlayController
    let bundleId: String
    let onDismiss: () -> Void
    
    @State private var jsonText = ""
    @State private var validationMessage = ""
    @State private var isValid = false
    @State private var saveSuccess = false
    @State private var isLoading = true
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom header with buttons
            HStack {
                Button("Cancel") {
                    onDismiss()
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Text("Edit JSON")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Save") {
                    saveJSON()
                }
                .disabled(jsonText.isEmpty || !isValid)
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(.regularMaterial)
            
            Divider()
            
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text("Edit shortcuts for")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    if let appShortcuts = shortcutDatabase.shortcuts[bundleId] {
                        Text(appShortcuts.applicationName)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                }
                
                Text("Modify the JSON below to update the shortcuts configuration.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                GroupBox("JSON Editor") {
                    VStack(alignment: .leading, spacing: 12) {
                        if isLoading {
                            ProgressView("Loading...")
                                .frame(maxWidth: .infinity, minHeight: 200)
                        } else {
                            ScrollView {
                                TextEditor(text: $jsonText)
                                    .font(.system(.body, design: .monospaced))
                                    .frame(minHeight: 300)
                            }
                            .frame(maxHeight: 400)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(.quaternary)
                            )
                        }
                        
                        if !validationMessage.isEmpty {
                            HStack {
                                Image(systemName: isValid ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                                    .foregroundColor(isValid ? .green : .orange)
                                Text(validationMessage)
                                    .font(.caption)
                                    .foregroundColor(isValid ? .green : .orange)
                            }
                        }
                    }
                    .padding()
                }
                
                if saveSuccess {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Shortcuts updated successfully!")
                            .font(.subheadline)
                            .foregroundColor(.green)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.green.opacity(0.1))
                    )
                }
                
                Spacer()
            }
            .padding()
        }
        .frame(width: 600, height: 500)
        .onAppear {
            loadExistingJSON()
        }
        .onChange(of: jsonText) {
            validateJSON()
        }
    }
    
    private func loadExistingJSON() {
        guard let appShortcuts = shortcutDatabase.shortcuts[bundleId] else {
            jsonText = ""
            isLoading = false
            return
        }
        
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(appShortcuts)
            jsonText = String(data: data, encoding: .utf8) ?? ""
            isLoading = false
            validateJSON()
        } catch {
            validationMessage = "Failed to load existing JSON: \(error.localizedDescription)"
            isValid = false
            isLoading = false
        }
    }
    
    private func validateJSON() {
        guard !jsonText.isEmpty else {
            validationMessage = ""
            isValid = false
            return
        }
        
        // Use the same validation logic as JSONInputView
        let cleanedJsonText = jsonText
            .replacingOccurrences(of: "\u{201C}", with: "\"")
            .replacingOccurrences(of: "\u{201D}", with: "\"")
            .replacingOccurrences(of: "\u{2012}", with: "-")
            .replacingOccurrences(of: "\u{2014}", with: "-")
        
        guard let jsonData = cleanedJsonText.data(using: .utf8) else {
            validationMessage = "Cannot convert text to data - check for invalid characters"
            isValid = false
            return
        }
        
        do {
            _ = try JSONSerialization.jsonObject(with: jsonData)
        } catch {
            validationMessage = "Invalid JSON syntax: \(error.localizedDescription)"
            isValid = false
            return
        }
        
        do {
            let decoder = JSONDecoder()
            let applicationShortcuts = try decoder.decode(ApplicationShortcuts.self, from: jsonData)
            
            // Validate required fields
            if applicationShortcuts.applicationId.isEmpty {
                validationMessage = "Missing required field: applicationId"
                isValid = false
                return
            }
            
            if applicationShortcuts.applicationName.isEmpty {
                validationMessage = "Missing required field: applicationName"
                isValid = false
                return
            }
            
            if applicationShortcuts.groups.isEmpty {
                validationMessage = "At least one group is required"
                isValid = false
                return
            }
            
            for group in applicationShortcuts.groups {
                if group.title.isEmpty {
                    validationMessage = "Group title is required"
                    isValid = false
                    return
                }
                
                if group.shortcuts.isEmpty {
                    validationMessage = "Each group must have at least one shortcut"
                    isValid = false
                    return
                }
                
                for shortcut in group.shortcuts {
                    if shortcut.key.isEmpty {
                        validationMessage = "Shortcut key is required"
                        isValid = false
                        return
                    }
                    
                    if shortcut.description.isEmpty {
                        validationMessage = "Shortcut description is required"
                        isValid = false
                        return
                    }
                }
            }
            
            validationMessage = "JSON is valid and ready to save"
            isValid = true
            
        } catch {
            if let decodingError = error as? DecodingError {
                switch decodingError {
                case .dataCorrupted(let context):
                    validationMessage = "Invalid JSON format: \(context.debugDescription)"
                case .keyNotFound(let key, let context):
                    validationMessage = "Missing required field '\(key.stringValue)' at \(context.codingPath.map(\.stringValue).joined(separator: "."))"
                case .typeMismatch(let type, let context):
                    validationMessage = "Type mismatch: expected \(type) at \(context.codingPath.map(\.stringValue).joined(separator: "."))"
                case .valueNotFound(let type, let context):
                    validationMessage = "Missing value: expected \(type) at \(context.codingPath.map(\.stringValue).joined(separator: "."))"
                @unknown default:
                    validationMessage = "JSON decoding error: \(error.localizedDescription)"
                }
            } else {
                validationMessage = "Invalid JSON format: \(error.localizedDescription)"
            }
            isValid = false
        }
    }
    
    private func saveJSON() {
        guard isValid else { return }
        
        do {
            let cleanedJsonText = jsonText
                .replacingOccurrences(of: "\u{201C}", with: "\"")
                .replacingOccurrences(of: "\u{201D}", with: "\"")
                .replacingOccurrences(of: "\u{2012}", with: "-")
                .replacingOccurrences(of: "\u{2014}", with: "-")
            
            guard let jsonData = cleanedJsonText.data(using: .utf8) else {
                validationMessage = "Cannot convert text to data"
                isValid = false
                return
            }
            
            // Parse the new JSON to get the new bundle ID
            let decoder = JSONDecoder()
            let newApplicationShortcuts = try decoder.decode(ApplicationShortcuts.self, from: jsonData)
            
            // Delete the old entry (with original bundle ID)
            try shortcutDatabase.deleteShortcuts(for: bundleId)
            
            // If the bundle ID changed, also delete any existing entry with the new bundle ID
            if newApplicationShortcuts.applicationId != bundleId {
                try? shortcutDatabase.deleteShortcuts(for: newApplicationShortcuts.applicationId)
            }
            
            // Import the new configuration
            try shortcutDatabase.importShortcuts(from: jsonData)
            
            // Refresh the overlay controller
            overlayController.refreshCurrentShortcuts()
            
            print("✅ Updated shortcuts: '\(bundleId)' → '\(newApplicationShortcuts.applicationId)'")
            
            saveSuccess = true
            
            // Close after a brief delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                onDismiss()
            }
            
        } catch {
            validationMessage = "Save failed: \(error.localizedDescription)"
            isValid = false
        }
    }
}

struct JSONFormatGuideView: View {
    @State private var showingCopySuccess = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
            Text("JSON Format Guide")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Create custom shortcut files to import into KeysOnTop. Copy the JSON format below and modify it for your applications.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // JSON Example
            GroupBox("JSON Format") {
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
                    
                    // Field explanations
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Field Explanations:")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("• applicationId: Bundle identifier of the target app (e.g., com.apple.finder)")
                            Text("• applicationName: Display name of the application")
                            Text("• version: Optional version number for your shortcut set")
                            Text("• groups: Array of shortcut categories")
                            Text("• title: Name of the shortcut group")
                            Text("• category: Optional category for this group (e.g., 'file', 'edit')")
                            Text("• shortcuts: Array of keyboard shortcuts in this group")
                            Text("• key: Keyboard combination using symbols (⌘⇧⌥⌃)")
                            Text("• description: What the shortcut does")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                }
                .padding()
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
        .overlay(
            // Success popup
            Group {
                if showingCopySuccess {
                    VStack {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Copied to clipboard!")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.regularMaterial)
                                .shadow(radius: 4)
                        )
                        Spacer()
                    }
                    .padding(.top, 60)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .animation(.easeInOut(duration: 0.3), value: showingCopySuccess)
        )
    }
    
    private var jsonExample: String {
        return basicApplicationJSON
    }
    
    private func copyJSONToClipboard() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(jsonExample, forType: .string)
        
        // Show success popup
        showingCopySuccess = true
        
        // Hide after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            showingCopySuccess = false
        }
    }
    
    private var basicApplicationJSON: String {
        """
{
  "applicationId": "com.example.myapp",
  "applicationName": "My Application",
  "groups": [
    {
      "title": "File Operations",
      "category": "file",
      "shortcuts": [
        {
          "key": "⌘N",
          "description": "New document"
        }
      ]
    },
    {
      "title": "Edit Operations",
      "category": "edit",
      "shortcuts": [
        {
          "key": "⌘Z",
          "description": "Undo"
        },
        {
          "key": "⌘⇧Z",
          "description": "Redo"
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