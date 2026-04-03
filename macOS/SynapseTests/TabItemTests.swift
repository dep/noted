import XCTest
@testable import Synapse

/// Tests for the TabItem enum: display names, type helpers, and associated value accessors.
/// TabItem is the core data model for the tab system — if these helpers break,
/// tab labels show incorrect names and type-based UI logic silently misbehaves.
final class TabItemTests: XCTestCase {

    // MARK: - displayName

    func test_displayName_fileTab_returnsLastPathComponent() {
        let url = URL(fileURLWithPath: "/vault/notes/My Note.md")
        XCTAssertEqual(TabItem.file(url).displayName, "My Note.md")
    }

    func test_displayName_fileTab_withNoExtension_returnsFilename() {
        let url = URL(fileURLWithPath: "/vault/README")
        XCTAssertEqual(TabItem.file(url).displayName, "README")
    }

    func test_displayName_tagTab_returnsPoundPrefixedTagName() {
        XCTAssertEqual(TabItem.tag("swift").displayName, "#swift")
    }

    func test_displayName_tagTab_emptyTag_returnsPoundOnly() {
        XCTAssertEqual(TabItem.tag("").displayName, "#")
    }

    func test_displayName_graphTab_returnsGraph() {
        XCTAssertEqual(TabItem.graph.displayName, "Graph")
    }

