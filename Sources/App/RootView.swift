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
            // While the splash shows, try to restore the saved playlist.
            async let restore: Void = {
                if playlist.hasPlaylist && playlist.data.isEmpty {
                    await playlist.reloadSaved()
                }
            }()
            async let minimum: Void = {
                try? await Task.sleep(nanoseconds: 2_200_000_000)
            }()
            _ = await (restore, minimum)
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
