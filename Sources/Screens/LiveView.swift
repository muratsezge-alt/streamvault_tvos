import SwiftUI

struct LiveView: View {
    @EnvironmentObject var playlist: PlaylistStore
    @EnvironmentObject var theme: ThemeStore
    @EnvironmentObject var favorites: FavoritesStore
    @EnvironmentObject var history: HistoryStore
    @State private var selectedGroup: String? = nil
    @State private var player: PlayerItem?
    private let columns = [GridItem(.adaptive(minimum: 340), spacing: 44)]

    private var groups: [String] {
        Array(Set(playlist.data.channels.compactMap { $0.groupTitle })).sorted()
    }
    private var filtered: [Channel] {
        guard let g = selectedGroup else { return playlist.data.channels }
        return playlist.data.channels.filter { $0.groupTitle == g }
    }

    var body: some View {
        let t = theme.theme
        HStack(spacing: 0) {
            CategorySidebar(title: "Canlı TV", categories: groups,
                            selected: $selectedGroup, searchKind: .channels, historyKind: .channels, historyLabel: "Son İzlenenler", theme: t)
            ZStack {
                t.background.ignoresSafeArea()
                if playlist.data.channels.isEmpty {
                    EmptyHint(text: "Bu listede kanal bulunamadı.", theme: t)
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 50) {
                            ForEach(filtered) { ch in
                                Button {
                                    history.recordChannel(ch.id)
                                    player = PlayerItem(title: ch.name, url: ch.streamURL, isLive: true)
                                } label: {
                                    ChannelCard(name: ch.name, logoURL: ch.logoURL, theme: t)
                                }
                                .buttonStyle(.card)
                                .contextMenu {
                                    Button {
                                        favorites.toggle(.channel, ch.id)
                                    } label: {
                                        Label(favorites.isFavorite(.channel, ch.id) ? "Favorilerden çıkar" : "Favorilere ekle",
                                              systemImage: "star")
                                    }
                                }
                            }
                        }
                        .padding(50)
                    }
                }
            }
        }
        .fullScreenCover(item: $player) { PlayerView(item: $0) }
    }
}

struct CategoryChip: View {
    let label: String
    let selected: Bool
    var theme: AppTheme
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.headline)
                .padding(.horizontal, 28).padding(.vertical, 14)
                .background(selected ? theme.gold : theme.surface)
                .foregroundStyle(selected ? theme.background : theme.textPrimary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
