import SwiftUI

struct MoviesView: View {
    @EnvironmentObject var playlist: PlaylistStore
    @EnvironmentObject var theme: ThemeStore
    @State private var selectedGroup: String? = nil

    private var groups: [String] {
        Array(Set(playlist.data.movies.compactMap { $0.groupTitle })).sorted()
    }
    private var filtered: [Movie] {
        guard let g = selectedGroup else { return playlist.data.movies }
        return playlist.data.movies.filter { $0.groupTitle == g }
    }
    private let columns = [GridItem(.adaptive(minimum: 240), spacing: 40)]

    var body: some View {
        let t = theme.theme
        NavigationStack {
            ZStack {
                t.background.ignoresSafeArea()
                ScrollView {
                    if playlist.data.movies.isEmpty {
                        EmptyHint(text: "Bu listede film bulunamadı.", theme: t)
                    } else {
                        if !groups.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    CategoryChip(label: "Tümü", selected: selectedGroup == nil, theme: t) { selectedGroup = nil }
                                    ForEach(groups, id: \.self) { g in
                                        CategoryChip(label: g, selected: selectedGroup == g, theme: t) { selectedGroup = g }
                                    }
                                }.padding(.horizontal, 60)
                            }.padding(.vertical, 10)
                        }
                        LazyVGrid(columns: columns, spacing: 50) {
                            ForEach(filtered) { movie in
                                NavigationLink(value: movie) {
                                    PosterCard(title: movie.name, imageURL: movie.coverURL,
                                               subtitle: movie.year, theme: t)
                                }
                                .buttonStyle(.card)
                            }
                        }.padding(60)
                    }
                }
            }
            .navigationDestination(for: Movie.self) { MovieDetailView(movie: $0) }
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
        .frame(maxWidth: .infinity, minHeight: 500)
    }
}
