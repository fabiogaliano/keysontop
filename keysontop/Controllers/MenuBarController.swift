import Cocoa
import SwiftUI

class MenuBarController: ObservableObject {
    private var statusItem: NSStatusItem?
    private let overlayController: OverlayController
    private let permissionsManager: PermissionsManager
    
    init(overlayController: OverlayController, permissionsManager: PermissionsManager) {
        self.overlayController = overlayController
        self.permissionsManager = permissionsManager
        setupMenuBar()
    }
    
    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "keyboard", accessibilityDescription: "KeysOnTop")
            button.image?.isTemplate = true
        }
        
        setupMenu()
    }
    
    private func setupMenu() {
        let menu = NSMenu()
        
        // Show/Hide Overlay
        let showOverlayItem = NSMenuItem(
            title: "Show Overlay",
            action: #selector(showOverlay),
            keyEquivalent: ""
        )
        showOverlayItem.target = self
        menu.addItem(showOverlayItem)
        
        let hideOverlayItem = NSMenuItem(
            title: "Hide Overlay",
            action: #selector(hideOverlay),
            keyEquivalent: ""
        )
        hideOverlayItem.target = self
        menu.addItem(hideOverlayItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Settings
        let settingsItem = NSMenuItem(
            title: "Settings...",
            action: #selector(openSettings),
            keyEquivalent: ","
        )
        settingsItem.target = self
        menu.addItem(settingsItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Permissions status
        let permissionsItem = NSMenuItem(
            title: permissionsManager.hasAccessibilityPermissions ? "✓ Permissions Granted" : "⚠ Grant Permissions",
            action: permissionsManager.hasAccessibilityPermissions ? nil : #selector(requestPermissions),
            keyEquivalent: ""
        )
        permissionsItem.target = self
        permissionsItem.isEnabled = !permissionsManager.hasAccessibilityPermissions
        menu.addItem(permissionsItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Quit
        let quitItem = NSMenuItem(
            title: "Quit KeysOnTop",
            action: #selector(quit),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)
        
        statusItem?.menu = menu
    }
    
    @objc private func showOverlay() {
        overlayController.showOverlay()
    }
    
    @objc private func hideOverlay() {
        overlayController.hideOverlay()
    }
    
    @objc private func openSettings() {
        SettingsWindowController.showSettings(
            overlayController: overlayController,
            permissionsManager: permissionsManager
        )
    }
    
    @objc private func requestPermissions() {
        _ = permissionsManager.requestAccessibilityPermissions()
        // Refresh menu after permission request
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.setupMenu()
        }
    }
    
    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }
    
    func updateMenu() {
        setupMenu()
    }
}