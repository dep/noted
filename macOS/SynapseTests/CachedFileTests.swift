import XCTest
@testable import Synapse

/// Tests for `CachedFile` — the vault index cache entry for parsed note content.
/// Wrong equality or field handling would corrupt graph, search, and link features.
final class CachedFileTests: XCTestCase {

    func test_equatable_sameValues_areEqual() {
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        let a = CachedFile(
            content: "hello",
            modificationDate: date,
            wikiLinks: ["alpha", "beta"],
            tags: ["work"]
        )
        let b = CachedFile(
            content: "hello",
            modificationDate: date,
            wikiLinks: ["alpha", "beta"],
            tags: ["work"]
        )
        XCTAssertEqual(a, b)
    }

    func test_equatable_differentContent_notEqual() {
        let date = Date()
        let a = CachedFile(content: "a", modificationDate: date, wikiLinks: [], tags: [])
        let b = CachedFile(content: "b", modificationDate: date, wikiLinks: [], tags: [])
        XCTAssertNotEqual(a, b)
    }

    func test_equatable_differentWikiLinks_notEqual() {
        let date = Date()
        let base = CachedFile(content: "x", modificationDate: date, wikiLinks: ["a"], tags: [])
        let other = CachedFile(content: "x", modificationDate: date, wikiLinks: ["b"], tags: [])
        XCTAssertNotEqual(base, other)
    }

    func test_equatable_differentTags_notEqual() {
        let date = Date()
        let base = CachedFile(content: "x", modificationDate: date, wikiLinks: [], tags: ["t1"])
        let other = CachedFile(content: "x", modificationDate: date, wikiLinks: [], tags: ["t2"])
        XCTAssertNotEqual(base, other)
    }

    func test_equatable_nilVsNonNilModificationDate_notEqual() {
        let withDate = CachedFile(content: "x", modificationDate: Date(), wikiLinks: [], tags: [])
        let withoutDate = CachedFile(content: "x", modificationDate: nil, wikiLinks: [], tags: [])
        XCTAssertNotEqual(withDate, withoutDate)
    }
}
