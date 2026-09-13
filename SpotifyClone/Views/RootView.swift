import SwiftUI

struct RootView: View {
    @EnvironmentObject private var player: PlayerViewModel
    @Namespace private var playerNamespace

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottom) {
                Theme.Color.background
                    .ignoresSafeArea()

                TabView {
                    HomeView()
                        .tabItem { Label("Home", systemImage: "house.fill") }

                    SearchView()
                        .tabItem { Label("Suchen", systemImage: "magnifyingglass") }

                    LibraryView()
                        .tabItem { Label("Mediathek", systemImage: "books.vertical.fill") }

                    SettingsView()
                        .tabItem { Label("Einstellungen", systemImage: "gearshape.fill") }
                }
                .tint(Theme.Color.accent)
                .background(Theme.Color.background)
                .frame(width: proxy.size.width, height: proxy.size.height)
                .ignoresSafeArea()

                if player.currentTrack != nil && !player.isFullPlayerPresented {
                    MiniPlayerView(namespace: playerNamespace)
                        .padding(.bottom, 49)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Color.background)
        .ignoresSafeArea()
        .animation(Theme.Animation.spring, value: player.currentTrack?.id)
        .fullScreenCover(isPresented: $player.isFullPlayerPresented) {
            FullPlayerView(namespace: playerNamespace)
        }
    }
}
