import SwiftUI

enum HomeSection: Hashable { case live, movies, series, favorites, settings }

struct HomeView: View {
    @EnvironmentObject var playlist: PlaylistStore
    @EnvironmentObject var theme: ThemeStore
    @State private var now = Date()
    private let clock = Timer.publish(every: 20, on: .main, in: .common).autoconnect()

    private var dateText: String {
        let f = DateFormatter(); f.locale = Locale(identifier: "tr_TR")
        f.dateFormat = "d MMMM yyyy"; return f.string(from: now)
    }
    private var timeText: String {
        let f = DateFormatter(); f.dateFormat = "HH:mm"; return f.string(from: now)
    }

    var body: some View {
        let t = theme.theme
        NavigationStack {
            ZStack {
                t.background.ignoresSafeArea()
                RadialGradient(colors: [t.gold.opacity(0.10), .clear],
                               center: .topTrailing, startRadius: 60, endRadius: 850)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    topBar(t)
                    Spacer(minLength: 24)
                    HStack(spacing: 44) {
                        HomeCard(title: "CANLI TV", icon: "tv.fill", accent: Color(hex: 0x4A90E2),
                                 count: playlist.data.channels.count, suffix: "kanal",
                                 value: .live, theme: t)
                        HomeCard(title: "FİLMLER", icon: "film.fill", accent: t.gold,
                                 count: playlist.data.movies.count, suffix: "film",
                                 value: .movies, theme: t)
                        HomeCard(title: "DİZİLER", icon: "rectangle.stack.fill", accent: Color(hex: 0x9B6DD6),
                                 count: playlist.data.series.count, suffix: "dizi",
                                 value: .series, theme: t)
                    }
                    .frame(maxHeight: 460)
                    Spacer(minLength: 24)
                    footer(t)
                }
                .padding(.horizontal, 80)
                .padding(.vertical, 56)
            }
            .navigationDestination(for: HomeSection.self) { section in
                switch section {
                case .live:      LiveView()
                case .movies:    MoviesView()
                case .series:    SeriesView()
                case .favorites: FavoritesView()
                case .settings:  SettingsView()
                }
            }
            .navigationDestination(for: Movie.self) { MovieDetailView(movie: $0) }
            .navigationDestination(for: Series.self) { SeriesDetailView(series: $0) }
        }
        .onReceive(clock) { now = $0 }
    }

    private func topBar(_ t: AppTheme) -> some View {
        HStack(spacing: 22) {
            Image("AppLogo").resizable().scaledToFit()
                .frame(width: 66, height: 66)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            VStack(alignment: .leading, spacing: 0) {
                Text("StreamVault").font(.title2.bold()).foregroundStyle(t.textPrimary)
                Text("ULTRA PREMIUM IPTV").font(.caption2).tracking(3).foregroundStyle(t.gold)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 0) {
                Text(timeText).font(.title.bold()).foregroundStyle(t.textPrimary)
                Text(dateText).font(.callout).foregroundStyle(t.textSecondary)
            }
            .padding(.trailing, 12)
            NavigationLink(value: HomeSection.favorites) {
                Image(systemName: "star.fill").font(.title3)
            }.buttonStyle(.card)
            NavigationLink(value: HomeSection.settings) {
                Image(systemName: "gearshape.fill").font(.title3)
            }.buttonStyle(.card)
        }
    }

    private func footer(_ t: AppTheme) -> some View {
        let total = playlist.data.channels.count + playlist.data.movies.count + playlist.data.series.count
        return HStack {
            Image(systemName: "checkmark.seal.fill").foregroundStyle(t.gold)
            Text("Liste hazır").font(.callout).foregroundStyle(t.textSecondary)
            Spacer()
            Text("\(total) içerik").font(.callout).foregroundStyle(t.textSecondary)
        }
    }
}

/// Premium brand card. Uses the system `.card` focus (lift + shine, no white frame).
struct HomeCard: View {
    let title: String
    let icon: String
    let accent: Color
    let count: Int
    let suffix: String
    let value: HomeSection
    var theme: AppTheme

    var body: some View {
        NavigationLink(value: value) {
            ZStack {
                LinearGradient(colors: [theme.surface, theme.background],
                               startPoint: .top, endPoint: .bottom)
                RadialGradient(colors: [accent.opacity(0.40), .clear],
                               center: .top, startRadius: 10, endRadius: 380)
                VStack(spacing: 22) {
                    ZStack {
                        Circle().fill(theme.gold.opacity(0.16)).frame(width: 124, height: 124)
                        Image(systemName: icon).font(.system(size: 56, weight: .semibold))
                            .foregroundStyle(theme.gold)
                    }
                    Text(title).font(.system(size: 30, weight: .bold)).foregroundStyle(theme.textPrimary)
                    Text("\(count) \(suffix)").font(.headline).foregroundStyle(theme.textSecondary)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .buttonStyle(.card)
    }
}

// MARK: - Shared left category sidebar (categories only; search is via .searchable)

struct CategorySidebar: View {
    let title: String
    let categories: [String]
    @Binding var selected: String?
    var searchKind: SearchView.Kind
    var historyKind: HistoryView.Kind
    var historyLabel: String
    var theme: AppTheme

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(title).font(.largeTitle.bold()).foregroundStyle(theme.gold)
            NavigationLink(destination: SearchView(kind: searchKind)) {
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                    Text("Ara")
                    Spacer()
                }
                .font(.headline)
                .foregroundStyle(theme.textPrimary)
                .padding(.vertical, 14).padding(.horizontal, 18)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.card)
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 8) {
                    SidebarRow(label: "Tümü", selected: selected == nil, theme: theme) { selected = nil }
                    NavigationLink(destination: HistoryView(kind: historyKind)) {
                        HStack(spacing: 10) {
                            Image(systemName: historyKind == .channels ? "clock.arrow.circlepath" : "play.circle.fill")
                            Text(historyLabel).lineLimit(1)
                            Spacer()
                        }
                        .font(.headline)
                        .foregroundStyle(theme.gold)
                        .padding(.vertical, 14).padding(.horizontal, 18)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.card)
                    ForEach(categories, id: \.self) { c in
                        SidebarRow(label: c, selected: selected == c, theme: theme) { selected = c }
                    }
                }
            }
        }
        .frame(width: 440)
        .padding(36)
        .background(theme.backgroundSecondary.ignoresSafeArea())
    }
}

struct SidebarRow: View {
    let label: String
    let selected: Bool
    var theme: AppTheme
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Text(label)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                    .multilineTextAlignment(.leading)
                Spacer(minLength: 6)
                if selected { Image(systemName: "checkmark.circle.fill") }
            }
            .font(.headline)
            .foregroundStyle(selected ? theme.gold : theme.textPrimary)
            .padding(.vertical, 14).padding(.horizontal, 18)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.card)
    }
}
