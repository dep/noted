import XCTest
@testable import Synapse

/// Tests for `CachedFile` — the vault file snapshot used by `NoteContentCache` for wikilinks and tags.
final class CachedFileTests: XCTestCase {

    func test_equatable_sameValues_equal() {
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        let a = CachedFile(
            content: "body",
            modificationDate: date,
            wikiLinks: ["alpha", "beta"],
            tags: ["work"]
        )
        let b = CachedFile(
            content: "body",
            modificationDate: date,
            wikiLinks: ["alpha", "beta"],
            tags: ["work"]
        )
        XCTAssertEqual(a, b)
    }

    func test_equatable_differentContent_notEqual() {
        let a = CachedFile(content: "a", modificationDate: nil, wikiLinks: [], tags: [])
        let b = CachedFile(content: "b", modificationDate: nil, wikiLinks: [], tags: [])
        XCTAssertNotEqual(a, b)
    }

    func test_equatable_differentWikiLinks_notEqual() {
        let a = CachedFile(content: "x", modificationDate: nil, wikiLinks: ["a"], tags: [])
        let b = CachedFile(content: "x", modificationDate: nil, wikiLinks: ["b"], tags: [])
        XCTAssertNotEqual(a, b)
    }

    func test_equatable_differentTags_notEqual() {
        let a = CachedFile(content: "x", modificationDate: nil, wikiLinks: [], tags: ["t1"])
        let b = CachedFile(content: "x", modificationDate: nil, wikiLinks: [], tags: ["t2"])
        XCTAssertNotEqual(a, b)
    }

    func test_equatable_modificationDateNil_vsSet_notEqual() {
        let a = CachedFile(content: "x", modificationDate: nil, wikiLinks: [], tags: [])
        let b = CachedFile(content: "x", modificationDate: Date(), wikiLinks: [], tags: [])
        XCTAssertNotEqual(a, b)
    }
}
