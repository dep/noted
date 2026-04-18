import XCTest
@testable import Synapse

final class MarkdownEditorRefreshPlanTests: XCTestCase {
    private let parser = MarkdownDocumentParser()

    func test_make_returnsBlockRangeForInlineParagraphEdit() {
        let oldText = "# Title\n\nParagraph one\n\nParagraph two"
        let newText = "# Title\n\nParagraph ones\n\nParagraph two"
        let document = parser.parse(newText)
        let editedRange = NSRange(location: 22, length: 1)

        let plan = MarkdownEditorRefreshPlan.make(oldText: oldText, newText: newText, editedRange: editedRange, changeInLength: 1, document: document)

        XCTAssertEqual(plan.kind, .blockRange((newText as NSString).range(of: "Paragraph ones")))
    }

    func test_make_returnsBlockRangeForInlineCodeBlockEdit() {
        let oldText = "```swift\nlet value = 1\n```"
        let newText = "```swift\nlet value = 2\n```"
        let document = parser.parse(newText)
        let editedRange = NSRange(location: 21, length: 1)

        let plan = MarkdownEditorRefreshPlan.make(oldText: oldText, newText: newText, editedRange: editedRange, changeInLength: 0, document: document)

        XCTAssertEqual(plan.kind, .blockRange(NSRange(location: 0, length: (newText as NSString).length)))
    }

    func test_make_returnsFullDocumentForStructuralNewlineEdit() {
        let oldText = "Paragraph one"
        let newText = "Paragraph\none"
        let document = parser.parse(newText)
        let editedRange = NSRange(location: 9, length: 1)

        let plan = MarkdownEditorRefreshPlan.make(oldText: oldText, newText: newText, editedRange: editedRange, changeInLength: 1, document: document)

        XCTAssertEqual(plan, .fullDocument)
    }

    func test_make_returnsFullDocumentForTableEdit() {
        let oldText = "| Name | Value |\n| --- | --- |\n| One | 1 |"
        let newText = "| Name | Value |\n| --- | --- |\n| One | 2 |"
        let document = parser.parse(newText)
        let editedRange = NSRange(location: 41, length: 1)

        let plan = MarkdownEditorRefreshPlan.make(oldText: oldText, newText: newText, editedRange: editedRange, changeInLength: 0, document: document)

        XCTAssertEqual(plan, .fullDocument)
    }

    func test_make_emptyOldText_returnsFullDocument() {
        let oldText = ""
        let newText = "Hello"
        let document = parser.parse(newText)
        let editedRange = NSRange(location: 0, length: 5)

        let plan = MarkdownEditorRefreshPlan.make(oldText: oldText, newText: newText, editedRange: editedRange, changeInLength: 5, document: document)

        XCTAssertEqual(plan, .fullDocument)
    }

    func test_make_emptyNewText_returnsFullDocument() {
        let oldText = "Hello"
        let newText = ""
        let document = parser.parse(oldText)
        let editedRange = NSRange(location: 0, length: 0)

        let plan = MarkdownEditorRefreshPlan.make(oldText: oldText, newText: newText, editedRange: editedRange, changeInLength: -5, document: document)

        XCTAssertEqual(plan, .fullDocument)
    }

    func test_make_returnsFullDocumentForThematicBreakEdit() {
        let oldText = "Intro\n\n---\n\nOutro"
        let newText = "Intro\n\n----\n\nOutro"
        let document = parser.parse(newText)
        let editedRange = NSRange(location: 9, length: 1)

        let plan = MarkdownEditorRefreshPlan.make(oldText: oldText, newText: newText, editedRange: editedRange, changeInLength: 0, document: document)

        XCTAssertEqual(plan, .fullDocument)
    }
}
