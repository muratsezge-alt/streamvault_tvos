import SwiftUI
import VLCKitSPM

struct PlayerItem: Identifiable {
    let id = UUID()
    let title: String
    let url: String
}

/// VLC-backed player: plays .ts, .mkv, .avi, HLS, MP4 — everything IPTV throws at it.
final class VLCPlayerModel: NSObject, ObservableObject {
    let player = VLCMediaPlayer()
    @Published var failed = false
    @Published var buffering = true
    @Published var isPlaying = false
    @Published var isLive = true
    @Published var progress: Double = 0
    @Published var elapsed = "00:00"
    @Published var remaining = ""
    private var monitor: Timer?

    func attach(to view: UIView) { player.drawable = view }

    func play(urlString: String) {
        guard let url = URL(string: urlString) else { failed = true; buffering = false; return }
        let media = VLCMedia(url: url)
        media.addOption(":network-caching=1500")
        player.media = media
        player.play()
        startMonitoring()
    }

    func togglePlayPause() {
        if player.isPlaying { player.pause() } else { player.play() }
    }

    func seek(_ seconds: Int32) {
        guard !isLive else { return }
        if seconds >= 0 { player.jumpForward(seconds) } else { player.jumpBackward(-seconds) }
    }

    private func startMonitoring() {
        monitor?.invalidate()
        var elapsedSec = 0.0
        monitor = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self else { return }
            elapsedSec += 0.5
            self.isPlaying = self.player.isPlaying
            if self.player.isPlaying { self.buffering = false; self.failed = false }
            else if self.player.state == .error { self.failed = true; self.buffering = false }
            else if elapsedSec > 20 && !self.player.isPlaying { self.failed = true; self.buffering = false }

            let lengthMs = Int(self.player.media?.length.intValue ?? 0)
            if lengthMs > 1000 {
                self.isLive = false
                let timeMs = Int(self.player.time.intValue)
                self.progress = min(1, max(0, Double(timeMs) / Double(lengthMs)))
                self.elapsed = Self.fmt(timeMs)
                self.remaining = "-" + Self.fmt(max(0, lengthMs - timeMs))
            } else {
                self.isLive = true
            }
        }
    }

    func stop() { monitor?.invalidate(); monitor = nil; player.stop() }

    private static func fmt(_ ms: Int) -> String {
        let s = ms / 1000
        let h = s / 3600, m = (s % 3600) / 60, sec = s % 60
        return h > 0 ? String(format: "%d:%02d:%02d", h, m, sec) : String(format: "%02d:%02d", m, sec)
    }
}

private struct VLCVideoView: UIViewRepresentable {
    @ObservedObject var model: VLCPlayerModel
    func makeUIView(context: Context) -> UIView {
        let v = UIView(); v.backgroundColor = .black
        model.attach(to: v); return v
    }
    func updateUIView(_ uiView: UIView, context: Context) {}
}

struct PlayerView: View {
    let item: PlayerItem
    @Environment(\.dismiss) private var dismiss
    @StateObject private var model = VLCPlayerModel()
    @State private var showControls = true
    @State private var hideTask: DispatchWorkItem?

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
                    Image(systemName: "exclamationmark.triangle").font(.system(size: 60)).foregroundStyle(.yellow)
                    Text("Yayın açılamadı").font(.title2).foregroundStyle(.white)
                    Text("Sunucu yanıt vermiyor ya da bağlantı geçersiz olabilir. Başka bir içerik deneyin.")
                        .font(.callout).foregroundStyle(.gray)
                        .multilineTextAlignment(.center).frame(maxWidth: 700)
                    Button("Kapat") { dismiss() }
                }
            }

            if showControls && !model.failed {
                VStack {
                    Spacer()
                    controlBar
                }
                .transition(.opacity)
            }
        }
        .onAppear { model.play(urlString: item.url); flashControls() }
        .onDisappear { model.stop() }
        .onExitCommand { dismiss() }
        .onPlayPauseCommand { model.togglePlayPause(); flashControls() }
        .onMoveCommand { dir in
            switch dir {
            case .left:  model.seek(-15)
            case .right: model.seek(15)
            default: break
            }
            flashControls()
        }
    }

    private var controlBar: some View {
        VStack(spacing: 16) {
            HStack {
                Text(item.title).font(.title3.bold()).foregroundStyle(.white).lineLimit(1)
                Spacer()
                if model.isLive {
                    Label("CANLI", systemImage: "dot.radiowaves.left.and.right")
                        .font(.headline).foregroundStyle(.red)
                }
            }
            HStack(spacing: 18) {
                Image(systemName: model.isPlaying ? "pause.fill" : "play.fill")
                    .font(.title2).foregroundStyle(.white)
                if !model.isLive {
                    Text(model.elapsed).font(.caption).foregroundStyle(.white).monospacedDigit()
                    ProgressView(value: model.progress).tint(.white)
                    Text(model.remaining).font(.caption).foregroundStyle(.white).monospacedDigit()
                } else {
                    Text("Oynat/Duraklat için uzaktan kumanda ▶︎❙❙ tuşu")
                        .font(.caption).foregroundStyle(.white.opacity(0.6))
                    Spacer()
                }
            }
        }
        .padding(40)
        .background(LinearGradient(colors: [.clear, .black.opacity(0.85)],
                                   startPoint: .top, endPoint: .bottom))
    }

    private func flashControls() {
        withAnimation { showControls = true }
        hideTask?.cancel()
        let task = DispatchWorkItem {
            if model.isPlaying { withAnimation { showControls = false } }
        }
        hideTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.5, execute: task)
    }
}
