import SwiftUI

struct CreatePlaylistView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var libraryViewModel: LibraryViewModel

    @State private var name = ""
    @State private var selectedEmoji = "🎵"
    private let emojiOptions = ["🎵", "🔥", "🌙", "🌊", "🎧", "☀️", "💫", "🚗"]

    var body: some View {
        NavigationStack {
            VStack(spacing: Theme.Spacing.lg) {
                RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous)
                    .fill(Theme.Color.surfaceElevated)
                    .containerRelativeFrame(.horizontal, count: 2, span: 1, spacing: Theme.Spacing.md)
                    .aspectRatio(1, contentMode: .fit)
                    .overlay(Text(selectedEmoji).font(.system(.largeTitle)))
                    .padding(.top, Theme.Spacing.lg)

                TextField("Playlist-Name", text: $name)
                    .font(Theme.Font.heading())
                    .padding()
                    .background(Theme.Color.surface)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
                    .padding(.horizontal, Theme.Spacing.md)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: Theme.Spacing.sm) {
                    ForEach(emojiOptions, id: \.self) { emoji in
                        Button(action: { selectedEmoji = emoji }) {
                            Text(emoji)
                                .font(.system(.title2))
                                .frame(minWidth: 52, minHeight: 52)
                                .background(selectedEmoji == emoji ? Theme.Color.accent.opacity(0.25) : Theme.Color.surface)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                    }
                }
                .padding(.horizontal, Theme.Spacing.md)

                Spacer()

                Button(action: {
                    libraryViewModel.createPlaylist(name: name, emoji: selectedEmoji)
                    dismiss()
                }) {
                    Text("Erstellen")
                        .font(Theme.Font.subheading())
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(name.trimmingCharacters(in: .whitespaces).isEmpty ? Theme.Color.textTertiary : Theme.Color.accent)
                        .clipShape(Capsule())
                }
                .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.bottom, Theme.Spacing.lg)
            }
            .background(Theme.Color.background.ignoresSafeArea())
            .navigationTitle("Neue Playlist")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
            }
        }
    }
}
