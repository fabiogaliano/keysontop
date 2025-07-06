//
//  keysontopApp.swift
//  keysontop
//
//  Created by fábio on 06/07/2025.
//

import SwiftUI
import Cocoa

@main
struct keysontopApp: App {
    @StateObject private var overlayController = OverlayController()
    @StateObject private var hotkeyMonitor = HotkeyMonitor()
    @StateObject private var permissionsManager = PermissionsManager()
    @State private var menuBarController: MenuBarController?
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(overlayController)
                .environmentObject(permissionsManager)
                .onAppear {
                    setupHotkeys()
                    setupMenuBar()
                }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("Show Overlay") {
                    overlayController.showOverlay()
                }
                .keyboardShortcut("o", modifiers: .command)
                
                Button("Hide Overlay") {
                    overlayController.hideOverlay()
                }
                .keyboardShortcut("h", modifiers: .command)
                
                Divider()
                
                Button("Settings...") {
                    // This will be handled by the main window
                    NotificationCenter.default.post(name: .showSettings, object: nil)
                }
                .keyboardShortcut(",", modifiers: .command)
            }
        }
        
        // Settings are now handled by SettingsWindowController
    }
    
    private func setupHotkeys() {
        hotkeyMonitor.onHotkeyPressed = {
            overlayController.toggleOverlay()
        }
        hotkeyMonitor.startMonitoring()
    }
    
    private func setupMenuBar() {
        menuBarController = MenuBarController(
            overlayController: overlayController,
            permissionsManager: permissionsManager
        )
    }
}
