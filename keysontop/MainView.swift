//
//  MainView.swift
//  keysontop
//
//  Created by fábio on 06/07/2025.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject private var overlayController: OverlayController
    @EnvironmentObject private var permissionsManager: PermissionsManager
    @StateObject private var shortcutConfigManager = ShortcutConfigManager()
    @State private var showingShortcutConfig = false
    @State private var settingsObserver: Any?
    
    var body: some View {
        VStack(spacing: 24) {
            // App Header
            VStack(spacing: 8) {
                Image(systemName: "keyboard")
                    .font(.system(size: 48))
                    .foregroundColor(.accentColor)
                
                Text("KeysOnTop")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Keyboard shortcuts overlay for macOS")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Status Section
            VStack(spacing: 16) {
                // Permissions Status
                HStack {
                    Image(systemName: permissionsManager.hasAccessibilityPermissions ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                        .foregroundColor(permissionsManager.hasAccessibilityPermissions ? .green : .orange)
                    
                    Text("Accessibility Permissions")
                        .font(.headline)
                    
                    Spacer()
                    
                    if !permissionsManager.hasAccessibilityPermissions {
                        Button("Grant Access") {
                            _ = permissionsManager.requestAccessibilityPermissions()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.regularMaterial)
                )
                
                // Current Application Status
                if let app = overlayController.currentApplication {
                    HStack {
                        Image(systemName: "app.badge")
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading) {
                            Text("Active Application")
                                .font(.headline)
                            Text(app.name)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text("\(overlayController.currentShortcuts.count) shortcuts")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.regularMaterial)
                    )
                }
            }
            
            // Instructions
            VStack(spacing: 12) {
                Text("How to use:")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Button(action: { showingShortcutConfig = true }) {
                            Text(shortcutConfigManager.globalShortcut)
                                .font(.system(.body, design: .monospaced))
                                .fontWeight(.bold)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.2))
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                        .buttonStyle(.plain)
                        
                        Text("Show/hide shortcuts overlay (click to configure)")
                            .font(.subheadline)
                    }
                    
                    HStack {
                        Text("⎋")
                            .font(.system(.body, design: .monospaced))
                            .fontWeight(.bold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                        
                        Text("Hide overlay")
                            .font(.subheadline)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Spacer()
            
            // Action Buttons
            HStack(spacing: 12) {
                Button("Settings") {
                    openSettings()
                }
                .buttonStyle(.bordered)
                
                Button("Test Overlay") {
                    overlayController.showOverlay()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!permissionsManager.hasAccessibilityPermissions)
            }
        }
        .padding()
        .frame(maxWidth: 400)
        .onAppear {
            permissionsManager.checkPermissions()
            setupSettingsObserver()
        }
        .onDisappear {
            if let observer = settingsObserver {
                NotificationCenter.default.removeObserver(observer)
            }
        }
        .sheet(isPresented: $showingShortcutConfig) {
            ShortcutConfigView(
                shortcutKey: $shortcutConfigManager.globalShortcut,
                onSave: { newShortcut in
                    shortcutConfigManager.saveShortcut(newShortcut)
                    showingShortcutConfig = false
                }
            )
            .frame(width: 400, height: 300)
        }
    }
    
    private func openSettings() {
        SettingsWindowController.showSettings(
            overlayController: overlayController,
            permissionsManager: permissionsManager
        )
    }
    
    private func setupSettingsObserver() {
        settingsObserver = NotificationCenter.default.addObserver(
            forName: .showSettings,
            object: nil,
            queue: .main
        ) { _ in
            openSettings()
        }
    }
}

#Preview {
    MainView()
        .environmentObject(OverlayController())
        .environmentObject(PermissionsManager())
}