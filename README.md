# SpotifyClone

Native SwiftUI music UI with one unified search screen. No Spotify/SoundCloud WebView is used.

The app can combine Spotify and SoundCloud search results in one list. SoundCloud custom-player playback uses the API's stream endpoint; Spotify playback uses the official iOS App Remote SDK.

Provider authentication credentials are intentionally not hard-coded into Swift source.


## Suche konfigurieren

Die native Suche verwendet ausschließlich die offiziellen Provider-APIs. Die GitHub Action liest dafür diese Repository-Secrets und schreibt sie vor dem Xcode-Build in `Info.plist`:

- `SPOTIFY_CLIENT_ID`
- `SPOTIFY_WEB_API_ACCESS_TOKEN`
- `SOUNDCLOUD_OAUTH_TOKEN`

Ohne mindestens einen gültigen Provider-Token zeigt die App jetzt explizit an, warum keine Ergebnisse erscheinen, statt einfach eine leere Liste zu zeigen. Es werden weiterhin weder WebViews noch iTunes-30-Sekunden-Previews verwendet.
