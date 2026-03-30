import XCTest
@testable import Synapse

/// Tests for MarkdownTablePrettifier — the engine that re-formats raw
/// Markdown pipe-tables into aligned columns and adjusts the cursor offset.
///
/// This is critical functionality: every Tab keypress inside a table goes
/// through this code. A regression here silently corrupts table content or
/// drops the cursor to a wrong position.
final class MarkdownTablePrettifierTests: XCTestCase {

    // MARK: - Basic prettification

    func test_prettify_simpleTable_producesEquallyPaddedColumns() {
        let input = "| A | BB |\n| --- | --- |\n"
        let result = MarkdownTablePrettifier.prettify(tableText: input, cursorOffsetInTable: 0)
        XCTAssertNotNil(result)
        XCTAssertEqual(
            result?.formatted,
            "| A   | BB  |\n| --- | --- |\n",
            "Columns should pad to the same width (minimum 3) with spaces inside cells"
        )
    }

    func test_prettify_preservesTrailingNewline_whenInputHasOne() {
        let input = "| x |\n| --- |\n"
        let result = MarkdownTablePrettifier.prettify(tableText: input, cursorOffsetInTable: 0)
        XCTAssertNotNil(result)
        XCTAssertTrue(result?.formatted.hasSuffix("\n") == true)
    }

    func test_prettify_noTrailingNewline_outputHasNoTrailingNewline() {
        let input = "| x |\n| --- |"
        let result = MarkdownTablePrettifier.prettify(tableText: input, cursorOffsetInTable: 0)
        XCTAssertNotNil(result)
        XCTAssertFalse(result?.formatted.hasSuffix("\n") ?? true)
    }

    /// GitHub Actions checks out with LF, but editors on Windows use CRLF; prettify must accept both.
    func test_prettify_normalizesCRLF() {
        let input = "| a | b |\r\n| --- | --- |\r\n"
        let result = MarkdownTablePrettifier.prettify(tableText: input, cursorOffsetInTable: 0)
        XCTAssertNotNil(result)
        XCTAssertEqual(
            result?.formatted,
            "| a   | b   |\n| --- | --- |\n",
            "CRLF input should normalize to LF-only output with a trailing newline when the block ended with CRLF"
        )
    }

    // MARK: - Separator row handling

    func test_prettify_leftAligned_separatorHasNoPrefixOrSuffixColon() {
        let input = "| L |\n| --- |\n"
        let result = MarkdownTablePrettifier.prettify(tableText: input, cursorOffsetInTable: 0)
        XCTAssertNotNil(result)
        XCTAssertTrue(result?.formatted.contains("| --- |") == true)
        XCTAssertFalse(result?.formatted.contains(":---") ?? true)
    }

    func test_prettify_rightAligned_separatorHasSuffixColon() {
        let input = "| R |\n| --: |\n"
        let result = MarkdownTablePrettifier.prettify(tableText: input, cursorOffsetInTable: 0)
        XCTAssertNotNil(result)
        // Minimum column width is 3, so the separator grows to "---:" inside the cell.
        XCTAssertTrue(result?.formatted.contains("---:") == true)
    }

    func test_prettify_centerAligned_separatorHasBothColons() {
        let input = "| C |\n| :---: |\n"
        let result = MarkdownTablePrettifier.prettify(tableText: input, cursorOffsetInTable: 0)
        XCTAssertNotNil(result)
        XCTAssertTrue(result?.formatted.contains("| :---: |") == true)
    }

    // MARK: - Minimum column width

    func test_prettify_shortContent_columnWidthAtLeast3() {
        let input = "| a | b |\n| - | - |\n"
        let result = MarkdownTablePrettifier.prettify(tableText: input, cursorOffsetInTable: 0)
        XCTAssertNotNil(result)
        // Separator uses three dashes because minimum column width is 3
        XCTAssertTrue(result?.formatted.contains("| --- |") == true)
    }

    // MARK: - Guard / nil cases

