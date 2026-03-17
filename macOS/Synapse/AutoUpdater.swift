import Foundation
import AppKit

/// AutoUpdater handles silent background updates from GitHub Releases.
/// On every app launch, it checks for a newer version and installs it automatically.
@MainActor
class AutoUpdater: ObservableObject {
    @Published var updateAvailable: Bool = false
    @Published var latestVersion: String?
    @Published var updateInstalled: Bool = false
    
    private let repoOwner = "dep"
    private let repoName = "synapse"
    private let currentVersion: String
    
    init() {
        // Read version from Info.plist
        if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            self.currentVersion = version
        } else {
            self.currentVersion = "1.0"
        }
    }
    
    /// Check for updates on app launch. Non-blocking, runs in background.
    func checkForUpdatesOnLaunch() {
        Task {
            await checkForUpdates()
        }
    }
    
    /// Check GitHub Releases API for the latest version
    private func checkForUpdates() async {
        do {
            guard let latestRelease = try await fetchLatestRelease() else {
                // No release found, fail silently
                return
            }
            
            let latestVersion = latestRelease.tagName.trimmingCharacters(in: CharacterSet(charactersIn: "v"))
            self.latestVersion = latestVersion
            
            if isNewerVersion(latest: latestVersion, current: currentVersion) {
                updateAvailable = true
                await downloadAndInstallUpdate(release: latestRelease)
            }
        } catch {
            // Network error or API failure - fail silently
            print("[AutoUpdater] Update check failed: \(error)")
        }
    }
    
    /// Fetch the latest release from GitHub API
    private func fetchLatestRelease() async throws -> GitHubRelease? {
        let urlString = "https://api.github.com/repos/\(repoOwner)/\(repoName)/releases/latest"
        guard let url = URL(string: urlString) else { return nil }
        
        var request = URLRequest(url: url)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 10.0
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            return nil
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(GitHubRelease.self, from: data)
    }
    
    /// Download and install the update in the background
    private func downloadAndInstallUpdate(release: GitHubRelease) async {
        do {
            // Find the appropriate asset (.app.zip, .dmg, or .app)
            guard let assetURL = findDownloadAsset(in: release) else {
                print("[AutoUpdater] No suitable download asset found")
                return
            }
            
            let downloadedFile = try await downloadFile(from: assetURL)
            try await installUpdate(from: downloadedFile)
            
            // Mark update as installed
            await MainActor.run {
                updateInstalled = true
            }
        } catch {
            print("[AutoUpdater] Update download/install failed: \(error)")
        }
    }
    
    /// Find the appropriate download asset from the release
    private func findDownloadAsset(in release: GitHubRelease) -> URL? {
        // Look for .zip, .dmg, or .app assets
        let preferredExtensions = [".app.zip", ".zip", ".dmg", ".app"]
        
        for ext in preferredExtensions {
            if let asset = release.assets.first(where: { $0.name.hasSuffix(ext) }) {
                return URL(string: asset.browserDownloadUrl)
            }
        }
        
        return nil
    }
    
    /// Download file from URL
    private func downloadFile(from url: URL) async throws -> URL {
        let (tempURL, response) = try await URLSession.shared.download(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw UpdateError.downloadFailed
        }
        
        // Move to a persistent temp location
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = url.lastPathComponent
        let destinationURL = tempDir.appendingPathComponent(fileName)
        
        // Remove existing file if present
        try? FileManager.default.removeItem(at: destinationURL)
        try FileManager.default.moveItem(at: tempURL, to: destinationURL)
        
        return destinationURL
    }
    
    /// Install the update by replacing the current app bundle
    private func installUpdate(from fileURL: URL) async throws {
        let currentAppURL = Bundle.main.bundleURL
        let fileName = fileURL.lastPathComponent
        
        if fileName.hasSuffix(".zip") || fileName.hasSuffix(".app.zip") {
            // Unzip the archive
            let unzipDestination = fileURL.deletingLastPathComponent().appendingPathComponent("SynapseUpdate")
            try? FileManager.default.removeItem(at: unzipDestination)
            try FileManager.default.createDirectory(at: unzipDestination, withIntermediateDirectories: true)
            
            // Unzip using system unzip command
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/unzip")
            process.arguments = ["-q", fileURL.path, "-d", unzipDestination.path]
            try process.run()
            process.waitUntilExit()
            
            guard process.terminationStatus == 0 else {
                throw UpdateError.installFailed
            }
            
            // Find the .app bundle in the unzipped content
            let contents = try FileManager.default.contentsOfDirectory(at: unzipDestination, includingPropertiesForKeys: nil)
            guard let newAppURL = contents.first(where: { $0.pathExtension == "app" }) else {
                throw UpdateError.installFailed
            }
            
            try replaceCurrentApp(with: newAppURL, currentApp: currentAppURL)
        } else if fileName.hasSuffix(".app") {
            // Direct .app bundle
            try replaceCurrentApp(with: fileURL, currentApp: currentAppURL)
        } else if fileName.hasSuffix(".dmg") {
            // Mount DMG and copy app
            try await installFromDMG(dmgURL: fileURL, currentApp: currentAppURL)
        } else {
            throw UpdateError.unsupportedFormat
        }
    }
    
    /// Replace the current app bundle with the new one
    private func replaceCurrentApp(with newAppURL: URL, currentApp: URL) throws {
        let backupURL = currentApp.deletingLastPathComponent().appendingPathComponent("Synapse.backup")
        
        // Remove old backup if exists
        try? FileManager.default.removeItem(at: backupURL)
        
        // Move current app to backup
        try FileManager.default.moveItem(at: currentApp, to: backupURL)
        
        do {
            // Copy new app to application location
            try FileManager.default.copyItem(at: newAppURL, to: currentApp)
            
            // Remove backup after successful install
            try? FileManager.default.removeItem(at: backupURL)
        } catch {
            // Restore backup on failure
            try? FileManager.default.removeItem(at: currentApp)
            try? FileManager.default.moveItem(at: backupURL, to: currentApp)
            throw error
        }
    }
    
    /// Install from a DMG file
    private func installFromDMG(dmgURL: URL, currentApp: URL) async throws {
        // Mount the DMG
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/hdiutil")
        process.arguments = ["attach", dmgURL.path, "-nobrowse", "-quiet"]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        
        try process.run()
        process.waitUntilExit()
        
        guard process.terminationStatus == 0 else {
            throw UpdateError.installFailed
        }
        
        // Parse mount point from output
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        guard let output = String(data: data, encoding: .utf8),
              let mountPoint = output.components(separatedBy: "\t").last?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            throw UpdateError.installFailed
        }
        
        let mountURL = URL(fileURLWithPath: mountPoint)
        
        defer {
            // Unmount DMG
            let unmountProcess = Process()
            unmountProcess.executableURL = URL(fileURLWithPath: "/usr/bin/hdiutil")
            unmountProcess.arguments = ["detach", mountPoint, "-quiet"]
            try? unmountProcess.run()
            unmountProcess.waitUntilExit()
        }
        
        // Find .app in mounted volume
        let contents = try FileManager.default.contentsOfDirectory(at: mountURL, includingPropertiesForKeys: nil)
        guard let newAppURL = contents.first(where: { $0.pathExtension == "app" }) else {
            throw UpdateError.installFailed
        }
        
        try replaceCurrentApp(with: newAppURL, currentApp: currentApp)
    }
    
    /// Compare version strings (semantic versioning)
    private func isNewerVersion(latest: String, current: String) -> Bool {
        let latestComponents = latest.split(separator: ".").compactMap { Int($0) }
        let currentComponents = current.split(separator: ".").compactMap { Int($0) }
        
        for i in 0..<max(latestComponents.count, currentComponents.count) {
            let latestPart = i < latestComponents.count ? latestComponents[i] : 0
            let currentPart = i < currentComponents.count ? currentComponents[i] : 0
            
            if latestPart > currentPart {
                return true
            } else if latestPart < currentPart {
                return false
            }
        }
        
        return false
    }
}

// MARK: - Models

struct GitHubRelease: Codable {
    let tagName: String
    let name: String
    let assets: [GitHubAsset]
}

struct GitHubAsset: Codable {
    let name: String
    let browserDownloadUrl: String
    let size: Int
}

enum UpdateError: Error {
    case downloadFailed
    case installFailed
    case unsupportedFormat
}
