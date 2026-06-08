import SwiftUI

struct RootView: View {
    @EnvironmentObject var playlist: PlaylistStore
    @EnvironmentObject var theme: ThemeStore
    @State private var showSplash = true

    var body: some View {
        ZStack {
            if showSplash {
                SplashView()
                    .transition(.opacity)
            } else if playlist.data.isEmpty {
                AddPlaylistView()
                    .transition(.opacity)
            } else {
                HomeView()
                    .transition(.opacity)
            }
        }
        .task {
            // Restore saved playlist while the splash shows (main-actor safe).
            let start = Date()
            if playlist.hasPlaylist && playlist.data.isEmpty {
                await playlist.reloadSaved()
            }
            let elapsed = Date().timeIntervalSince(start)
            if elapsed < 2.0 {
                try? await Task.sleep(nanoseconds: UInt64((2.0 - elapsed) * 1_000_000_000))
            }
            withAnimation(.easeInOut(duration: 0.5)) { showSplash = false }
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
