import SwiftUI

struct SeriesView: View {
    @EnvironmentObject var playlist: PlaylistStore
    @EnvironmentObject var theme: ThemeStore
    private let columns = [GridItem(.adaptive(minimum: 240), spacing: 40)]

    var body: some View {
        let t = theme.theme
        NavigationStack {
            ZStack {
                t.background.ignoresSafeArea()
                ScrollView {
                    if playlist.data.series.isEmpty {
                        EmptyHint(text: "Bu listede dizi bulunamadı.", theme: t)
                    } else {
                        LazyVGrid(columns: columns, spacing: 50) {
                            ForEach(playlist.data.series) { s in
                                NavigationLink(value: s) {
                                    PosterCard(title: s.name, imageURL: s.coverURL,
                                               subtitle: "\(s.episodes.count) bölüm", theme: t)
                                }
                                .buttonStyle(.card)
                            }
                        }.padding(60)
                    }
                }
            }
            .navigationDestination(for: Series.self) { SeriesDetailView(series: $0) }
        }
    }
}

struct SeriesDetailView: View {
    let series: Series
    @EnvironmentObject var theme: ThemeStore
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
