import SwiftUI

/// Premium onboarding: brand hero + feature highlights + refined M3U entry.
struct AddPlaylistView: View {
    @EnvironmentObject var playlist: PlaylistStore
    @State private var url: String = ""
    @FocusState private var fieldFocused: Bool

    var body: some View {
        ZStack {
            Brand.backgroundGradient.ignoresSafeArea()
            RadialGradient(colors: [Brand.gold.opacity(0.12), .clear],
                           center: .topLeading, startRadius: 40, endRadius: 700)
                .ignoresSafeArea()

            HStack(spacing: 80) {
                // Left: brand + value props
                VStack(alignment: .leading, spacing: 34) {
                    HStack(spacing: 20) {
                        Image("AppLogo")
                            .resizable().scaledToFit()
                            .frame(width: 120, height: 120)
                            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                            .shadow(color: Brand.gold.opacity(0.3), radius: 20, y: 6)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("StreamVault")
                                .font(.system(size: 52, weight: .bold, design: .rounded))
                                .foregroundStyle(Brand.textPrimary)
                            Text("ULTRA PREMIUM IPTV")
                                .font(.system(size: 16, weight: .semibold))
                                .tracking(6)
                                .foregroundStyle(Brand.gold)
                        }
                    }

                    VStack(alignment: .leading, spacing: 22) {
                        FeatureRow(icon: "tv", title: "Canlı TV",
                                   subtitle: "Binlerce kanal, anlık erişim")
                        FeatureRow(icon: "film", title: "Filmler",
                                   subtitle: "Geniş arşiv, kategori ve sıralama")
                        FeatureRow(icon: "rectangle.stack", title: "Diziler",
                                   subtitle: "Sezon ve bölüm desteğiyle")
                    }
                }
                .frame(maxWidth: 560)

                // Right: refined M3U entry card
                VStack(alignment: .leading, spacing: 24) {
                    Text("Başlamak için listeni ekle")
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundStyle(Brand.textPrimary)
                    Text("Sahip olduğun M3U adresini gir; StreamVault içeriğini senin için düzenlesin.")
                        .font(.title3)
                        .foregroundStyle(Brand.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    TextField("https://ornek.com/playlist.m3u", text: $url)
                        .textContentType(.URL)
                        .focused($fieldFocused)
                        .padding(.vertical, 6)

                    if let error = playlist.errorMessage {
                        Label(error, systemImage: "exclamationmark.triangle.fill")
                            .font(.callout)
                            .foregroundStyle(.red)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Button {
                        Task { await playlist.load(urlString: url) }
                    } label: {
                        HStack(spacing: 12) {
                            if playlist.isLoading {
                                ProgressView().tint(Brand.navyBottom)
                            } else {
                                Image(systemName: "arrow.right.circle.fill")
                            }
                            Text(playlist.isLoading ? "Yükleniyor…" : "Listeyi Yükle")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .disabled(url.isEmpty || playlist.isLoading)
                    .padding(.top, 6)
                }
                .frame(maxWidth: 620)
                .padding(44)
                .background(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .stroke(Brand.gold.opacity(0.25), lineWidth: 1)
                        )
                )
            }
            .padding(.horizontal, 90)
        }
    }
}

private struct FeatureRow: View {
    let icon: String
    let title: String
    let subtitle: String
    var body: some View {
        HStack(spacing: 20) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Brand.gold.opacity(0.15))
                    .frame(width: 72, height: 72)
                Image(systemName: icon)
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundStyle(Brand.gold)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Brand.textPrimary)
                Text(subtitle)
                    .font(.callout)
                    .foregroundStyle(Brand.textSecondary)
            }
        }
    }
}
