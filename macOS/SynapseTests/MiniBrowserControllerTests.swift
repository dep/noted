import XCTest
@testable import Synapse

/// Tests for `MiniBrowserController.load` — URL normalization before `WKWebView.load` (embedded browser pane).
@MainActor
final class MiniBrowserControllerTests: XCTestCase {

    func test_load_emptyInput_doesNotChangeUrlText() {
        let c = MiniBrowserController()
        let before = c.urlText
        c.load("   \n  ")
        XCTAssertEqual(c.urlText, before)
    }

    func test_load_preservesHttpURL() {
        let c = MiniBrowserController()
        c.load("http://example.com/path")
        XCTAssertEqual(c.urlText, "http://example.com/path")
    }

    func test_load_preservesHttpsURL() {
        let c = MiniBrowserController()
        c.load("https://example.org/")
        XCTAssertEqual(c.urlText, "https://example.org/")
    }

    func test_load_prependsHttps_whenSchemeOmitted() {
        let c = MiniBrowserController()
        c.load("example.com")
        XCTAssertEqual(c.urlText, "https://example.com")
    }

    func test_load_trimsWhitespaceBeforeNormalization() {
        let c = MiniBrowserController()
        c.load("  news.ycombinator.com  ")
        XCTAssertEqual(c.urlText, "https://news.ycombinator.com")
    }
}
