import XCTest
@testable import Synapse

/// Tests for `ThemeEnvironment` — reactive theme tokens and light/dark detection used across the UI.
@MainActor
final class ThemeEnvironmentTests: XCTestCase {

    private var previousShared: ThemeEnvironment?

    override func setUp() {
        super.setUp()
        previousShared = ThemeEnvironment.shared
    }

    override func tearDown() {
        ThemeEnvironment.shared = previousShared
        previousShared = nil
        super.tearDown()
    }

    func test_init_defaultsToSynapseDarkPalette() {
        let env = ThemeEnvironment()
        XCTAssertEqual(env.theme.name, AppTheme.synapseDark.name)
        XCTAssertNotNil(env.canvas)
        XCTAssertNotNil(env.accent)
    }

    func test_isLightTheme_falseForSynapseDark() {
        let env = ThemeEnvironment()
        env.theme = .synapseDark
        XCTAssertFalse(env.isLightTheme)
    }

    func test_isLightTheme_trueForSynapseLight() {
        let env = ThemeEnvironment()
        env.theme = .synapseLight
        XCTAssertTrue(env.isLightTheme)
    }

    func test_nsAppearance_darkForDarkTheme() {
        let env = ThemeEnvironment()
        env.theme = .synapseDark
        XCTAssertEqual(env.nsAppearance.name, NSAppearance.Name.darkAqua)
    }

    func test_nsAppearance_aquaForLightTheme() {
        let env = ThemeEnvironment()
        env.theme = .synapseLight
        XCTAssertEqual(env.nsAppearance.name, NSAppearance.Name.aqua)
    }

    func test_observe_registersSharedAndMirrorsActiveThemeFromSettings() {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }
        try! FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        let configPath = tempDir.appendingPathComponent("settings-test.json").path
        let settings = SettingsManager(configPath: configPath)
        settings.activeThemeName = "Dracula (Dark)"

        let env = ThemeEnvironment()
        env.observe(settings)

        XCTAssertEqual(env.theme.name, "Dracula (Dark)")
        XCTAssertTrue(ThemeEnvironment.shared === env)

        settings.activeThemeName = "Synapse (Light)"
        let drained = expectation(description: "Drain main queue for Combine sink")
        DispatchQueue.main.async { drained.fulfill() }
        wait(for: [drained], timeout: 2.0)
        XCTAssertEqual(env.theme.name, "Synapse (Light)")
    }
}
