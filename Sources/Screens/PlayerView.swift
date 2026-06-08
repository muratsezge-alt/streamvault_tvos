import SwiftUI
import VLCKitSPM

/// Identifiable wrapper so we can drive fullScreenCover(item:).
struct PlayerItem: Identifiable {
    let id = UUID()
    let title: String
    let url: String
}

/// VLC-backed player: handles raw MPEG-TS (.ts), MKV, AVI, HLS, MP4 — everything
/// a real IPTV stream throws at it (AVPlayer cannot).
final class VLCPlayerModel: NSObject, ObservableObject, VLCMediaPlayerDelegate {
    let player = VLCMediaPlayer()
    @Published var failed = false
    @Published var buffering = true

    override init() {
        super.init()
        player.delegate = self
    }

    func attach(to view: UIView) { player.drawable = view }

    func play(urlString: String) {
        guard let url = URL(string: urlString) else { failed = true; buffering = false; return }
        let media = VLCMedia(url: url)
        media.addOption(":network-caching=1500")   // smoother live streams
        player.media = media
        player.play()
    }

    func stop() { player.stop() }

    func mediaPlayerStateChanged(_ aNotification: Notification!) {
        DispatchQueue.main.async {
            switch self.player.state {
            case .error:
                self.failed = true; self.buffering = false
            case .playing:
                self.failed = false; self.buffering = false
            case .buffering, .opening:
                self.buffering = true
            default:
                break
            }
        }
    }
}

private struct VLCVideoView: UIViewRepresentable {
    @ObservedObject var model: VLCPlayerModel
    func makeUIView(context: Context) -> UIView {
        let v = UIView()
        v.backgroundColor = .black
        model.attach(to: v)
        return v
    }
    func updateUIView(_ uiView: UIView, context: Context) {}
}

struct PlayerView: View {
    let item: PlayerItem
    @Environment(\.dismiss) private var dismiss
    @StateObject private var model = VLCPlayerModel()

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VLCVideoView(model: model).ignoresSafeArea()

            if model.buffering && !model.failed {
                VStack(spacing: 16) {
                    ProgressView().scaleEffect(1.6).tint(.white)
                    Text(item.title).font(.headline).foregroundStyle(.white.opacity(0.85))
                }
            }

            if model.failed {
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 60)).foregroundStyle(.yellow)
                    Text("Yayın açılamadı").font(.title2).foregroundStyle(.white)
                    Text("Sunucu yanıt vermiyor ya da bağlantı geçersiz olabilir. Başka bir kanal/içerik deneyin.")
                        .font(.callout).foregroundStyle(.gray)
                        .multilineTextAlignment(.center).frame(maxWidth: 700)
                    Button("Kapat") { dismiss() }
                }
            }
        }
        .onAppear { model.play(urlString: item.url) }
        .onDisappear { model.stop() }
        .onExitCommand { dismiss() }   // Siri Remote "Menu/Back"
    }
}
