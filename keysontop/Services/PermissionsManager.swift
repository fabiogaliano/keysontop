import Foundation
import ApplicationServices
import Cocoa

class PermissionsManager: ObservableObject {
    @Published var hasAccessibilityPermissions = false
    
    init() {
        checkPermissions()
    }
    
    func checkPermissions() {
        hasAccessibilityPermissions = AXIsProcessTrusted()
    }
    
    func requestAccessibilityPermissions() -> Bool {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue(): true]
        let result = AXIsProcessTrustedWithOptions(options as CFDictionary)
        
        DispatchQueue.main.async {
            self.hasAccessibilityPermissions = result
        }
        
        return result
    }
    
    func openSystemPreferences() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        NSWorkspace.shared.open(url)
    }
}