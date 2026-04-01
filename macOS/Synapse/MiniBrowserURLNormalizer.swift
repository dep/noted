import Foundation

/// Normalizes user-entered browser input into an absolute URL for `WKWebView.load`.
/// Shared with tests so URL rules stay consistent with `MiniBrowserController.load`.
enum MiniBrowserURLNormalizer {
    /// Returns the normalized URL string and `URL` value, or `nil` if input is empty or invalid.
    static func normalizedURL(for input: String) -> (string: String, url: URL)? {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let normalized: String
        if trimmed.hasPrefix("http://") || trimmed.hasPrefix("https://") {
            normalized = trimmed
        } else {
            normalized = "https://\(trimmed)"
        }

        guard let url = URL(string: normalized) else { return nil }
        return (normalized, url)
    }
}
