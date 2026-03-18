import SwiftUI

/// AppDelegate adapter to handle application termination with unsaved changes
class SynapseAppDelegate: NSObject, NSApplicationDelegate {
    var appState: AppState?
    
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        guard let appState = appState else {
            return .terminateNow
        }
        
        // Check if any pane has unsaved changes
        if appState.hasUnsavedChanges() {
            // Show confirmation dialog
            let alert = NSAlert()
            alert.messageText = "You have unsaved changes."
            alert.informativeText = "Do you want to save your changes before quitting?"
            alert.alertStyle = .warning
            alert.addButton(withTitle: "Save & Exit")
            alert.addButton(withTitle: "Exit Without Saving")
            alert.addButton(withTitle: "Cancel")
            
            let response = alert.runModal()
            
            switch response {
            case .alertFirstButtonReturn: // Save & Exit
                // Save all unsaved changes
                appState.saveAllUnsavedChanges()
                return .terminateNow
                
            case .alertSecondButtonReturn: // Exit Without Saving
                return .terminateNow
                
            default: // Cancel (third button or ESC)
                return .terminateCancel
            }
        }
        
        return .terminateNow
    }
}

@main
struct SynapseApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var autoUpdater = AutoUpdater()
    @NSApplicationDelegateAdaptor(SynapseAppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            if appState.rootURL == nil {
                FolderPickerView()
                    .environmentObject(appState)
                    .tint(SynapseTheme.accent)
                    .preferredColorScheme(.dark)
                    .frame(minWidth: 560, minHeight: 420)
            } else {
                ContentView()
                    .environmentObject(appState)
                    .environmentObject(autoUpdater)
                    .tint(SynapseTheme.accent)
                    .preferredColorScheme(.dark)
                    .frame(minWidth: 900, minHeight: 600)
                    .onAppear {
                        autoUpdater.checkForUpdatesOnLaunch()
                        // Wire up app delegate to appState
                        appDelegate.appState = appState
                    }
            }
        }
        .defaultSize(width: 1320, height: 820)
        .windowResizability(.contentMinSize)
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Note…") {
                    appState.presentRootNoteSheet()
                }
                .keyboardShortcut("n", modifiers: .command)
                .disabled(appState.rootURL == nil)

                Button("Open Folder…") {
                    appState.pickFolder()
                }

                Button("Close Vault") {
                    appState.exitVault()
                }
                .keyboardShortcut("n", modifiers: [.command, .shift])
                .disabled(appState.rootURL == nil)
            }

            CommandGroup(after: .newItem) {
                Button("Quick Open…") {
                    appState.presentCommandPalette()
                }
                .keyboardShortcut("p", modifiers: .command)
                .disabled(appState.rootURL == nil)

                Button("Command Palette…") {
                    NotificationCenter.default.post(name: .commandKPressed, object: nil)
                }
                .keyboardShortcut("k", modifiers: .command)
                .disabled(appState.rootURL == nil)
            }

            CommandGroup(replacing: .saveItem) {
                Button("Save") {
                    appState.saveAndSyncCurrentFile()
                }
                .keyboardShortcut("s", modifiers: .command)
                .disabled(appState.selectedFile == nil)
            }

            CommandGroup(after: .textEditing) {
                Button("Find in Note…") {
                    appState.presentSearch(mode: .currentFile)
                }
                .keyboardShortcut("f", modifiers: .command)
                .disabled(appState.selectedFile == nil)

                Button("Find in All Notes…") {
                    appState.presentSearch(mode: .allFiles)
                }
                .keyboardShortcut("f", modifiers: [.command, .shift])
                .disabled(appState.rootURL == nil)

                Button("Find Next") {
                    NotificationCenter.default.post(name: .advanceSearchMatch, object: nil, userInfo: [SearchMatchKey.delta: 1])
                }
                .keyboardShortcut("g", modifiers: .command)
                .disabled(!appState.isSearchPresented || appState.searchMode != .currentFile)

                Button("Find Previous") {
                    NotificationCenter.default.post(name: .advanceSearchMatch, object: nil, userInfo: [SearchMatchKey.delta: -1])
                }
                .keyboardShortcut("g", modifiers: [.command, .shift])
                .disabled(!appState.isSearchPresented || appState.searchMode != .currentFile)
            }
        }

        Settings {
            SettingsView(settings: appState.settings)
                .environmentObject(appState)
                .preferredColorScheme(.dark)
                .frame(minWidth: 920, minHeight: 760)
        }
    }
}
