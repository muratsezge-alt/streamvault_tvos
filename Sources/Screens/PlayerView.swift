import SwiftUI
import AVKit

/// Identifiable wrapper so we can drive fullScreenCover(item:).
struct PlayerItem: Identifiable {
    let id = UUID()
    let title: String
    let url: String
}

struct PlayerView: View {
    let item: PlayerItem
    @Environment(\.dismiss) private var dismiss
    @State private var player = AVPlayer()
    @State private var failed = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            if failed {
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle").font(.system(size: 60)).foregroundStyle(.yellow)
                    Text("Yayın açılamadı")
                        .font(.title2).foregroundStyle(.white)
                    Text("Bu akış tvOS'un desteklemediği bir formatta olabilir (ör. ham .ts). HLS (.m3u8) akışlar sorunsuz çalışır.")
                        .font(.callout).foregroundStyle(.gray)
                        .multilineTextAlignment(.center).frame(maxWidth: 700)
                    Button("Kapat") { dismiss() }
                }
            } else {
                VideoPlayer(player: player)
                    .ignoresSafeArea()
            }
        }
        .onAppear { start() }
        .onDisappear { player.pause() }
    }

    private func start() {
        guard let url = URL(string: item.url) else { failed = true; return }
        let asset = AVURLAsset(url: url, options: [
            "AVURLAssetHTTPHeaderFieldsKey": ["User-Agent": "VLC/3.0 LibVLC/3.0"]
        ])
        let playerItem = AVPlayerItem(asset: asset)
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemFailedToPlayToEndTime, object: playerItem, queue: .main) { _ in
                failed = true
            }
        player.replaceCurrentItem(with: playerItem)
        player.play()

        // If still not playing shortly after, surface a friendly error.
        DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
            if player.currentItem?.status == .failed { failed = true }
        }
    }
}
