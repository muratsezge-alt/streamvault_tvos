import SwiftUI

struct MoviesView: View {
    @EnvironmentObject var playlist: PlaylistStore
    @EnvironmentObject var theme: ThemeStore
    @State private var selectedGroup: String? = nil
    private let columns = [GridItem(.adaptive(minimum: 300), spacing: 44)]

    private var groups: [String] {
        Array(Set(playlist.data.movies.compactMap { $0.groupTitle })).sorted()
    }
    private var filtered: [Movie] {
        guard let g = selectedGroup else { return playlist.data.movies }
        return playlist.data.movies.filter { $0.groupTitle == g }
    }

    var body: some View {
        let t = theme.theme
        HStack(spacing: 0) {
            CategorySidebar(title: "Filmler", categories: groups,
                            selected: $selectedGroup, searchKind: .movies, theme: t)
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
