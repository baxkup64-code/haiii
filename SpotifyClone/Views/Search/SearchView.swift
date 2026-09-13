import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @EnvironmentObject private var player: PlayerViewModel

    var body: some View {
        ZStack {
            Theme.Color.background.ignoresSafeArea()
            ScrollView {
                LazyVStack(spacing: 0) {
                    header
                        .padding(.bottom, 12)

                    if viewModel.isSearching {
                        ProgressView()
                            .tint(Theme.Color.accent)
                            .padding(.top, 24)
                    } else if viewModel.results.tracks.isEmpty {
                        emptyState
                            .padding(.top, 56)
                    } else {
                        ForEach(viewModel.results.tracks) { track in
                            TrackSearchRow(track: track) {
                                player.play(tracks: [track])
                            }
                            Divider()
                                .overlay(Theme.Color.divider)
                                .padding(.leading, 80)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 110)
            }
            .scrollDismissesKeyboard(.interactively)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Suchen")
                .font(Theme.Font.largeTitle())
                .foregroundStyle(Theme.Color.textPrimary)

            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Theme.Color.textSecondary)

                TextField("Song, Artist oder Album", text: $viewModel.query)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .submitLabel(.search)
                    .foregroundStyle(Theme.Color.textPrimary)
                    .onSubmit { viewModel.searchNow() }

                if !viewModel.query.isEmpty {
                    Button {
                        viewModel.query = ""
                        viewModel.results = SearchResults()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Theme.Color.textSecondary)
                    }
                }
            }
            .padding(.horizontal, 14)
            .frame(minHeight: 50)
            .background(Theme.Color.surface)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            HStack(spacing: 8) {
                SourcePill(title: "Alle", systemImage: "music.note.2", highlighted: true)
                SourcePill(title: "Spotify", systemImage: "circle.fill", highlighted: false)
                SourcePill(title: "SoundCloud", systemImage: "waveform", highlighted: false)
                Spacer(minLength: 0)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "music.note.list")
                .font(.system(size: 44, weight: .semibold))
                .foregroundStyle(Theme.Color.textTertiary)
            Text("Suche nach Musik")
                .font(Theme.Font.heading())
                .foregroundStyle(Theme.Color.textPrimary)
            Text("Spotify und SoundCloud erscheinen gemeinsam in dieser Liste.")
                .font(Theme.Font.body())
                .foregroundStyle(Theme.Color.textSecondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 330)
        }
    }
}

private struct SourcePill: View {
    let title: String
    let systemImage: String
    let highlighted: Bool

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: systemImage)
            Text(title)
        }
        .font(.system(size: 13, weight: .semibold))
        .foregroundStyle(highlighted ? Theme.Color.background : Theme.Color.textSecondary)
        .padding(.horizontal, 12)
        .frame(minHeight: 34)
        .background(highlighted ? Theme.Color.accent : Theme.Color.surface)
        .clipShape(Capsule())
    }
}

private struct TrackSearchRow: View {
    let track: Track
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                AsyncImage(url: track.artworkURL) { phase in
                    switch phase {
                    case .success(let image): image.resizable().scaledToFill()
                    default:
                        ZStack {
                            Theme.Color.surfaceElevated
                            Image(systemName: "music.note")
                                .foregroundStyle(Theme.Color.textTertiary)
                        }
                    }
                }
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text(track.title)
                        .font(Theme.Font.subheading())
                        .foregroundStyle(Theme.Color.textPrimary)
                        .lineLimit(1)
                    HStack(spacing: 6) {
                        Text(track.artistName)
                            .font(Theme.Font.caption())
                            .foregroundStyle(Theme.Color.textSecondary)
                            .lineLimit(1)
                        Circle().fill(Theme.Color.textTertiary).frame(width: 3, height: 3)
                        Text(track.source == .spotify ? "Spotify" : "SoundCloud")
                            .font(Theme.Font.caption())
                            .foregroundStyle(track.source == .spotify ? Theme.Color.accentSecondary : Theme.Color.accent)
                    }
                }

                Spacer(minLength: 8)

                Image(systemName: "play.circle.fill")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(Theme.Color.accent)
            }
            .contentShape(Rectangle())
            .padding(.vertical, 10)
        }
        .buttonStyle(.plain)
    }
}
