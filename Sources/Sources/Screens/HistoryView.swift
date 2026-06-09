import SwiftUI

/// "İzlemeye Devam Et" (movies/series) and "Son İzlenenler" (channels), with delete.
struct HistoryView: View {
    enum Kind { case channels, movies, series }
    let kind: Kind

    @EnvironmentObject var playlist: PlaylistStore
    @EnvironmentObject var history: HistoryStore
    @EnvironmentObject var theme: ThemeStore
    @State private var player: PlayerItem?

    private let posterColumns = [GridItem(.adaptive(minimum: 300), spacing: 36)]
    private let channelColumns = [GridItem(.adaptive(minimum: 340), spacing: 40)]

    private var title: String { kind == .channels ? "Son İzlenenler" : "İzlemeye Devam Et" }

    private var isEmpty: Bool {
        switch kind {
        case .channels: return history.channels.isEmpty
        case .movies:   return history.movies.isEmpty
        case .series:   return history.series.isEmpty
        }
    }

    var body: some View {
        let t = theme.theme
        ZStack {
            t.background.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 24) {
                HStack {
                    Text(title).font(.largeTitle.bold()).foregroundStyle(t.gold)
                    Spacer()
                    if !isEmpty {
                        Button { clearAll() } label: {
                            Label("Tümünü Sil", systemImage: "trash")
                        }.buttonStyle(.card)
                    }
                }
                if isEmpty {
                    VStack(spacing: 14) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 60)).foregroundStyle(t.textSecondary)
                        Text("Henüz kayıt yok. İzledikçe burada görünecek.")
                            .font(.title3).foregroundStyle(t.textSecondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView { grid(t) }
                }
            }
            .padding(48)
        }
        .fullScreenCover(item: $player) { PlayerView(item: $0) }
    }

    @ViewBuilder private func grid(_ t: AppTheme) -> some View {
        switch kind {
        case .channels:
            LazyVGrid(columns: channelColumns, spacing: 44) {
                ForEach(channelItems) { ch in
                    Button {
                        history.recordChannel(ch.id)
                        player = PlayerItem(title: ch.name, url: ch.streamURL, isLive: true)
                    } label: {
                        ChannelCard(name: ch.name, logoURL: ch.logoURL, theme: t)
                    }
                    .buttonStyle(.card)
                    .contextMenu {
                        Button(role: .destructive) { history.removeChannel(ch.id) } label: {
                            Label("Listeden kaldır", systemImage: "trash")
                        }
                    }
                }
            }
        case .movies:
            LazyVGrid(columns: posterColumns, spacing: 36) {
                ForEach(movieItems) { m in
                    NavigationLink(value: m) {
                        PosterCard(title: m.name, imageURL: m.coverURL, subtitle: m.year, theme: t)
                    }
                    .buttonStyle(.card)
                    .contextMenu {
                        Button(role: .destructive) { history.removeMovie(m.id) } label: {
                            Label("Listeden kaldır", systemImage: "trash")
                        }
                    }
                }
            }
        case .series:
            LazyVGrid(columns: posterColumns, spacing: 36) {
                ForEach(seriesItems) { s in
                    NavigationLink(value: s) {
                        PosterCard(title: s.name, imageURL: s.coverURL,
                                   subtitle: "\(s.episodes.count) bölüm", theme: t)
                    }
                    .buttonStyle(.card)
                    .contextMenu {
                        Button(role: .destructive) { history.removeSeries(s.id) } label: {
                            Label("Listeden kaldır", systemImage: "trash")
                        }
                    }
                }
            }
        }
    }

    // Resolve stored ids back to objects, preserving history order.
    private var channelItems: [Channel] {
        history.channels.compactMap { id in playlist.data.channels.first { $0.id == id } }
    }
    private var movieItems: [Movie] {
        history.movies.compactMap { id in playlist.data.movies.first { $0.id == id } }
    }
    private var seriesItems: [Series] {
        history.series.compactMap { id in playlist.data.series.first { $0.id == id } }
    }

    private func clearAll() {
        switch kind {
        case .channels: history.clearChannels()
        case .movies:   history.clearMovies()
        case .series:   history.clearSeries()
        }
    }
}
