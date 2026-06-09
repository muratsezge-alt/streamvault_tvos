import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var playlist: PlaylistStore
    @EnvironmentObject var theme: ThemeStore

    var body: some View {
        let t = theme.theme
        ZStack {
            t.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 40) {
                    Text("Ayarlar").font(.largeTitle.bold()).foregroundStyle(t.textPrimary)

                    // Theme
                    SectionTitle(text: "Tema", theme: t)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 24) {
                            ForEach(AppTheme.allCases) { variant in
                                Button { theme.theme = variant } label: {
                                    VStack(spacing: 10) {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(variant.background)
                                            .frame(width: 200, height: 120)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(theme.theme == variant ? variant.gold : .clear, lineWidth: 4)
                                            )
                                            .overlay(
                                                Circle().fill(variant.ambient).frame(width: 36, height: 36)
                                            )
                                        Text(variant.displayName).font(.headline).foregroundStyle(t.textPrimary)
                                        Text(variant.description).font(.caption2)
                                            .foregroundStyle(t.textSecondary).frame(width: 200)
                                            .multilineTextAlignment(.center)
                                    }
                                }
                                .buttonStyle(.card)
                            }
                        }
                    }

                    // Playlist
                    SectionTitle(text: "Liste", theme: t)
                    HStack(spacing: 24) {
                        Button {
                            Task { await playlist.reloadSaved() }
                        } label: {
                            Label("Listeyi Yenile", systemImage: "arrow.clockwise")
                        }
                        Button(role: .destructive) {
                            playlist.clear()
                        } label: {
                            Label("Listeyi Değiştir", systemImage: "trash")
                        }
                    }

                    let d = playlist.data
                    Text("\(d.channels.count) kanal · \(d.movies.count) film · \(d.series.count) dizi")
                        .font(.callout).foregroundStyle(t.textSecondary)

                    Text("StreamVault tvOS · v1.0.0")
                        .font(.caption).foregroundStyle(t.textSecondary)
                }
                .padding(80)
            }
        }
    }
}
