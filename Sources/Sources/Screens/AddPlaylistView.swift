import SwiftUI

enum InputMode { case m3u, xtream }

/// Premium onboarding: brand hero + M3U / Xtream Codes entry.
struct AddPlaylistView: View {
    @EnvironmentObject var playlist: PlaylistStore
    @State private var mode: InputMode = .m3u

    // M3U
    @State private var url: String = ""
    // Xtream
    @State private var server: String = ""
    @State private var username: String = ""
    @State private var password: String = ""

    var body: some View {
        ZStack {
            Brand.backgroundGradient.ignoresSafeArea()
            RadialGradient(colors: [Brand.gold.opacity(0.12), .clear],
                           center: .topLeading, startRadius: 40, endRadius: 700)
                .ignoresSafeArea()

            HStack(spacing: 72) {
                brandPanel.frame(maxWidth: 520)
                entryCard.frame(maxWidth: 680)
            }
            .padding(.horizontal, 80)
        }
    }

    // MARK: Left brand panel
    private var brandPanel: some View {
        VStack(alignment: .leading, spacing: 32) {
            HStack(spacing: 20) {
                Image("AppLogo")
                    .resizable().scaledToFit()
                    .frame(width: 110, height: 110)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .shadow(color: Brand.gold.opacity(0.3), radius: 18, y: 6)
                VStack(alignment: .leading, spacing: 4) {
                    Text("StreamVault")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(Brand.textPrimary)
                    Text("ULTRA PREMIUM IPTV")
                        .font(.system(size: 15, weight: .semibold))
                        .tracking(6).foregroundStyle(Brand.gold)
                }
            }
            VStack(alignment: .leading, spacing: 20) {
                FeatureRow(icon: "tv", title: "Canlı TV", subtitle: "Binlerce kanal, anlık erişim")
                FeatureRow(icon: "film", title: "Filmler", subtitle: "Geniş arşiv, kategori ve sıralama")
                FeatureRow(icon: "rectangle.stack", title: "Diziler", subtitle: "Sezon ve bölüm desteğiyle")
            }
        }
    }

    // MARK: Right entry card
    private var entryCard: some View {
        VStack(alignment: .leading, spacing: 22) {
            Text("Başlamak için listeni ekle")
                .font(.system(size: 30, weight: .semibold))
                .foregroundStyle(Brand.textPrimary)

            ModeToggle(mode: $mode)

            if mode == .m3u {
                Text("M3U adresini gir; StreamVault içeriğini senin için düzenlesin.")
                    .font(.title3).foregroundStyle(Brand.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                TextField("https://ornek.com/playlist.m3u", text: $url)
                    .textContentType(.URL)
            } else {
                Text("Xtream Codes bilgilerini gir; bağlantını otomatik kuralım.")
                    .font(.title3).foregroundStyle(Brand.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                TextField("Sunucu (ör. http://sunucu.com:8080)", text: $server)
                    .textContentType(.URL)
                TextField("Kullanıcı adı", text: $username)
                    .textContentType(.username)
                SecureField("Şifre", text: $password)
                    .textContentType(.password)
            }

            if let error = playlist.errorMessage {
                Label(error, systemImage: "exclamationmark.triangle.fill")
                    .font(.callout).foregroundStyle(.red)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Button {
                Task { await submit() }
            } label: {
                HStack(spacing: 12) {
                    if playlist.isLoading { ProgressView().tint(Brand.navyBottom) }
                    else { Image(systemName: "arrow.right.circle.fill") }
                    Text(playlist.isLoading ? "Yükleniyor…" : "Bağlan ve Yükle")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
            }
            .disabled(!canSubmit || playlist.isLoading)
            .padding(.top, 4)
        }
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.white.opacity(0.05))
                .overlay(RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(Brand.gold.opacity(0.25), lineWidth: 1))
        )
    }

    private var canSubmit: Bool {
        switch mode {
        case .m3u:    return !url.trimmingCharacters(in: .whitespaces).isEmpty
        case .xtream: return ![server, username, password].contains {
            $0.trimmingCharacters(in: .whitespaces).isEmpty }
        }
    }

    private func submit() async {
        switch mode {
        case .m3u:
            await playlist.load(urlString: url)
        case .xtream:
            if let built = Self.xtreamM3UURL(server: server, user: username, pass: password) {
                await playlist.load(urlString: built)
            } else {
                playlist.errorMessage = "Sunucu adresi geçersiz."
            }
        }
    }

    /// Builds an Xtream Codes m3u_plus URL the existing M3U parser can consume.
    static func xtreamM3UURL(server: String, user: String, pass: String) -> String? {
        var s = server.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !s.isEmpty else { return nil }
        if !s.lowercased().hasPrefix("http") { s = "http://" + s }
        while s.hasSuffix("/") { s.removeLast() }
        let q = CharacterSet.urlQueryAllowed
        let u = user.addingPercentEncoding(withAllowedCharacters: q) ?? user
        let p = pass.addingPercentEncoding(withAllowedCharacters: q) ?? pass
        return "\(s)/get.php?username=\(u)&password=\(p)&type=m3u_plus&output=ts"
    }
}

private struct ModeToggle: View {
    @Binding var mode: InputMode
    var body: some View {
        HStack(spacing: 12) {
            toggleButton("M3U", .m3u)
            toggleButton("Xtream Codes", .xtream)
        }
    }
    private func toggleButton(_ title: String, _ value: InputMode) -> some View {
        Button { mode = value } label: {
            HStack(spacing: 8) {
                if mode == value { Image(systemName: "checkmark.circle.fill") }
                Text(title)
            }
            .font(.headline)
            .foregroundStyle(mode == value ? Brand.gold : Brand.textSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
        }
        .buttonStyle(.card)
    }
}

private struct FeatureRow: View {
    let icon: String; let title: String; let subtitle: String
    var body: some View {
        HStack(spacing: 18) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Brand.gold.opacity(0.15)).frame(width: 66, height: 66)
                Image(systemName: icon).font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(Brand.gold)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.title3.weight(.semibold)).foregroundStyle(Brand.textPrimary)
                Text(subtitle).font(.callout).foregroundStyle(Brand.textSecondary)
            }
        }
    }
}
