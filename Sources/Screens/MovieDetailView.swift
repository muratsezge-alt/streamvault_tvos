import SwiftUI

struct MovieDetailView: View {
    let movie: Movie
    @EnvironmentObject var theme: ThemeStore
    @EnvironmentObject var favorites: FavoritesStore
    @EnvironmentObject var history: HistoryStore
    @State private var player: PlayerItem?

    var body: some View {
        let t = theme.theme
        ZStack {
            t.background.ignoresSafeArea()
            HStack(alignment: .top, spacing: 50) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16).fill(t.surface)
                    AsyncImage(url: URL(string: movie.coverURL ?? "")) { phase in
                        if case .success(let img) = phase {
                            img.resizable().scaledToFill()
                        } else {
                            Image(systemName: "film").font(.system(size: 80)).foregroundStyle(t.textSecondary)
                        }
                    }
                }
                .frame(width: 360, height: 520)
                .clipShape(RoundedRectangle(cornerRadius: 16))

                VStack(alignment: .leading, spacing: 24) {
                    Text(movie.name).font(.largeTitle.bold()).foregroundStyle(t.textPrimary)
                    if let year = movie.year {
                        Text(year).font(.title3).foregroundStyle(t.textSecondary)
                    }
                    if let group = movie.groupTitle {
                        Text(group).font(.headline).foregroundStyle(t.gold)
                    }
                    Spacer().frame(height: 20)
                    HStack(spacing: 24) {
                        Button {
                            history.recordMovie(movie.id)
                            player = PlayerItem(title: movie.name, url: movie.streamURL)
                        } label: {
                            Label("Şimdi İzle", systemImage: "play.fill").font(.headline).padding(.horizontal, 30)
                        }
                        Button {
                            favorites.toggle(.movie, movie.id)
                        } label: {
                            Label(favorites.isFavorite(.movie, movie.id) ? "Favorilerde" : "Favorilere Ekle",
                                  systemImage: favorites.isFavorite(.movie, movie.id) ? "star.fill" : "star")
                        }
                    }
                    Spacer()
                }
                Spacer()
            }
            .padding(80)
        }
        .fullScreenCover(item: $player) { PlayerView(item: $0) }
    }
}
