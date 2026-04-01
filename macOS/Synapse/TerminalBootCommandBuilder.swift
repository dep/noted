import Foundation

/// Builds the shell command sent to the embedded terminal on startup (`LocalTerminalView`).
enum TerminalBootCommandBuilder {
    /// Escapes spaces in `workingDirectory` and optionally appends a user-defined on-boot command.
    static func shellCommandLine(workingDirectory: String, onBootCommand: String?) -> String {
        let escaped = workingDirectory.replacingOccurrences(of: " ", with: "\\ ")
        if let custom = onBootCommand, !custom.isEmpty {
            return "cd \(escaped) && \(custom)"
        }
        return "cd \(escaped)"
    }
}
