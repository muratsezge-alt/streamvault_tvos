import SwiftUI

// MARK: - Home (launch) screen

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
                    HStack(spacing: 40) {
                        HomeCard(title: "CANLI TV", icon: "tv",
                                 gradient: [Color(hex: 0x2E8B57), Color(hex: 0x1E5FA8)],
                                 count: playlist.data.channels.count, suffix: "kanal",
                                 destination: AnyView(LiveView()), theme: t)
                        HomeCard(title: "FİLMLER", icon: "film",
                                 gradient: [Color(hex: 0xC0392B), Color(hex: 0xE67E22)],
                                 count: playlist.data.movies.count, suffix: "film",
                                 destination: AnyView(MoviesView()), theme: t)
                        HomeCard(title: "DİZİLER", icon: "rectangle.stack",
                                 gradient: [Color(hex: 0x7D3C98), Color(hex: 0x2980B9)],
                                 count: playlist.data.series.count, suffix: "dizi",
                                 destination: AnyView(SeriesView()), theme: t)
                    }
                    .frame(maxHeight: 440)
                    Spacer(minLength: 24)
                    footer(t)
                }
                .padding(.horizontal, 70)
                .padding(.vertical, 50)
            }
        }
        .onReceive(clock) { now = $0 }
    }

    private func topBar(_ t: AppTheme) -> some View {
        HStack(spacing: 22) {
            Image("AppLogo").resizable().scaledToFit()
                .frame(width: 64, height: 64)
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
            NavigationLink(destination: FavoritesView()) {
                Image(systemName: "star.fill").font(.title3)
            }.buttonStyle(.card)
            NavigationLink(destination: SettingsView()) {
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

// MARK: - Big launch card

struct HomeCard: View {
    let title: String
    let icon: String
    let gradient: [Color]
    let count: Int
    let suffix: String
    let destination: AnyView
    var theme: AppTheme

    var body: some View {
        NavigationLink(destination: destination) {
            ZStack {
                LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                LinearGradient(colors: [.clear, .black.opacity(0.35)], startPoint: .top, endPoint: .bottom)
                VStack(spacing: 16) {
                    Image(systemName: icon).font(.system(size: 78, weight: .semibold))
                        .foregroundStyle(.white)
                    Text(title).font(.system(size: 32, weight: .bold)).foregroundStyle(.white)
                    Text("\(count) \(suffix)").font(.headline).foregroundStyle(.white.opacity(0.85))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .buttonStyle(.card)
    }
}

// MARK: - Shared left category sidebar (with search)

struct CategorySidebar: View {
    let title: String
    let categories: [String]
    @Binding var selected: String?
    @Binding var query: String
    var theme: AppTheme

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title).font(.title.bold()).foregroundStyle(theme.gold)
            TextField("Ara…", text: $query)
                .padding(12)
                .background(theme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 6) {
                    SidebarRow(label: "Tümü", selected: selected == nil, theme: theme) { selected = nil }
                    ForEach(categories, id: \.self) { c in
                        SidebarRow(label: c, selected: selected == c, theme: theme) { selected = c }
                    }
                }
            }
        }
        .frame(width: 380)
        .padding(28)
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
            HStack {
                Text(label).lineLimit(1)
                Spacer()
                if selected { Image(systemName: "checkmark") }
            }
            .font(.headline)
            .foregroundStyle(selected ? theme.gold : theme.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 10).padding(.horizontal, 14)
        }
        .buttonStyle(.card)
    }
}
