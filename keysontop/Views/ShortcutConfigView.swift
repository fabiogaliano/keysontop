import SwiftUI
import Cocoa

struct ShortcutConfigView: View {
    @StateObject private var keyRecorder = KeyRecorder()
    @Binding var shortcutKey: String
    let onSave: (String) -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Configure Shortcut")
                .font(.headline)
            
            // Current shortcut display
            HStack {
                Text("Current shortcut:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(shortcutKey.isEmpty ? "Not set" : shortcutKey)
                    .font(.system(.body, design: .monospaced))
                    .fontWeight(.bold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(.quaternary)
                    )
            }
            
            // Recording area
            VStack(spacing: 8) {
                Button(action: toggleRecording) {
                    HStack {
                        Image(systemName: keyRecorder.isRecording ? "stop.circle.fill" : "record.circle")
                            .font(.title2)
                        
                        Text(keyRecorder.isRecording ? "Stop Recording" : "Record New Shortcut")
                            .font(.headline)
                    }
                    .foregroundColor(keyRecorder.isRecording ? .red : .blue)
                }
                .buttonStyle(.bordered)
                
                if keyRecorder.isRecording {
                    Text("Press your desired key combination...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.yellow.opacity(0.1))
                                .stroke(.yellow, lineWidth: 1)
                        )
                } else if !keyRecorder.recordedShortcut.isEmpty {
                    Text("Recorded: \(keyRecorder.recordedShortcut)")
                        .font(.subheadline)
                        .foregroundColor(.green)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.green.opacity(0.1))
                                .stroke(.green, lineWidth: 1)
                        )
                }
            }
            
            // Common shortcuts
            VStack(alignment: .leading, spacing: 8) {
                Text("Common shortcuts:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                    ForEach(commonShortcuts, id: \.self) { shortcut in
                        Button(shortcut) {
                            shortcutKey = shortcut
                            keyRecorder.recordedShortcut = shortcut
                        }
                        .font(.system(.caption, design: .monospaced))
                        .buttonStyle(.bordered)
                    }
                }
            }
            
            // Action buttons
            HStack(spacing: 12) {
                Button("Reset to Default") {
                    shortcutKey = "⌘?"
                    keyRecorder.recordedShortcut = "⌘?"
                }
                .buttonStyle(.bordered)
                
                Button("Save") {
                    let newShortcut = keyRecorder.recordedShortcut.isEmpty ? shortcutKey : keyRecorder.recordedShortcut
                    onSave(newShortcut)
                }
                .buttonStyle(.borderedProminent)
                .disabled(keyRecorder.recordedShortcut.isEmpty && shortcutKey.isEmpty)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.regularMaterial)
        )
        .onAppear {
            keyRecorder.recordedShortcut = shortcutKey
        }
        .onDisappear {
            keyRecorder.stopRecording()
        }
    }
    
    private var commonShortcuts: [String] {
        [
            "⌘?", "⌘/", "⌘K",
            "⌘⇧K", "⌘⇧P", "⌘⇧A",
            "⌥Space", "⌃Space", "F1",
            "F2", "F3", "F12"
        ]
    }
    
    private func toggleRecording() {
        if keyRecorder.isRecording {
            keyRecorder.stopRecording()
        } else {
            keyRecorder.startRecording()
        }
    }
}

// MARK: - Key Recording Helper
class KeyRecorder: ObservableObject {
    @Published var isRecording = false
    @Published var recordedShortcut = ""
    
    private var localMonitor: Any?
    
    func startRecording() {
        isRecording = true
        recordedShortcut = ""
        
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .flagsChanged]) { [weak self] event in
            self?.handleKeyEvent(event)
            return nil // Consume the event
        }
    }
    
    func stopRecording() {
        isRecording = false
        
        if let monitor = localMonitor {
            NSEvent.removeMonitor(monitor)
            localMonitor = nil
        }
    }
    
    private func handleKeyEvent(_ event: NSEvent) {
        guard isRecording else { return }
        
        if event.type == .keyDown {
            var modifierString = ""
            let modifiers = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
            
            if modifiers.contains(.command) {
                modifierString += "⌘"
            }
            if modifiers.contains(.option) {
                modifierString += "⌥"
            }
            if modifiers.contains(.shift) {
                modifierString += "⇧"
            }
            if modifiers.contains(.control) {
                modifierString += "⌃"
            }
            
            let keyString = keyCodeToString(event.keyCode)
            recordedShortcut = modifierString + keyString
            
            // Auto-stop recording after capturing a key
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.stopRecording()
            }
        }
    }
    
    private func keyCodeToString(_ keyCode: UInt16) -> String {
        switch keyCode {
        case 0x7A: return "F1"
        case 0x78: return "F2"
        case 0x63: return "F3"
        case 0x76: return "F4"
        case 0x60: return "F5"
        case 0x61: return "F6"
        case 0x62: return "F7"
        case 0x64: return "F8"
        case 0x65: return "F9"
        case 0x6D: return "F10"
        case 0x67: return "F11"
        case 0x6F: return "F12"
        case 0x35: return "⎋"
        case 0x31: return "Space"
        case 0x30: return "⇥"
        case 0x33: return "⌫"
        case 0x75: return "⌦"
        case 0x24: return "↩"
        case 0x7E: return "↑"
        case 0x7D: return "↓"
        case 0x7B: return "←"
        case 0x7C: return "→"
        case 0x2C: return "/"
        case 0x2F: return "."
        case 0x2B: return ","
        case 0x27: return "'"
        case 0x29: return ";"
        case 0x2A: return "\\"
        case 0x21: return "["
        case 0x1E: return "]"
        case 0x32: return "`"
        case 0x18: return "="
        case 0x1B: return "-"
        case 0x00: return "A"
        case 0x0B: return "B"
        case 0x08: return "C"
        case 0x02: return "D"
        case 0x0E: return "E"
        case 0x03: return "F"
        case 0x05: return "G"
        case 0x04: return "H"
        case 0x22: return "I"
        case 0x26: return "J"
        case 0x28: return "K"
        case 0x25: return "L"
        case 0x2E: return "M"
        case 0x2D: return "N"
        case 0x1F: return "O"
        case 0x23: return "P"
        case 0x0C: return "Q"
        case 0x0F: return "R"
        case 0x01: return "S"
        case 0x11: return "T"
        case 0x20: return "U"
        case 0x09: return "V"
        case 0x0D: return "W"
        case 0x07: return "X"
        case 0x10: return "Y"
        case 0x06: return "Z"
        case 0x12: return "1"
        case 0x13: return "2"
        case 0x14: return "3"
        case 0x15: return "4"
        case 0x17: return "5"
        case 0x16: return "6"
        case 0x1A: return "7"
        case 0x1C: return "8"
        case 0x19: return "9"
        case 0x1D: return "0"
        default:
            return "Key\(keyCode)"
        }
    }
    
    deinit {
        stopRecording()
    }
}

#Preview {
    ShortcutConfigView(
        shortcutKey: .constant("⌘?"),
        onSave: { _ in }
    )
}