    func test_prettify_onlyOneRow_returnsNil() {
        let input = "| Col |\n"

        let result = MarkdownTablePrettifier.prettify(tableText: input, cursorOffsetInTable: 0)

        XCTAssertNil(result, "A table with only a header row (no separator) must not be prettified")
    }

    func test_prettify_missingSeparatorRow_returnsNil() {
        let input = "| Col |\n| NotASeparator |\n"

        let result = MarkdownTablePrettifier.prettify(tableText: input, cursorOffsetInTable: 0)

        XCTAssertNil(result, "A table without a valid separator row must not be prettified")
    }

    func test_prettify_emptyString_returnsNil() {
        let result = MarkdownTablePrettifier.prettify(tableText: "", cursorOffsetInTable: 0)

        XCTAssertNil(result, "Prettifying an empty string must return nil")
    }

    // MARK: - Cell parsing

    func test_parseCells_leadingAndTrailingPipes_stripsExactlyOne() {
        let cells = MarkdownTablePrettifier.parseCells(from: "| Alpha | Beta |")

        XCTAssertEqual(cells.count, 2, "Should parse 2 cells from a 2-column row — got: \(cells)")
        XCTAssertEqual(cells[0].trimmingCharacters(in: .whitespaces), "Alpha")
        XCTAssertEqual(cells[1].trimmingCharacters(in: .whitespaces), "Beta")
    }

    func test_parseCells_noPipes_returnsSingleCell() {
        let cells = MarkdownTablePrettifier.parseCells(from: "NoPipes")

        XCTAssertEqual(cells.count, 1)
        XCTAssertEqual(cells[0], "NoPipes")
    }

    func test_parseCells_emptyString_returnsSingleEmptyString() {
        let cells = MarkdownTablePrettifier.parseCells(from: "")

        XCTAssertEqual(cells.count, 1)
        XCTAssertEqual(cells[0], "")
    }

    // MARK: - Cursor adjustment

    func test_prettify_cursorAtColumnBoundary_staysWithinFormattedLength() {
        let input = "| x | yy |\n| --- | --- |\n"
        guard let result = MarkdownTablePrettifier.prettify(tableText: input, cursorOffsetInTable: input.count - 1) else {
            return XCTFail("Expected prettify to succeed")
        }
        XCTAssertGreaterThanOrEqual(result.cursorOffset, 0)
        XCTAssertLessThanOrEqual(result.cursorOffset, result.formatted.count)
    }

    func test_prettify_cursorAtZero_returnsNonNegativeOffset() {
        let input = "| a | b |\n| --- | --- |\n"
        guard let result = MarkdownTablePrettifier.prettify(tableText: input, cursorOffsetInTable: 0) else {
            return XCTFail("Expected prettify to succeed")
        }
        XCTAssertGreaterThanOrEqual(result.cursorOffset, 0)
    }

    // MARK: - Multi-column alignment mix

    func test_prettify_multipleAlignments_allRowsHaveSameColumnCount() {
        let input = "| L | R | C |\n| --- | --: | :---: |\n| 1 | 2 | 3 |\n"
        let result = MarkdownTablePrettifier.prettify(tableText: input, cursorOffsetInTable: 0)
        XCTAssertNotNil(result)
        let lines = result!.formatted.split(separator: "\n", omittingEmptySubsequences: false).filter { !$0.isEmpty }
        XCTAssertEqual(lines.count, 3)
        for line in lines {
            let pipeCount = line.filter { $0 == "|" }.count
            XCTAssertEqual(pipeCount, 4, "Each row should have the same number of pipes (3 columns): \(line)")
        }
    }

    // MARK: - PrettifyResult properties

    func test_prettifyResult_formattedIsDifferentFromRawWhenInputIsUnaligned() {
        let raw = "|short|widecol|\n|-----|-----|\n"
        let result = MarkdownTablePrettifier.prettify(tableText: raw, cursorOffsetInTable: 0)
        XCTAssertNotNil(result)
        XCTAssertNotEqual(result?.formatted, raw)
    }
}
