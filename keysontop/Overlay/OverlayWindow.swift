import Cocoa
import SwiftUI

class OverlayWindow: NSWindow {
    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
        
        setupWindow()
    }
    
    convenience init() {
        // Calculate a good size based on screen dimensions
        let screenSize = NSScreen.main?.visibleFrame.size ?? NSSize(width: 1920, height: 1080)
        let width = min(max(800, screenSize.width * 0.6), 1200)
        let height = min(max(600, screenSize.height * 0.7), 800)
        
        self.init(
            contentRect: NSRect(x: 0, y: 0, width: width, height: height),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
    }
    
    private func setupWindow() {
        // Window level to stay above all other windows - use floating window level
        level = NSWindow.Level.floating
        
        // Window behavior
        isOpaque = false
        backgroundColor = .clear
        hasShadow = true
        
        // Make window movable by dragging
        isMovableByWindowBackground = true
        
        // Allow mouse events
        ignoresMouseEvents = false
        
        // Collection behavior - stay visible across spaces and don't hide when inactive
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        
        // Prevent window from hiding when app becomes inactive
        hidesOnDeactivate = false
        
        // Center window on screen
        center()
    }
    
    func show() {
        makeKeyAndOrderFront(nil)
        orderFrontRegardless()
    }
    
    func hide() {
        orderOut(nil)
    }
    
    func centerOnScreen() {
        if let screen = NSScreen.main {
            let screenRect = screen.visibleFrame
            let windowRect = frame
            
            let x = screenRect.midX - windowRect.width / 2
            let y = screenRect.midY - windowRect.height / 2
            
            setFrameOrigin(NSPoint(x: x, y: y))
        }
    }
    
    // Allow window to become key so search field can receive focus
    override var canBecomeKey: Bool {
        return true
    }
    
    // Override to prevent the window from becoming main
    override var canBecomeMain: Bool {
        return false
    }
    
    // Override mouse events to prevent focus stealing
    override func mouseDown(with event: NSEvent) {
        // Handle mouse events without stealing focus
        super.mouseDown(with: event)
    }
}