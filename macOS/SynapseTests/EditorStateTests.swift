import XCTest
@testable import Synapse

/// Tests that EditorState exists as an ObservableObject and holds per-editor data.
final class EditorStateTests: XCTestCase {

    var sut: AppState!
    var tempDir: URL!

    override func setUp() {
        super.setUp()
        sut = AppState()
        tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try! FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: tempDir)
        sut = nil
        super.tearDown()
    }

    // MARK: - EditorState is accessible from AppState

    func test_appState_exposes_editorState() {
        XCTAssertNotNil(sut.editorState)
    }

    func test_editorState_isObservableObject() {
        let _ = sut.editorState as ObservableObject
        XCTAssertTrue(true, "EditorState conforms to ObservableObject")
    }

    // MARK: - EditorState owns editor-level published properties

    func test_editorState_selectedFile_initiallyNil() {
        XCTAssertNil(sut.editorState.selectedFile)
    }

    func test_editorState_fileContent_initiallyEmpty() {
        XCTAssertEqual(sut.editorState.fileContent, "")
    }

    func test_editorState_isDirty_initiallyFalse() {
        XCTAssertFalse(sut.editorState.isDirty)
    }

    // MARK: - AppState properties forward to EditorState

    func test_appState_selectedFile_forwardsToEditorState() {
        let file = tempDir.appendingPathComponent("note.md")
        try! "hello".write(to: file, atomically: true, encoding: .utf8)
        sut.openFolder(tempDir)
        sut.openFile(file)
        XCTAssertEqual(sut.selectedFile, sut.editorState.selectedFile,
                       "appState.selectedFile must equal editorState.selectedFile")
    }

    func test_appState_fileContent_forwardsToEditorState() {
        let file = tempDir.appendingPathComponent("note.md")
        try! "hello".write(to: file, atomically: true, encoding: .utf8)
        sut.openFolder(tempDir)
        sut.openFile(file)
        XCTAssertEqual(sut.fileContent, sut.editorState.fileContent)
    }

    func test_appState_isDirty_forwardsToEditorState() {
        XCTAssertEqual(sut.isDirty, sut.editorState.isDirty)
    }

    func test_appState_setIsDirty_propagatesToEditorState() {
        sut.isDirty = true
        XCTAssertTrue(sut.editorState.isDirty)
    }

    func test_appState_setFileContent_propagatesToEditorState() {
        sut.fileContent = "new content"
        XCTAssertEqual(sut.editorState.fileContent, "new content")
    }
}
