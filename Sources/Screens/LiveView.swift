import SwiftUI

struct LiveView: View {
    @EnvironmentObject var playlist: PlaylistStore
    @EnvironmentObject var theme: ThemeStore
    @EnvironmentObject var favorites: FavoritesStore
    @State private var selectedGroup: String? = nil
    @State private var player: PlayerItem?

    private var groups: [String] {
        let all = playlist.data.channels.compactMap { $0.groupTitle }
        return Array(Set(all)).sorted()
    }

    private var filtered: [Channel] {
        guard let g = selectedGroup else { return playlist.data.channels }
        return playlist.data.channels.filter { $0.groupTitle == g }
    }

    private let columns = [GridItem(.adaptive(minimum: 280), spacing: 40)]

    var body: some View {
        let t = theme.theme
        ZStack {
            t.background.ignoresSafeArea()
            ScrollView {
                if !groups.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            CategoryChip(label: "Tümü", selected: selectedGroup == nil, theme: t) {
                                selectedGroup = nil
                            }
                            ForEach(groups, id: \.self) { g in
                                CategoryChip(label: g, selected: selectedGroup == g, theme: t) {
                                    selectedGroup = g
                                }
                            }
                        }
                        .padding(.horizontal, 60)
                    }
                    .padding(.vertical, 10)
                }

                LazyVGrid(columns: columns, spacing: 50) {
                    ForEach(filtered) { ch in
                        Button {
                            player = PlayerItem(title: ch.name, url: ch.streamURL)
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
                .padding(60)
            }
        }
        .fullScreenCover(item: $player) { item in
            PlayerView(item: item)
        }
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
                .padding(.horizontal, 28)
                .padding(.vertical, 14)
                .background(selected ? theme.gold : theme.surface)
                .foregroundStyle(selected ? theme.background : theme.textPrimary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
