# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a KeyClue/KeyCue clone - a native macOS application that displays keyboard shortcuts for the currently active application in an overlay window. The app uses SwiftUI for the interface and AppKit for system-level window management.

## Build and Development Commands

This is an Xcode project that should be built and run through Xcode:

- **Build**: Open `keysontop.xcodeproj` in Xcode and use Cmd+B
- **Run**: Use Cmd+R in Xcode to build and run the application
- **Test**: Use Cmd+U in Xcode to run tests (if any exist)
- **Clean**: Use Cmd+Shift+K to clean build folder

## Architecture

### Domain Models

- **Application**: Represents a detected macOS application with bundle identifier and name
- **Shortcut**: Individual keyboard shortcut with key combination and description
- **ShortcutGroup**: Collection of related shortcuts organized by category
- **ApplicationShortcuts**: Complete shortcut set for a specific application

### Core Components

- **keysontopApp.swift**: Main app entry point that sets up overlay controller and global hotkeys
- **MainView.swift**: Main application interface showing permissions status and instructions
- **OverlayView.swift**: Floating overlay window that displays shortcuts with search functionality
- **OverlayWindow.swift**: NSWindow subclass configured to stay above all other windows
- **OverlayController.swift**: Coordinates overlay display, application detection, and shortcut loading

### Services Layer

- **ApplicationDetector**: Protocol and NSWorkspace implementation for detecting active applications
- **PermissionsManager**: Handles accessibility permissions required for global monitoring
- **HotkeyMonitor**: Monitors global hotkeys (⌘? to show/hide overlay)
- **ShortcutDatabase**: JSON-based storage and management of shortcut data

### Data Layer

- JSON-based shortcut storage in Documents/KeysOnTop/
- Built-in shortcuts for common applications (Finder, Safari)
- Supports import/export of shortcut definitions
- LLM-friendly JSON schema for generating new shortcut sets

## App Capabilities

The app requires special permissions and capabilities:
- **Accessibility permissions**: Required for global hotkey monitoring and application detection
- **App sandbox**: Enabled with automation and file access permissions
- **Window management**: Overlay window stays above all applications at screen saver level

## Development Notes

### Key Technical Challenges

1. **Overlay Window Management**: Uses NSWindow with screenSaver level to stay on top
2. **Accessibility Permissions**: Must request and handle accessibility permissions gracefully
3. **Global Hotkey Monitoring**: Carbon Event Manager for system-wide hotkey detection
4. **Application Detection**: NSWorkspace monitoring for active app changes

### JSON Schema for Shortcuts

```json
{
  "applicationId": "com.example.app",
  "applicationName": "Example App",
  "version": "1.0",
  "groups": [
    {
      "title": "Navigation",
      "shortcuts": [
        {
          "key": "⌘↑",
          "description": "Go up",
          "category": "navigation"
        }
      ]
    }
  ]
}
```

### Symbol Usage

- Use proper symbols in key combinations: ⌘ (Cmd), ⌥ (Opt), ⇧ (Shift), ⌃ (Ctrl)
- Arrows: ↑ ↓ ← → for directional keys
- Special keys: ⎋ (Escape), ⌫ (Delete), ⌦ (Forward Delete)

## Implementation Priorities

1. **Core Functionality**: Overlay window, application detection, basic shortcuts
2. **Permissions**: Accessibility permissions handling and user guidance
3. **Data Management**: JSON import/export, built-in shortcut database
4. **Polish**: Animations, positioning, visual improvements

## Security Considerations

- Never log or expose sensitive information from monitored applications
- Respect user privacy in application detection
- Handle permissions gracefully without being intrusive
- Validate JSON imports to prevent malicious data

## Development Notes

- This is a SwiftUI + AppKit hybrid application
- Follow SwiftUI best practices for view composition
- Use AppKit for system-level window management
- Maintain clear separation between domain models and presentation
- Use proper error handling with Result types
- Test overlay behavior across different screen configurations