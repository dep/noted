import XCTest
import SwiftUI
@testable import Synapse

/// Tests for folder color/icon palette and `FolderAppearance` — persisted per-folder UI metadata.
final class FolderAppearanceTests: XCTestCase {

    // MARK: - FolderColor.palette

    func test_folderColor_palette_hasTwelveUniqueIds() {
        let ids = FolderColor.palette.map(\.id)
        XCTAssertEqual(ids.count, 12)
        XCTAssertEqual(Set(ids).count, 12, "Palette ids must be unique for settings keys")
    }

    func test_folderColor_colorForKnownId_returnsMatch() {
        let rose = FolderColor.color(for: "rose")
        XCTAssertNotNil(rose)
        XCTAssertEqual(rose?.id, "rose")
        XCTAssertEqual(rose?.label, "Rose")
    }

    func test_folderColor_colorForUnknownId_returnsNil() {
        XCTAssertNil(FolderColor.color(for: "not-a-real-key"))
    }

    // MARK: - FolderIcon.set

    func test_folderIcon_set_hasTwentyUniqueIds() {
        let ids = FolderIcon.set.map(\.id)
        XCTAssertEqual(ids.count, 20)
        XCTAssertEqual(Set(ids).count, 20, "Icon ids must be unique for settings keys")
    }

    func test_folderIcon_iconForKnownId_returnsSymbolName() {
        let star = FolderIcon.icon(for: "star")
        XCTAssertNotNil(star)
        XCTAssertEqual(star?.symbolName, "star")
    }

    func test_folderIcon_iconForUnknownId_returnsNil() {
        XCTAssertNil(FolderIcon.icon(for: "unknown-icon-key"))
    }

    // MARK: - FolderAppearance

    func test_folderAppearance_resolvedColor_nilWhenNoKey() {
        let sut = FolderAppearance(relativePath: "Notes", colorKey: nil, iconKey: nil)
        XCTAssertNil(sut.resolvedColor)
    }

    func test_folderAppearance_resolvedColor_nonNilForValidKey() {
        let sut = FolderAppearance(relativePath: "Notes", colorKey: "mint", iconKey: nil)
        XCTAssertNotNil(sut.resolvedColor)
    }

    func test_folderAppearance_resolvedSymbolName_nilWhenNoIconKey() {
        let sut = FolderAppearance(relativePath: "Notes", colorKey: nil, iconKey: nil)
        XCTAssertNil(sut.resolvedSymbolName)
    }

    func test_folderAppearance_resolvedSymbolName_nonNilForValidKey() {
        let sut = FolderAppearance(relativePath: "Notes", colorKey: nil, iconKey: "book")
        XCTAssertEqual(sut.resolvedSymbolName, "book.closed")
    }

    func test_folderAppearance_id_isRelativePath() {
        let sut = FolderAppearance(relativePath: "Projects/Work", colorKey: "sky", iconKey: "bolt")
        XCTAssertEqual(sut.id, "Projects/Work")
    }

    func test_folderAppearance_codable_roundTrip() throws {
        let original = FolderAppearance(relativePath: "A/B", colorKey: "teal", iconKey: "moon")
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(FolderAppearance.self, from: data)
        XCTAssertEqual(decoded, original)
    }
}
