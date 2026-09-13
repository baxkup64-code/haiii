import Foundation

final class MusicAPIService {
    static let shared = MusicAPIService()
    private(set) var lastErrorMessage: String?
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func search(query: String) async -> SearchResults {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return SearchResults() }

        async let spotify = searchSpotify(trimmed)
        async let soundCloud = searchSoundCloud(trimmed)
        let (spotifyResults, soundCloudResults) = await (spotify, soundCloud)

        let allTracks = (spotifyResults ?? []) + (soundCloudResults ?? [])
        if allTracks.isEmpty {
            if !APIConfig.isSpotifySearchConfigured && !APIConfig.isSoundCloudSearchConfigured {
                lastErrorMessage = "Keine Suchanbieter konfiguriert. Hinterlege SpotifyWebAPIAccessToken und/oder SoundCloudOAuthToken."
            } else {
                lastErrorMessage = "Keine Treffer oder die Provider-Anfrage wurde abgewiesen. Prüfe die API-Zugangsdaten."
            }
        } else {
            lastErrorMessage = nil
        }
        return SearchResults(tracks: allTracks, artists: [], albums: [], playlists: [])
    }

    private func searchSpotify(_ query: String) async -> [Track]? {
        guard !APIConfig.spotifyAccessToken.isEmpty else { return nil }
        var components = URLComponents(string: "https://api.spotify.com/v1/search")!
        components.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "type", value: "track"),
            URLQueryItem(name: "limit", value: "20")
        ]
        guard let url = components.url else { return nil }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(APIConfig.spotifyAccessToken)", forHTTPHeaderField: "Authorization")

        do {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse else { return nil }
            guard 200..<300 ~= http.statusCode else {
                if http.statusCode == 401 || http.statusCode == 403 { lastErrorMessage = "Spotify-Zugangsdaten ungültig oder abgelaufen." }
                return nil
            }
            let root = try JSONDecoder().decode(SpotifySearchResponse.self, from: data)
            return root.tracks.items.map {
                Track(
                    id: $0.id,
                    title: $0.name,
                    artistName: $0.artists.first?.name ?? "Spotify",
                    albumName: $0.album.name,
                    artworkURL: URL(string: $0.album.images.first?.url ?? ""),
                    streamURL: nil,
                    sourceURL: URL(string: $0.external_urls["spotify"] ?? ""),
                    duration: TimeInterval($0.duration_ms) / 1000,
                    source: .spotify
                )
            }
        } catch {
            return nil
        }
    }

    func resolveSoundCloudStream(trackID: String) async -> URL? {
        guard !APIConfig.soundCloudAccessToken.isEmpty else { return nil }
        guard let url = URL(string: "https://api.soundcloud.com/tracks/\(trackID)/streams") else { return nil }
        var request = URLRequest(url: url)
        request.setValue("OAuth \(APIConfig.soundCloudAccessToken)", forHTTPHeaderField: "Authorization")
        do {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else { return nil }
            let streams = try JSONDecoder().decode(SoundCloudStreams.self, from: data)
            return URL(string: streams.hls_aac_160_url ?? streams.hls_aac_96_url ?? streams.http_mp3_128_url ?? streams.http_opus_128_url ?? "")
        } catch {
            return nil
        }
    }

    private func searchSoundCloud(_ query: String) async -> [Track]? {
        guard !APIConfig.soundCloudAccessToken.isEmpty else { return nil }
        var components = URLComponents(string: "https://api.soundcloud.com/tracks")!
        components.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "access", value: "playable"),
            URLQueryItem(name: "limit", value: "20")
        ]
        guard let url = components.url else { return nil }

        var request = URLRequest(url: url)
        request.setValue("OAuth \(APIConfig.soundCloudAccessToken)", forHTTPHeaderField: "Authorization")

        do {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse else { return nil }
            guard 200..<300 ~= http.statusCode else {
                if http.statusCode == 401 || http.statusCode == 403 { lastErrorMessage = "SoundCloud-Zugangsdaten ungültig oder abgelaufen." }
                return nil
            }
            let root = try JSONDecoder().decode([SoundCloudTrackDTO].self, from: data)
            return root.compactMap { item in
                guard item.access == "playable" else { return nil }
                return Track(
                    id: String(item.id),
                    title: item.title,
                    artistName: item.user.username,
                    albumName: "",
                    artworkURL: URL(string: item.artwork_url ?? item.user.avatar_url ?? ""),
                    streamURL: nil,
                    sourceURL: URL(string: item.permalink_url),
                    duration: TimeInterval(item.duration) / 1000,
                    source: .soundcloud
                )
            }
        } catch {
            return nil
        }
    }

    struct SpotifySearchResponse: Codable {
        struct Tracks: Codable { let items: [SpotifyTrack] }
        let tracks: Tracks
    }

    struct SpotifyTrack: Codable {
        struct Artist: Codable { let name: String }
        struct Image: Codable { let url: String }
        struct Album: Codable { let name: String; let images: [Image] }
        let id: String
        let name: String
        let duration_ms: Int
        let artists: [Artist]
        let album: Album
        let external_urls: [String: String]
    }

    struct SoundCloudStreams: Codable {
        let hls_aac_160_url: String?
        let hls_aac_96_url: String?
        let http_mp3_128_url: String?
        let http_opus_128_url: String?
    }

    struct SoundCloudTrackDTO: Codable {
        struct User: Codable { let username: String; let avatar_url: String? }
        let id: Int
        let title: String
        let duration: Int
        let permalink_url: String
        let artwork_url: String?
        let access: String
        let user: User
    }
}
