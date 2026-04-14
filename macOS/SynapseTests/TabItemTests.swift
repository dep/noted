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

    func test_displayName_dateTab_returnsIso8601Date() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let date = try XCTUnwrap(calendar.date(from: DateComponents(year: 2024, month: 3, day: 15)))
        XCTAssertEqual(TabItem.date(date).displayName, "2024-03-15")
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
        XCTAssertTrue(TabItem.date(Date()).isDate)
    }

    func test_isDate_fileTab_returnsFalse() {
        let tab = TabItem.file(URL(fileURLWithPath: "/vault/note.md"))
        XCTAssertFalse(tab.isDate)
    }

    func test_isDate_tagTab_returnsFalse() {
        XCTAssertFalse(TabItem.tag("swift").isDate)
    }

    func test_isDate_graphTab_returnsFalse() {
        XCTAssertFalse(TabItem.graph.isDate)
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

    // MARK: - dateValue

    func test_dateValue_dateTab_returnsAssociatedDate() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let date = try XCTUnwrap(calendar.date(from: DateComponents(year: 2025, month: 12, day: 1)))
        XCTAssertEqual(TabItem.date(date).dateValue, date)
    }

    func test_dateValue_nonDateTabs_returnNil() {
        XCTAssertNil(TabItem.file(URL(fileURLWithPath: "/a.md")).dateValue)
        XCTAssertNil(TabItem.tag("t").dateValue)
        XCTAssertNil(TabItem.graph.dateValue)
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

    func test_dateTabEquality_sameInstant_isEqual() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let date = try XCTUnwrap(calendar.date(from: DateComponents(year: 2024, month: 7, day: 4)))
        XCTAssertEqual(TabItem.date(date), TabItem.date(date))
    }

    func test_dateTabEquality_differentCalendarDays_isNotEqual() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let a = try XCTUnwrap(calendar.date(from: DateComponents(year: 2024, month: 1, day: 1)))
        let b = try XCTUnwrap(calendar.date(from: DateComponents(year: 2024, month: 1, day: 2)))
        XCTAssertNotEqual(TabItem.date(a), TabItem.date(b))
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

    func test_differentTabTypes_dateVsFile_areNotEqual() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let date = try XCTUnwrap(calendar.date(from: DateComponents(year: 2024, month: 2, day: 29)))
        let url = URL(fileURLWithPath: "/vault/note.md")
        XCTAssertNotEqual(TabItem.date(date), TabItem.file(url))
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
