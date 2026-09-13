import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var recentlyPlayed: [Track] = []
    @Published var madeForYou: [Track] = []
    @Published var newReleases: [Album] = []
    @Published var isLoading = false

    func load() async {
        isLoading = false
        // No hidden catalog/API fallback. The app starts with a provider-first
        // home and users choose Spotify or SoundCloud from Search.
        recentlyPlayed = []
        madeForYou = []
        newReleases = []
    }
}
