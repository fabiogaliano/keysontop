import SwiftUI

struct OverlayView: View {
    let application: Application
    let shortcutGroups: [ShortcutGroup]
    @State private var searchText = ""
    let onClose: () -> Void
    
    var filteredGroups: [ShortcutGroup] {
        if searchText.isEmpty {
            return shortcutGroups
        } else {
            return shortcutGroups.compactMap { group in
                let filteredShortcuts = group.shortcuts.filter { shortcut in
                    shortcut.key.localizedCaseInsensitiveContains(searchText) ||
                    shortcut.description.localizedCaseInsensitiveContains(searchText)
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
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search shortcuts...", text: $searchText)
                .textFieldStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.quaternary)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
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