import XCTest
import Combine
@testable import Synapse

/// Tests for the lastContentChange signal that triggers UI refresh when file content changes.
/// This signal ensures TagsPaneView and GraphPaneView update when note content is edited.
final class AppStateContentChangeTests: XCTestCase {

    var sut: AppState!
    var tempDir: URL!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        sut = AppState()
        tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try! FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        cancellables = Set<AnyCancellable>()
        sut.openFolder(tempDir)
    }

    override func tearDown() {
        cancellables = nil
        try? FileManager.default.removeItem(at: tempDir)
        sut = nil
        super.tearDown()
    }

    // MARK: - Initial State

    func test_lastContentChange_hasInitialValue() {
        // The lastContentChange should be set to approximately now
        let initialValue = sut.lastContentChange
        let timeDiff = Date().timeIntervalSince(initialValue)
        XCTAssertLessThan(timeDiff, 1.0, "Initial value should be recent")
    }

    // MARK: - saveCurrentFile updates lastContentChange

    func test_saveCurrentFile_updatesLastContentChange() throws {
        let url = makeFile(named: "note.md", content: "original")
        sut.openFile(url)
        let initialTimestamp = sut.lastContentChange
        
        // Wait a tiny bit to ensure timestamp difference
        Thread.sleep(forTimeInterval: 0.01)
        
        sut.saveCurrentFile(content: "updated content")
        
        XCTAssertGreaterThan(sut.lastContentChange, initialTimestamp, 
            "lastContentChange should update when file is saved")
    }

    func test_saveCurrentFile_withNoSelectedFile_doesNotUpdateLastContentChange() {
        let initialTimestamp = sut.lastContentChange
        Thread.sleep(forTimeInterval: 0.01)
        
        sut.selectedFile = nil
        sut.saveCurrentFile(content: "orphan content")
        
        XCTAssertEqual(sut.lastContentChange, initialTimestamp,
            "lastContentChange should not update when there's no selected file")
    }

    func test_saveCurrentFile_multipleSaves_updatesEachTime() throws {
        let url = makeFile(named: "note.md", content: "v1")
        sut.openFile(url)
        
        var timestamps: [Date] = []
        
        for i in 2...4 {
            Thread.sleep(forTimeInterval: 0.01)
            sut.saveCurrentFile(content: "v\(i)")
            timestamps.append(sut.lastContentChange)
        }
        
        // Each timestamp should be strictly greater than the previous
        for i in 1..<timestamps.count {
            XCTAssertGreaterThan(timestamps[i], timestamps[i-1],
                "Each save should produce a newer timestamp")
        }
    }

    // MARK: - reloadSelectedFileFromDiskIfNeeded updates lastContentChange

    func test_reloadSelectedFileFromDiskIfNeeded_updatesLastContentChangeWhenDiskChanges() throws {
        let url = makeFile(named: "note.md", content: "original")
        sut.openFile(url)
        let initialTimestamp = sut.lastContentChange
        
        // Simulate external change to file on disk
        Thread.sleep(forTimeInterval: 0.01)
        try "modified externally".write(to: url, atomically: true, encoding: .utf8)
        
        // Force reload
        sut.reloadSelectedFileFromDiskIfNeeded(force: true)
        
        XCTAssertGreaterThan(sut.lastContentChange, initialTimestamp,
            "lastContentChange should update when disk changes are detected")
    }

    // MARK: - Published property notifications

    func test_lastContentChange_publishesChanges() throws {
        let url = makeFile(named: "note.md", content: "original")
        sut.openFile(url)
        
        var publishCount = 0
        let expectation = self.expectation(description: "lastContentChange publishes")
        
        sut.$lastContentChange
            .dropFirst() // Skip initial value
            .sink { _ in
                publishCount += 1
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.saveCurrentFile(content: "updated")
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(publishCount, 1, "lastContentChange should publish when updated")
    }

    // MARK: - Helpers

    private func makeFile(named name: String, content: String = "") -> URL {
        let url = tempDir.appendingPathComponent(name)
        try! content.write(to: url, atomically: true, encoding: .utf8)
        return url
    }
}
