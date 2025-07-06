import Foundation
import Carbon
import Cocoa

class HotkeyMonitor: ObservableObject {
    private var eventMonitor: Any?
    private var hotKeyRef: EventHotKeyRef?
    private var shortcutChangeObserver: Any?
    
    var onHotkeyPressed: (() -> Void)?
    private var currentShortcut: String = "⌘?"
    
    func startMonitoring() {
        // Stop any existing monitoring
        stopMonitoring()
        
        // Load current shortcut from UserDefaults
        loadCurrentShortcut()
        
        // Register global hotkey
        registerGlobalHotkey()
        
        // Monitor for escape key to hide overlay
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.keyCode == 53 { // Escape key
                self?.onHotkeyPressed?()
            }
        }
        
        // Listen for shortcut changes
        shortcutChangeObserver = NotificationCenter.default.addObserver(
            forName: .shortcutChanged,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let shortcut = notification.userInfo?["shortcut"] as? String {
                self?.updateShortcut(shortcut)
            }
        }
    }
    
    func stopMonitoring() {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
        
        if let observer = shortcutChangeObserver {
            NotificationCenter.default.removeObserver(observer)
            shortcutChangeObserver = nil
        }
        
        unregisterGlobalHotkey()
    }
    
    private func registerGlobalHotkey() {
        let hotkeyID = EventHotKeyID(signature: 0x4B534F54, id: 1) // 'KSOT' as OSType
        
        // Parse the current shortcut
        let (keyCode, modifiers) = parseShortcut(currentShortcut)
        
        // Register the hotkey
        let status = RegisterEventHotKey(
            UInt32(keyCode),
            modifiers,
            hotkeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
        
        if status != noErr {
            print("Failed to register global hotkey '\(currentShortcut)': \(status)")
        } else {
            print("Successfully registered global hotkey: \(currentShortcut)")
            // Install event handler
            installEventHandler()
        }
    }
    
    private func unregisterGlobalHotkey() {
        if let hotKeyRef = hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }
    }
    
    private func installEventHandler() {
        var eventSpec = EventTypeSpec(eventClass: UInt32(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        
        let callback: EventHandlerUPP = { (nextHandler, theEvent, userData) -> OSStatus in
            guard let monitor = Unmanaged<HotkeyMonitor>.fromOpaque(userData!).takeUnretainedValue() as HotkeyMonitor? else {
                return OSStatus(eventNotHandledErr)
            }
            
            DispatchQueue.main.async {
                monitor.onHotkeyPressed?()
            }
            
            return OSStatus(noErr)
        }
        
        let selfPtr = Unmanaged.passUnretained(self).toOpaque()
        
        var eventHandler: EventHandlerRef?
        InstallEventHandler(
            GetApplicationEventTarget(),
            callback,
            1,
            &eventSpec,
            selfPtr,
            &eventHandler
        )
    }
    
    private func loadCurrentShortcut() {
        if let saved = UserDefaults.standard.string(forKey: "GlobalShortcutKey") {
            currentShortcut = saved
        }
    }
    
    private func updateShortcut(_ newShortcut: String) {
        currentShortcut = newShortcut
        // Re-register with new shortcut
        unregisterGlobalHotkey()
        registerGlobalHotkey()
    }
    
    private func parseShortcut(_ shortcut: String) -> (keyCode: UInt16, modifiers: UInt32) {
        var modifiers: UInt32 = 0
        var keyChar = ""
        
        // Extract modifiers
        if shortcut.contains("⌘") {
            modifiers |= UInt32(cmdKey)
        }
        if shortcut.contains("⌥") {
            modifiers |= UInt32(optionKey)
        }
        if shortcut.contains("⇧") {
            modifiers |= UInt32(shiftKey)
        }
        if shortcut.contains("⌃") {
            modifiers |= UInt32(controlKey)
        }
        
        // Extract the key character (everything after modifiers)
        keyChar = shortcut.replacingOccurrences(of: "⌘", with: "")
                         .replacingOccurrences(of: "⌥", with: "")
                         .replacingOccurrences(of: "⇧", with: "")
                         .replacingOccurrences(of: "⌃", with: "")
        
        // Convert key character to key code
        let keyCode = stringToKeyCode(keyChar)
        
        return (keyCode, modifiers)
    }
    
    private func stringToKeyCode(_ string: String) -> UInt16 {
        switch string.lowercased() {
        case "?", "/": return UInt16(kVK_ANSI_Slash)
        case "a": return UInt16(kVK_ANSI_A)
        case "b": return UInt16(kVK_ANSI_B)
        case "c": return UInt16(kVK_ANSI_C)
        case "d": return UInt16(kVK_ANSI_D)
        case "e": return UInt16(kVK_ANSI_E)
        case "f": return UInt16(kVK_ANSI_F)
        case "g": return UInt16(kVK_ANSI_G)
        case "h": return UInt16(kVK_ANSI_H)
        case "i": return UInt16(kVK_ANSI_I)
        case "j": return UInt16(kVK_ANSI_J)
        case "k": return UInt16(kVK_ANSI_K)
        case "l": return UInt16(kVK_ANSI_L)
        case "m": return UInt16(kVK_ANSI_M)
        case "n": return UInt16(kVK_ANSI_N)
        case "o": return UInt16(kVK_ANSI_O)
        case "p": return UInt16(kVK_ANSI_P)
        case "q": return UInt16(kVK_ANSI_Q)
        case "r": return UInt16(kVK_ANSI_R)
        case "s": return UInt16(kVK_ANSI_S)
        case "t": return UInt16(kVK_ANSI_T)
        case "u": return UInt16(kVK_ANSI_U)
        case "v": return UInt16(kVK_ANSI_V)
        case "w": return UInt16(kVK_ANSI_W)
        case "x": return UInt16(kVK_ANSI_X)
        case "y": return UInt16(kVK_ANSI_Y)
        case "z": return UInt16(kVK_ANSI_Z)
        case "space": return UInt16(kVK_Space)
        case "tab": return UInt16(kVK_Tab)
        case "return", "enter": return UInt16(kVK_Return)
        case "escape": return UInt16(kVK_Escape)
        case "delete": return UInt16(kVK_Delete)
        case "f1": return UInt16(kVK_F1)
        case "f2": return UInt16(kVK_F2)
        case "f3": return UInt16(kVK_F3)
        case "f4": return UInt16(kVK_F4)
        case "f5": return UInt16(kVK_F5)
        case "f6": return UInt16(kVK_F6)
        case "f7": return UInt16(kVK_F7)
        case "f8": return UInt16(kVK_F8)
        case "f9": return UInt16(kVK_F9)
        case "f10": return UInt16(kVK_F10)
        case "f11": return UInt16(kVK_F11)
        case "f12": return UInt16(kVK_F12)
        default: return UInt16(kVK_ANSI_Slash) // Default to slash
        }
    }
    
    deinit {
        stopMonitoring()
    }
}