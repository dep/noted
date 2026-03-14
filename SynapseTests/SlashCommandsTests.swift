import XCTest
import AppKit
@testable import Synapse

final class SlashCommandsTests: XCTestCase {
    func test_slashCommandContext_detectsSlashTokenAtStartOfLine() {
        let text = "Title\n/ti"

        let context = slashCommandContext(in: text, cursor: (text as NSString).length)

        XCTAssertEqual(context, SlashCommandContext(range: NSRange(location: 6, length: 3), query: "ti"))
    }

    func test_slashCommandContext_ignoresSlashMidLine() {
        let text = "Title /ti"

        let context = slashCommandContext(in: text, cursor: (text as NSString).length)

        XCTAssertNil(context)
    }

    func test_filteredSlashCommands_returnsPrefixMatchesInCommandOrder() {
        XCTAssertEqual(filteredSlashCommands(for: "d"), [.date, .datetime])
        XCTAssertEqual(filteredSlashCommands(for: "ti"), [.time])
    }

    func test_resolveSlashCommandOutput_formatsDateTimeAndFilenameCommands() {
        let now = Date(timeIntervalSince1970: 1_773_498_840)
        let context = SlashCommandResolverContext(
            now: now,
            currentFileURL: URL(fileURLWithPath: "/tmp/my-note.md"),
            locale: Locale(identifier: "en_US_POSIX"),
            timeZone: TimeZone(secondsFromGMT: 0)!
        )

        XCTAssertEqual(resolveSlashCommandOutput(.time, context: context), "2:34 pm")
        XCTAssertEqual(resolveSlashCommandOutput(.date, context: context), "2026-03-14")
        XCTAssertEqual(resolveSlashCommandOutput(.datetime, context: context), "2026-03-14 2:34 PM")
        XCTAssertEqual(resolveSlashCommandOutput(.todo, context: context), "- [ ] ")
        XCTAssertEqual(resolveSlashCommandOutput(.note, context: context), "> **Note:** ")
        XCTAssertEqual(resolveSlashCommandOutput(.filename, context: context), "my-note")
    }

    func test_insertSlashCommand_replacesTypedTokenAndMovesCursorToEnd() {
        let textView = LinkAwareTextView()
        textView.currentFileURL = URL(fileURLWithPath: "/tmp/my-note.md")
        textView.slashCommandNowProvider = { Date(timeIntervalSince1970: 1_773_498_840) }
        textView.slashCommandTimeZone = TimeZone(secondsFromGMT: 0)!
        textView.string = "/ti"
        textView.setSelectedRange(NSRange(location: 3, length: 0))
        textView.checkForSlashCommandTrigger()

        let didInsert = textView.insertSlashCommand(.time)

        XCTAssertTrue(didInsert)
        XCTAssertEqual(textView.string, "2:34 pm")
        XCTAssertEqual(textView.selectedRange(), NSRange(location: 7, length: 0))
    }
}
