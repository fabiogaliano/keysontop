import SwiftUI
import Cocoa

class OverlayController: ObservableObject {
    @Published var isVisible = false
    @Published var currentApplication: Application?
    @Published var currentShortcuts: [ShortcutGroup] = []
    
    private var overlayWindow: OverlayWindow?
    private let applicationDetector: ApplicationDetector
    private let shortcutDatabase: ShortcutDatabase
    private let permissionsManager: PermissionsManager
    
    // Keep track of the last non-KeysOnTop application
    private var lastTargetApplication: Application?
    private let keysOnTopBundleId = Bundle.main.bundleIdentifier ?? "com.unknown.keysontop"
    
    init(
        applicationDetector: ApplicationDetector = NSWorkspaceApplicationDetector(),
        shortcutDatabase: ShortcutDatabase = ShortcutDatabase(),
        permissionsManager: PermissionsManager = PermissionsManager()
    ) {
        self.applicationDetector = applicationDetector
        self.shortcutDatabase = shortcutDatabase
        self.permissionsManager = permissionsManager
        
        setupApplicationObserver()
        updateCurrentApplication()
    }
    
    func toggleOverlay() {
        if isVisible {
            hideOverlay()
        } else {
            showOverlay()
        }
    }
    
    func showOverlay() {
        guard permissionsManager.hasAccessibilityPermissions else {
            _ = permissionsManager.requestAccessibilityPermissions()
            return
        }
        
        DispatchQueue.main.async {
            // If we have a last target application, use that instead of current
            if let lastApp = self.lastTargetApplication {
                self.currentApplication = lastApp
                self.currentShortcuts = self.shortcutDatabase.loadShortcuts(for: lastApp.bundleIdentifier) ?? []
            } else {
                self.updateCurrentApplication()
            }
            
            self.createOverlayWindow()
            self.overlayWindow?.show()
            self.overlayWindow?.centerOnScreen()
            self.isVisible = true
        }
    }
    
    func hideOverlay() {
        DispatchQueue.main.async {
            self.overlayWindow?.orderOut(nil)
            self.isVisible = false
        }
    }
    
    func refreshCurrentShortcuts() {
        guard let app = currentApplication else { return }
        currentShortcuts = shortcutDatabase.loadShortcuts(for: app.bundleIdentifier) ?? []
        
        // Update overlay if visible
        if isVisible {
            updateOverlayContent()
        }
    }
    
    private func setupApplicationObserver() {
        applicationDetector.observeApplicationChanges { [weak self] application in
            DispatchQueue.main.async {
                self?.updateCurrentApplication(with: application)
            }
        }
    }
    
    private func updateCurrentApplication(with application: Application? = nil) {
        let app = application ?? applicationDetector.getCurrentActiveApplication()
        
        // Check if this is our own app
        if let app = app, app.bundleIdentifier == keysOnTopBundleId {
            // Don't update if it's KeysOnTop - keep showing the last target app
            return
        }
        
        // Update the target application
        if let app = app {
            lastTargetApplication = app
            currentApplication = app
            
            // Debug logging
            print("🔍 Active app: \(app.name) (\(app.bundleIdentifier))")
            
            currentShortcuts = shortcutDatabase.loadShortcuts(for: app.bundleIdentifier) ?? []
            
            print("📋 Found \(currentShortcuts.count) shortcut groups for \(app.bundleIdentifier)")
            if currentShortcuts.isEmpty {
                print("⚠️  Available bundle IDs: \(Array(shortcutDatabase.shortcuts.keys))")
            }
        } else {
            currentApplication = app
            currentShortcuts = []
        }
        
        // Update overlay if visible
        if isVisible {
            updateOverlayContent()
        }
    }
    
    private func createOverlayWindow() {
        if overlayWindow == nil {
            overlayWindow = OverlayWindow()
        }
        
        updateOverlayContent()
    }
    
    private func updateOverlayContent() {
        guard let window = overlayWindow,
              let app = currentApplication else { return }
        
        let overlayView = OverlayView(
            application: app,
            shortcutGroups: currentShortcuts,
            onClose: { [weak self] in
                self?.hideOverlay()
            }
        )
        // Remove the auto-hide behavior - overlay should stay visible
        
        let hostingView = NSHostingView(rootView: overlayView)
        hostingView.frame = window.contentView?.bounds ?? NSRect.zero
        hostingView.autoresizingMask = [.width, .height]
        
        window.contentView = hostingView
    }
    
    deinit {
        applicationDetector.stopObserving()
    }
}