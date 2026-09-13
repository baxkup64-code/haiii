import SwiftUI

struct FullPlayerView: View {
    var namespace: Namespace.ID
    @EnvironmentObject private var player: PlayerViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var isDraggingSeek = false
    @State private var seekValue: Double = 0
    @State private var showingQueue = false
    @GestureState private var dragOffset: CGSize = .zero

    var body: some View {
        guard let track = player.currentTrack else { return AnyView(EmptyView()) }

        return AnyView(
            GeometryReader { proxy in
                let width = proxy.size.width
                let height = proxy.size.height
                let horizontalPadding = min(24, max(16, width * 0.055))
                let artworkSize = min(width - horizontalPadding * 2, max(188, min(360, height * 0.34)))
                let controlSize = min(68, max(58, width * 0.17))

                ZStack {
                    backgroundGradient(for: track)

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: min(24, max(14, height * 0.026))) {
                            grabberAndHeader

                            if let sourceURL = track.sourceURL, track.streamURL == nil {
                                VStack(spacing: 14) {
                                    ProviderPlayerView(trackURL: sourceURL, source: track.source)
                                        .frame(height: min(520, max(180, height * 0.30)))
                                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                    Text(providerHint(for: track.source))
                                        .font(Theme.Font.caption())
                                        .foregroundStyle(Theme.Color.textSecondary)
                                        .multilineTextAlignment(.center)
                                }
                            } else {
                                ArtworkView(url: track.artworkURL, cornerRadius: 16)
                                    .matchedGeometryEffect(id: "artwork", in: namespace)
                                    .frame(width: artworkSize, height: artworkSize)
                                    .shadow(color: .black.opacity(0.4), radius: 30, y: 20)
                                    .scaleEffect(player.audio.isPlaying ? 1.0 : 0.94)
                                    .animation(Theme.Animation.spring, value: player.audio.isPlaying)
                            }

                            trackInfo(track)
                            if track.streamURL != nil {
                                seekSection
                                transportControls(controlSize: controlSize)
                            }
                            bottomRow(track)
                        }
                        .frame(maxWidth: 680)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, horizontalPadding)
                        .padding(.top, 8)
                        .padding(.bottom, max(16, proxy.safeAreaInsets.bottom + 8))
                    }
                }
                .offset(y: max(0, dragOffset.height))
                .gesture(
                    DragGesture()
                        .updating($dragOffset) { value, state, _ in
                            state = value.translation
                        }
                        .onEnded { value in
                            if value.translation.height > 120 {
                                dismiss()
                            }
                        }
                )
                .sheet(isPresented: $showingQueue) { QueueView() }
            }
            .ignoresSafeArea()
        )
    }

    private func backgroundGradient(for track: Track) -> some View {
        LinearGradient(
            colors: [Theme.Color.surfaceElevated, Theme.Color.background],
            startPoint: .top, endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    private var grabberAndHeader: some View {
        VStack(spacing: Theme.Spacing.md) {
            Capsule().fill(Theme.Color.textTertiary).frame(width: 36, height: 5)
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.down").font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Theme.Color.textPrimary)
                        .frame(minWidth: 44, minHeight: 44)
                }
                Spacer()
                Text("Wird abgespielt")
                    .font(Theme.Font.caption())
                    .foregroundStyle(Theme.Color.textSecondary)
                Spacer()
                Button(action: { showingQueue = true }) {
                    Image(systemName: "list.bullet")
                        .foregroundStyle(Theme.Color.textPrimary)
                        .frame(minWidth: 44, minHeight: 44)
                }
            }
        }
    }

    private func trackInfo(_ track: Track) -> some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(track.title).font(Theme.Font.heading()).foregroundStyle(Theme.Color.textPrimary).lineLimit(2)
                Text(track.artistName).font(Theme.Font.body()).foregroundStyle(Theme.Color.textSecondary).lineLimit(1)
            }
            Spacer(minLength: 8)
            Button(action: { player.toggleLike(track) }) {
                Image(systemName: player.isLiked(track) ? "heart.fill" : "heart")
                    .font(.system(size: 20))
                    .foregroundStyle(player.isLiked(track) ? Theme.Color.accent : Theme.Color.textPrimary)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(PressableStyle())
        }
    }

    private var seekSection: some View {
        VStack(spacing: 4) {
            Slider(
                value: Binding(
                    get: { isDraggingSeek ? seekValue : player.audio.currentTime },
                    set: { seekValue = $0 }
                ),
                in: 0...(max(player.audio.duration, 1)),
                onEditingChanged: { editing in
                    isDraggingSeek = editing
                    if !editing { player.audio.seek(to: seekValue) }
                }
            )
            .tint(Theme.Color.accent)

            HStack {
                Text(formatted(isDraggingSeek ? seekValue : player.audio.currentTime))
                Spacer()
                Text(formatted(player.audio.duration))
            }
            .font(Theme.Font.caption())
            .foregroundStyle(Theme.Color.textSecondary)
        }
    }

    private func transportControls(controlSize: CGFloat) -> some View {
        HStack(spacing: min(32, max(18, controlSize * 0.42))) {
            Button(action: { player.toggleShuffle() }) {
                Image(systemName: "shuffle")
                    .frame(width: 44, height: 44)
                    .foregroundStyle(player.isShuffled ? Theme.Color.accent : Theme.Color.textSecondary)
            }

            Button(action: { Theme.Haptics.light(); player.playPrevious() }) {
                Image(systemName: "backward.fill")
                    .font(.system(size: 24))
                    .frame(width: 44, height: 44)
                    .foregroundStyle(Theme.Color.textPrimary)
            }

            Button(action: { Theme.Haptics.medium(); player.togglePlayPause() }) {
                Image(systemName: player.audio.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: controlSize * 0.5))
                    .foregroundStyle(.black)
                    .frame(width: controlSize, height: controlSize)
                    .background(Theme.Color.textPrimary)
                    .clipShape(Circle())
            }
            .buttonStyle(PressableStyle())

            Button(action: { Theme.Haptics.light(); player.playNext() }) {
                Image(systemName: "forward.fill")
                    .font(.system(size: 24))
                    .frame(width: 44, height: 44)
                    .foregroundStyle(Theme.Color.textPrimary)
            }

            Button(action: { player.cycleRepeatMode() }) {
                Image(systemName: player.repeatMode == .one ? "repeat.1" : "repeat")
                    .frame(width: 44, height: 44)
                    .foregroundStyle(player.repeatMode == .off ? Theme.Color.textSecondary : Theme.Color.accent)
            }
        }
    }

    private func bottomRow(_ track: Track) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "iphone.and.arrow.forward").foregroundStyle(Theme.Color.textSecondary)
            Spacer()
            Text(sourceLabel(for: track)).font(Theme.Font.caption()).foregroundStyle(Theme.Color.textTertiary)
            Spacer()
            Image(systemName: "airplayaudio").foregroundStyle(Theme.Color.textSecondary)
        }
        .frame(minHeight: 44)
        .padding(.top, Theme.Spacing.xs)
    }

    private func providerHint(for source: TrackSource) -> String {
        switch source {
        case .spotify:
            return "Spotify spielt den Titel über den offiziellen eingebetteten Player. Anmeldung bzw. ein unterstütztes Spotify-Konto kann erforderlich sein."
        case .soundcloud:
            return "SoundCloud spielt den Titel über den offiziellen eingebetteten Player."
        case .local:
            return ""
        }
    }

    private func sourceLabel(for track: Track) -> String {
        switch track.source {
        case .spotify: return "Spotify"
        case .soundcloud: return "SoundCloud"
        case .local: return "Demo"
        }
    }

    private func formatted(_ seconds: TimeInterval) -> String {
        guard seconds.isFinite, seconds >= 0 else { return "0:00" }
        let m = Int(seconds) / 60
        let s = Int(seconds) % 60
        return String(format: "%d:%02d", m, s)
    }
}
