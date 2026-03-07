import SwiftUI

struct FolderPickerView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        ZStack {
            AppBackdrop()

            VStack {
                Spacer(minLength: 0)

                VStack(spacing: 18) {
                    // App Icon Representation
                    ZStack {
                        // Glow effect
                        Circle()
                            .fill(NotedTheme.accent.opacity(0.20))
                            .frame(width: 120, height: 120)
                            .blur(radius: 20)
                        
                        // App icon background - macOS icon shape
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.15, green: 0.16, blue: 0.18),
                                        Color(red: 0.10, green: 0.11, blue: 0.13)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 96, height: 96)
                            .shadow(color: .black.opacity(0.4), radius: 8, x: 0, y: 4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 22, style: .continuous)
                                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
                            )
                        
                        // Icon symbol
                        Image(systemName: "doc.text.fill")
                            .font(.system(size: 42, weight: .semibold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.90, green: 0.92, blue: 0.95),
                                        Color(red: 0.75, green: 0.78, blue: 0.82)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                    }
                    .padding(.bottom, 8)

                    VStack(spacing: 10) {
                        Text("Noted")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(NotedTheme.textPrimary)

                        Text("A sleek markdown workspace with a focused editor, polished navigation, and a built-in terminal.")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(NotedTheme.textSecondary)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: 360)
                    }

                    HStack(spacing: 8) {
                        TinyBadge(text: "Dark canvas")
                        TinyBadge(text: "Live markdown")
                        TinyBadge(text: "Terminal ready")
                    }

                    Button(action: appState.pickFolder) {
                        Label("Open Folder…", systemImage: "folder.badge.plus")
                            .frame(width: 210)
                    }
                    .buttonStyle(PrimaryChromeButtonStyle())
                    .keyboardShortcut(.defaultAction)

                    Text("Choose a folder of notes to load your workspace.")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(NotedTheme.textMuted)
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 28)
                .frame(maxWidth: 460)
                .notedPanel(radius: 6)

                Spacer(minLength: 0)
            }
            .padding(24)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