    func test_displayName_dateTab_returnsYYYYMMDD() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let components = DateComponents(year: 2026, month: 4, day: 3)
        let date = calendar.date(from: components)!
        XCTAssertEqual(TabItem.date(date).displayName, "2026-04-03")
    }

    // MARK: - isFile

    func test_isFile_fileTab_returnsTrue() {
        let tab = TabItem.file(URL(fileURLWithPath: "/vault/note.md"))
        XCTAssertTrue(tab.isFile)
    }

    func test_isFile_tagTab_returnsFalse() {
        XCTAssertFalse(TabItem.tag("swift").isFile)
    }

    func test_isFile_graphTab_returnsFalse() {
        XCTAssertFalse(TabItem.graph.isFile)
    }

    // MARK: - isTag

    func test_isTag_tagTab_returnsTrue() {
        XCTAssertTrue(TabItem.tag("swift").isTag)
    }

    func test_isTag_fileTab_returnsFalse() {
        let tab = TabItem.file(URL(fileURLWithPath: "/vault/note.md"))
        XCTAssertFalse(tab.isTag)
    }

    func test_isTag_graphTab_returnsFalse() {
        XCTAssertFalse(TabItem.graph.isTag)
    }

    // MARK: - isGraph

    func test_isGraph_graphTab_returnsTrue() {
        XCTAssertTrue(TabItem.graph.isGraph)
    }

    func test_isGraph_fileTab_returnsFalse() {
        let tab = TabItem.file(URL(fileURLWithPath: "/vault/note.md"))
        XCTAssertFalse(tab.isGraph)
    }

    func test_isGraph_tagTab_returnsFalse() {
        XCTAssertFalse(TabItem.tag("swift").isGraph)
    }

    // MARK: - isDate

    func test_isDate_dateTab_returnsTrue() {
        let date = Date(timeIntervalSince1970: 0)
        XCTAssertTrue(TabItem.date(date).isDate)
    }

    func test_isDate_fileTab_returnsFalse() {
        let tab = TabItem.file(URL(fileURLWithPath: "/vault/note.md"))
        XCTAssertFalse(tab.isDate)
    }

    func test_isDate_graphTab_returnsFalse() {
        XCTAssertFalse(TabItem.graph.isDate)
    }

    // MARK: - dateValue

    func test_dateValue_dateTab_returnsAssociatedDate() {
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        XCTAssertEqual(TabItem.date(date).dateValue, date)
    }

    func test_dateValue_fileTab_returnsNil() {
        XCTAssertNil(TabItem.file(URL(fileURLWithPath: "/vault/note.md")).dateValue)
    }

    func test_dateValue_tagTab_returnsNil() {
        XCTAssertNil(TabItem.tag("swift").dateValue)
    }

    // MARK: - fileURL

    func test_fileURL_fileTab_returnsAssociatedURL() {
        let url = URL(fileURLWithPath: "/vault/note.md")
        XCTAssertEqual(TabItem.file(url).fileURL, url)
    }

    func test_fileURL_tagTab_returnsNil() {
        XCTAssertNil(TabItem.tag("swift").fileURL)
    }

    func test_fileURL_graphTab_returnsNil() {
        XCTAssertNil(TabItem.graph.fileURL)
    }

    func test_fileURL_dateTab_returnsNil() {
        XCTAssertNil(TabItem.date(Date()).fileURL)
    }

    // MARK: - tagName

    func test_tagName_tagTab_returnsAssociatedName() {
        XCTAssertEqual(TabItem.tag("swift").tagName, "swift")
    }

    func test_tagName_tagTab_multiWordTag_returnsFullName() {
        XCTAssertEqual(TabItem.tag("my-tag-name").tagName, "my-tag-name")
    }

    func test_tagName_fileTab_returnsNil() {
        let tab = TabItem.file(URL(fileURLWithPath: "/vault/note.md"))
        XCTAssertNil(tab.tagName)
    }

    func test_tagName_graphTab_returnsNil() {
        XCTAssertNil(TabItem.graph.tagName)
    }

    func test_tagName_dateTab_returnsNil() {
        XCTAssertNil(TabItem.date(Date()).tagName)
    }

    // MARK: - Hashable / Equatable

    func test_fileTabEquality_sameURL_isEqual() {
        let url = URL(fileURLWithPath: "/vault/note.md")
        XCTAssertEqual(TabItem.file(url), TabItem.file(url))
    }

    func test_fileTabEquality_differentURL_isNotEqual() {
        let urlA = URL(fileURLWithPath: "/vault/a.md")
        let urlB = URL(fileURLWithPath: "/vault/b.md")
        XCTAssertNotEqual(TabItem.file(urlA), TabItem.file(urlB))
    }

    func test_tagTabEquality_sameTag_isEqual() {
        XCTAssertEqual(TabItem.tag("swift"), TabItem.tag("swift"))
    }

    func test_tagTabEquality_differentTag_isNotEqual() {
        XCTAssertNotEqual(TabItem.tag("swift"), TabItem.tag("python"))
    }

    func test_graphTabEquality_isEqualToItself() {
        XCTAssertEqual(TabItem.graph, TabItem.graph)
    }

    func test_dateTabEquality_sameInstant_isEqual() {
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        XCTAssertEqual(TabItem.date(date), TabItem.date(date))
    }

    func test_dateTabEquality_differentInstant_isNotEqual() {
        let a = TabItem.date(Date(timeIntervalSince1970: 0))
        let b = TabItem.date(Date(timeIntervalSince1970: 1))
        XCTAssertNotEqual(a, b)
    }

    func test_differentTabTypes_fileVsGraph_areNotEqual() {
        let url = URL(fileURLWithPath: "/vault/note.md")
        XCTAssertNotEqual(TabItem.file(url), TabItem.graph)
    }

    func test_differentTabTypes_tagVsGraph_areNotEqual() {
        XCTAssertNotEqual(TabItem.tag("swift"), TabItem.graph)
    }

    func test_differentTabTypes_fileVsTag_areNotEqual() {
        let url = URL(fileURLWithPath: "/vault/note.md")
        XCTAssertNotEqual(TabItem.file(url), TabItem.tag("swift"))
    }

    func test_differentTabTypes_dateVsGraph_areNotEqual() {
        XCTAssertNotEqual(TabItem.date(Date()), TabItem.graph)
    }

    func test_tabItem_usableInSet_deduplicatesCorrectly() {
        let url = URL(fileURLWithPath: "/vault/note.md")
        let set: Set<TabItem> = [.file(url), .file(url), .tag("swift"), .graph]
        XCTAssertEqual(set.count, 3, "Set should deduplicate identical TabItems")
    }

    func test_tabItem_usableAsArrayElement_roundTripsViaContains() {
        let url = URL(fileURLWithPath: "/vault/note.md")
        let tabs: [TabItem] = [.file(url), .tag("swift"), .graph]

        XCTAssertTrue(tabs.contains(.file(url)))
        XCTAssertTrue(tabs.contains(.tag("swift")))
        XCTAssertTrue(tabs.contains(.graph))
        XCTAssertFalse(tabs.contains(.tag("other")))
    }
}
