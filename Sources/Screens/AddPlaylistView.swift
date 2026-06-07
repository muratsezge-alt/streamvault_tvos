import SwiftUI

struct AddPlaylistView: View {
    @EnvironmentObject var playlist: PlaylistStore
    @EnvironmentObject var theme: ThemeStore
    @State private var url: String = ""

    var body: some View {
        let t = theme.theme
        VStack(spacing: 40) {
            VStack(spacing: 12) {
                Image(systemName: "play.rectangle.on.rectangle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(t.gold)
                Text("StreamVault")
                    .font(.system(size: 56, weight: .bold))
                    .foregroundStyle(t.textPrimary)
                Text("M3U liste adresini girerek başlayın")
                    .font(.title3)
                    .foregroundStyle(t.textSecondary)
            }

            VStack(spacing: 24) {
                TextField("https://ornek.com/playlist.m3u", text: $url)
                    .textContentType(.URL)
                    .frame(maxWidth: 900)

                if let error = playlist.errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                        .font(.callout)
                        .multilineTextAlignment(.center)
                }

                Button {
                    Task { await playlist.load(urlString: url) }
                } label: {
                    HStack {
                        if playlist.isLoading {
                            ProgressView().tint(t.background)
                        }
                        Text(playlist.isLoading ? "Yükleniyor…" : "Listeyi Yükle")
                            .font(.headline)
                    }
                    .frame(maxWidth: 500)
                }
                .disabled(url.isEmpty || playlist.isLoading)
            }
        }
        .padding(80)
    }
}
