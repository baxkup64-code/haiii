import Foundation
#if canImport(SpotifyiOS)
import SpotifyiOS
#endif

@MainActor
final class SpotifyPlaybackService: NSObject {
    static let shared = SpotifyPlaybackService()

    #if canImport(SpotifyiOS)
    private lazy var configuration: SPTConfiguration? = {
        guard !APIConfig.spotifyClientID.isEmpty, let redirect = APIConfig.spotifyRedirectURI else { return nil }
        return SPTConfiguration(clientID: APIConfig.spotifyClientID, redirectURL: redirect)
    }()

    private lazy var appRemote: SPTAppRemote? = {
        guard let configuration else { return nil }
        let remote = SPTAppRemote(configuration: configuration, logLevel: .debug)
        remote.delegate = self
        return remote
    }()

    private(set) var accessToken: String?

    func authorizeAndPlay(trackID: String) {
        guard let appRemote else { return }
        let uri = "spotify:track:\(trackID)"
        appRemote.authorizeAndPlayURI(uri)
    }

    func handleOpenURL(_ url: URL) {
        guard let appRemote else { return }
        let parameters = appRemote.authorizationParameters(from: url)
        if let token = parameters?[SPTAppRemoteAccessTokenKey] as? String {
            accessToken = token
            appRemote.connectionParameters.accessToken = token
            appRemote.connect()
        }
    }

    func togglePlayback() {
        appRemote?.playerAPI?.resume(nil)
    }
    #else
    private(set) var accessToken: String?
    func authorizeAndPlay(trackID: String) {}
    func handleOpenURL(_ url: URL) {}
    func togglePlayback() {}
    #endif
}

#if canImport(SpotifyiOS)
@MainActor extension SpotifyPlaybackService: SPTAppRemoteDelegate {
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {}
    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {}
    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {}
}
#endif
