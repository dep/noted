import XCTest
@testable import Synapse

/// Tests for `SplitOrientation` — controls split-editor layout; must stay stable for persisted UI state.
final class SplitOrientationTests: XCTestCase {

    func test_verticalEquality() {
        XCTAssertEqual(SplitOrientation.vertical, SplitOrientation.vertical)
    }

    func test_horizontalEquality() {
        XCTAssertEqual(SplitOrientation.horizontal, SplitOrientation.horizontal)
    }

    func test_casesAreDistinct() {
        XCTAssertNotEqual(SplitOrientation.vertical, SplitOrientation.horizontal)
    }
}
