import XCTest
import AppKit
@testable import Synapse

final class TaskListCheckboxInteractionTests: XCTestCase {
    func test_taskCheckboxTarget_atViewPoint_resolvesUncheckedTaskMarker() {
        let textView = LinkAwareTextView()
        textView.frame = NSRect(x: 0, y: 0, width: 800, height: 600)
        textView.isEditable = true
        textView.setPlainText("- [ ] Ship phase C")

        let point = point(in: textView, forCharacterAt: 3)
        let hit = textView.taskCheckboxTarget(at: point)

        XCTAssertEqual(hit?.isChecked, false)
        XCTAssertEqual(hit?.markerRange, NSRange(location: 2, length: 3))
        XCTAssertEqual(hit?.replacement, "[x]")
    }

    func test_toggleTaskCheckbox_togglesUncheckedToChecked() {
        let textView = LinkAwareTextView()
        textView.frame = NSRect(x: 0, y: 0, width: 800, height: 600)
        textView.isEditable = true
        textView.setPlainText("- [ ] Ship phase C")

        XCTAssertTrue(textView.toggleTaskCheckbox(atCharacterIndex: 3))
        XCTAssertEqual(textView.string, "- [x] Ship phase C")
    }

    func test_toggleTaskCheckbox_togglesCheckedToUnchecked() {
        let textView = LinkAwareTextView()
        textView.frame = NSRect(x: 0, y: 0, width: 800, height: 600)
        textView.isEditable = true
        textView.setPlainText("- [x] Ship phase C")

        XCTAssertTrue(textView.toggleTaskCheckbox(atCharacterIndex: 3))
        XCTAssertEqual(textView.string, "- [ ] Ship phase C")
    }

    func test_applyPreviewStyling_doesNotCreateNativeCheckboxButtonsForTaskItems() {
        let textView = LinkAwareTextView()
        textView.frame = NSRect(x: 0, y: 0, width: 800, height: 600)
        textView.isEditable = true
        textView.setPlainText("- [ ] First\n- [x] Second")

        textView.applyPreviewStyling()

        XCTAssertTrue(textView.taskCheckboxButtons.isEmpty)
    }

    func test_applyPreviewStyling_keepsMarkdownCheckboxTextVisible() {
        let textView = LinkAwareTextView()
        textView.frame = NSRect(x: 0, y: 0, width: 800, height: 600)
        textView.isEditable = true
        textView.setPlainText("- [ ] Ship phase C")
        textView.applyPreviewStyling()

        guard let storage = textView.textStorage else {
            return XCTFail("Expected text storage")
        }
        let color = storage.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? NSColor
        XCTAssertNotEqual(color?.alphaComponent ?? 1, 0, "Task checkbox markdown should remain visible")
    }

    private func point(in textView: LinkAwareTextView, forCharacterAt characterIndex: Int) -> NSPoint {
        let layout = textView.layoutManager!
        let container = textView.textContainer!
        let glyphIndex = layout.glyphIndexForCharacter(at: characterIndex)
        let glyphRect = layout.boundingRect(forGlyphRange: NSRange(location: glyphIndex, length: 1), in: container)
        return NSPoint(x: textView.textContainerOrigin.x + glyphRect.midX, y: textView.textContainerOrigin.y + glyphRect.midY)
    }
}
