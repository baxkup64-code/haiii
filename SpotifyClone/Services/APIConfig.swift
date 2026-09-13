import Foundation

/// Runtime provider configuration.
/// No secrets are hard-coded into source code. Values are read from Info.plist.
enum APIConfig {
    static var spotifyClientID: String {
        (Bundle.main.object(forInfoDictionaryKey: "SpotifyClientID") as? String ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static var spotifyRedirectURI: URL? {
        guard let value = Bundle.main.object(forInfoDictionaryKey: "SpotifyRedirectURI") as? String else { return nil }
        return URL(string: value)
    }

    static var spotifyAccessToken: String {
        (Bundle.main.object(forInfoDictionaryKey: "SpotifyWebAPIAccessToken") as? String ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static var soundCloudAccessToken: String {
        (Bundle.main.object(forInfoDictionaryKey: "SoundCloudOAuthToken") as? String ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static var isSpotifySearchConfigured: Bool { !spotifyAccessToken.isEmpty }
    static var isSoundCloudSearchConfigured: Bool { !soundCloudAccessToken.isEmpty }
}
