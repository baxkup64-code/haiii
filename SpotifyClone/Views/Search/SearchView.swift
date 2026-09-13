import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @EnvironmentObject private var player: PlayerViewModel
    @FocusState private var isSearchFocused: Bool

    var body: some View {
        ZStack {
            Theme.Color.background.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    header
                    searchField

                    if let error = viewModel.errorMessage, viewModel.results.tracks.isEmpty && !viewModel.isSearching {
                        messageCard(error: error)
                            .padding(.top, 18)
                    } else if viewModel.isSearching {
                        loadingState
                            .padding(.top, 42)
                    } else if viewModel.results.tracks.isEmpty {
                        idleState
                            .padding(.top, 54)
                    } else {
                        resultsSection
                            .padding(.top, 22)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 120)
                .frame(maxWidth: 760, alignment: .leading)
                .frame(maxWidth: .infinity)
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)
        }
        .onAppear {
            if !viewModel.query.isEmpty { isSearchFocused = true }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text("Suchen")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.Color.textPrimary)

            Text("Spotify + SoundCloud in einer Liste")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Theme.Color.textSecondary)
        }
        .padding(.bottom, 18)
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Theme.Color.textSecondary)

            TextField("Song, Artist oder Album", text: $viewModel.query)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.search)
                .focused($isSearchFocused)
                .foregroundStyle(Theme.Color.textPrimary)
                .onSubmit { viewModel.searchNow() }

            if viewModel.isSearching {
                ProgressView()
                    .tint(Theme.Color.accent)
            } else if !viewModel.query.isEmpty {
                Button {
                    viewModel.query = ""
                    viewModel.results = SearchResults()
                    viewModel.errorMessage = nil
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(Theme.Color.textTertiary)
                }
                .buttonStyle(.plain)
            }

            Button {
                isSearchFocused = false
                viewModel.searchNow()
            } label: {
                Text("Suchen")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Theme.Color.background)
                    .padding(.horizontal, 14)
                    .frame(height: 36)
                    .background(Theme.Color.accent)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .disabled(viewModel.query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isSearching)
            .opacity(viewModel.query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.45 : 1)
        }
        .padding(.leading, 15)
        .padding(.trailing, 8)
        .frame(height: 56)
        .background(Theme.Color.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Theme.Color.divider, lineWidth: 1))
    }

    private var resultsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Ergebnisse")
                    .font(.system(size: 20, weight: .bold))
                Spacer()
                Text("\(viewModel.results.tracks.count)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Theme.Color.textTertiary)
            }
            .foregroundStyle(Theme.Color.textPrimary)

            LazyVStack(spacing: 2) {
                ForEach(viewModel.results.tracks) { track in
                    TrackSearchRow(track: track) {
                        player.play(tracks: [track])
                    }
                }
            }
        }
    }

    private var loadingState: some View {
        VStack(spacing: 14) {
            ProgressView()
                .controlSize(.large)
                .tint(Theme.Color.accent)
            Text("Musik wird gesucht…")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Theme.Color.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var idleState: some View {
        VStack(spacing: 14) {
            Image(systemName: "waveform.and.magnifyingglass")
                .font(.system(size: 44, weight: .semibold))
                .foregroundStyle(Theme.Color.accent)

            Text("Suche nach einem Song")
                .font(.system(size: 21, weight: .bold))
                .foregroundStyle(Theme.Color.textPrimary)

            Text("Tippe einen Titel, Künstler oder ein Album ein und starte die Suche.")
                .font(.system(size: 15))
                .foregroundStyle(Theme.Color.textSecondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 320)
        }
        .frame(maxWidth: .infinity)
    }

    private func messageCard(error: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Suche nicht verfügbar", systemImage: "exclamationmark.triangle.fill")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Theme.Color.textPrimary)

            Text(error)
                .font(.system(size: 14))
                .foregroundStyle(Theme.Color.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Text("Die App enthält absichtlich keine iTunes-30-Sekunden-Previews und keinen WebView. Für echte Provider-Suche müssen die offiziellen API-Zugangsdaten gesetzt sein.")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Theme.Color.textTertiary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.Color.surface)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Theme.Color.divider, lineWidth: 1))
    }
}

private struct TrackSearchRow: View {
    let track: Track
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                AsyncImage(url: track.artworkURL) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    default:
                        ZStack {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Theme.Color.surfaceElevated)
                            Image(systemName: "music.note")
                                .foregroundStyle(Theme.Color.textTertiary)
                        }
                    }
                }
                .frame(width: 62, height: 62)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                VStack(alignment: .leading, spacing: 5) {
                    Text(track.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Theme.Color.textPrimary)
                        .lineLimit(1)
                    Text(track.artistName)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Theme.Color.textSecondary)
                        .lineLimit(1)
                    Text(track.source == .spotify ? "Spotify" : "SoundCloud")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(track.source == .spotify ? Theme.Color.accentSecondary : Theme.Color.accent)
                }

                Spacer(minLength: 8)

                Image(systemName: "play.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Theme.Color.background)
                    .frame(width: 42, height: 42)
                    .background(Theme.Color.accent)
                    .clipShape(Circle())
            }
            .padding(.vertical, 9)
            .padding(.horizontal, 6)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
