import Foundation

/// Sort order for vault-wide search hits in `AllFilesSearchView.scheduleSearch`.
enum AllFilesSearchResultSorting {
    static func sortByModificationDate(_ results: [FileSearchResult], modDates: [URL: Date]) -> [FileSearchResult] {
        results.sorted {
            let a = modDates[$0.url] ?? .distantPast
            let b = modDates[$1.url] ?? .distantPast
            if a != b { return a > b }
            return $0.lineNumber < $1.lineNumber
        }
    }
}
