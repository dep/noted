import Foundation

/// Tag list filtering used by `TagsPaneView.filteredTags`.
enum TagsPaneFiltering {
    static func sortedFilteredTags(from cached: [String: Int], filter query: String) -> [(key: String, value: Int)] {
        let all = cached.sorted { $0.key < $1.key }.map { (key: $0.key, value: $0.value) }
        guard !query.isEmpty else { return all }
        return all.filter { $0.key.localizedCaseInsensitiveContains(query) }
    }
}
