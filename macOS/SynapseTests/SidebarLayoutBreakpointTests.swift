import XCTest
@testable import Synapse

/// Pins sidebar auto-collapse breakpoints and their relationship to `SynapseTheme.Layout` widths.
/// Wrong numbers collapse the wrong panes at common window sizes and make the UI feel broken.
final class SidebarLayoutBreakpointTests: XCTestCase {

    func test_layoutBreakpointConstants_matchDocumentedOrder() {
        XCTAssertGreaterThan(
            SynapseTheme.Layout.allSidebarsExpandedWidth,
            SynapseTheme.Layout.twoSidebarsExpandedWidth
        )
        XCTAssertGreaterThan(
            SynapseTheme.Layout.twoSidebarsExpandedWidth,
            SynapseTheme.Layout.oneSidebarExpandedWidth
        )
    }

    func test_sidebarAutoCollapseIDs_atAllExpandedWidth_returnsEmpty() {
        let width = SynapseTheme.Layout.allSidebarsExpandedWidth
        XCTAssertTrue(sidebarAutoCollapseIDs(forWindowWidth: width).isEmpty)
    }

    func test_sidebarAutoCollapseIDs_justBelowAllExpanded_collapsesRight2Only() {
        let width = SynapseTheme.Layout.allSidebarsExpandedWidth - 1
        XCTAssertEqual(sidebarAutoCollapseIDs(forWindowWidth: width), [FixedSidebar.right2ID])
    }

    func test_sidebarAutoCollapseIDs_atTwoSidebarsThreshold_collapsesRight2Only() {
        let width = SynapseTheme.Layout.twoSidebarsExpandedWidth
        XCTAssertEqual(sidebarAutoCollapseIDs(forWindowWidth: width), [FixedSidebar.right2ID])
    }

    func test_sidebarAutoCollapseIDs_justBelowTwoSidebars_collapsesBothRightPanes() {
        let width = SynapseTheme.Layout.twoSidebarsExpandedWidth - 1
        XCTAssertEqual(
            sidebarAutoCollapseIDs(forWindowWidth: width),
            [FixedSidebar.right1ID, FixedSidebar.right2ID]
        )
    }

    func test_sidebarAutoCollapseIDs_atOneSidebarThreshold_collapsesBothRightPanes() {
        let width = SynapseTheme.Layout.oneSidebarExpandedWidth
        XCTAssertEqual(
            sidebarAutoCollapseIDs(forWindowWidth: width),
            [FixedSidebar.right1ID, FixedSidebar.right2ID]
        )
    }

    func test_sidebarAutoCollapseIDs_justBelowOneSidebar_collapsesAllThree() {
        let width = SynapseTheme.Layout.oneSidebarExpandedWidth - 1
        XCTAssertEqual(
            sidebarAutoCollapseIDs(forWindowWidth: width),
            [FixedSidebar.leftID, FixedSidebar.right1ID, FixedSidebar.right2ID]
        )
    }

    func test_sidebarAutoCollapseIDs_narrowWindow_collapsesAllThree() {
        XCTAssertEqual(
            sidebarAutoCollapseIDs(forWindowWidth: 400),
            [FixedSidebar.leftID, FixedSidebar.right1ID, FixedSidebar.right2ID]
        )
    }
}
