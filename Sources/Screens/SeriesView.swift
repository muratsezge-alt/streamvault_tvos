import SwiftUI

struct SeriesView: View {
    @EnvironmentObject var playlist: PlaylistStore
    @EnvironmentObject var theme: ThemeStore
    @State private var selectedGroup: String? = nil
    private let columns = [GridItem(.adaptive(minimum: 300), spacing: 44)]

    private var groups: [String] {
        Array(Set(playlist.data.series.compactMap { $0.groupTitle })).sorted()
    }
    private var filtered: [Series] {
        guard let g = selectedGroup else { return playlist.data.series }
        return playlist.data.series.filter { $0.groupTitle == g }
    }

    var body: some View {
        let t = theme.theme
        HStack(spacing: 0) {
            CategorySidebar(title: "Diziler", categories: groups,
                            selected: $selectedGroup, searchKind: .series, historyKind: .series, historyLabel: "İzlemeye Devam Et", theme: t)
            ZStack {
                t.background.ignoresSafeArea()
                if playlist.data.series.isEmpty {
                    EmptyHint(text: "Bu listede dizi bulunamadı.", theme: t)
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 50) {
                            ForEach(filtered) { s in
                                NavigationLink(value: s) {
                                    PosterCard(title: s.name, imageURL: s.coverURL,
                                               subtitle: "\(s.episodes.count) bölüm", theme: t)
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

struct SeriesDetailView: View {
    let series: Series
    @EnvironmentObject var theme: ThemeStore
    @EnvironmentObject var history: HistoryStore
    @State private var season: Int = 1
    @State private var player: PlayerItem?

    var body: some View {
        let t = theme.theme
        ZStack {
            t.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    Text(series.name).font(.largeTitle.bold()).foregroundStyle(t.textPrimary)

                    if series.seasons.count > 1 {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(series.seasons, id: \.self) { s in
                                    CategoryChip(label: "Sezon \(s)", selected: season == s, theme: t) { season = s }
                                }
                            }
                        }
                    }

                    ForEach(episodesForCurrentSeason) { ep in
                        Button {
                            history.recordSeries(series.id)
                            player = PlayerItem(title: ep.name, url: ep.streamURL)
                        } label: {
                            HStack {
                                Image(systemName: "play.circle.fill").foregroundStyle(t.gold)
                                Text(ep.name).foregroundStyle(t.textPrimary)
                                Spacer()
                            }
                            .padding()
                            .background(t.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(60)
            }
        }
        .onAppear { season = series.seasons.first ?? 1 }
        .fullScreenCover(item: $player) { PlayerView(item: $0) }
    }

    private var episodesForCurrentSeason: [Episode] {
        series.episodes(inSeason: season)
    }
}
