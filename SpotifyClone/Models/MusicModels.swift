import Foundation

enum TrackSource: String, Codable {
    case spotify
    case soundcloud
    case local
}

struct Track: Identifiable, Codable, Hashable {
    let id: String
    var title: String
    var artistName: String
    var albumName: String
    var artworkURL: URL?
    var streamURL: URL?
    var sourceURL: URL?
    var duration: TimeInterval
    var source: TrackSource

    static func placeholder() -> Track {
        Track(
            id: UUID().uuidString,
            title: "Unbekannter Titel",
            artistName: "Unbekannt",
            albumName: "",
            artworkURL: nil,
            streamURL: nil,
            sourceURL: nil,
            duration: 0,
            source: .local
        )
    }
}

struct Album: Identifiable, Codable, Hashable {
    let id: String
    var name: String
    var artistName: String
    var artworkURL: URL?
    var tracks: [Track]
}

struct Artist: Identifiable, Codable, Hashable {
    let id: String
    var name: String
    var imageURL: URL?
}

struct RemotePlaylist: Identifiable, Codable, Hashable {
    let id: String
    var name: String
    var ownerName: String
    var artworkURL: URL?
    var trackCount: Int
}

struct SearchResults: Codable, Equatable {
    var tracks: [Track] = []
    var artists: [Artist] = []
    var albums: [Album] = []
    var playlists: [RemotePlaylist] = []

    var isEmpty: Bool { tracks.isEmpty && artists.isEmpty && albums.isEmpty && playlists.isEmpty }
}

enum RepeatMode {
    case off, all, one
}
