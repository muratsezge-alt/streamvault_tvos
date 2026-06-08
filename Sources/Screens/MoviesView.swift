import SwiftUI

struct MoviesView: View {
    @EnvironmentObject var playlist: PlaylistStore
    @EnvironmentObject var theme: ThemeStore
    @State private var selectedGroup: String? = nil
    @State private var query = ""
    private let columns = [GridItem(.adaptive(minimum: 240), spacing: 40)]

    private var groups: [String] {
        Array(Set(playlist.data.movies.compactMap { $0.groupTitle })).sorted()
    }
    private var filtered: [Movie] {
        playlist.data.movies.filter { m in
            (selectedGroup == nil || m.groupTitle == selectedGroup) &&
            (query.isEmpty || m.name.localizedCaseInsensitiveContains(query))
        }
    }

    var body: some View {
        let t = theme.theme
        HStack(spacing: 0) {
            CategorySidebar(title: "Filmler", categories: groups,
                            selected: $selectedGroup, query: $query, theme: t)
            ZStack {
                t.background.ignoresSafeArea()
                if playlist.data.movies.isEmpty {
                    EmptyHint(text: "Bu listede film bulunamadı.", theme: t)
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 50) {
                            ForEach(filtered) { movie in
                                NavigationLink(value: movie) {
                                    PosterCard(title: movie.name, imageURL: movie.coverURL,
                                               subtitle: movie.year, theme: t)
                                }
                                .buttonStyle(.card)
                            }
                        }
                        .padding(50)
                    }
                }
            }
        }
        .navigationDestination(for: Movie.self) { MovieDetailView(movie: $0) }
    }
}

struct EmptyHint: View {
    let text: String
    var theme: AppTheme
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray").font(.system(size: 60)).foregroundStyle(theme.textSecondary)
            Text(text).font(.title3).foregroundStyle(theme.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
