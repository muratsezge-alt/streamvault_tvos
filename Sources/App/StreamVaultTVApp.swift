import SwiftUI

@main
struct StreamVaultTVApp: App {
    @StateObject private var playlist = PlaylistStore()
    @StateObject private var favorites = FavoritesStore()
    @StateObject private var themeStore = ThemeStore()
    @StateObject private var history = HistoryStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(playlist)
                .environmentObject(favorites)
                .environmentObject(themeStore)
                .environmentObject(history)
                .preferredColorScheme(.dark)
        }
    }
}
