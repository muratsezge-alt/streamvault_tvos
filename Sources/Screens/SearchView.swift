import SwiftUI

/// Custom search: compact on-screen keys at the top, live-updating results below.
/// (tvOS's built-in `.searchable` forces an ugly fixed split keyboard — this replaces it.)
struct SearchView: View {
    enum Kind { case channels, movies, series }
    let kind: Kind

    @EnvironmentObject var playlist: PlaylistStore
    @EnvironmentObject var theme: ThemeStore
    @State private var query = ""
    @State private var player: PlayerItem?

    private let keyColumns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 10)
    private let resultColumns = [GridItem(.adaptive(minimum: 240), spacing: 36)]
    private let keys: [String] = "abcçdefgğhıijklmnoöpqrsştuüvwxyz0123456789".map { String($0) }

    private var title: String {
        switch kind { case .channels: return "Kanal Ara"; case .movies: return "Film Ara"; case .series: return "Dizi Ara" }
    }

    var body: some View {
        let t = theme.theme
        ZStack {
            t.background.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 22) {
                queryBar(t)
                keyboard(t)
                Divider().overlay(t.textSecondary.opacity(0.3))
                results(t)
            }
            .padding(48)
        }
        .fullScreenCover(item: $player) { PlayerView(item: $0) }
    }

    private func queryBar(_ t: AppTheme) -> some View {
        HStack(spacing: 14) {
            Image(systemName: "magnifyingglass").font(.title2).foregroundStyle(t.gold)
            Text(query.isEmpty ? title : query)
                .font(.title.bold())
                .foregroundStyle(query.isEmpty ? t.textSecondary : t.textPrimary)
                .lineLimit(1)
            Spacer()
            if !query.isEmpty {
                Text("\(resultCount) sonuç").font(.headline).foregroundStyle(t.textSecondary)
            }
        }
    }

    private func keyboard(_ t: AppTheme) -> some View {
        VStack(spacing: 12) {
            LazyVGrid(columns: keyColumns, spacing: 12) {
                ForEach(keys, id: \.self) { k in
                    KeyButton(label: k.uppercased(), theme: t) { query.append(k) }
                }
            }
            HStack(spacing: 12) {
                KeyButton(label: "BOŞLUK", theme: t) { query.append(" ") }
                KeyButton(label: "← SİL", theme: t) { if !query.isEmpty { query.removeLast() } }
                KeyButton(label: "TEMİZLE", theme: t) { query = "" }
            }
        }
    }

    @ViewBuilder private func results(_ t: AppTheme) -> some View {
        if query.trimmingCharacters(in: .whitespaces).isEmpty {
            VStack(spacing: 14) {
                Image(systemName: "magnifyingglass").font(.system(size: 60)).foregroundStyle(t.textSecondary)
                Text("Aramak için yukarıdan harf seçin").font(.title3).foregroundStyle(t.textSecondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView {
                LazyVGrid(columns: resultColumns, spacing: 36) {
                    switch kind {
                    case .channels:
                        ForEach(channelResults) { ch in
                            Button { player = PlayerItem(title: ch.name, url: ch.streamURL) } label: {
                                ChannelCard(name: ch.name, logoURL: ch.logoURL, theme: t)
                            }.buttonStyle(.card)
                        }
                    case .movies:
                        ForEach(movieResults) { m in
                            NavigationLink(value: m) {
                                PosterCard(title: m.name, imageURL: m.coverURL, subtitle: m.year, theme: t)
                            }.buttonStyle(.card)
                        }
                    case .series:
                        ForEach(seriesResults) { s in
                            NavigationLink(value: s) {
                                PosterCard(title: s.name, imageURL: s.coverURL,
                                           subtitle: "\(s.episodes.count) bölüm", theme: t)
                            }.buttonStyle(.card)
                        }
                    }
                }
                .padding(.top, 8)
            }
        }
    }

    // MARK: filtering
    private var q: String { query.trimmingCharacters(in: .whitespaces) }
    private var movieResults: [Movie] { playlist.data.movies.filter { $0.name.localizedCaseInsensitiveContains(q) } }
    private var channelResults: [Channel] { playlist.data.channels.filter { $0.name.localizedCaseInsensitiveContains(q) } }
    private var seriesResults: [Series] { playlist.data.series.filter { $0.name.localizedCaseInsensitiveContains(q) } }
    private var resultCount: Int {
        switch kind { case .channels: return channelResults.count; case .movies: return movieResults.count; case .series: return seriesResults.count }
    }
}

struct KeyButton: View {
    let label: String
    var theme: AppTheme
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.headline)
                .frame(maxWidth: .infinity, minHeight: 46)
        }
        .buttonStyle(.card)
    }
}
