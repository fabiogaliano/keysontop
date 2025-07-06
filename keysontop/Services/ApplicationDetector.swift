import Foundation
import Cocoa

protocol ApplicationDetector {
    func getCurrentActiveApplication() -> Application?
    func observeApplicationChanges(callback: @escaping (Application) -> Void)
    func stopObserving()
}

class NSWorkspaceApplicationDetector: ApplicationDetector {
    private var observer: Any?
    private var callback: ((Application) -> Void)?
    
    func getCurrentActiveApplication() -> Application? {
        guard let frontmostApp = NSWorkspace.shared.frontmostApplication else {
            return nil
        }
        
        return Application(
            name: frontmostApp.localizedName ?? "Unknown",
            bundleIdentifier: frontmostApp.bundleIdentifier ?? "unknown.app"
        )
    }
    
    func observeApplicationChanges(callback: @escaping (Application) -> Void) {
        self.callback = callback
        
        // Remove existing observer if any
        stopObserving()
        
        // Add observer for application activation
        observer = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didActivateApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let app = self?.getCurrentActiveApplication() {
                callback(app)
            }
        }
    }
    
    func stopObserving() {
        if let observer = observer {
            NSWorkspace.shared.notificationCenter.removeObserver(observer)
            self.observer = nil
        }
    }
    
    deinit {
        stopObserving()
    }
}