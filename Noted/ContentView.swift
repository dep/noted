import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var isLeftSidebarVisible = true
    @State private var isRightSidebarVisible = true
    @State private var isRelatedPaneVisible = true

    var body: some View {
        ZStack {
            AppBackdrop()

            VStack(spacing: 0) {
                headerBar
                Rectangle().fill(NotedTheme.border).frame(height: 1)

                HSplitView {
                    if isLeftSidebarVisible {
                        leftSidebar
                            .frame(minWidth: 220, idealWidth: 280, maxWidth: 420)
                            .background(NotedTheme.panel)
                    }

                    EditorView()
                        .frame(minWidth: 420)
                        .background(NotedTheme.editorShell)

                    if isRightSidebarVisible {
                        TerminalPaneView()
                            .frame(minWidth: 280, idealWidth: 340, maxWidth: 620)
                            .background(NotedTheme.panel)
                    }
                }
            }

            if appState.isCommandPalettePresented {
                CommandPaletteView()
                    .environmentObject(appState)
                    .transition(.opacity)
                    .zIndex(1)
            }

            Group {
                Button("") { appState.presentCommandPalette() }
                    .keyboardShortcut("k", modifiers: .command)
                    .hidden()
                Button("") { appState.presentCommandPalette() }
                    .keyboardShortcut("p", modifiers: .command)
                    .hidden()
            }
        }
        .animation(.easeInOut(duration: 0.14), value: appState.isCommandPalettePresented)
        .sheet(
            isPresented: Binding(
                get: { appState.isRootNoteSheetPresented },
                set: { if !$0 { appState.dismissRootNoteSheet() } }
            )
        ) {
            RootNoteSheet()
                .environmentObject(appState)
        }
    }

    @ViewBuilder
    private var leftSidebar: some View {
        if isRelatedPaneVisible {
            VSplitView {
                FileTreeView()
                    .frame(minHeight: 260)

                RelatedLinksPaneView()
                    .frame(minHeight: 180, idealHeight: 240)
            }
        } else {
            FileTreeView()
        }
    }

    private var headerBar: some View {
        HStack(spacing: 12) {
            HStack(spacing: 10) {
                Text("Noted")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(NotedTheme.textPrimary)

                if let rootURL = appState.rootURL {
                    Text(rootURL.lastPathComponent)
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(NotedTheme.textMuted)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 4, style: .continuous))
                }
            }

            Spacer(minLength: 0)

            if let file = appState.selectedFile {
                HStack(spacing: 8) {
                    Text(file.lastPathComponent)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(NotedTheme.textSecondary)
                        .lineLimit(1)

                    if appState.isDirty {
                        TinyBadge(text: "Unsaved", color: NotedTheme.success)
                    }
                }
            }

            HStack(spacing: 8) {
                headerToggleButton(
                    systemName: isLeftSidebarVisible ? "sidebar.left" : "sidebar.left",
                    isActive: isLeftSidebarVisible,
                    action: { isLeftSidebarVisible.toggle() },
                    help: isLeftSidebarVisible ? "Hide Left Sidebar" : "Show Left Sidebar"
                )

                headerToggleButton(
                    systemName: isRelatedPaneVisible ? "rectangle.bottomthird.inset.filled" : "rectangle.bottomthird.inset.filled",
                    isActive: isRelatedPaneVisible,
                    action: { isRelatedPaneVisible.toggle() },
                    help: isRelatedPaneVisible ? "Collapse Related Notes" : "Expand Related Notes"
                )
                .disabled(!isLeftSidebarVisible)
                .opacity(isLeftSidebarVisible ? 1 : 0.5)

                headerToggleButton(
                    systemName: isRightSidebarVisible ? "sidebar.right" : "sidebar.right",
                    isActive: isRightSidebarVisible,
                    action: { isRightSidebarVisible.toggle() },
                    help: isRightSidebarVisible ? "Hide Right Sidebar" : "Show Right Sidebar"
                )

                Button(action: appState.goBack) {
                    Image(systemName: "chevron.left")
                }
                .buttonStyle(ChromeButtonStyle())
                .disabled(!appState.canGoBack)
                .keyboardShortcut("[", modifiers: .command)
                .help("Go Back (⌘[)")

                Button(action: appState.goForward) {
                    Image(systemName: "chevron.right")
                }
                .buttonStyle(ChromeButtonStyle())
                .disabled(!appState.canGoForward)
                .keyboardShortcut("]", modifiers: .command)
                .help("Go Forward (⌘])")

                Button(action: appState.pickFolder) {
                    Image(systemName: "folder.badge.plus")
                }
                .buttonStyle(ChromeButtonStyle())
                .keyboardShortcut("o", modifiers: [.command, .shift])
                .help("Open Folder (⇧⌘O)")

                if appState.selectedFile != nil {
                    Button(action: { appState.saveCurrentFile(content: appState.fileContent) }) {
                        Image(systemName: "square.and.arrow.down")
                    }
                    .buttonStyle(PrimaryChromeButtonStyle())
                    .keyboardShortcut("s", modifiers: .command)
                    .help("Save (⌘S)")
                    .opacity(appState.isDirty ? 1 : 0.78)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(NotedTheme.panelElevated)
    }

    private func headerToggleButton(systemName: String, isActive: Bool, action: @escaping () -> Void, help: String) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .foregroundStyle(isActive ? NotedTheme.textPrimary : NotedTheme.textMuted)
        }
        .buttonStyle(ChromeButtonStyle())
        .overlay {
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .stroke(isActive ? NotedTheme.accent.opacity(0.45) : Color.clear, lineWidth: 1)
        }
        .help(help)
    }
}

private struct RootNoteSheet: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var errorMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("New Note")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(NotedTheme.textPrimary)

            VStack(alignment: .leading, spacing: 8) {
                Text("Filename")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(NotedTheme.textSecondary)

                TextField("Inbox", text: $name)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit(createNote)

                Text("Creates the note in your workspace root. `.md` is added automatically.")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(NotedTheme.textMuted)
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.red)
            }

            HStack {
                Spacer()
                Button("Cancel") {
                    appState.dismissRootNoteSheet()
                    dismiss()
                }
                Button("Create", action: createNote)
                    .keyboardShortcut(.defaultAction)
            }
        }
        .padding(20)
        .frame(width: 360)
    }

    private func createNote() {
        do {
            _ = try appState.createNote(named: name)
            appState.dismissRootNoteSheet()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
