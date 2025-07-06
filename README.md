# KeysOnTop

A native macOS application that displays keyboard shortcuts for the currently active application in a floating overlay window. Similar to KeyClue/KeyCue, KeysOnTop helps you discover and remember keyboard shortcuts for any application.

![KeysOnTop Demo](demo.png)

## Features

### 🎯 **Smart Overlay System**
- **Always-on-top floating window** that displays shortcuts for the currently active application
- **Automatic application detection** using NSWorkspace monitoring
- **Sticky mode** - overlay stays locked to the last active app when interacting with KeysOnTop itself
- **Draggable overlay** - position it anywhere on your screen
- **Multi-column layout** - Chrome-style large window format for easy browsing

### 🔍 **Powerful Smart Search**
- **Text search** - Find shortcuts by description
- **Key-based search** - Use `-cmd`, `-opt`, `-shift` syntax to find shortcuts by modifier keys
- **Combined search** - Mix key and text searches like `-cmd open` or `-opt -shift zoom`
- **Real-time filtering** - Results update as you type
- **Auto-focus** - Search field is ready to use immediately when overlay opens

### ⚙️ **Comprehensive Settings**
- **Global hotkey configuration** - Customize the show/hide shortcut (default: ⌘?)
- **Accessibility permissions management** - Built-in guidance for required permissions
- **Import/Export system** - JSON-based shortcut definitions with validation
- **Built-in JSON editor** - Edit shortcuts directly in the app
- **Delete functionality** - Remove imported shortcuts with one click

### 📱 **Data Management**
- **Persistent storage** - Imported shortcuts survive app rebuilds and restarts
- **JSON format** - LLM-friendly schema for easy shortcut generation
- **Case-insensitive matching** - Works with any bundle identifier capitalization
- **Built-in shortcuts** - Comes with shortcuts for Finder, Safari, and Chrome
- **Flexible import** - Import from files or paste JSON directly

## Installation

### Requirements
- macOS 12.0 or later
- Xcode 14.0 or later (for building from source)

### Building from Source
1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/keysontop.git
   cd keysontop
   ```

2. Open the project in Xcode:
   ```bash
   open keysontop.xcodeproj
   ```

3. Build and run the project (⌘+R)

### First Launch Setup
1. **Grant Accessibility Permissions** - Required for global hotkey monitoring
   - The app will guide you through this process
   - Go to System Preferences → Security & Privacy → Accessibility
   - Check the box next to KeysOnTop

2. **Configure Global Hotkey** (Optional)
   - Default: ⌘? (Command + ?)
   - Customize in Settings → General → Global Hotkey

## Usage

### Basic Usage
1. **Show overlay** - Press your global hotkey (default: ⌘?)
2. **Browse shortcuts** - Scroll through categorized shortcuts for the active app
3. **Search shortcuts** - Type in the search bar to filter results
4. **Hide overlay** - Press the global hotkey again or click the X button

### Smart Search Examples
- `"-cmd"` - Show all Command key shortcuts
- `"-opt -shift"` - Show shortcuts using both Option and Shift
- `"-cmd copy"` - Show Command shortcuts containing "copy"
- `"zoom"` - Show all shortcuts with "zoom" in the description

### Importing Custom Shortcuts

#### Option 1: JSON Import
1. Go to **Settings → Shortcuts → Import from JSON...**
2. Paste your JSON configuration
3. Click **Import**

#### Option 2: File Import
1. Go to **Settings → Shortcuts → Import from File...**
2. Select a `.json` file
3. The shortcuts are automatically imported

#### JSON Format
```json
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
        },
        {
          "key": "⌘O",
          "description": "Open document"
        }
      ]
    }
  ]
}
```

### Keyboard Symbols Reference
- **⌘** - Command (Cmd)
- **⌥** - Option (Alt)
- **⇧** - Shift
- **⌃** - Control (Ctrl)
- **⎋** - Escape
- **⌫** - Delete (Backspace)
- **⌦** - Forward Delete
- **↩** - Return (Enter)
- **⇥** - Tab
- **↑↓←→** - Arrow keys
- **⇞⇟** - Page Up/Down

## Architecture

### Core Components
- **keysontopApp.swift** - Main app entry point and global hotkey setup
- **OverlayController.swift** - Manages overlay display and application detection
- **OverlayWindow.swift** - Custom NSWindow for always-on-top behavior
- **OverlayView.swift** - SwiftUI overlay interface with search functionality
- **ShortcutDatabase.swift** - JSON-based shortcut storage and management

### Domain Models
- **Application** - Represents detected macOS applications
- **Shortcut** - Individual keyboard shortcut with key and description
- **ShortcutGroup** - Collection of related shortcuts organized by category
- **ApplicationShortcuts** - Complete shortcut set for a specific application

### Services
- **ApplicationDetector** - NSWorkspace-based application monitoring
- **PermissionsManager** - Accessibility permissions handling
- **HotkeyMonitor** - Global hotkey registration and monitoring
- **ShortcutDatabase** - Persistent shortcut storage and retrieval

## File Storage

KeysOnTop stores imported shortcuts in:
```
~/Documents/KeysOnTop/
├── com.example.app1.json
├── com.example.app2.json
└── ...
```

Each application gets its own JSON file based on its bundle identifier.

## Troubleshooting

### Overlay Not Showing
- Check accessibility permissions in System Preferences
- Verify the global hotkey isn't conflicting with other apps
- Try restarting the application

### Shortcuts Not Loading
- Check that the bundle identifier in your JSON matches the actual app
- Use case-insensitive matching - capitalization doesn't matter
- Verify JSON format using the built-in validator

### Global Hotkey Not Working
- Ensure accessibility permissions are granted
- Check for conflicts with other applications
- Try configuring a different hotkey combination

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Commit your changes: `git commit -am 'Add feature'`
4. Push to the branch: `git push origin feature-name`
5. Submit a pull request

### Development Guidelines
- Follow SwiftUI best practices
- Use domain-driven architecture patterns
- Write comprehensive commit messages
- Test on multiple macOS versions
- Ensure accessibility compliance

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Inspired by KeyClue/KeyCue
- Built with SwiftUI and AppKit
- Uses Carbon Event Manager for global hotkey monitoring
- JSON schema designed for LLM compatibility

## Support

- **Issues**: Report bugs and feature requests on GitHub Issues
- **Discussions**: Join conversations in GitHub Discussions
- **Documentation**: Check the built-in JSON format guide in Settings

---

**Note**: This application requires accessibility permissions to monitor global hotkeys and detect active applications. All permissions are used solely for the app's core functionality and no data is transmitted externally.