import Foundation
import Combine

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var query = ""
    @Published var results = SearchResults()
    @Published var isSearching = false
    @Published var errorMessage: String?

    private let api = MusicAPIService.shared
    private var searchTask: Task<Void, Never>?

    func searchNow() {
        searchTask?.cancel()
        let currentQuery = query
        searchTask = Task { [weak self] in
            guard let self else { return }
            let trimmed = currentQuery.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else {
                results = SearchResults()
                isSearching = false
                return
            }
            isSearching = true
            errorMessage = nil
            let searchResults = await api.search(query: trimmed)
            guard !Task.isCancelled else { return }
            results = searchResults
            isSearching = false
            if searchResults.isEmpty {
                errorMessage = api.lastErrorMessage
            }
        }
    }

    deinit { searchTask?.cancel() }
}
