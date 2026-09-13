import SwiftUI

struct ProviderPlayerView: View {
    let trackURL: URL
    let source: TrackSource

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: source == .spotify ? "waveform" : "music.note")
                .foregroundStyle(Theme.Color.accent)
            Text(source == .spotify ? "Wiedergabe über Spotify" : "Wiedergabe über SoundCloud")
                .font(Theme.Font.caption())
                .foregroundStyle(Theme.Color.textSecondary)
            Spacer()
        }
    }
}
