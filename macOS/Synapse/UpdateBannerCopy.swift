import Foundation

/// Strings and icon choice for `UpdateBannerView`, kept testable separately from SwiftUI layout.
enum UpdateBannerCopy {
    static func iconName(downloadProgress: Double?, restartRequired: Bool) -> String {
        if restartRequired { return "checkmark.circle.fill" }
        if downloadProgress != nil { return "arrow.down.circle.fill" }
        return "arrow.down.circle.fill"
    }

    static func titleText(version: String, downloadProgress: Double?, restartRequired: Bool) -> String {
        if restartRequired { return "Synapse v\(version) installed" }
        if let progress = downloadProgress {
            let pct = Int(progress * 100)
            return "Downloading v\(version)… \(pct)%"
        }
        return "Update available: v\(version)"
    }

    static func subtitleText(restartRequired: Bool) -> String {
        if restartRequired { return "Restart to finish updating" }
        return "Click Install to update automatically"
    }
}
