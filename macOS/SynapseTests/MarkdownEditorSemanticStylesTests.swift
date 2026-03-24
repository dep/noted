import XCTest
@testable import Synapse

final class MarkdownEditorSemanticStylesTests: XCTestCase {
    func test_make_findsHeadingBlockquoteCodeBlockAndFrontmatterRanges() {
        let markdown = """
        ---
        title: Hello
        ---
        # Heading
        > Quote
        ```swift
        let x = 1
        ```
        """

        let styles = MarkdownEditorSemanticStyles.make(from: markdown)
        let ns = markdown as NSString

        XCTAssertEqual(styles.headings.count, 1)
        XCTAssertEqual(styles.headings[0].level, 1)
        XCTAssertEqual(styles.headings[0].range, ns.range(of: "# Heading"))

        XCTAssertEqual(styles.blockquotes, [ns.range(of: "> Quote")])
        XCTAssertEqual(styles.codeBlocks, [ns.range(of: "```swift\nlet x = 1\n```")])
        XCTAssertEqual(styles.frontmatter?.range, ns.range(of: "---\ntitle: Hello\n---"))
        XCTAssertEqual(styles.frontmatter?.contentRange, ns.range(of: "title: Hello\n"))
    }

    func test_make_findsThematicBreakAndTableRanges() {
        let markdown = """
        Intro
        ---
        | Name | Value |
        | --- | --- |
        | One | 1 |
        """

        let styles = MarkdownEditorSemanticStyles.make(from: markdown)
        let ns = markdown as NSString

        XCTAssertEqual(styles.thematicBreaks, [ns.range(of: "---")])
        XCTAssertEqual(styles.tables.count, 1)
        XCTAssertEqual(styles.tables[0].range, ns.range(of: "| Name | Value |\n| --- | --- |\n| One | 1 |"))
        XCTAssertEqual(styles.tables[0].columnCount, 2)
    }

    func test_make_detectsCalloutMetadataFromBlockquote() {
        let markdown = "> [!NOTE] Remember this\n> Body line"
        let styles = MarkdownEditorSemanticStyles.make(from: markdown)
        let ns = markdown as NSString

        XCTAssertEqual(styles.callouts.count, 1)
        XCTAssertEqual(styles.callouts[0].kind, "note")
        XCTAssertEqual(styles.callouts[0].markerRange, ns.range(of: "[!NOTE]"))
        XCTAssertEqual(styles.callouts[0].titleRange, ns.range(of: "Remember this"))
    }
}
