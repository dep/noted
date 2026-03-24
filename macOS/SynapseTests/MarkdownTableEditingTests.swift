import XCTest
@testable import Synapse

final class MarkdownTableEditingTests: XCTestCase {
    func test_tableLayout_detectsCellsInValidTable() {
        let text = "| Name | Value |\n| --- | --- |\n| One | 1 |"

        let layout = MarkdownTableEditing.tableLayout(in: text, at: 5)

        XCTAssertEqual(layout?.columnCount, 2)
        XCTAssertEqual(layout?.cells.count, 4)
        XCTAssertEqual((text as NSString).substring(with: layout!.cells[0].contentRange), "Name")
        XCTAssertEqual((text as NSString).substring(with: layout!.cells[3].contentRange), "1")
    }

    func test_tableLayout_nextAndPreviousCellNavigateAcrossRows() {
        let text = "| Name | Value |\n| --- | --- |\n| One | 1 |"
        let ns = text as NSString
        let nameLocation = ns.range(of: "Name").location
        let oneLocation = ns.range(of: "One").location

        let layout = try! XCTUnwrap(MarkdownTableEditing.tableLayout(in: text, at: nameLocation))

        XCTAssertEqual((text as NSString).substring(with: try! XCTUnwrap(layout.nextCell(after: nameLocation)).contentRange), "Value")
        XCTAssertEqual((text as NSString).substring(with: try! XCTUnwrap(layout.previousCell(before: oneLocation)).contentRange), "Value")
    }

    func test_insertionForNewRow_createsEmptyRowWithMatchingColumns() {
        let text = "| Name | Value |\n| --- | --- |\n| One | 1 |"
        let ns = text as NSString
        let location = ns.range(of: "One").location

        let insertion = try! XCTUnwrap(MarkdownTableEditing.insertionForNewRow(in: text, at: location))

        XCTAssertEqual(insertion.replacement, "\n|   |   |")
        XCTAssertEqual(insertion.selection.location, insertion.range.location + 3)
    }

    func test_insertTab_movesToNextTableCell() {
        let textView = LinkAwareTextView(frame: .zero)
        textView.isEditable = true
        textView.setPlainText("| Name | Value |\n| --- | --- |\n| One | 1 |")
        let ns = textView.string as NSString
        textView.setSelectedRange(NSRange(location: ns.range(of: "Name").location, length: 0))

        textView.insertTab(nil)

        XCTAssertEqual(textView.selectedRange().location, ns.range(of: "Value").location)
    }

    func test_insertNewline_inTableAddsEmptyRow() {
        let textView = LinkAwareTextView(frame: .zero)
        textView.isEditable = true
        textView.setPlainText("| Name | Value |\n| --- | --- |\n| One | 1 |")
        let ns = textView.string as NSString
        textView.setSelectedRange(NSRange(location: ns.range(of: "One").location, length: 0))

        textView.insertNewline(nil)

        XCTAssertTrue(textView.string.contains("| One | 1 |\n|   |   |"))
    }
}
