import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var playlist: PlaylistStore
    @EnvironmentObject var favorites: FavoritesStore
    @EnvironmentObject var theme: ThemeStore
    @State private var player: PlayerItem?

    private var favChannels: [Channel] {
        playlist.data.channels.filter { favorites.isFavorite(.channel, $0.id) }
    }
    private var favMovies: [Movie] {
        playlist.data.movies.filter { favorites.isFavorite(.movie, $0.id) }
    }
    private let columns = [GridItem(.adaptive(minimum: 240), spacing: 40)]

    var body: some View {
        let t = theme.theme
        NavigationStack {
            ZStack {
                t.background.ignoresSafeArea()
                ScrollView {
                    if favChannels.isEmpty && favMovies.isEmpty {
                        EmptyHint(text: "Henüz favori eklemediniz.", theme: t)
                    } else {
                        VStack(alignment: .leading, spacing: 40) {
                            if !favChannels.isEmpty {
                                SectionTitle(text: "Kanallar", theme: t)
                                LazyVGrid(columns: columns, spacing: 50) {
                                    ForEach(favChannels) { ch in
                                        Button { player = PlayerItem(title: ch.name, url: ch.streamURL) } label: {
                                            ChannelCard(name: ch.name, logoURL: ch.logoURL, theme: t)
                                        }.buttonStyle(.card)
                                    }
                                }
                            }
                            if !favMovies.isEmpty {
                                SectionTitle(text: "Filmler", theme: t)
                                LazyVGrid(columns: columns, spacing: 50) {
                                    ForEach(favMovies) { m in
                                        NavigationLink(value: m) {
                                            PosterCard(title: m.name, imageURL: m.coverURL, subtitle: m.year, theme: t)
                                        }.buttonStyle(.card)
                                    }
                                }
                            }
                        }
                        .padding(60)
                    }
                }
                .navigationDestination(for: Movie.self) { MovieDetailView(movie: $0) }
            }
        }
        .fullScreenCover(item: $player) { PlayerView(item: $0) }
    }
}
