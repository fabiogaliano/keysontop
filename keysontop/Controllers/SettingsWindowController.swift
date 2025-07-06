import Cocoa
import SwiftUI

class SettingsWindowController: NSWindowController {
    private static var shared: SettingsWindowController?
    
    static func showSettings(overlayController: OverlayController, permissionsManager: PermissionsManager) {
        if let existing = shared {
            existing.window?.makeKeyAndOrderFront(nil)
            return
        }
        
        let windowController = SettingsWindowController(
            overlayController: overlayController,
            permissionsManager: permissionsManager
        )
        shared = windowController
        windowController.showWindow(nil)
    }
    
    convenience init(overlayController: OverlayController, permissionsManager: PermissionsManager) {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 700, height: 600),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        
        self.init(window: window)
        
        window.title = "KeysOnTop Settings"
        window.center()
        window.delegate = self
        
        // Set minimum and maximum window size
        window.minSize = NSSize(width: 600, height: 500)
        window.maxSize = NSSize(width: 1000, height: 800)
        
        // Make window resizable
        window.isRestorable = true
        
        let settingsView = SettingsView()
            .environmentObject(overlayController)
            .environmentObject(permissionsManager)
        
        window.contentView = NSHostingView(rootView: settingsView)
    }
}

extension SettingsWindowController: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        // Clear the shared reference when window closes
        SettingsWindowController.shared = nil
    }
    
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        return true
    }
}