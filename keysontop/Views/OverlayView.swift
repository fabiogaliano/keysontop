import SwiftUI

struct OverlayView: View {
    let application: Application
    let shortcutGroups: [ShortcutGroup]
    @State private var searchText = ""
    @FocusState private var isSearchFocused: Bool
    let onClose: () -> Void
    
    var filteredGroups: [ShortcutGroup] {
        if searchText.isEmpty {
            return shortcutGroups
        } else {
            let searchResult = parseSearchQuery(searchText)
            
            return shortcutGroups.compactMap { group in
                let filteredShortcuts = group.shortcuts.filter { shortcut in
                    matchesSearchCriteria(shortcut: shortcut, searchResult: searchResult)
                }
                
                if filteredShortcuts.isEmpty {
                    return nil
                } else {
                    return ShortcutGroup(title: group.title, shortcuts: filteredShortcuts)
                }
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            // Search bar
            searchBar
            
            // Shortcuts list
            shortcutsList
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
        )
        .padding()
        .frame(minWidth: 800, maxWidth: 1200, minHeight: 600, maxHeight: 800)
        .onTapGesture {
            // Allow clicks to propagate through for dragging
        }
        .gesture(
            DragGesture()
                .onChanged { _ in
                    // Handle dragging - this will be handled by the window
                }
        )
        .onAppear {
            // Auto-focus search field when overlay appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isSearchFocused = true
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            // Drag handle indicator
            VStack(spacing: 2) {
                ForEach(0..<3, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 1)
                        .fill(.tertiary)
                        .frame(width: 20, height: 2)
                }
            }
            .padding(.trailing, 8)
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(application.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    // Show lock icon to indicate it's locked to this app
                    Image(systemName: "lock.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                        .help("Locked to \(application.name) - shortcuts won't change when switching apps")
                }
                
                Text(application.bundleIdentifier)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: onClose) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .onHover { hovering in
                // Visual feedback on hover
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 8)
        .background(.clear)
        .contentShape(Rectangle())
    }
    
    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
                .font(.system(size: 16))
            
            TextField("Search shortcuts... (try: -cmd open, -opt -shift)", text: $searchText)
                .textFieldStyle(.plain)
                .font(.system(size: 16))
                .focused($isSearchFocused)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.quaternary)
                .stroke(.separator, lineWidth: 0.5)
        )
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 16)
    }
    
    private var shortcutsList: some View {
        GeometryReader { geometry in
            let columns = max(2, min(4, Int(geometry.size.width / 300)))
            let columnWidth = (geometry.size.width - CGFloat(columns + 1) * 20) / CGFloat(columns)
            
            HStack(alignment: .top, spacing: 20) {
                ForEach(0..<columns, id: \.self) { columnIndex in
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(groupsForColumn(columnIndex, totalColumns: columns)) { group in
                            GroupView(group: group)
                        }
                        Spacer()
                    }
                    .frame(width: columnWidth)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
    
    private func groupsForColumn(_ columnIndex: Int, totalColumns: Int) -> [ShortcutGroup] {
        let groupsPerColumn = Int(ceil(Double(filteredGroups.count) / Double(totalColumns)))
        let startIndex = columnIndex * groupsPerColumn
        let endIndex = min(startIndex + groupsPerColumn, filteredGroups.count)
        
        guard startIndex < filteredGroups.count else { return [] }
        return Array(filteredGroups[startIndex..<endIndex])
    }
    
    // MARK: - Smart Search Logic
    
    struct SearchCriteria {
        let requiredKeys: Set<String>
        let textTerms: [String]
    }
    
    private func parseSearchQuery(_ query: String) -> SearchCriteria {
        let components = query.split(separator: " ").map(String.init)
        var requiredKeys = Set<String>()
        var textTerms = [String]()
        
        for component in components {
            if component.hasPrefix("-") {
                let keyName = String(component.dropFirst())
                if let symbol = mapKeyNameToSymbol(keyName) {
                    requiredKeys.insert(symbol)
                }
            } else {
                textTerms.append(component)
            }
        }
        
        return SearchCriteria(requiredKeys: requiredKeys, textTerms: textTerms)
    }
    
    private func mapKeyNameToSymbol(_ keyName: String) -> String? {
        let lowercaseKey = keyName.lowercased()
        
        switch lowercaseKey {
        case "cmd", "command":
            return "⌘"
        case "opt", "option", "alt":
            return "⌥"
        case "shift":
            return "⇧"
        case "ctrl", "control":
            return "⌃"
        case "fn", "function":
            return "fn"
        case "space":
            return "Space"
        case "tab":
            return "⇥"
        case "esc", "escape":
            return "⎋"
        case "return", "enter":
            return "↩"
        case "delete", "backspace":
            return "⌫"
        case "forwarddelete":
            return "⌦"
        case "up":
            return "↑"
        case "down":
            return "↓"
        case "left":
            return "←"
        case "right":
            return "→"
        case "home":
            return "⇱"
        case "end":
            return "⇲"
        case "pageup":
            return "⇞"
        case "pagedown":
            return "⇟"
        default:
            return nil
        }
    }
    
    private func matchesSearchCriteria(shortcut: Shortcut, searchResult: SearchCriteria) -> Bool {
        // Check if all required keys are present
        for requiredKey in searchResult.requiredKeys {
            if !shortcut.key.contains(requiredKey) {
                return false
            }
        }
        
        // Check if all text terms are present in description
        for term in searchResult.textTerms {
            if !shortcut.description.localizedCaseInsensitiveContains(term) {
                return false
            }
        }
        
        return true
    }
}

struct GroupView: View {
    let group: ShortcutGroup
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(group.title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .padding(.bottom, 4)
            
            VStack(spacing: 6) {
                ForEach(group.shortcuts) { shortcut in
                    ShortcutRowView(shortcut: shortcut)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 8)
    }
}

struct ShortcutRowView: View {
    let shortcut: Shortcut
    
    var body: some View {
        HStack(spacing: 12) {
            // Description
            Text(shortcut.description)
                .font(.subheadline)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Key combination
            Text(shortcut.key)
                .font(.system(.subheadline, design: .monospaced))
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.quaternary)
                        .stroke(.separator, lineWidth: 0.5)
                )
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 2)
    }
}

#Preview {
    OverlayView(
        application: Application(name: "Finder", bundleIdentifier: "com.apple.finder"),
        shortcutGroups: ApplicationShortcuts.sample.groups,
        onClose: {}
    )
}