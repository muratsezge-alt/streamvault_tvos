import SwiftUI

@main
struct StreamVaultTVApp: App {
    @StateObject private var playlist = PlaylistStore()
    @StateObject private var favorites = FavoritesStore()
    @StateObject private var themeStore = ThemeStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(playlist)
                .environmentObject(favorites)
                .environmentObject(themeStore)
                .preferredColorScheme(.dark)
        }
    }
}
