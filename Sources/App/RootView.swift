import SwiftUI

struct RootView: View {
    @EnvironmentObject var playlist: PlaylistStore
    @EnvironmentObject var theme: ThemeStore

    var body: some View {
        ZStack {
            theme.theme.background.ignoresSafeArea()

            if playlist.data.isEmpty {
                AddPlaylistView()
            } else {
                MainTabView()
            }
        }
        .task {
            // Auto-reload the saved list on launch.
            if playlist.hasPlaylist && playlist.data.isEmpty {
                await playlist.reloadSaved()
            }
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject var theme: ThemeStore

    var body: some View {
        TabView {
            LiveView()
                .tabItem { Label("Canlı TV", systemImage: "tv") }
            MoviesView()
                .tabItem { Label("Filmler", systemImage: "film") }
            SeriesView()
                .tabItem { Label("Diziler", systemImage: "rectangle.stack") }
            FavoritesView()
                .tabItem { Label("Favoriler", systemImage: "star") }
            SettingsView()
                .tabItem { Label("Ayarlar", systemImage: "gearshape") }
        }
        .tint(theme.theme.gold)
    }
}
